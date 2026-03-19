/**
 * 链式歌词组件 V2 版本
 * 支持链式动画、弹簧动画、手动拖拽、惯性滑动
 * 支持逐字歌词效果
 * 使用 @ComponentV2 和 @ObservedV2 状态管理
 */
import { curves } from '@kit.ArkUI';
import {
  LyricLine,
  ChainLyricsConfig,
  SpringAnimationParams,
  DEFAULT_CONFIG_V2,
  LyricTheme,
  DEFAULT_THEME_V2,
  LyricEventCallbacks,
  createDefaultConfig
} from '../types/indexV2';
import { LyricItemV2 } from './LyricItemV2';

/** 逐字计时器间隔（毫秒） */
const WORD_TIMER_INTERVAL = 8;

@ComponentV2
export struct ChainLyricsViewV2 {
  // ==================== 输入属性 ====================
  /** 歌词数据 */
  @Param lyrics: LyricLine[] = []
  /** 当前高亮索引（外部控制） */
  @Param currentIndex: number = 0
  /** 是否显示翻译 */
  @Param showTranslation: boolean = false
  /** 是否显示模糊遮罩（默认显示） */
  @Param showBlurMask: boolean = true
  /** 组件配置 */
  @Param config: ChainLyricsConfig = DEFAULT_CONFIG_V2
  /** 主题配置 */
  @Param theme: LyricTheme = DEFAULT_THEME_V2
  /** 事件回调 */
  @Param eventCallbacks: LyricEventCallbacks = new LyricEventCallbacks()
  /** 容器高度（外部传入，避免动态测量导致的问题） */
  @Param containerHeight: number = 0
  /** 重置信号（外部改变此值时触发重置到当前行） */
  @Param resetSignal: number = 0
  /** 是否正在播放 */
  @Param isPlaying: boolean = false

  // ==================== 内部状态 ====================
  /** 手动滑动偏移 */
  @Local manualOffset: number = 0
  /** 是否手动滑动中 */
  @Local isManualScroll: boolean = false
  /** 是否自动滚动中 */
  @Local isAutoScroll: boolean = false
  /** 显示用的高亮索引（用于延迟更新） */
  @Local displayLyricsIndex: number = 0
  /** 上一次的歌词索引 */
  @Local prevLyricsIndex: number = -1

  /** 每行的实际高度 */
  @Local itemHeights: number[] = []
  /** 每行的 Y 位置（独立控制） */
  @Local itemYPositions: number[] = []
  /** 每行额外的偏移（链式动画拖拽效果） */
  @Local itemExtraOffset: number[] = []

  /** 当前行已播放时长（毫秒） */
  @Local currentLineElapsed: number = 0

  // ==================== 私有变量 ====================
  /** 上一次的高亮行索引（用于判断 scale 变化导致的高度变化） */
  private prevHighlightIndex: number = -1
  /** 动画 timeout 列表 */
  private animationTimeouts: number[] = []
  /** 拖动开始时的偏移 */
  private dragStartOffset: number = 0
  /** 上一次拖动 Y 位置 */
  private lastDragY: number = 0
  /** 拖动速度 */
  private velocityY: number = 0
  /** 惯性动画 timeout ID */
  private inertiaTimeoutId: number = -1
  /** 手动滚动恢复定时器 */
  private manualScrollTimeoutId: number = -1
  /** 缓存的动画曲线 */
  private cachedAnimationCurve: ICurve | null = null
  /** 上次更新高亮时的偏移量 */
  private lastHighlightOffset: number = 0
  /** 内部测量的容器高度（当外部未传入时使用） */
  private measuredContainerHeight: number = 0
  /** 是否已完成初始化（用于避免初始化时的 monitor 回调干扰） */
  private isInitialized: boolean = false
  /** 是否有待处理的位置更新（动画期间收到样式/配置变化时标记） */
  private hasPendingUpdate: boolean = false
  /** 逐字计时器 ID */
  private wordTimerId: number = -1
  /** 上次 tick 时间 */
  private lastTickTime: number = 0

  // ==================== 生命周期 ====================
  aboutToAppear(): void {
    this.displayLyricsIndex = this.currentIndex
    if (this.lyrics.length > 0) {
      this.initPositions()
    }
    this.updateCachedAnimationCurve()
    this.isInitialized = true
  }

