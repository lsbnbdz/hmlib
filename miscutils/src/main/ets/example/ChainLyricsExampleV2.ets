/**
 * 链式歌词示例组件 V2 版本
 * 使用定时器模拟歌词滚动，不实际播放音乐
 * 使用 @ComponentV2 和 V2 状态管理
 */
import { ChainLyricsViewV2 } from '../components/ChainLyricsViewV2'
import { LyricLine, LyricEventCallbacks } from '../types/indexV2'

@ComponentV2
export struct ChainLyricsExampleV2 {
  // 歌词数据（约20行）
  @Local lyrics: LyricLine[] = []
  // 当前高亮索引
  @Local currentIndex: number = 0
  // 是否正在播放
  @Local isPlaying: boolean = false

  // 定时器 ID
  private playTimer: number = -1

  aboutToAppear(): void {
    // 初始化歌词数据
    this.lyrics = this.createLyricsData()
  }

  // 创建歌词数据
  private createLyricsData(): LyricLine[] {
    const data: LyricLine[] = []
    data.push(this.createLyricLine('夜空中最亮的星', 0))
    data.push(this.createLyricLine('能否听清', 4000))
    data.push(this.createLyricLine('那仰望的人', 7000))
    data.push(this.createLyricLine('心底的孤独和叹息', 11000))
    data.push(this.createLyricLine('夜空中最亮的星', 15000))
    data.push(this.createLyricLine('能否记起', 19000))
    data.push(this.createLyricLine('曾与我同行', 22000))
    data.push(this.createLyricLine('消失在风里的身影', 26000))
    data.push(this.createLyricLine('我祈祷拥有一颗透明的心灵', 30000))
    data.push(this.createLyricLine('和会流泪的眼睛', 35000))
    data.push(this.createLyricLine('给我再去相信的勇气', 39000))
    data.push(this.createLyricLine('越过谎言去拥抱你', 43000))
    data.push(this.createLyricLine('每当我找不到存在的意义', 47000))
    data.push(this.createLyricLine('每当我迷失在黑夜里', 52000))
    data.push(this.createLyricLine('夜空中最亮的星', 56000))
    data.push(this.createLyricLine('请指引我靠近你', 60000))
    data.push(this.createLyricLine('夜空中最亮的星', 64000))
    data.push(this.createLyricLine('是否知道', 68000))
    data.push(this.createLyricLine('曾与我同行', 71000))
    data.push(this.createLyricLine('消失在风里的身影', 75000))
    return data
  }

  // 创建单行歌词
  private createLyricLine(text: string, time: number): LyricLine {
    const line = new LyricLine()
    line.text = text
    line.time = time
    return line
  }

  aboutToDisappear(): void {
    this.stopPlay()
  }

  // 开始播放
  startPlay(): void {
    if (this.isPlaying) return
    this.isPlaying = true
    this.scheduleNextLine()
  }

  // 暂停播放
  stopPlay(): void {
    this.isPlaying = false
    if (this.playTimer !== -1) {
      clearTimeout(this.playTimer)
      this.playTimer = -1
    }
  }

  // 切换播放状态
  togglePlay(): void {
    if (this.isPlaying) {
      this.stopPlay()
    } else {
      this.startPlay()
    }
  }

  // 创建事件回调
  private createEventCallbacks(): LyricEventCallbacks {
    const callbacks = new LyricEventCallbacks()
    callbacks.onLineClick = (_time: number, index: number) => {
      this.currentIndex = index
      if (this.isPlaying) {
        if (this.playTimer !== -1) {
          clearTimeout(this.playTimer)
        }
        this.scheduleNextLine()
      }
    }
    return callbacks
  }

  // 调度下一行
  private scheduleNextLine(): void {
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
      ChainLyricsViewV2({
        lyrics: this.lyrics,
        currentIndex: this.currentIndex,
        isPlaying: this.isPlaying,
        eventCallbacks: this.createEventCallbacks()
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