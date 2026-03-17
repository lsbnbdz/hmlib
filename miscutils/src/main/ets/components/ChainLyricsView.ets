/**
 * 链式歌词组件
 * 支持链式动画、弹簧动画、手动拖拽、惯性滑动
 */
import { curves } from '@kit.ArkUI';
import {
  LyricLine,
  ChainLyricsConfig,
  SpringAnimationParams,
  DEFAULT_CONFIG,
  getDefaultSpringParams,
  getDefaultConfigValues,
  LyricTheme,
  DEFAULT_THEME,
  LyricEventCallbacks
} from '../types';
import { LyricItem } from './LyricItem';

@Component
export struct ChainLyricsView {
  // ==================== 输入属性 ====================
  /** 歌词数据 */
  @Prop @Watch('onLyricsChange') lyrics: LyricLine[] = []
  /** 当前高亮索引（外部控制） */
  @Prop @Watch('onCurrentIndexChange') currentIndex: number = 0
  /** 是否显示翻译 */
  @Prop @Watch('onShowTranslationChange') showTranslation: boolean = false
  /** 是否显示模糊遮罩（默认显示） */
  @Prop showBlurMask: boolean = true
  /** 组件配置 */
  @Prop @Watch('onConfigChange') config: ChainLyricsConfig = DEFAULT_CONFIG
  /** 主题配置 */
  @Prop @Watch('onThemeChange') theme: LyricTheme = DEFAULT_THEME
  /** 事件回调 */
  @Prop eventCallbacks: LyricEventCallbacks = {}
  /** 容器高度（外部传入，避免动态测量导致的问题） */
  @Prop containerHeight: number = 0
  /** 重置信号（外部改变此值时触发重置到当前行） */
  @Prop @Watch('onResetSignalChange') resetSignal: number = 0

  // ==================== 内部状态 ====================
  /** 手动滑动偏移 */
  @State private manualOffset: number = 0
  /** 是否手动滑动中 */
  @State private isManualScroll: boolean = false
  /** 是否自动滚动中 */
  @State private isAutoScroll: boolean = false
  /** 显示用的高亮索引（用于延迟更新） */
  @State private displayLyricsIndex: number = 0
  /** 上一次的歌词索引 */
  @State private prevLyricsIndex: number = -1
  /** 上一次的高亮行索引（用于判断 scale 变化导致的高度变化） */
  private prevHighlightIndex: number = -1

  /** 每行的实际高度 */
  @State private itemHeights: number[] = []
  /** 每行的 Y 位置（独立控制） */
  @State private itemYPositions: number[] = []
  /** 每行额外的偏移（链式动画拖拽效果） */
  @State private itemExtraOffset: number[] = []

  /** 弹簧动画参数 */
  @State private springParams: SpringAnimationParams = DEFAULT_CONFIG.springParams!

  // ==================== 私有变量 ====================
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
  /** 是否已完成初始化（用于避免初始化时的 watch 回调干扰） */
  private isInitialized: boolean = false
  /** 是否有待处理的位置更新（动画期间收到样式/配置变化时标记） */
  private hasPendingUpdate: boolean = false

  // ==================== 生命周期 ====================
  aboutToAppear() {
    this.displayLyricsIndex = this.currentIndex
    // 合并弹簧参数（使用默认值函数）
    const customParams = this.config.springParams
    const defaultSpring = getDefaultSpringParams()
    this.springParams = {
      velocity: customParams?.velocity ?? defaultSpring.velocity,
      mass: customParams?.mass ?? defaultSpring.mass,
      stiffness: customParams?.stiffness ?? defaultSpring.stiffness,
      damping: customParams?.damping ?? defaultSpring.damping,
      lineSpacing: customParams?.lineSpacing ?? defaultSpring.lineSpacing,
      highlightLineSpacing: customParams?.highlightLineSpacing ?? defaultSpring.highlightLineSpacing,
      dragDelay: customParams?.dragDelay ?? defaultSpring.dragDelay
    }
    if (this.lyrics.length > 0) {
      this.initPositions()
    }
    this.updateCachedAnimationCurve()
    // 标记初始化完成
    this.isInitialized = true
  }

