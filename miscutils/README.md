# @ospark/misc-utils

链式歌词组件库，支持链式动画、弹簧动画、手动拖拽、惯性滑动。

> **声明**：本组件只支持逐行歌词，不支持逐字歌词。

## 特性

- **开箱即用**：只需传入歌词数组和当前索引即可使用
- **链式动画**：歌词切换时产生依次拖拽的视觉效果
- **智能动画跳过**：当前歌词行持续时间太短时自动跳过动画
- **弹簧动画**：使用物理弹簧曲线，自然流畅
- **手动拖拽**：支持手指拖动查看歌词
- **惯性滑动**：拖动结束后有惯性效果
- **自动恢复**：手动滚动后自动回到当前播放位置
- **翻译支持**：支持显示翻译和音译

## 安装

### 本地引用

在 `oh-package.json5` 中添加本地 har 包引用：

```json
{
  "dependencies": {
    "@ospark/misc-utils": "file:./libs/miscutils.har"
  }
}
```

### 远端安装（发布后可用）

```bash
ohpm install @ospark/misc-utils
```

或手动在 `oh-package.json5` 中添加：

```json
{
  "dependencies": {
    "@ospark/misc-utils": "^1.0.0"
  }
}
```

## 入参说明

### ChainLyricsView 属性

| 属性 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| `lyrics` | LyricLine[] | 是 | `[]` | 歌词数据数组 |
| `currentIndex` | number | 是 | `0` | 当前高亮索引 |
| `showTranslation` | boolean | 否 | `false` | 是否显示翻译 |
| `showBlurMask` | boolean | 否 | `true` | 是否显示模糊遮罩。开启后，非高亮行会有渐变模糊效果，手动滑动时自动隐藏遮罩 |
| `config` | ChainLyricsConfig | 否 | `DEFAULT_CONFIG` | 组件配置 |
| `theme` | LyricTheme | 否 | `DEFAULT_THEME` | 主题配置 |
| `containerHeight` | number | 否 | `0` | 容器高度，不传则自动测量 |
| `resetSignal` | number | 否 | `0` | 重置信号。当外部需要强制将歌词重置到当前高亮行时，改变此值即可触发重置。常用于用户点击"回到当前播放位置"按钮、播放模式切换等场景。组件内部通过 `@Watch` 监听此值变化，**只有当新值大于 0 时才会触发重置**到 `currentIndex` 对应的位置。建议使用方式：每次需要重置时让值 +1 即可 |
| `eventCallbacks` | LyricEventCallbacks | 否 | `{}` | 事件回调 |

### LyricLine 歌词行数据

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `text` | string | 是 | 歌词文本 |
| `time` | number | 是 | 时间戳（毫秒） |
| `translation` | string | 否 | 翻译 |
| `transliteration` | string | 否 | 音译 |

### ChainLyricsConfig 组件配置

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `highlightPositionRatio` | number | 0.25 | 高亮行在容器中的位置比例 (0-1)，0.25 表示在屏幕上方 1/4 处 |
| `dragOffset` | number | 30 | 链式动画时歌词行的"拖拽"偏移量 (vp) |
| `chainAnimationRange` | number | 20 | 链式动画影响的行数范围 |
| `dragHoldDuration` | number | 35 | 链式动画中每行"拖拽"停留的时间 (ms) |
| `manualScrollRecoveryTime` | number | 7000 | 用户手动滑动后自动恢复的时间 (ms) |
| `defaultLineHeight` | number | 12 | 普通歌词行的预估高度 (vp) |
| `lineHeightWithTranslation` | number | 80 | 带翻译/罗马音的歌词行的预估高度 (vp) |
| `springParams` | SpringAnimationParams | - | 弹簧动画参数 |

### SpringAnimationParams 弹簧动画参数

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `velocity` | number | 0 | 弹簧动画的初始速度 |
| `mass` | number | 0.3 | 弹簧质量，值越大惯性越大 |
| `stiffness` | number | 200 | 弹簧刚度，值越大回弹越快 |
| `damping` | number | 15 | 阻尼系数，值越大振荡越少 |
| `lineSpacing` | number | 24 | 歌词行与行之间的基础间距 (vp) |
| `highlightLineSpacing` | number | 8 | 高亮行与相邻行的额外间距 (vp) |
| `dragDelay` | number | 35 | 链式动画中每行开始动画的延迟时间 (ms) |