  aboutToDisappear(): void {
    this.clearAllAnimations()
    this.clearInertiaAnimation()
    this.stopWordTimer()
  }

  // ==================== Monitor 回调 ====================
  /** 监听配置变化 */
  @Monitor('config')
  onConfigChange(monitor: IMonitor): void {
    if (!this.isInitialized) {
      return
    }

    this.updateCachedAnimationCurve()

    if (this.isManualScroll || this.isAutoScroll) {
      this.hasPendingUpdate = true
      return
    }

    this.clearAllAnimations()
    this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
    this.manualOffset = 0
    if (this.lyrics.length > 0) {
      this.itemYPositions = this.calculateItemYPositions(this.displayLyricsIndex)
    }
  }

  /** 监听主题变化 */
  @Monitor('theme')
  onThemeChange(monitor: IMonitor): void {
    if (!this.isInitialized) {
      return
    }

    if (this.isManualScroll || this.isAutoScroll) {
      this.hasPendingUpdate = true
      return
    }

    this.clearAllAnimations()
    this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
    this.manualOffset = 0
    if (this.lyrics.length > 0) {
      this.itemYPositions = this.calculateItemYPositions(this.displayLyricsIndex)
    }
  }

  /** 监听歌词数据变化 */
  @Monitor('lyrics')
  onLyricsChange(monitor: IMonitor): void {
    if (this.lyrics.length > 0) {
      this.displayLyricsIndex = this.currentIndex
      this.isManualScroll = false
      this.isAutoScroll = false
      this.manualOffset = 0
      this.prevLyricsIndex = -1
      this.prevHighlightIndex = -1
      this.resetWordProgress()
      this.clearAllAnimations()
      this.clearInertiaAnimation()
      this.initPositions()
    }
  }

  /** 监听翻译显示变化 */
  @Monitor('showTranslation')
  onShowTranslationChange(monitor: IMonitor): void {
    if (this.lyrics.length > 0) {
      this.isManualScroll = false
      if (this.manualScrollTimeoutId !== -1) {
        clearTimeout(this.manualScrollTimeoutId)
        this.manualScrollTimeoutId = -1
      }
      this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
      this.manualOffset = 0
      this.initPositions()
    }
  }

  /** 监听重置信号变化 */
  @Monitor('resetSignal')
  onResetSignalChange(monitor: IMonitor): void {
    if (this.resetSignal > 0) {
      this.resetToCurrentIndex()
    }
  }

  /** 监听当前索引变化 */
  @Monitor('currentIndex')
  onCurrentIndexChange(monitor: IMonitor): void {
    this.resetWordProgress()

    if (this.currentIndex !== -1 && !this.isManualScroll) {
      this.prevHighlightIndex = this.displayLyricsIndex

      const isNextLine = this.currentIndex === this.displayLyricsIndex + 1
      const minDuration = 1000
      const currentLineDuration = this.getLyricLineDuration(this.displayLyricsIndex)
      const shouldUseAnimation = isNextLine && currentLineDuration >= minDuration

      if (shouldUseAnimation) {
        this.triggerChainAnimation(this.currentIndex)
      } else {
        this.displayLyricsIndex = this.currentIndex
        this.updatePositionsForIndex(this.currentIndex)
      }
    }
    this.prevLyricsIndex = this.currentIndex
  }

  /** 监听播放状态变化 */
  @Monitor('isPlaying')
  onPlayStateChange(monitor: IMonitor): void {
    if (this.isPlaying) {
      this.startWordTimer()
    } else {
      this.stopWordTimer()
    }
  }

  // ==================== 逐字计时器 ====================
  private startWordTimer(): void {
    if (this.wordTimerId !== -1) {
      return
    }
    this.lastTickTime = Date.now()
    this.tickWordProgress()
  }

  private tickWordProgress(): void {
    this.doTick()
    this.wordTimerId = setInterval(() => {
      this.doTick()
    }, WORD_TIMER_INTERVAL) as number
  }

  private doTick(): void {
    if (!this.isPlaying) {
      return
    }
    const now = Date.now()
    const delta = now - this.lastTickTime
    this.lastTickTime = now
    this.currentLineElapsed += delta
  }

