/**
 * 逐字组件
 * 支持逐字颜色填充效果
 */
import { LyricItemStyle, DEFAULT_THEME } from '../types';

@Reusable
@Component
export struct WordItem {
  /** 字文本 */
  @Prop word: string = ''
  /** 进度（0-1，0=未唱，1=已唱完） */
  @Prop progress: number = 0
  /** 高亮样式 */
  @Prop highlightStyle: LyricItemStyle = DEFAULT_THEME.highlightStyle
  /** 普通样式 */
  @Prop normalStyle: LyricItemStyle = DEFAULT_THEME.normalStyle
  /** 已唱部分颜色 */
  @Prop sungFontColor: ResourceColor = DEFAULT_THEME.sungFontColor as ResourceColor

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