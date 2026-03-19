/**
 * 链式歌词组件 V2 版本类型定义
 * 使用 @ObservedV2 和 @Trace 实现深度观测
 */

/**
 * 逐字数据类
 */
@ObservedV2
export class LyricWord {
  /** 字文本 */
  @Trace word: string
  /** 开始时间（相对于行起始，毫秒） */
  @Trace startTime: number
  /** 结束时间（相对于行起始，毫秒） */
  @Trace endTime: number

  constructor(init?: Partial<LyricWord>) {
    this.word = init?.word ?? ''
    this.startTime = init?.startTime ?? 0
    this.endTime = init?.endTime ?? 0
  }
}

/**
 * 歌词行数据类
 */
@ObservedV2
export class LyricLine {
  /** 歌词文本 */
  @Trace text: string
  /** 时间戳（毫秒） */
  @Trace time: number
  /** 翻译（可选） */
  @Trace translation?: string
  /** 音译（可选） */
  @Trace transliteration?: string
  /** 逐字数据（可选，支持逐字歌词） */
  @Trace words?: LyricWord[]

  constructor(init?: Partial<LyricLine>) {
    this.text = init?.text ?? ''
    this.time = init?.time ?? 0
    this.translation = init?.translation
    this.transliteration = init?.transliteration
    if (init?.words) {
      this.words = init.words.map(w => new LyricWord(w))
    }
  }
}

/**
 * 弹簧动画参数类
 */
@ObservedV2
export class SpringAnimationParams {
  /** 初始速度 */
  @Trace velocity: number
  /** 质量 */
  @Trace mass: number
  /** 刚度 */
  @Trace stiffness: number
  /** 阻尼 */
  @Trace damping: number
  /** 行间距 */
  @Trace lineSpacing: number
  /** 高亮行与非高亮行之间的额外间距 */
  @Trace highlightLineSpacing: number
  /** 链式动画每行延迟（毫秒） */
  @Trace dragDelay: number

  constructor(init?: Partial<SpringAnimationParams>) {
    this.velocity = init?.velocity ?? 0
    this.mass = init?.mass ?? 0.3
    this.stiffness = init?.stiffness ?? 200
    this.damping = init?.damping ?? 15
    this.lineSpacing = init?.lineSpacing ?? 24
    this.highlightLineSpacing = init?.highlightLineSpacing ?? 8
    this.dragDelay = init?.dragDelay ?? 35
  }
}

/**
 * 链式歌词组件配置类
 */
@ObservedV2
export class ChainLyricsConfig {
  /** 弹簧动画参数 */
  @Trace springParams: SpringAnimationParams
  /** 高亮位置比例（0-1，相对于容器高度） */
  @Trace highlightPositionRatio: number
  /** 链式动画拖拽偏移量 */
  @Trace dragOffset: number
  /** 链式动画范围 */
  @Trace chainAnimationRange: number
  /** 拖拽持续时间（毫秒） */
  @Trace dragHoldDuration: number
  /** 手动滚动后自动恢复时间（毫秒） */
  @Trace manualScrollRecoveryTime: number
  /** 默认行高 */
  @Trace defaultLineHeight: number
  /** 带翻译的行高 */
  @Trace lineHeightWithTranslation: number
  /** 是否启用逐字歌词 */
  @Trace enableWordByWord: boolean

  constructor(init?: Partial<ChainLyricsConfig>) {
    this.springParams = new SpringAnimationParams(init?.springParams)
    this.highlightPositionRatio = init?.highlightPositionRatio ?? 0.25
    this.dragOffset = init?.dragOffset ?? 0
    this.chainAnimationRange = init?.chainAnimationRange ?? 20
    this.dragHoldDuration = init?.dragHoldDuration ?? 35
    this.manualScrollRecoveryTime = init?.manualScrollRecoveryTime ?? 7000
    this.defaultLineHeight = init?.defaultLineHeight ?? 12
    this.lineHeightWithTranslation = init?.lineHeightWithTranslation ?? 80
    this.enableWordByWord = init?.enableWordByWord ?? false
  }
}

/**
 * 歌词行样式配置类
 */