  private stopWordTimer(): void {
    if (this.wordTimerId !== -1) {
      clearInterval(this.wordTimerId)
      this.wordTimerId = -1
    }
  }

  private resetWordProgress(): void {
    this.currentLineElapsed = 0
    this.lastTickTime = Date.now()
  }

  // ==================== 公共方法 ====================
  refreshPositions(): void {
    this.initPositions()
  }

  resetToCurrentIndex(): void {
    this.clearAllAnimations()
    this.clearInertiaAnimation()
    this.isManualScroll = false
    this.displayLyricsIndex = this.currentIndex
    this.resetWordProgress()
    this.updatePositionsForIndex(this.currentIndex)
  }

  // ==================== 内部方法 ====================
  private getHighlightPositionRatio(): number {
    return this.config.highlightPositionRatio
  }

  private getDragOffset(): number {
    return this.config.dragOffset
  }

  private getChainAnimationRange(): number {
    return this.config.chainAnimationRange
  }

  private getDragHoldDuration(): number {
    return this.config.dragHoldDuration
  }

  private getManualScrollRecoveryTime(): number {
    return this.config.manualScrollRecoveryTime
  }

  private getDefaultLineHeight(): number {
    return this.config.defaultLineHeight
  }

  private getLineHeightWithTranslation(): number {
    return this.config.lineHeightWithTranslation
  }

  private getTargetY(): number {
    const height = this.containerHeight > 0 ? this.containerHeight : this.measuredContainerHeight
    if (height <= 0) {
      return 0
    }
    return height * this.getHighlightPositionRatio()
  }

  private getAnimationCurve(): ICurve {
    if (!this.cachedAnimationCurve) {
      this.updateCachedAnimationCurve()
    }
    return this.cachedAnimationCurve!
  }

  private updateCachedAnimationCurve(): void {
    this.cachedAnimationCurve = curves.springCurve(
      this.config.springParams.velocity,
      this.config.springParams.mass,
      this.config.springParams.stiffness,
      this.config.springParams.damping
    )
  }

  private getItemCenterY(index: number, highlightIndex: number): number {
    const lineSpacing = this.config.springParams.lineSpacing
    const highlightLineSpacing = this.config.springParams.highlightLineSpacing
    let y = 0
    for (let i = 0; i < index; i++) {
      y += (this.itemHeights[i] ?? this.getDefaultLineHeight()) + lineSpacing
      if (i + 1 === highlightIndex) {
        y += highlightLineSpacing
      }
      if (i === highlightIndex) {
        y += highlightLineSpacing
      }
    }
    const currentHeight = this.itemHeights[index] ?? this.getDefaultLineHeight()
    return y + currentHeight / 2
  }

  private getItemDisplayY(index: number): number {
    const centerY = (this.itemYPositions[index] ?? 0) + this.manualOffset + (this.itemExtraOffset[index] ?? 0)
    const height = this.itemHeights[index] ?? this.getDefaultLineHeight()
    return centerY - height / 2
  }

  private calculateItemYPositions(targetIndex: number): number[] {
    const positions: number[] = []
    const highlightCenterY = this.getItemCenterY(targetIndex, targetIndex)

    for (let i = 0; i < this.lyrics.length; i++) {
      const itemCenterY = this.getItemCenterY(i, targetIndex)
      positions[i] = this.getTargetY() + (itemCenterY - highlightCenterY)
    }
    return positions
  }

  private getClampedManualOffset(offset: number): number {
    if (this.lyrics.length === 0) return 0

    const firstY = this.itemYPositions[0] ?? 0
    const lastY = this.itemYPositions[this.lyrics.length - 1] ?? 0

    const pullDownLimit = this.getTargetY() - firstY
    const pushUpLimit = this.getTargetY() - lastY

    const lower = Math.min(pullDownLimit, pushUpLimit)
    const upper = Math.max(pullDownLimit, pushUpLimit)

    return Math.max(lower, Math.min(upper, offset))
  }

  private initPositions(): void {
    if (this.lyrics.length === 0) return

    this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
    this.itemYPositions = new Array(this.lyrics.length).fill(0)

    this.itemHeights = this.lyrics.map((item: LyricLine): number => {
      const hasContent = this.showTranslation &&
        ((item.translation !== undefined && item.translation.trim().length > 0) ||
          (item.transliteration !== undefined && item.transliteration.length > 0))
      return hasContent ? this.getLineHeightWithTranslation() : this.getDefaultLineHeight()
    })

    this.itemYPositions = this.calculateItemYPositions(this.displayLyricsIndex)
    this.manualOffset = 0
  }

