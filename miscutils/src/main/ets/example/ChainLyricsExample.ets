/**
 * 链式歌词示例组件
 * 使用定时器模拟歌词滚动，不实际播放音乐
 */
import { ChainLyricsView } from '../components/ChainLyricsView'
import { LyricLine } from '../types'

@Component
export struct ChainLyricsExample {
  // 歌词数据（约20行）
  @State lyrics: LyricLine[] = [
    { text: '夜空中最亮的星', time: 0 },
    { text: '能否听清', time: 4000 },
    { text: '那仰望的人', time: 7000 },
    { text: '心底的孤独和叹息', time: 11000 },
    { text: '夜空中最亮的星', time: 15000 },
    { text: '能否记起', time: 19000 },
    { text: '曾与我同行', time: 22000 },
    { text: '消失在风里的身影', time: 26000 },
    { text: '我祈祷拥有一颗透明的心灵', time: 30000 },
    { text: '和会流泪的眼睛', time: 35000 },
    { text: '给我再去相信的勇气', time: 39000 },
    { text: '越过谎言去拥抱你', time: 43000 },
    { text: '每当我找不到存在的意义', time: 47000 },
    { text: '每当我迷失在黑夜里', time: 52000 },
    { text: '夜空中最亮的星', time: 56000 },
    { text: '请指引我靠近你', time: 60000 },
    { text: '夜空中最亮的星', time: 64000 },
    { text: '是否知道', time: 68000 },
    { text: '曾与我同行', time: 71000 },
    { text: '消失在风里的身影', time: 75000 }
  ]

  // 当前高亮索引
  @State currentIndex: number = 0

  // 是否正在播放
  @State isPlaying: boolean = false

  // 定时器 ID
  private playTimer: number = -1

  aboutToDisappear() {
    this.stopPlay()
  }

  // 开始播放
  startPlay() {
    if (this.isPlaying) return
    this.isPlaying = true
    this.scheduleNextLine()
  }

  // 暂停播放
  stopPlay() {
    this.isPlaying = false
    if (this.playTimer !== -1) {
      clearTimeout(this.playTimer)
      this.playTimer = -1
    }
  }

  // 切换播放状态
  togglePlay() {
    if (this.isPlaying) {
      this.stopPlay()
    } else {
      this.startPlay()
    }
  }

  // 调度下一行
  private scheduleNextLine() {
    if (!this.isPlaying) return

    const currentLyric = this.lyrics[this.currentIndex]
    const nextIndex = this.currentIndex + 1

    if (nextIndex >= this.lyrics.length) {
      // 播放完毕，回到第一行
      this.currentIndex = 0
      this.stopPlay()
      return
    }

    const nextLyric = this.lyrics[nextIndex]
    const delay = nextLyric.time - currentLyric.time

    this.playTimer = setTimeout(() => {
      this.currentIndex = nextIndex
      this.scheduleNextLine()
    }, delay) as number
  }

  build() {
    Column() {
      // 歌词组件
      ChainLyricsView({
        lyrics: this.lyrics,
        currentIndex: this.currentIndex,
        eventCallbacks: {
          onLineClick: (time: number, index: number) => {
            this.currentIndex = index
            if (this.isPlaying) {
              if (this.playTimer !== -1) {
                clearTimeout(this.playTimer)
              }
              this.scheduleNextLine()
            }
          }
        }
      })
      .width('100%')
      .layoutWeight(1)

      // 控制栏
      Row() {
        Button(this.isPlaying ? '暂停' : '播放')
          .fontSize(16)
          .width(100)
          .onClick(() => this.togglePlay())

        Text(`当前: 第 ${this.currentIndex + 1} / ${this.lyrics.length} 行`)
          .fontSize(14)
          .fontColor('rgba(255, 255, 255, 0.7)')
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a2e')
  }
}