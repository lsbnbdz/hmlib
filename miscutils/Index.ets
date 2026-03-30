/**
 * MiscUtils - 组件库
 * @version 1.0.4
 */

// ==================== V1 版本导出 ====================
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

// ==================== V2 版本导出 ====================
// 组件导出
export { ChainLyricsViewV2 } from './src/main/ets/components/ChainLyricsViewV2'
export { LyricItemV2 } from './src/main/ets/components/LyricItemV2'
export { WordItemV2 } from './src/main/ets/components/WordItemV2'

// 示例组件导出
export { ChainLyricsExampleV2 } from './src/main/ets/example/ChainLyricsExampleV2'
export { WordByWordLyricsExampleV2 } from './src/main/ets/example/WordByWordLyricsExampleV2'

// 类型导出
export {
 LyricLine as LyricLineV2,
 LyricWord as LyricWordV2,
 SpringAnimationParams as SpringAnimationParamsV2,
 ChainLyricsConfig as ChainLyricsConfigV2,
 LyricItemStyle as LyricItemStyleV2,
 LyricTheme as LyricThemeV2,
 LyricEventCallbacks as LyricEventCallbacksV2,
 DEFAULT_CONFIG_V2,
 DEFAULT_THEME_V2,
 createDefaultConfig,
 createDefaultTheme
} from './src/main/ets/types/indexV2'