  private updateItemHeight(index: number, height: number): void {
    if (index < 0 || index >= this.lyrics.length) return
    if (this.isManualScroll) return

    const oldHeight = this.itemHeights[index] ?? 0
    if (Math.abs(oldHeight - height) > 0.5) {
      this.itemHeights = this.itemHeights.map((h, i) => i === index ? height : h)
      if (index === this.displayLyricsIndex || index === this.prevHighlightIndex) {
        return
      }
      this.itemYPositions = this.calculateItemYPositions(this.displayLyricsIndex)
    }
  }

  private clearAllAnimations(): void {
    this.animationTimeouts.forEach(id => clearTimeout(id))
    this.animationTimeouts = []
  }

  private clearInertiaAnimation(): void {
    if (this.inertiaTimeoutId !== -1) {
      clearTimeout(this.inertiaTimeoutId)
      this.inertiaTimeoutId = -1
    }
  }

  private getLyricLineDuration(index: number): number {
    if (index < 0 || index >= this.lyrics.length - 1) {
      return 10000
    }
    const currentLine = this.lyrics[index]
    const nextLine = this.lyrics[index + 1]
    return nextLine.time - currentLine.time
  }

  private updatePositionsForIndex(targetIndex: number): void {
    if (targetIndex < 0) return

    this.clearAllAnimations()
    this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
    this.manualOffset = 0
    this.displayLyricsIndex = targetIndex
    this.itemYPositions = this.calculateItemYPositions(targetIndex)
  }

  private triggerChainAnimation(currentIndex: number): void {
    this.clearAllAnimations()

    if (this.itemYPositions.length !== this.lyrics.length) {
      this.initPositions()
    }

    this.isAutoScroll = true
    this.manualOffset = 0
    const direction = currentIndex > this.prevLyricsIndex ? 1 : -1

    const targetPositions = this.calculateItemYPositions(currentIndex)
    const chainRange = this.getChainAnimationRange()
    const minAnimIndex = Math.max(0, Math.min(this.prevLyricsIndex, currentIndex) - 5)
    const maxAnimIndex = Math.min(this.lyrics.length - 1, Math.max(this.prevLyricsIndex, currentIndex) + chainRange)

    for (let i = 0; i < this.lyrics.length; i++) {
      if (i < minAnimIndex || i > maxAnimIndex) {
        this.itemYPositions[i] = targetPositions[i]
      }
    }

    this.itemExtraOffset = new Array(this.lyrics.length).fill(0)

    const totalItems = maxAnimIndex - minAnimIndex + 1
    let completedCount = 0
    const dragHoldDuration = this.getDragHoldDuration()

    for (let i = minAnimIndex; i <= maxAnimIndex; i++) {
      const delay = (i - minAnimIndex) * this.config.springParams.dragDelay
      const dragOffset = (direction === 1 ? -1 : 1) * this.getDragOffset()

      const timeoutId = setTimeout(() => {
        if (this.isManualScroll) return

        if (i === currentIndex) {
          this.displayLyricsIndex = currentIndex
        }

        this.setItemExtraOffset(i, dragOffset)
        this.setItemYPosition(i, targetPositions[i])

        const reboundTimeoutId = setTimeout(() => {
          if (this.isManualScroll) return
          this.setItemExtraOffset(i, 0)

          completedCount++
          if (completedCount >= totalItems) {
            this.isAutoScroll = false
            if (this.hasPendingUpdate) {
              this.hasPendingUpdate = false
              this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
              this.manualOffset = 0
              this.itemYPositions = this.calculateItemYPositions(this.displayLyricsIndex)
            }
          }
        }, dragHoldDuration) as number

        this.animationTimeouts.push(reboundTimeoutId)
      }, delay) as number

      this.animationTimeouts.push(timeoutId)
    }
  }

  private setItemYPosition(index: number, y: number): void {
    if (this.isManualScroll) return
    this.itemYPositions = this.itemYPositions.map((item, i) => i === index ? y : item)
  }