@ObservedV2
export class LyricItemStyle {
  /** 字体大小 */
  @Trace fontSize: number
  /** 字体粗细 */
  @Trace fontWeight: FontWeight
  /** 字体颜色 */
  @Trace fontColor: ResourceColor
  /** 文字阴影 */
  @Trace textShadow?: ShadowOptions
  /** 透明度 */
  @Trace opacity: number
  /** 缩放比例 */
  @Trace scale: number

  constructor(init?: Partial<LyricItemStyle>) {
    this.fontSize = init?.fontSize ?? 18
    this.fontWeight = init?.fontWeight ?? FontWeight.Medium
    this.fontColor = init?.fontColor ?? Color.White
    this.textShadow = init?.textShadow
    this.opacity = init?.opacity ?? 1
    this.scale = init?.scale ?? 1
  }
}

/**
 * 歌词主题配置类
 */
@ObservedV2
export class LyricTheme {
  /** 普通行样式 */
  @Trace normalStyle: LyricItemStyle
  /** 高亮行样式 */
  @Trace highlightStyle: LyricItemStyle
  /** 翻译字体大小 */
  @Trace translationFontSize: number
  /** 罗马音字体大小 */
  @Trace transliterationFontSize: number
  /** 已唱部分的字体颜色（逐字模式） */
  @Trace sungFontColor: ResourceColor

  constructor(init?: Partial<LyricTheme>) {
    this.normalStyle = new LyricItemStyle(init?.normalStyle)
    this.highlightStyle = new LyricItemStyle(init?.highlightStyle)
    this.translationFontSize = init?.translationFontSize ?? 16
    this.transliterationFontSize = init?.transliterationFontSize ?? 12
    this.sungFontColor = init?.sungFontColor ?? '#FFD700'
  }
}

/**
 * 歌词组件事件回调接口（使用类实现以支持可选方法）
 */
export class LyricEventCallbacks {
  /** 歌词行点击回调 */
  onLineClick?: (time: number, index: number) => void
  /** 高亮索引变化回调 */
  onHighlightChange?: (index: number) => void
  /** 手动滚动开始回调 */
  onManualScrollStart?: () => void
  /** 手动滚动结束回调 */
  onManualScrollEnd?: () => void
}

/**
 * 创建默认配置
 */
export function createDefaultConfig(): ChainLyricsConfig {
  const config = new ChainLyricsConfig()
  config.springParams = new SpringAnimationParams()
  config.highlightPositionRatio = 0.25
  config.dragOffset = 0
  config.chainAnimationRange = 20
  config.dragHoldDuration = 35
  config.manualScrollRecoveryTime = 7000
  config.defaultLineHeight = 12
  config.lineHeightWithTranslation = 80
  config.enableWordByWord = false
  return config
}

/**
 * 默认配置
 */
export const DEFAULT_CONFIG_V2: ChainLyricsConfig = createDefaultConfig()

/**
 * 创建默认主题
 */
export function createDefaultTheme(): LyricTheme {
  const theme = new LyricTheme()

  // 普通行样式
  theme.normalStyle = new LyricItemStyle()
  theme.normalStyle.fontSize = 24
  theme.normalStyle.fontWeight = FontWeight.Medium
  theme.normalStyle.fontColor = 'rgba(255, 255, 255, 0.85)'
  theme.normalStyle.opacity = 0.9
  theme.normalStyle.scale = 0.85

  // 高亮行样式
  theme.highlightStyle = new LyricItemStyle()
  theme.highlightStyle.fontSize = 24
  theme.highlightStyle.fontWeight = FontWeight.Bolder
  theme.highlightStyle.fontColor = Color.White
  theme.highlightStyle.textShadow = {
    radius: 12,
    color: 'rgba(255, 255, 255, 0.6)',
    offsetX: 0,
    offsetY: 0
  }
  theme.highlightStyle.opacity = 1
  theme.highlightStyle.scale = 1.0

  theme.translationFontSize = 16
  theme.transliterationFontSize = 12
  theme.sungFontColor = '#FFD700'

  return theme
}

/**
 * 默认主题
 */
export const DEFAULT_THEME_V2: LyricTheme = createDefaultTheme()