  /** 监听配置变化 */
  private onConfigChange() {
    // 初始化阶段跳过，避免与 aboutToAppear 中的初始化逻辑冲突
    if (!this.isInitialized) {
      return
    }

    // 合并弹簧参数（使用默认值函数）
    const customParams = this.config.springParams
    const defaultSpring = getDefaultSpringParams()
    this.springParams = {
      velocity: customParams?.velocity ?? defaultSpring.velocity,
      mass: customParams?.mass ?? defaultSpring.mass,
      stiffness: customParams?.stiffness ?? defaultSpring.stiffness,
      damping: customParams?.damping ?? defaultSpring.damping,
      lineSpacing: customParams?.lineSpacing ?? defaultSpring.lineSpacing,
      highlightLineSpacing: customParams?.highlightLineSpacing ?? defaultSpring.highlightLineSpacing,
      dragDelay: customParams?.dragDelay ?? defaultSpring.dragDelay
    }
    this.updateCachedAnimationCurve()

    // 手动滑动或自动滚动期间不重新计算位置，标记待处理，等动画结束后再生效
    if (this.isManualScroll || this.isAutoScroll) {
      this.hasPendingUpdate = true
      return
    }

    // 清除可能残留的动画，重置偏移
    this.clearAllAnimations()
    this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
    this.manualOffset = 0
    // 重新计算位置
    if (this.lyrics.length > 0) {
      this.itemYPositions = this.calculateItemYPositions(this.displayLyricsIndex)
    }
  }

  /** 监听主题变化 */
  private onThemeChange() {
    // 初始化阶段跳过，避免与 aboutToAppear 中的初始化逻辑冲突
    if (!this.isInitialized) {
      return
    }

    // 手动滑动或自动滚动期间不重新计算位置，标记待处理，等动画结束后再生效
    if (this.isManualScroll || this.isAutoScroll) {
      this.hasPendingUpdate = true
      return
    }

    // 清除可能残留的动画，重置偏移
    this.clearAllAnimations()
    this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
    this.manualOffset = 0
    // 重新计算位置
    if (this.lyrics.length > 0) {
      this.itemYPositions = this.calculateItemYPositions(this.displayLyricsIndex)
    }
  }

  /** 监听歌词数据变化 */
  private onLyricsChange() {
    if (this.lyrics.length > 0) {
      // 重置所有状态
      this.displayLyricsIndex = this.currentIndex
      this.isManualScroll = false
      this.isAutoScroll = false
      this.manualOffset = 0
      this.prevLyricsIndex = -1
      this.prevHighlightIndex = -1
      this.clearAllAnimations()
      this.clearInertiaAnimation()
      this.initPositions()
    }
  }

  /** 监听翻译显示变化 */
  private onShowTranslationChange() {
    // 切换翻译显示时，需要重新计算高度和位置
    if (this.lyrics.length > 0) {
      // 清除手动滚动状态
      this.isManualScroll = false
      if (this.manualScrollTimeoutId !== -1) {
        clearTimeout(this.manualScrollTimeoutId)
        this.manualScrollTimeoutId = -1
      }
      // 清除偏移
      this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
      this.manualOffset = 0
      // 重新初始化高度和位置
      this.initPositions()
    }
  }

  /** 监听重置信号变化 */
  private onResetSignalChange() {
    // 外部触发重置时，立即恢复到当前行
    if (this.resetSignal > 0) {
      this.resetToCurrentIndex()
    }
  }

  aboutToDisappear() {
    this.clearAllAnimations()
    this.clearInertiaAnimation()
  }

  // ==================== 公共方法 ====================
  /** 刷新歌词位置（外部调用） */
  refreshPositions() {
    this.initPositions()
  }

  /** 重置到当前高亮位置 */
  resetToCurrentIndex() {
    this.clearAllAnimations()
    this.clearInertiaAnimation()
    this.isManualScroll = false
    this.displayLyricsIndex = this.currentIndex
    this.updatePositionsForIndex(this.currentIndex)
  }

  // ==================== 内部方法 ====================
  /** 获取高亮位置比例 */
  private getHighlightPositionRatio(): number {
    return this.config.highlightPositionRatio ?? getDefaultConfigValues().highlightPositionRatio as number
  }

  /** 获取链式动画拖拽偏移量 */
  private getDragOffset(): number {
    return this.config.dragOffset ?? getDefaultConfigValues().dragOffset as number
  }

