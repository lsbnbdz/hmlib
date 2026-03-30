# Changelog

本项目的所有重要更改都将记录在此文件中。

本文件格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.0.4] - 2026-03-30

### 修复

- **切换歌词时前几行显示旧歌词问题**
  - 修复切换歌曲时，前几行歌词有概率显示上一首歌歌词的问题
  - 原因：ForEach 的 key 使用 `time_index` 格式，不同歌曲的 time 可能相同，导致组件被错误复用
  - 解决：ForEach key 改为使用歌词文本（前2字+后2字+索引），确保不同歌曲的 key 不同

## [1.0.3] - 2026-03-19

### 新增

- **V2 版本组件（基于状态管理V2）**
  - 新增 `ChainLyricsViewV2` 组件，使用 `@ComponentV2` 和 `@Local`/`@Param` 装饰器
  - 新增 `LyricItemV2` 组件，使用 `@ComponentV2` 和 `@Computed` 计算属性
  - 新增 `WordItemV2` 组件，使用 `@ReusableV2` 支持组件复用
  - 所有类型定义新增 V2 版本（使用 `@ObservedV2` 和 `@Trace` 装饰器）
    - `LyricLineV2`、`LyricWordV2`、`ChainLyricsConfigV2`、`LyricThemeV2` 等
    - 提供 `DEFAULT_CONFIG_V2`、`DEFAULT_THEME_V2` 默认配置
  - V2 版本支持深度观测嵌套对象属性变化

- **V2 示例组件**
  - 新增 `ChainLyricsExampleV2` 示例组件
  - 新增 `WordByWordLyricsExampleV2` 逐字歌词示例组件
  - 使用 `@ComponentV2` 和 `@Local` 状态管理

### 变更

- V1 和 V2 版本共存，可根据项目需求选择使用
- V2 版本导出命名带 `V2` 后缀（如 `ChainLyricsViewV2`、`LyricLineV2`）

## [1.0.2] - 2026-03-18

### 新增

- **逐字歌词功能**
  - 新增 `LyricWord` 接口，支持逐字数据（`word`、`startTime`、`endTime`）
  - `LyricLine` 新增 `words` 可选字段，支持逐字歌词数据
  - 新增 `WordItem` 组件，实现逐字颜色填充效果
  - `ChainLyricsView` 新增 `isPlaying` 属性，控制逐字计时
  - `ChainLyricsConfig` 新增 `enableWordByWord` 配置，开启逐字模式
  - `LyricTheme` 新增 `sungFontColor` 配置，设置已唱部分颜色

- **逐字歌词示例组件**
  - 新增 `WordByWordLyricsExample` 示例组件
  - 包含约20行带逐字信息的示例歌词
  - 支持长句（占2+行）和短句
  - 包含快慢节奏变化，有连续快速字和慢速字
  - 可通过 `import { WordByWordLyricsExample } from '@ospark/misc-utils'` 使用

### 修复

- **Tabs 中初始化位置问题**
  - 修复在 Tabs 组件中，非首个 TabContent 的歌词组件初始化时位置不正确的问题
  - 当 `onAreaChange` 测量到有效高度变化时，重新计算歌词位置

## [1.0.1] - 2026-03-17

### 新增

- **ChainLyricsExample 示例组件**
  - 新增示例组件，使用定时器模拟歌词滚动（不实际播放音乐）
  - 包含约20行示例歌词数据
  - 支持播放/暂停控制和点击跳转
  - 可通过 `import { ChainLyricsExample } from '@ospark/misc-utils'` 直接使用

### 优化

- **样式/配置变化时的动画处理**
  - 新增初始化标志 `isInitialized`，避免组件初始化时 `@Watch` 回调干扰
  - 新增待处理更新标志 `hasPendingUpdate`，支持动画期间样式变化的延迟生效
  - 配置变化（`config`）时：如果正在滚动，标记待处理，等动画结束后自动应用
  - 主题变化（`theme`）时：如果正在滚动，标记待处理，等动画结束后自动应用
  - 解决了调整字体大小等样式参数时歌词行重叠的问题
  - 统一使用 `getDefaultSpringParams()` 和 `getDefaultConfigValues()` 函数获取默认值

## [1.0.0] - 2026-03-10

### 新增

- **ChainLyricsView 链式歌词组件**
  - 链式动画：歌词切换时产生依次拖拽的视觉效果
  - 智能动画跳过：当前歌词行持续时间太短时自动跳过动画
  - 弹簧动画：使用物理弹簧曲线，自然流畅
  - 手动拖拽：支持手指拖动查看歌词
  - 惯性滑动：拖动结束后有惯性效果
  - 自动恢复：手动滚动后自动回到当前播放位置
  - 翻译支持：支持显示翻译和音译/罗马音
  - 点击跳转：支持点击歌词行跳转播放位置
  - 高度可定制：支持自定义主题、弹簧参数、行间距等配置
