/**
 * 逐字组件 V2 版本
 * 支持逐字颜色填充效果
 */
import { LyricItemStyle, DEFAULT_THEME_V2 } from '../types/indexV2';

@ReusableV2
@ComponentV2
export struct WordItemV2 {
  /** 字文本 */
  @Param word: string = ''
  /** 进度（0-1，0=未唱，1=已唱完） */
  @Param progress: number = 0
  /** 高亮样式 */
  @Param highlightStyle: LyricItemStyle = DEFAULT_THEME_V2.highlightStyle
  /** 普通样式 */
  @Param normalStyle: LyricItemStyle = DEFAULT_THEME_V2.normalStyle
  /** 已唱部分颜色 */
  @Param sungFontColor: ResourceColor = DEFAULT_THEME_V2.sungFontColor

  build() {
    Stack() {
      // 底层：未唱部分（普通样式）
      Text(this.word)
        .fontSize(this.highlightStyle.fontSize)
        .fontWeight(this.highlightStyle.fontWeight)
        .fontColor(this.normalStyle.fontColor)

      // 顶层：已唱部分（逐字颜色，使用 clip 裁剪）
      Text(this.word)
        .fontSize(this.highlightStyle.fontSize)
        .fontWeight(this.highlightStyle.fontWeight)
        .fontColor(this.sungFontColor)
        .textShadow(this.highlightStyle.textShadow)
        .padding(12)
        .margin(-12)
        .clipShape(new Circle({
          width: `${this.progress * 100}%`,
          height: '100%'
        }))
    }
    .animation({ duration: 100, curve: Curve.Linear })
    .alignContent(Alignment.Start)
  }
}