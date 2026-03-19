/**
 * 逐字歌词示例组件 V2 版本
 * 演示链式动画 + 逐字填充效果
 * 使用 @ComponentV2 和 V2 状态管理
 */
import { ChainLyricsViewV2 } from '../components/ChainLyricsViewV2'
import { LyricLine, LyricWord, LyricEventCallbacks, ChainLyricsConfig, LyricTheme, DEFAULT_THEME_V2 } from '../types/indexV2'

@ComponentV2
export struct WordByWordLyricsExampleV2 {
  // 歌词数据（带逐字信息，包含长短句、快慢节奏）
  @Local lyrics: LyricLine[] = []
  // 当前高亮索引
  @Local currentIndex: number = 0
  // 是否正在播放
  @Local isPlaying: boolean = false

  // 定时器 ID
  private playTimer: number = -1

  aboutToAppear(): void {
    this.lyrics = this.createLyricsData()
  }

  // 创建歌词数据
  private createLyricsData(): LyricLine[] {
    const data: LyricLine[] = []

    // 短句 - 正常速度
    data.push(this.createLyricLineWithWords('夜空中最亮的星', 0, 4000))

    // 短句 - 快速结尾
    let line = new LyricLine()
    line.text = '能否听清'
    line.time = 4000
    line.words = this.createWordList('能否听清', [0, 600, 1200, 1400], [600, 1200, 1400, 1600])
    data.push(line)

    // 短句 - 慢速
    line = new LyricLine()
    line.text = '那仰望的人'
    line.time = 6000
    line.words = this.createWordList('那仰望的人', [0, 800, 1800, 2800, 3400], [800, 1800, 2800, 3400, 5000])
    data.push(line)

    // 长句 - 占2行
    data.push(this.createLyricLineWithWords('心底的孤独和叹息在风中飘散远去不再回来', 11000, 17000))

    // 短句 - 连续快速
    line = new LyricLine()
    line.text = '是否能懂'
    line.time = 17000
    line.words = this.createWordList('是否能懂', [0, 150, 300, 450], [150, 300, 450, 600])
    data.push(line)

    // 短句
    data.push(this.createLyricLineWithWords('夜空中最亮的星', 18000, 22000))

    // 短句 - 快速
    line = new LyricLine()
    line.text = '能否记起'
    line.time = 22000
    line.words = this.createWordList('能否记起', [0, 200, 400, 600], [200, 400, 600, 800])
    data.push(line)

    // 短句 - 很慢
    line = new LyricLine()
    line.text = '曾与我同行'
    line.time = 23000
    line.words = this.createWordList('曾与我同行', [0, 1000, 2000, 3000, 4000], [1000, 2000, 3000, 4000, 6000])
    data.push(line)

    // 长句 - 占2行，包含连续快速
    line = new LyricLine()
    line.text = '消失在风里的身影我再也看不见摸不着找不到'
    line.time = 29000
    line.words = this.createWordList('消失在风里的身影我再也看不见摸不着找不到',
      [0, 400, 800, 1200, 1600, 2000, 2400, 2800, 3200, 3400, 3500, 3600, 3700, 3800, 4200, 4400, 4500, 4600, 4700, 4800],
      [400, 800, 1200, 1600, 2000, 2400, 2800, 3200, 3400, 3500, 3600, 3700, 3800, 4200, 4400, 4500, 4600, 4700, 4800, 5000])
    data.push(line)

    // 长句 - 占2行
    data.push(this.createLyricLineWithWords('我祈祷拥有一颗透明的心灵和会流泪的眼睛', 34000, 42000))

    // 短句 - 快速开头
    line = new LyricLine()
    line.text = '给我勇气'
    line.time = 42000
    line.words = this.createWordList('给我勇气', [0, 100, 200, 600], [100, 200, 600, 1000])
    data.push(line)

    // 长句 - 占2行，慢速
    line = new LyricLine()
    line.text = '给我再去相信的勇气越过谎言去拥抱你哪怕遍体鳞伤'
    line.time = 43000
    line.words = this.createWordList('给我再去相信的勇气越过谎言去拥抱你哪怕遍体鳞伤',
      [0, 600, 1200, 1800, 2400, 3000, 3600, 4200, 4800, 5400, 6000, 6600, 7200, 7800, 8400, 9000, 9600, 10200, 10800, 11400, 12000, 12600, 13200],
      [600, 1200, 1800, 2400, 3000, 3600, 4200, 4800, 5400, 6000, 6600, 7200, 7800, 8400, 9000, 9600, 10200, 10800, 11400, 12000, 12600, 13200, 14000])
    data.push(line)

    // 短句 - 慢速
    line = new LyricLine()
    line.text = '每当我找不到'
    line.time = 57000
    line.words = this.createWordList('每当我找不到', [0, 800, 1600, 2400, 3200, 4000], [800, 1600, 2400, 3200, 4000, 5000])
    data.push(line)

    // 短句 - 连续超快
    line = new LyricLine()
    line.text = '存在的意义'
    line.time = 62000
    line.words = this.createWordList('存在的意义', [0, 80, 160, 240, 320], [80, 160, 240, 320, 400])
    data.push(line)

    // 短句
    data.push(this.createLyricLineWithWords('每当我迷失在黑夜里', 62500, 67000))

    // 短句 - 慢速结尾
    line = new LyricLine()
    line.text = '照亮我前行'
    line.time = 74000
    line.words = this.createWordList('照亮我前行', [0, 800, 1600, 2400, 3200], [800, 1600, 2400, 3200, 5000])
    data.push(line)

    // 长句 - 占2行
    data.push(this.createLyricLineWithWords('夜空中最亮的星是否知道那曾与我同行消失在风里的身影', 79000, 89000))

    return data
  }