### LyricTheme 主题配置

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `normalStyle` | LyricItemStyle | 是 | 普通行样式 |
| `highlightStyle` | LyricItemStyle | 是 | 高亮行样式 |
| `translationFontSize` | number | 否 | 翻译字体大小 (vp)，默认 16 |
| `transliterationFontSize` | number | 否 | 罗马音字体大小 (vp)，默认 12 |

### LyricItemStyle 歌词行样式

| 属性 | 类型 | 说明 |
|------|------|------|
| `fontSize` | number | 字体大小 |
| `fontWeight` | FontWeight | 字体粗细 |
| `fontColor` | ResourceColor | 字体颜色 |
| `textShadow` | ShadowOptions | 文字阴影 |
| `opacity` | number | 透明度 (0-1) |
| `scale` | number | 缩放比例。注意：高亮行固定为 1.0，此值仅对普通行生效 |

> **注意**：缩放逻辑已优化为"当前行保持原始大小，其他行缩小"的模式。`normalStyle.scale` 控制普通行的缩放比例（默认 0.85），`highlightStyle.scale` 保留但不影响显示效果（高亮行始终为 1.0）。

### LyricEventCallbacks 事件回调

| 属性 | 类型 | 说明 |
|------|------|------|
| `onLineClick` | `(time: number, index: number) => void` | 歌词行点击回调，**传入此回调才会启用点击跳转功能** |
| `onHighlightChange` | `(index: number) => void` | 高亮索引变化回调 |
| `onManualScrollStart` | `() => void` | 手动滚动开始回调 |
| `onManualScrollEnd` | `() => void` | 手动滚动结束回调 |

## 完整使用示例

```typescript
import { ChainLyricsView, LyricLine, ChainLyricsConfig, LyricTheme, LyricEventCallbacks } from '@ospark/misc-utils'

@Entry
@Component
struct LyricsPage {
  // 歌词数据
  @State lyrics: LyricLine[] = [
    { text: '第一句歌词', time: 0, translation: '翻译一', transliteration: 'yi' },
    { text: '第二句歌词', time: 5000, translation: '翻译二', transliteration: 'er' },
    { text: '第三句歌词', time: 10000, translation: '翻译三', transliteration: 'san' },
    { text: '第四句歌词', time: 15000 },
    { text: '第五句歌词', time: 20000 }
  ]

  // 当前高亮索引
  @State currentIndex: number = 0

  // 组件配置
  private config: ChainLyricsConfig = {
    highlightPositionRatio: 0.25,
    dragOffset: 30,
    chainAnimationRange: 20,
    dragHoldDuration: 35,
    manualScrollRecoveryTime: 7000,
    defaultLineHeight: 12,
    lineHeightWithTranslation: 80,
    springParams: {
      velocity: 0,
      mass: 0.3,
      stiffness: 200,
      damping: 15,
      lineSpacing: 24,
      highlightLineSpacing: 8,
      dragDelay: 35
    }
  }

  // 主题配置
  private theme: LyricTheme = {
    normalStyle: {
      fontSize: 16,
      fontWeight: FontWeight.Medium,
      fontColor: 'rgba(255, 255, 255, 0.7)',
      opacity: 0.8,
      scale: 0.85
    },
    highlightStyle: {
      fontSize: 20,
      fontWeight: FontWeight.Bold,
      fontColor: Color.White,
      textShadow: {
        radius: 10,
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

  // 事件回调
  private eventCallbacks: LyricEventCallbacks = {
    onLineClick: (time: number, index: number) => {
      console.log(`点击了第 ${index} 行，时间 ${time}ms`)
      // 调用播放器 seek 方法跳转
      // player.seek(time)
      this.currentIndex = index
    },
    onHighlightChange: (index: number) => {
      console.log(`当前高亮：${index}`)
    },
    onManualScrollStart: () => {
      console.log('开始手动滚动')
    },
    onManualScrollEnd: () => {
      console.log('手动滚动结束')
    }
  }

  build() {
    Column() {
      ChainLyricsView({
        lyrics: this.lyrics,
        currentIndex: this.currentIndex,
        showTranslation: true,
        config: this.config,
        theme: this.theme,
        eventCallbacks: this.eventCallbacks
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a2e')
  }
}
```

