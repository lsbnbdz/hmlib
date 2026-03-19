/**
 * 歌词行组件 V2 版本
 * 支持原文、翻译、音译显示
 * 支持逐字歌词效果
 */
import { LyricLine, LyricTheme, DEFAULT_THEME_V2, LyricItemStyle, LyricWord } from '../types/indexV2';
import { WordItemV2 } from './WordItemV2';

/** 动画配置 */
const ANIMATION_DURATION = 500;
const ANIMATION_CURVE = Curve.EaseOut;

@ReusableV2
@ComponentV2
export struct LyricItemV2 {
  /** 歌词行数据 */
  @Param item: LyricLine = new LyricLine()
  /** 行索引 */
  @Param index: number = 0
  /** 是否显示翻译 */
  @Param showTranslation: boolean = false
  /** 当前高亮索引（用于样式判断） */
  @Param currentLyricsIndex: number = 0
  /** 当前播放行索引（用于逐字效果判断） */
  @Param playingIndex: number = 0
  /** 主题配置 */
  @Param theme: LyricTheme = DEFAULT_THEME_V2
  /** 是否启用逐字模式 */
  @Param enableWordByWord: boolean = false
  /** 当前行已播放时长（毫秒） */
  @Param currentLineElapsed: number = 0

  /** 是否是当前高亮行（用于样式判断） */
  private get isCurrentLine(): boolean {
    return this.index === this.currentLyricsIndex
  }

  /** 是否是当前播放行（用于逐字效果判断） */
  private get isPlayingLine(): boolean {
    return this.index === this.playingIndex
  }

  /** 获取当前样式（基于高亮索引） */
  @Computed
  get currentStyle(): LyricItemStyle {
    return this.isCurrentLine ? this.theme.highlightStyle : this.theme.normalStyle
  }

  /** 计算单个字的进度 */
  private calculateWordProgress(word: LyricWord): number {
    if (this.currentLineElapsed < word.startTime) return 0
    if (this.currentLineElapsed >= word.endTime) return 1
    const duration = word.endTime - word.startTime
    if (duration <= 0) return 1
    return (this.currentLineElapsed - word.startTime) / duration
  }

  /** 是否使用逐字渲染（基于播放行索引） */
  private get shouldUseWordByWord(): boolean {
    return this.enableWordByWord &&
      this.isPlayingLine &&
      this.item.words !== undefined &&
      this.item.words.length > 0
  }

  build() {
    Column({ space: 4 }) {
      // 原文歌词
      if (this.shouldUseWordByWord) {
        // 逐字渲染
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.item.words!, (wordData: LyricWord, idx: number) => {
            WordItemV2({
              word: wordData.word,
              progress: this.calculateWordProgress(wordData),
              highlightStyle: this.theme.highlightStyle,
              normalStyle: this.theme.normalStyle,
              sungFontColor: this.theme.sungFontColor
            })
          }, (wordData: LyricWord, idx: number) => `word_${idx}_${wordData.word}`)
        }
        .width('100%')
      } else {
        // 普通整行渲染
        Text(this.item.text)
          .fontSize(this.currentStyle.fontSize)
          .fontWeight(this.currentStyle.fontWeight)
          .fontColor(this.currentStyle.fontColor)
          .textShadow(this.currentStyle.textShadow)
          .opacity(this.currentStyle.opacity)
          .textAlign(TextAlign.Start)
          .animation({
            duration: ANIMATION_DURATION,
            curve: ANIMATION_CURVE
          })
      }

      // 翻译歌词
      if (this.showTranslation && this.item.translation && this.item.translation.trim().length > 0) {
        Text(this.item.translation)
          .fontSize(this.theme.translationFontSize)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentStyle.fontColor)
          .opacity(this.currentStyle.opacity * 0.85)
          .textAlign(TextAlign.Start)
          .margin({ top: 2 })
          .animation({
            duration: ANIMATION_DURATION,
            curve: ANIMATION_CURVE
          })
      }

      // 音译歌词
      if (this.showTranslation && this.item.transliteration && this.item.transliteration.length > 0) {
        Text(this.item.transliteration)
          .fontSize(this.theme.transliterationFontSize)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentStyle.fontColor)
          .opacity(this.currentStyle.opacity * 0.85)
          .textAlign(TextAlign.Start)
          .margin({ top: 2 })
          .animation({
            duration: ANIMATION_DURATION,
            curve: ANIMATION_CURVE
          })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .renderGroup(true)
  }
}