  /** 获取链式动画范围 */
  private getChainAnimationRange(): number {
    return this.config.chainAnimationRange ?? getDefaultConfigValues().chainAnimationRange as number
  }

  /** 获取拖拽持续时间 */
  private getDragHoldDuration(): number {
    return this.config.dragHoldDuration ?? getDefaultConfigValues().dragHoldDuration as number
  }

  /** 获取手动滚动恢复时间 */
  private getManualScrollRecoveryTime(): number {
    return this.config.manualScrollRecoveryTime ?? getDefaultConfigValues().manualScrollRecoveryTime as number
  }

  /** 获取默认行高 */
  private getDefaultLineHeight(): number {
    return this.config.defaultLineHeight ?? getDefaultConfigValues().defaultLineHeight as number
  }

  /** 获取带翻译的行高 */
  private getLineHeightWithTranslation(): number {
    return this.config.lineHeightWithTranslation ?? getDefaultConfigValues().lineHeightWithTranslation as number
  }

  /** 获取高亮位置 Y 坐标 */
  private getTargetY(): number {
    // 优先使用外部传入的 containerHeight，否则使用内部测量的高度
    const height = this.containerHeight > 0 ? this.containerHeight : this.measuredContainerHeight
    if (height <= 0) {
      return 0
    }
    return height * this.getHighlightPositionRatio()
  }

  /** 获取动画曲线 */
  private getAnimationCurve(): ICurve {
    if (!this.cachedAnimationCurve) {
      this.updateCachedAnimationCurve()
    }
    return this.cachedAnimationCurve!
  }

  /** 更新缓存的动画曲线 */
  private updateCachedAnimationCurve() {
    const defaultSpring = getDefaultSpringParams()
    this.cachedAnimationCurve = curves.springCurve(
      this.springParams.velocity ?? defaultSpring.velocity,
      this.springParams.mass ?? defaultSpring.mass,
      this.springParams.stiffness ?? defaultSpring.stiffness,
      this.springParams.damping ?? defaultSpring.damping
    )
  }

  /** 计算某行的中心 Y 位置（考虑高亮行的额外间距） */
  private getItemCenterY(index: number, highlightIndex: number): number {
    const defaultSpring = getDefaultSpringParams()
    const lineSpacing = this.springParams.lineSpacing ?? defaultSpring.lineSpacing as number
    const highlightLineSpacing = this.springParams.highlightLineSpacing ?? defaultSpring.highlightLineSpacing as number
    let y = 0
    for (let i = 0; i < index; i++) {
      y += (this.itemHeights[i] ?? this.getDefaultLineHeight()) + lineSpacing
      // 如果下一行是高亮行，添加额外间距（高亮行上方的间距）
      if (i + 1 === highlightIndex) {
        y += highlightLineSpacing
      }
      // 如果当前行是高亮行，添加额外间距（高亮行下方的间距）
      if (i === highlightIndex) {
        y += highlightLineSpacing
      }
    }
    const currentHeight = this.itemHeights[index] ?? this.getDefaultLineHeight()
    return y + currentHeight / 2
  }

  /** 获取某行显示位置的 Y 坐标 */
  private getItemDisplayY(index: number): number {
    const centerY = (this.itemYPositions[index] ?? 0) + this.manualOffset + (this.itemExtraOffset[index] ?? 0)
    const height = this.itemHeights[index] ?? this.getDefaultLineHeight()
    return centerY - height / 2
  }

  /** 计算目标行居中时每行的位置 */
  private calculateItemYPositions(targetIndex: number): number[] {
    const positions: number[] = []
    const highlightCenterY = this.getItemCenterY(targetIndex, targetIndex)

    for (let i = 0; i < this.lyrics.length; i++) {
      const itemCenterY = this.getItemCenterY(i, targetIndex)
      positions[i] = this.getTargetY() + (itemCenterY - highlightCenterY)
    }
    return positions
  }

  /** 获取限位后的手动偏移 */
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

