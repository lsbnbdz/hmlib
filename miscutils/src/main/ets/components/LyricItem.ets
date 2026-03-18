/**
 * 歌词行组件
 * 支持原文、翻译、音译显示
 * 支持逐字歌词效果
 */
import { LyricLine, LyricTheme, DEFAULT_THEME, LyricItemStyle, LyricWord } from '../types';
import { WordItem } from './WordItem';

/** 动画配置 */
const ANIMATION_DURATION = 500;
const ANIMATION_CURVE = Curve.EaseOut;

@Reusable
@Component
export struct LyricItem {
  /** 歌词行数据 */
  @Prop item: LyricLine = { text: '', time: 0 }
  /** 行索引 */
  @Prop index: number = 0
  /** 是否显示翻译 */
  @Prop showTranslation: boolean = false
  /** 当前高亮索引（用于样式判断） */
  @Prop currentLyricsIndex: number = 0
  /** 当前播放行索引（用于逐字效果判断） */
  @Prop playingIndex: number = 0
  /** 主题配置 */
  @Prop theme: LyricTheme = DEFAULT_THEME
  /** 是否启用逐字模式 */
  @Prop enableWordByWord: boolean = false
  /** 当前行已播放时长（毫秒） */
  @Prop currentLineElapsed: number = 0

  /** 获取当前样式（基于高亮索引） */
  private getCurrentStyle(): LyricItemStyle {
    return this.isCurrentLine() ? this.theme.highlightStyle : this.theme.normalStyle
  }

  /** 获取当前字体大小 */
  private getCurrentFontSize(): number {
    return this.getCurrentStyle().fontSize ?? 18
  }

  /** 获取翻译字体大小 */
  private getTranslationFontSize(): number {
    return this.theme.translationFontSize ?? 16
  }

  /** 获取罗马音字体大小 */
  private getTransliterationFontSize(): number {
    return this.theme.transliterationFontSize ?? 12
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
  private shouldUseWordByWord(): boolean {
    return (this.enableWordByWord &&
      this.isPlayingLine() &&
      this.item.words &&
      this.item.words.length > 0) ?? false
  }

  build() {
    Column({ space: 4 }) {
      // 原文歌词
      if (this.shouldUseWordByWord()) {
        // 逐字渲染
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.item.words!, (wordData: LyricWord, idx: number) => {
            WordItem({
              word: wordData.word,
              progress: this.calculateWordProgress(wordData),
              highlightStyle: this.theme.highlightStyle,
              normalStyle: this.theme.normalStyle,
              sungFontColor: this.theme.sungFontColor ?? DEFAULT_THEME.sungFontColor
            })
          }, (wordData: LyricWord, idx: number) => `word_${idx}_${wordData.word}`)
        }
        .width('100%')
      } else {
        // 普通整行渲染
        Text(this.item.text)
          .fontSize(this.getCurrentFontSize())
          .fontWeight(this.getCurrentStyle().fontWeight)
          .fontColor(this.getCurrentStyle().fontColor)
          .textShadow(this.getCurrentStyle().textShadow)
          .opacity(this.getCurrentStyle().opacity ?? 1)
          .textAlign(TextAlign.Start)
          .animation({
            duration: ANIMATION_DURATION,
            curve: ANIMATION_CURVE
          })
      }

      // 翻译歌词
      if (this.showTranslation && this.item.translation && this.item.translation.trim().length > 0) {
        Text(this.item.translation)
          .fontSize(this.getTranslationFontSize())
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentStyle().fontColor)
          .opacity((this.getCurrentStyle().opacity ?? 1) * 0.85)
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
          .fontSize(this.getTransliterationFontSize())
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentStyle().fontColor)
          .opacity((this.getCurrentStyle().opacity ?? 1) * 0.85)
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

  /** 是否是当前高亮行（用于样式判断） */
  private isCurrentLine(): boolean {
    return this.index === this.currentLyricsIndex
  }

  /** 是否是当前播放行（用于逐字效果判断） */
  private isPlayingLine(): boolean {
    return this.index === this.playingIndex
  }
}
