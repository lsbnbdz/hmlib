/**
 * 逐字歌词示例组件
 * 演示链式动画 + 逐字填充效果
 */
import { ChainLyricsView } from '../components/ChainLyricsView'
import { LyricLine, LyricWord, DEFAULT_THEME } from '../types'

@Component
export struct WordByWordLyricsExample {
  // 歌词数据（带逐字信息，包含长短句、快慢节奏）
  @State lyrics: LyricLine[] = [
    // 短句 - 正常速度
    {
      text: '夜空中最亮的星',
      time: 0,
      words: this.createWords('夜空中最亮的星', 0, 4000)
    },
    // 短句 - 快速结尾
    {
      text: '能否听清',
      time: 4000,
      words: [
        { word: '能', startTime: 0, endTime: 600 },
        { word: '否', startTime: 600, endTime: 1200 },
        { word: '听', startTime: 1200, endTime: 1400 },
        { word: '清', startTime: 1400, endTime: 1600 }
      ]
    },
    // 短句 - 慢速
    {
      text: '那仰望的人',
      time: 6000,
      words: [
        { word: '那', startTime: 0, endTime: 800 },
        { word: '仰', startTime: 800, endTime: 1800 },
        { word: '望', startTime: 1800, endTime: 2800 },
        { word: '的', startTime: 2800, endTime: 3400 },
        { word: '人', startTime: 3400, endTime: 5000 }
      ]
    },
    // 长句 - 占2行
    {
      text: '心底的孤独和叹息在风中飘散远去不再回来',
      time: 11000,
      words: this.createWords('心底的孤独和叹息在风中飘散远去不再回来', 11000, 17000)
    },
    // 短句 - 连续快速
    {
      text: '是否能懂',
      time: 17000,
      words: [
        { word: '是', startTime: 0, endTime: 150 },
        { word: '否', startTime: 150, endTime: 300 },
        { word: '能', startTime: 300, endTime: 450 },
        { word: '懂', startTime: 450, endTime: 600 }
      ]
    },
    // 短句
    {
      text: '夜空中最亮的星',
      time: 18000,
      words: this.createWords('夜空中最亮的星', 18000, 22000)
    },
    // 短句 - 快速
    {
      text: '能否记起',
      time: 22000,
      words: [
        { word: '能', startTime: 0, endTime: 200 },
        { word: '否', startTime: 200, endTime: 400 },
        { word: '记', startTime: 400, endTime: 600 },
        { word: '起', startTime: 600, endTime: 800 }
      ]
    },
    // 短句 - 很慢
    {
      text: '曾与我同行',
      time: 23000,
      words: [
        { word: '曾', startTime: 0, endTime: 1000 },
        { word: '与', startTime: 1000, endTime: 2000 },
        { word: '我', startTime: 2000, endTime: 3000 },
        { word: '同', startTime: 3000, endTime: 4000 },
        { word: '行', startTime: 4000, endTime: 6000 }
      ]
    },
    // 长句 - 占2行，包含连续快速
    {
      text: '消失在风里的身影我再也看不见摸不着找不到',
      time: 29000,
      words: [
        { word: '消', startTime: 0, endTime: 400 },
        { word: '失', startTime: 400, endTime: 800 },
        { word: '在', startTime: 800, endTime: 1200 },
        { word: '风', startTime: 1200, endTime: 1600 },
        { word: '里', startTime: 1600, endTime: 2000 },
        { word: '的', startTime: 2000, endTime: 2400 },
        { word: '身', startTime: 2400, endTime: 2800 },
        { word: '影', startTime: 2800, endTime: 3200 },
        { word: '我', startTime: 3200, endTime: 3400 },
        { word: '再', startTime: 3400, endTime: 3500 },
        { word: '也', startTime: 3500, endTime: 3600 },
        { word: '看', startTime: 3600, endTime: 3700 },
        { word: '不', startTime: 3700, endTime: 3800 },
        { word: '见', startTime: 3800, endTime: 4200 },
        { word: '摸', startTime: 4200, endTime: 4400 },
        { word: '不', startTime: 4400, endTime: 4500 },
        { word: '着', startTime: 4500, endTime: 4600 },
        { word: '找', startTime: 4600, endTime: 4700 },
        { word: '不', startTime: 4700, endTime: 4800 },
        { word: '到', startTime: 4800, endTime: 5000 }
      ]
    },
    // 长句 - 占2行
    {
      text: '我祈祷拥有一颗透明的心灵和会流泪的眼睛',
      time: 34000,
      words: this.createWords('我祈祷拥有一颗透明的心灵和会流泪的眼睛', 34000, 42000)
    },
    // 短句 - 快速开头
    {
      text: '给我勇气',
      time: 42000,
      words: [
        { word: '给', startTime: 0, endTime: 100 },
        { word: '我', startTime: 100, endTime: 200 },
        { word: '勇', startTime: 200, endTime: 600 },
        { word: '气', startTime: 600, endTime: 1000 }
      ]
    },
    // 长句 - 占2行，慢速
    {
      text: '给我再去相信的勇气越过谎言去拥抱你哪怕遍体鳞伤',
      time: 43000,
      words: [
        { word: '给', startTime: 0, endTime: 600 },
        { word: '我', startTime: 600, endTime: 1200 },
        { word: '再', startTime: 1200, endTime: 1800 },
        { word: '去', startTime: 1800, endTime: 2400 },
        { word: '相', startTime: 2400, endTime: 3000 },
        { word: '信', startTime: 3000, endTime: 3600 },
        { word: '的', startTime: 3600, endTime: 4200 },
        { word: '勇', startTime: 4200, endTime: 4800 },
        { word: '气', startTime: 4800, endTime: 5400 },
        { word: '越', startTime: 5400, endTime: 6000 },
        { word: '过', startTime: 6000, endTime: 6600 },
        { word: '谎', startTime: 6600, endTime: 7200 },
        { word: '言', startTime: 7200, endTime: 7800 },
        { word: '去', startTime: 7800, endTime: 8400 },
        { word: '拥', startTime: 8400, endTime: 9000 },
        { word: '抱', startTime: 9000, endTime: 9600 },
        { word: '你', startTime: 9600, endTime: 10200 },
        { word: '哪', startTime: 10200, endTime: 10800 },
        { word: '怕', startTime: 10800, endTime: 11400 },
        { word: '遍', startTime: 11400, endTime: 12000 },
        { word: '体', startTime: 12000, endTime: 12600 },
        { word: '鳞', startTime: 12600, endTime: 13200 },
        { word: '伤', startTime: 13200, endTime: 14000 }
      ]
    },
    // 短句 - 慢速
    {
      text: '每当我找不到',
      time: 57000,
      words: [
        { word: '每', startTime: 0, endTime: 800 },
        { word: '当', startTime: 800, endTime: 1600 },
        { word: '我', startTime: 1600, endTime: 2400 },
        { word: '找', startTime: 2400, endTime: 3200 },
        { word: '不', startTime: 3200, endTime: 4000 },
        { word: '到', startTime: 4000, endTime: 5000 }
      ]
    },
    // 短句 - 连续超快
    {
      text: '存在的意义',
      time: 62000,
      words: [
        { word: '存', startTime: 0, endTime: 80 },
        { word: '在', startTime: 80, endTime: 160 },
        { word: '的', startTime: 160, endTime: 240 },
        { word: '意', startTime: 240, endTime: 320 },
        { word: '义', startTime: 320, endTime: 400 }
      ]
    },
    // 短句
    {
      text: '每当我迷失在黑夜里',
      time: 62500,
      words: this.createWords('每当我迷失在黑夜里', 62500, 67000)
    },
    // 长句 - 占2行，混合快慢
    {
      text: '夜空中最亮的星请指引我靠近你给我方向和希望',
      time: 67000,
      words: [
        { word: '夜', startTime: 0, endTime: 500 },
        { word: '空', startTime: 500, endTime: 1000 },
        { word: '中', startTime: 1000, endTime: 1500 },
        { word: '最', startTime: 1500, endTime: 2000 },
        { word: '亮', startTime: 2000, endTime: 2500 },
        { word: '的', startTime: 2500, endTime: 2600 },
        { word: '星', startTime: 2600, endTime: 2700 },
        { word: '请', startTime: 2700, endTime: 3200 },
        { word: '指', startTime: 3200, endTime: 3700 },
        { word: '引', startTime: 3700, endTime: 3800 },
        { word: '我', startTime: 3800, endTime: 3900 },
        { word: '靠', startTime: 3900, endTime: 4000 },
        { word: '近', startTime: 4000, endTime: 4100 },
        { word: '你', startTime: 4100, endTime: 4600 },
        { word: '给', startTime: 4600, endTime: 5100 },
        { word: '我', startTime: 5100, endTime: 5600 },
        { word: '方', startTime: 5600, endTime: 6100 },
        { word: '向', startTime: 6100, endTime: 6600 },
        { word: '和', startTime: 6600, endTime: 6700 },
        { word: '希', startTime: 6700, endTime: 6800 },
        { word: '望', startTime: 6800, endTime: 7000 }
      ]
    },
    // 短句 - 慢速结尾
    {
      text: '照亮我前行',
      time: 74000,
      words: [
        { word: '照', startTime: 0, endTime: 800 },
        { word: '亮', startTime: 800, endTime: 1600 },
        { word: '我', startTime: 1600, endTime: 2400 },
        { word: '前', startTime: 2400, endTime: 3200 },
        { word: '行', startTime: 3200, endTime: 5000 }
      ]
    },
    // 长句 - 占2行
    {
      text: '夜空中最亮的星是否知道那曾与我同行消失在风里的身影',
      time: 79000,
      words: this.createWords('夜空中最亮的星是否知道那曾与我同行消失在风里的身影', 79000, 89000)
    }
  ]