  /** 初始化位置 */
  private initPositions(): void {
    if (this.lyrics.length === 0) return

    this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
    this.itemYPositions = new Array(this.lyrics.length).fill(0)

    // 估算高度
    this.itemHeights = this.lyrics.map((item: LyricLine): number => {
      const hasContent = this.showTranslation &&
        ((item.translation && item.translation.trim().length > 0) ||
          (item.transliteration && item.transliteration.length > 0))
      return hasContent ? this.getLineHeightWithTranslation() : this.getDefaultLineHeight()
    })

    this.itemYPositions = this.calculateItemYPositions(this.displayLyricsIndex)
    this.manualOffset = 0
  }

  /** 更新单行高度 */
  private updateItemHeight(index: number, height: number) {
    if (index < 0 || index >= this.lyrics.length) return
    if (this.isManualScroll) return

    const oldHeight = this.itemHeights[index] ?? 0
    if (Math.abs(oldHeight - height) > 0.5) {
      this.itemHeights = this.itemHeights.map((h, i) => i === index ? height : h)
      // 高亮状态变化导致的高度变化（scale 变化），不影响其他行位置，跳过重新计算
      if (index === this.displayLyricsIndex || index === this.prevHighlightIndex) {
        return
      }
      this.itemYPositions = this.calculateItemYPositions(this.displayLyricsIndex)
    }
  }

  /** 清除所有动画 */
  private clearAllAnimations() {
    this.animationTimeouts.forEach(id => clearTimeout(id))
    this.animationTimeouts = []
  }

  /** 清除惯性动画 */
  private clearInertiaAnimation() {
    if (this.inertiaTimeoutId !== -1) {
      clearTimeout(this.inertiaTimeoutId)
      this.inertiaTimeoutId = -1
    }
  }

  /** 监听外部索引变化 */
  private onCurrentIndexChange() {
    if (this.currentIndex !== -1 && !this.isManualScroll) {
      // 记录之前的高亮行（用于判断 scale 变化导致的高度变化）
      this.prevHighlightIndex = this.displayLyricsIndex

      // 判断是否使用链式动画：只有自动切换到下一行时才使用动画
      const isNextLine = this.currentIndex === this.displayLyricsIndex + 1
      // 判断当前高亮行持续时间是否足够长（太短就不用动画，避免连续快速滚动导致间距变大）
      const minDuration = 1000 // 最小持续时间阈值(ms)
      const currentLineDuration = this.getLyricLineDuration(this.displayLyricsIndex)
      const shouldUseAnimation = isNextLine && currentLineDuration >= minDuration

      if (shouldUseAnimation) {
        this.triggerChainAnimation(this.currentIndex)
      } else {
        this.displayLyricsIndex = this.currentIndex
        this.updatePositionsForIndex(this.currentIndex)
      }
    }
    // 注意：prevLyricsIndex 在 if 外部更新，保持与原实现一致
    this.prevLyricsIndex = this.currentIndex
  }

  /** 获取某行歌词的持续时间（到下一行的时间差） */
  private getLyricLineDuration(index: number): number {
    if (index < 0 || index >= this.lyrics.length - 1) {
      // 最后一行或无效索引，返回足够长的时间
      return 10000
    }
    const currentLine = this.lyrics[index]
    const nextLine = this.lyrics[index + 1]
    return nextLine.time - currentLine.time
  }

  /** 直接更新位置（无链式动画） */
  private updatePositionsForIndex(targetIndex: number) {
    if (targetIndex < 0) return

    // 先清除可能正在运行的链式动画
    this.clearAllAnimations()

    // 重置额外偏移和手动偏移（确保无链式拖拽效果）
    this.itemExtraOffset = new Array(this.lyrics.length).fill(0)
    this.manualOffset = 0

    // 更新高亮索引
    this.displayLyricsIndex = targetIndex

    // 计算新的位置并更新（会有整体平滑移动动画）
    this.itemYPositions = this.calculateItemYPositions(targetIndex)
  }