  // 创建逐字数据（通过起始和结束时间数组）
  private createWordList(text: string, startTimes: number[], endTimes: number[]): LyricWord[] {
    const words: LyricWord[] = []
    const chars = text.split('')
    for (let i = 0; i < chars.length && i < startTimes.length && i < endTimes.length; i++) {
      const word = new LyricWord()
      word.word = chars[i]
      word.startTime = startTimes[i]
      word.endTime = endTimes[i]
      words.push(word)
    }
    return words
  }

  // 创建带逐字数据的歌词行
  private createLyricLineWithWords(text: string, lineStartTime: number, lineEndTime: number): LyricLine {
    const line = new LyricLine()
    line.text = text
    line.time = lineStartTime
    line.words = this.createWordsAuto(text, lineEndTime - lineStartTime)
    return line
  }

  // 自动创建逐字数据（不均匀速度）
  private createWordsAuto(text: string, duration: number): LyricWord[] {
    const words: LyricWord[] = []
    const chars = text.split('')

    // 为每个字生成随机权重（模拟不均匀速度）
    const weights: number[] = chars.map(() => 0.3 + Math.random() * 0.7)
    const totalWeight = weights.reduce((sum, w) => sum + w, 0)

    let currentTime = 0
    for (let i = 0; i < chars.length; i++) {
      const charDuration = (weights[i] / totalWeight) * duration
      const word = new LyricWord()
      word.word = chars[i]
      word.startTime = currentTime
      word.endTime = currentTime + charDuration
      words.push(word)
      currentTime += charDuration
    }

    return words
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

  // 调度下一行
  private scheduleNextLine(): void {
    if (!this.isPlaying) return

    const currentLyric = this.lyrics[this.currentIndex]
    const nextIndex = this.currentIndex + 1

    if (nextIndex >= this.lyrics.length) {
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

  // 创建配置
  private createConfig(): ChainLyricsConfig {
    const config = new ChainLyricsConfig()
    config.enableWordByWord = true
    return config
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

  build() {
    Column() {
      // 歌词组件
      ChainLyricsViewV2({
        lyrics: this.lyrics,
        currentIndex: this.currentIndex,
        isPlaying: this.isPlaying,
        config: this.createConfig(),
        theme: DEFAULT_THEME_V2,
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