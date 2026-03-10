/**
 * 歌词行组件
 * 支持原文、翻译、音译显示
 */
import { LyricLine, LyricTheme, DEFAULT_THEME, LyricItemStyle } from '../types';

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
  /** 当前高亮索引 */
  @Prop currentLyricsIndex: number = 0
  /** 主题配置 */
  @Prop theme: LyricTheme = DEFAULT_THEME

  /** 获取当前样式 */
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

  build() {
    Column({ space: 4 }) {
      // 原文歌词
      Text(this.item.text)
        .fontSize(this.getCurrentFontSize())
        .fontWeight(this.getCurrentStyle().fontWeight)
        .fontColor(this.getCurrentStyle().fontColor)
        .textShadow(this.getCurrentStyle().textShadow)
        .opacity(this.getCurrentStyle().opacity ?? 1)
        .textAlign(TextAlign.Center)
        .animation({
          duration: ANIMATION_DURATION,
          curve: ANIMATION_CURVE
        })

      // 翻译歌词
      if (this.showTranslation && this.item.translation && this.item.translation.trim().length > 0) {
        Text(this.item.translation)
          .fontSize(this.getTranslationFontSize())
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentStyle().fontColor)
          .opacity((this.getCurrentStyle().opacity ?? 1) * 0.85)
          .textAlign(TextAlign.Center)
          .padding({ left: 16, right: 16, top: 2 })
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
          .textAlign(TextAlign.Center)
          .padding({ left: 16, right: 16, top: 2 })
          .animation({
            duration: ANIMATION_DURATION,
            curve: ANIMATION_CURVE
          })
      }
    }
    .width('90%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .scale({
      x: this.isCurrentLine() ? (this.getCurrentStyle().scale ?? 1.0) : 1.0,
      y: this.isCurrentLine() ? (this.getCurrentStyle().scale ?? 1.0) : 1.0
    })
    .animation({
      duration: ANIMATION_DURATION,
      curve: ANIMATION_CURVE
    })
    .renderGroup(true)
  }

  private isCurrentLine(): boolean {
    return this.index === this.currentLyricsIndex
  }
}