  /** 触发链式动画 */
  private triggerChainAnimation(currentIndex: number) {
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

    // 范围外的行立即设置位置
    for (let i = 0; i < this.lyrics.length; i++) {
      if (i < minAnimIndex || i > maxAnimIndex) {
        this.itemYPositions[i] = targetPositions[i]
      }
    }

    this.itemExtraOffset = new Array(this.lyrics.length).fill(0)

    const totalItems = maxAnimIndex - minAnimIndex + 1
    let completedCount = 0
    const dragHoldDuration = this.getDragHoldDuration()

    const defaultSpring = getDefaultSpringParams()
    for (let i = minAnimIndex; i <= maxAnimIndex; i++) {
      const delay = (i - minAnimIndex) * (this.springParams.dragDelay ?? defaultSpring.dragDelay as number)
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
            // 检查是否有待处理的位置更新
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

  /** 设置单行 Y 位置 */
  private setItemYPosition(index: number, y: number) {
    if (this.isManualScroll) return
    this.itemYPositions = this.itemYPositions.map((item, i) => i === index ? y : item)
  }

  /** 设置单行额外偏移 */
  private setItemExtraOffset(index: number, offset: number) {
    if (this.isManualScroll) return
    this.itemExtraOffset = this.itemExtraOffset.map((item, i) => i === index ? offset : item)
  }

  /** 更新高亮索引（二分查找） */
  private updateHighlightFromPosition() {
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
      if (this.eventCallbacks.onHighlightChange) {
        this.eventCallbacks.onHighlightChange(left)
      }
    }
  }

  /** 惯性滑动动画 */
  private startInertiaScroll(initialVelocity: number) {
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

  /** 开始手动滚动恢复定时器 */
  private startManualScrollTimer() {
    if (this.manualScrollTimeoutId !== -1) {
      clearTimeout(this.manualScrollTimeoutId)
    }

    this.isManualScroll = true
    if (this.eventCallbacks.onManualScrollStart) {
      this.eventCallbacks.onManualScrollStart()
    }

    const recoveryTime = this.getManualScrollRecoveryTime()
    this.manualScrollTimeoutId = setTimeout(() => {
      this.isManualScroll = false
      this.manualScrollTimeoutId = -1
      if (this.eventCallbacks.onManualScrollEnd) {
        this.eventCallbacks.onManualScrollEnd()
      }
      this.displayLyricsIndex = this.currentIndex
      // 直接更新位置（无动画）
      this.updatePositionsForIndex(this.currentIndex)
    }, recoveryTime) as number
  }

  /** 处理歌词行点击 */
  private handleLineClick(time: number, index: number) {
    this.clearAllAnimations()
    this.clearInertiaAnimation()
    this.isManualScroll = false
    this.isAutoScroll = false

    this.prevLyricsIndex = this.displayLyricsIndex
    this.displayLyricsIndex = index
    this.updatePositionsForIndex(index)

    if (this.eventCallbacks.onLineClick) {
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
              LyricItem({
                item: item,
                index: index,
                showTranslation: this.showTranslation,
                currentLyricsIndex: this.displayLyricsIndex,
                theme: this.theme
              })
            }
            .width('100%')
            .position({ x: 0, y: this.getItemDisplayY(index) })
            .scale({
              x: index === this.displayLyricsIndex ? 1.0 : (this.theme.normalStyle.scale ?? 1.0),
              y: index === this.displayLyricsIndex ? 1.0 : (this.theme.normalStyle.scale ?? 1.0),
              centerX: 0,
              centerY: "50%"
            })
            .animation(this.isManualScroll ? { duration: 0 } : {
              curve: this.getAnimationCurve()
            })
            .onClick(() => {
              // 只有传入了点击回调才允许点击跳转
              if (this.eventCallbacks.onLineClick) {
                this.handleLineClick(item.time, index)
              }
            })
            .onAreaChange((_oldValue: Area, newValue: Area) => {
              const newHeight = newValue.height as number
              this.updateItemHeight(index, newHeight)
            })
          }, (item: LyricLine, index: number) => `${item.time}_${index}`)

          // 模糊遮罩层（手动滑动时不显示，或用户关闭遮罩时不显示）
          if (!this.isManualScroll && this.showBlurMask) {
            // 高亮行高度
            // 上方遮罩结束位置 = targetY - 高亮行高度/2
            // 下方遮罩起始位置 = targetY + 高亮行高度/2
            // 上方渐变模糊遮罩：从顶部到当前行上方
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

            // 下方渐变模糊遮罩：从当前行下方到底部，使用百分比高度
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
      // 只有当外部未传入 containerHeight 时，才使用内部测量值
      if (this.containerHeight <= 0) {
        this.measuredContainerHeight = newValue.height as number
        if (this.lyrics.length > 0 && this.itemYPositions.length === 0) {
          this.initPositions()
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
