import { ChainLyricsExample } from '@ospark/misc-utils'

@Entry
@Component
struct Index {
  build() {
    Column() {
      ChainLyricsExample()
    }
    .width('100%')
    .height('100%')
  }
}