  private setItemExtraOffset(index: number, offset: number): void {
    if (this.isManualScroll) return
    this.itemExtraOffset = this.itemExtraOffset.map((item, i) => i === index ? offset : item)
  }

  private updateHighlightFromPosition(): void {
    if (Math.abs(this.manualOffset - this.lastHighlightOffset) < this.getDefaultLineHeight() / 2) {
      return
    }
    this.lastHighlightOffset = this.manualOffset

    let left = 0
    let right = this.lyrics.length - 1

    while (left < right) {
      const mid = Math.floor((left + right) / 2)
      const midY = (this.itemYPositions[mid] ?? 0) + this.manualOffset

      if (midY < this.getTargetY()) {
        left = mid + 1
      } else {
        right = mid
      }
    }

    const leftY = (this.itemYPositions[left] ?? 0) + this.manualOffset
    const leftDist = Math.abs(leftY - this.getTargetY())

    if (left > 0) {
      const prevY = (this.itemYPositions[left - 1] ?? 0) + this.manualOffset
      const prevDist = Math.abs(prevY - this.getTargetY())
      if (prevDist < leftDist) {
        left = left - 1
      }
    }

    if (left !== this.displayLyricsIndex) {
      this.displayLyricsIndex = left
      if (this.eventCallbacks.onHighlightChange !== undefined) {
        this.eventCallbacks.onHighlightChange(left)
      }
    }
  }

  private startInertiaScroll(initialVelocity: number): void {
    let velocity = initialVelocity
    const friction = 0.92
    const minVelocity = 0.5

    const step = () => {
      if (Math.abs(velocity) < minVelocity) {
        this.inertiaTimeoutId = -1
        this.startManualScrollTimer()
        return
      }

      const newOffset = this.getClampedManualOffset(this.manualOffset + velocity)

      if (Math.abs(newOffset - this.manualOffset) < 0.1) {
        this.inertiaTimeoutId = -1
        this.startManualScrollTimer()
        return
      }

      this.manualOffset = newOffset
      this.updateHighlightFromPosition()

      velocity *= friction
      this.inertiaTimeoutId = setTimeout(step, 8) as number
    }

    this.inertiaTimeoutId = setTimeout(step, 8) as number
  }

  private startManualScrollTimer(): void {
    if (this.manualScrollTimeoutId !== -1) {
      clearTimeout(this.manualScrollTimeoutId)
    }

    this.isManualScroll = true
    if (this.eventCallbacks.onManualScrollStart !== undefined) {
      this.eventCallbacks.onManualScrollStart()
    }

    const recoveryTime = this.getManualScrollRecoveryTime()
    this.manualScrollTimeoutId = setTimeout(() => {
      this.isManualScroll = false
      this.manualScrollTimeoutId = -1
      if (this.eventCallbacks.onManualScrollEnd !== undefined) {
        this.eventCallbacks.onManualScrollEnd()
      }
      this.displayLyricsIndex = this.currentIndex
      this.resetWordProgress()
      this.updatePositionsForIndex(this.currentIndex)
    }, recoveryTime) as number
  }

  private handleLineClick(time: number, index: number): void {
    this.clearAllAnimations()
    this.clearInertiaAnimation()
    this.isManualScroll = false
    this.isAutoScroll = false

    this.prevLyricsIndex = this.displayLyricsIndex
    this.displayLyricsIndex = index
    this.resetWordProgress()
    this.updatePositionsForIndex(index)

    if (this.eventCallbacks.onLineClick !== undefined) {
      this.eventCallbacks.onLineClick(time, index)
    }
  }

