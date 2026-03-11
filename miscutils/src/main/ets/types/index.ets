/**
 * 链式歌词组件类型定义
 */

/**
 * 歌词行数据接口
 */
export interface LyricLine {
  /** 歌词文本 */
  text: string
  /** 时间戳（毫秒） */
  time: number
  /** 翻译（可选） */
  translation?: string
  /** 音译（可选） */
  transliteration?: string
}

/**
 * 弹簧动画参数
 */
export interface SpringAnimationParams {
  /** 初始速度 */
  velocity?: number
  /** 质量 */
  mass?: number
  /** 刚度 */
  stiffness?: number
  /** 阻尼 */
  damping?: number
  /** 行间距 */
  lineSpacing?: number
  /** 高亮行与非高亮行之间的额外间距 */
  highlightLineSpacing?: number
  /** 链式动画每行延迟（毫秒） */
  dragDelay?: number
}

/**
 * 链式歌词组件配置
 */
export interface ChainLyricsConfig {
  /** 弹簧动画参数 */
  springParams?: SpringAnimationParams
  /** 高亮位置比例（0-1，相对于容器高度） */
  highlightPositionRatio?: number
  /** 链式动画拖拽偏移量 */
  dragOffset?: number
  /** 链式动画范围 */
  chainAnimationRange?: number
  /** 拖拽持续时间（毫秒） */
  dragHoldDuration?: number
  /** 手动滚动后自动恢复时间（毫秒） */
  manualScrollRecoveryTime?: number
  /** 默认行高 */
  defaultLineHeight?: number
  /** 带翻译的行高 */
  lineHeightWithTranslation?: number
}

/**
 * 歌词行样式配置
 */
export interface LyricItemStyle {
  /** 字体大小 */
  fontSize?: number
  /** 字体粗细 */
  fontWeight?: FontWeight
  /** 字体颜色 */
  fontColor?: ResourceColor
  /** 文字阴影 */
  textShadow?: ShadowOptions
  /** 透明度 */
  opacity?: number
  /** 缩放比例 */
  scale?: number
}

/**
 * 歌词主题配置
 */
export interface LyricTheme {
  /** 普通行样式 */
  normalStyle: LyricItemStyle
  /** 高亮行样式 */
  highlightStyle: LyricItemStyle
  /** 翻译字体大小 */
  translationFontSize?: number
  /** 罗马音字体大小 */
  transliterationFontSize?: number
}

/**
 * 默认配置
 */
export const DEFAULT_CONFIG: ChainLyricsConfig = {
  springParams: {
    velocity: 0,
    mass: 0.3,
    stiffness: 200,
    damping: 15,
    lineSpacing: 24,
    highlightLineSpacing: 8,
    dragDelay: 35
  },
  highlightPositionRatio: 0.25,
  dragOffset: 0,
  chainAnimationRange: 20,
  dragHoldDuration: 35,
  manualScrollRecoveryTime: 7000,
  defaultLineHeight: 12,
  lineHeightWithTranslation: 80
}

/**
 * 默认主题
 */
export const DEFAULT_THEME: LyricTheme = {
  normalStyle: {
    fontSize: 24,
    fontWeight: FontWeight.Medium,
    fontColor: 'rgba(255, 255, 255, 0.85)',
    opacity: 0.9,
    scale: 0.85
  },
  highlightStyle: {
    fontSize: 24,
    fontWeight: FontWeight.Bolder,
    fontColor: Color.White,
    textShadow: {
      radius: 12,
      color: 'rgba(255, 255, 255, 0.6)',
      offsetX: 0,
      offsetY: 0
    },
    opacity: 1,
    scale: 1.0
  },
  translationFontSize: 16,
  transliterationFontSize: 12
}

/**
 * 歌词组件事件回调接口
 */
export interface LyricEventCallbacks {
  /** 歌词行点击回调 */
  onLineClick?: (time: number, index: number) => void
  /** 高亮索引变化回调 */
  onHighlightChange?: (index: number) => void
  /** 手动滚动开始回调 */
  onManualScrollStart?: () => void
  /** 手动滚动结束回调 */
  onManualScrollEnd?: () => void
}
