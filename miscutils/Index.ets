/**
 * MiscUtils - 链式歌词组件库
 * @version 1.0.1
 */

// 组件导出
export { ChainLyricsView } from './src/main/ets/components/ChainLyricsView'
export { LyricItem } from './src/main/ets/components/LyricItem'

// 示例组件导出
export { ChainLyricsExample } from './src/main/ets/example/ChainLyricsExample'

// 类型导出
export {
  // 数据接口
  LyricLine,
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