## 最简使用

只需传入歌词数据和当前索引即可：

```typescript
import { ChainLyricsView, LyricLine } from '@ospark/misc-utils'

@Entry
@Component
struct SimplePage {
  @State lyrics: LyricLine[] = [
    { text: '第一句歌词', time: 0 },
    { text: '第二句歌词', time: 5000 },
    { text: '第三句歌词', time: 10000 }
  ]
  @State currentIndex: number = 0

  build() {
    ChainLyricsView({
      lyrics: this.lyrics,
      currentIndex: this.currentIndex
    })
  }
}
```

> **注意**：最简使用模式下，点击歌词行**不会触发跳转**。如需点击跳转功能，请添加 `onLineClick` 回调。

## 视觉效果示意

```
┌─────────────────────────────────┐
│  普通行 (透明度低、缩小)          │  ← lineSpacing 行间距
│  普通行 (透明度低、缩小)          │
│                                 │  ← highlightLineSpacing 额外间距
│  ★ 高亮行 (原始大小、高亮)        │  ← highlightPositionRatio 位置
│                                 │  ← highlightLineSpacing 额外间距
│  普通行 (透明度低、缩小)          │
│  普通行 (透明度低、缩小)          │
└─────────────────────────────────┘
```

> **注意**：歌词采用左对齐布局，缩放时以左侧中心点为基准，确保歌词不会因缩放而产生左右晃动。

## 链式动画效果说明

歌词切换时产生的"波浪"拖拽效果：

```
切换歌词时 (假设 dragDelay = 35ms, dragOffset = 30vp):

第1行 ↓ (延迟  0ms 开始，先下坠 30vp，停留 35ms 后回弹)
第2行 ↓ (延迟 35ms 开始，先下坠 30vp，停留 35ms 后回弹)
第3行 ↓ (延迟 70ms 开始，先下坠 30vp，停留 35ms 后回弹)
第4行 ↓ (延迟105ms 开始，先下坠 30vp，停留 35ms 后回弹)
...

形成从上到下依次波动的视觉效果，如同一阵风吹过
```

## 性能优化建议

### 样式/配置变化的延迟生效机制

组件内置了智能的样式/配置变化处理机制：

- 当 `config` 或 `theme` 发生变化时，如果组件**正在滚动**（链式动画或手动滑动），变化不会立即生效
- 变化会被标记为"待处理"，等滚动结束后自动应用
- 这样可以避免动画过程中位置重新计算导致的歌词重叠问题

> **注意**：不建议在播放音乐时实时修改歌词样式（如字体大小、行间距等）。实时渲染字体动画会占用较多性能资源，可能导致音乐播放出现卡顿。建议在暂停播放或播放前进行样式调整。

### 实时调整配置参数

如果需要实时调整配置参数（如通过 Slider），建议使用**节流**来避免每帧都触发重渲染：

```typescript
@Component
struct MyPage {
  @State lineSpacing: number = 24
  private updateTimer: number = -1
  private pendingValue: number = 24

  build() {
    Column() {
      ChainLyricsView({
        lyrics: this.lyrics,
        currentIndex: this.currentIndex,
        config: {
          springParams: {
            lineSpacing: this.lineSpacing
          }
        }
      })

      Slider({ value: this.lineSpacing, min: 8, max: 48, step: 2 })
        .onChange((value: number) => {
          this.pendingValue = value
          // 节流：100ms 内只更新一次
          if (this.updateTimer === -1) {
            this.updateTimer = setTimeout(() => {
              this.lineSpacing = this.pendingValue
              this.updateTimer = -1
            }, 100) as number
          }
        })
    }
  }
}
```

### 性能优化原理

| 优化项 | 说明 |
|--------|------|
| `renderGroup(true)` | 组件内置，开启渲染组减少重绘开销 |
| 缓存计算结果 | 组件内置，缓存样式和字体大小计算 |
| 延迟生效机制 | 组件内置，滚动期间不处理样式变化，避免重叠 |
| 节流更新 | 使用方实现，避免 Slider 每帧触发状态更新 |

## License

Apache-2.0