  // ==================== UI 构建 ====================
  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.lyrics.length === 0) {
        Text('暂无歌词')
          .fontSize(18)
          .fontColor('rgba(255, 255, 255, 0.5)')
          .margin(16)
      } else {
        Stack() {
          // 歌词层
          ForEach(this.lyrics, (item: LyricLine, index: number) => {
            Column() {
              LyricItemV2({
                item: item,
                index: index,
                showTranslation: this.showTranslation,
                currentLyricsIndex: this.displayLyricsIndex,
                playingIndex: this.currentIndex,
                theme: this.theme,
                enableWordByWord: this.config.enableWordByWord,
                currentLineElapsed: this.currentLineElapsed
              })
            }
            .width('100%')
            .position({ x: 0, y: this.getItemDisplayY(index) })
            .scale({
              x: index === this.displayLyricsIndex ? 1.0 : this.theme.normalStyle.scale,
              y: index === this.displayLyricsIndex ? 1.0 : this.theme.normalStyle.scale,
              centerX: 0,
              centerY: "50%"
            })
            .animation(this.isManualScroll ? { duration: 0 } : {
              curve: this.getAnimationCurve()
            })
            .onClick(() => {
              if (this.eventCallbacks.onLineClick !== undefined) {
                this.handleLineClick(item.time, index)
              }
            })
            .onAreaChange((_oldValue: Area, newValue: Area) => {
              const newHeight = newValue.height as number
              this.updateItemHeight(index, newHeight)
            })
          }, (item: LyricLine, index: number) => `${item.time}_${index}`)

          // 模糊遮罩层
          if (!this.isManualScroll && this.showBlurMask) {
            // 上方渐变模糊遮罩
            Column()
              .width('100%')
              .height(Math.max(0, this.getTargetY() - (this.itemHeights[this.displayLyricsIndex] ?? this.getDefaultLineHeight()) / 2))
              .position({ x: 0, y: 0 })
              .linearGradientBlur(BlurStyle.COMPONENT_ULTRA_THICK, {
                fractionStops: [
                  [1.0, 0.0],
                  [1.0, 0.7],
                  [0.0, 1.0]
                ],
                direction: GradientDirection.Bottom
              })
              .hitTestBehavior(HitTestMode.None)
              .animation({
                curve: this.getAnimationCurve()
              })

            // 下方渐变模糊遮罩
            Column()
              .width('100%')
              .height('100%')
              .position({ x: 0, y: this.getTargetY() + (this.itemHeights[this.displayLyricsIndex] ?? this.getDefaultLineHeight()) / 2 })
              .linearGradientBlur(BlurStyle.COMPONENT_ULTRA_THICK, {
                fractionStops: [
                  [1.0, 0.0],
                  [1.0, 0.7],
                  [0.0, 1.0]
                ],
                direction: GradientDirection.Top
              })
              .hitTestBehavior(HitTestMode.None)
              .animation({
                curve: this.getAnimationCurve()
              })
          }
        }
        .width('100%')
        .height('100%')
        .clip(true)
      }
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      if (this.containerHeight <= 0) {
        const newHeight = newValue.height as number
        if (newHeight > 0 && newHeight !== this.measuredContainerHeight) {
          this.measuredContainerHeight = newHeight
          if (this.lyrics.length > 0) {
            this.initPositions()
          }
        }
      }
    })
    .gesture(
      PanGesture({ fingers: 1, direction: PanDirection.Vertical, distance: 5 })
        .onActionStart(() => {
          if (this.isAutoScroll) {
            this.clearAllAnimations()
            this.isAutoScroll = false
          }

          const targetCenterY = this.getTargetY()
          const extraOffset = this.itemExtraOffset[0] ?? 0
          const currentDisplayY = (this.itemYPositions[this.displayLyricsIndex] ?? targetCenterY)
          const actualOffset = currentDisplayY - targetCenterY + this.manualOffset + extraOffset

          this.itemYPositions = this.calculateItemYPositions(this.displayLyricsIndex)
          this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
          this.manualOffset = actualOffset

          this.dragStartOffset = this.manualOffset
          this.lastDragY = 0
          this.velocityY = 0
          this.lastHighlightOffset = this.manualOffset

          this.isManualScroll = true
          this.clearInertiaAnimation()
          if (this.manualScrollTimeoutId !== -1) {
            clearTimeout(this.manualScrollTimeoutId)
            this.manualScrollTimeoutId = -1
          }
        })
        .onActionUpdate((event: GestureEvent) => {
          const deltaY = event.offsetY - this.lastDragY
          this.lastDragY = event.offsetY
          this.velocityY = deltaY

          const newOffset = this.getClampedManualOffset(this.dragStartOffset + event.offsetY)
          this.manualOffset = newOffset
          this.updateHighlightFromPosition()
        })
        .onActionEnd(() => {
          if (Math.abs(this.velocityY) > 2) {
            this.startInertiaScroll(this.velocityY * 1.5)
          } else {
            this.startManualScrollTimer()
          }
        })
    )
  }
}