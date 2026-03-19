import {
  ChainLyricsExample,
  ChainLyricsExampleV2, WordByWordLyricsExample, WordByWordLyricsExampleV2 } from '@ospark/misc-utils'

@Entry
@Component
struct Index {
  // 状态栏高度（px）
  @StorageLink('statusBarHeight') statusBarHeightPx: number = 0

  build() {
    Column() {
      // 状态栏占位（转换px到vp）
      Column()
        .width('100%')
        .height(this.getUIContext().px2vp(this.statusBarHeightPx))

      Tabs() {
        TabContent() {
          WordByWordLyricsExample()
        }
        .tabBar('逐字')

        TabContent() {
          ChainLyricsExample()
        }
        .tabBar('普通')

        TabContent() {
          WordByWordLyricsExampleV2()
        }
        .tabBar('逐字V2')

        TabContent() {
          ChainLyricsExampleV2()
        }
        .tabBar('普通V2')
      }
      .width('100%')
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .vertical(false)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a2e')
  }
}