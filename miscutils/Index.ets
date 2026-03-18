/**
 * MiscUtils - 组件库
 * @version 1.0.2
 */

// 组件导出
export { ChainLyricsView } from './src/main/ets/components/ChainLyricsView'
export { LyricItem } from './src/main/ets/components/LyricItem'
export { WordItem } from './src/main/ets/components/WordItem'

// 示例组件导出
export { ChainLyricsExample } from './src/main/ets/example/ChainLyricsExample'
export { WordByWordLyricsExample } from './src/main/ets/example/WordByWordLyricsExample'

// 类型导出
export {
  // 数据接口
  LyricLine,
  LyricWord,
  SpringAnimationParams,
  ChainLyricsConfig,
  LyricItemStyle,
  LyricTheme,
  LyricEventCallbacks,
  // 默认配置
  DEFAULT_CONFIG,
  DEFAULT_THEME,
  // 默认值函数
  getDefaultSpringParams,
  getDefaultConfigValues
} from './src/main/ets/types/index'