  // 当前高亮索引
  @State currentIndex: number = 0

  // 是否正在播放
  @State isPlaying: boolean = false

  // 定时器 ID
  private playTimer: number = -1

  /**
   * 创建逐字数据（不均匀速度）
   * @param text 歌词文本
   * @param lineStartTime 行起始时间
   * @param lineEndTime 行结束时间
   */
  private createWords(text: string, lineStartTime: number, lineEndTime: number): LyricWord[] {
    const words: LyricWord[] = []
    const chars = text.split('')
    const totalDuration = lineEndTime - lineStartTime

    // 为每个字生成随机权重（模拟不均匀速度）
    const weights: number[] = chars.map(() => 0.3 + Math.random() * 0.7)
    const totalWeight = weights.reduce((sum, w) => sum + w, 0)

    let currentTime = 0
    chars.forEach((char: string, index: number) => {
      const charDuration = (weights[index] / totalWeight) * totalDuration
      words.push({
        word: char,
        startTime: currentTime,
        endTime: currentTime + charDuration
      })
      currentTime += charDuration
    })

    return words
  }

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
        isPlaying: this.isPlaying,
        config: {
          enableWordByWord: true
        },
        theme: {
          normalStyle: DEFAULT_THEME.normalStyle,
          highlightStyle: DEFAULT_THEME.highlightStyle,
          sungFontColor: '#FFD700'
        },
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