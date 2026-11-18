/**
 * 今日运势（终端风）：ASCII 进度条 + 数据读数 + 宜忌 + 解读
 */
import { Chart, Fortune } from '../model/Bazi'
import { Theme } from '../model/Theme'
import { TermPanel } from './TermPanel'

@Component
export struct TodayCard {
  @Prop fortune: Fortune
  @Prop chart: Chart
  @Prop todayText: string

  @State private shown: number = 0
  @State private blink: boolean = false

  aboutToAppear(): void {
    const target: number = this.fortune.score
    const steps: number = 20
    let i: number = 0
    const tick: () => void = (): void => {
      i += 1
      this.shown = target * i / steps
      if (i < steps) {
        setTimeout(tick, 24)
      } else {
        this.shown = target
      }
    }
    setTimeout(tick, 100)
    const bl: () => void = (): void => {
      this.blink = !this.blink
      setTimeout(bl, 520)
    }
    setTimeout(bl, 400)
  }

  private scoreColor(): string {
    if (this.fortune.score >= 72) {
      return Theme.GREEN
    }
    if (this.fortune.score >= 58) {
      return Theme.AMBER
    }
    return Theme.RED
  }

  /** ASCII 进度条：[████████░░░░] */
  private bar(): string {
    const n: number = Math.round(this.shown / 5)
    const full: string = '█'.repeat(n)
    const empty: string = '░'.repeat(20 - n)
    return '[' + full + empty + ']'
  }

  private pillars(): string[] {
    const t: string = this.fortune.today.year.name + ' ' + this.fortune.today.month.name + ' ' +
      this.fortune.today.day.name + ' ' + this.fortune.today.hour.name
    return t.split(' ')
  }

  build() {
    TermPanel({
      title: '01 / 今日运势 TODAY',
      status: this.todayText,
      content: () => {
        this.body()
      }
    })
  }

  @Builder
  private body() {
    Column({ space: 12 }) {
      // 今日干支
      Row({ space: 10 }) {
        ForEach(this.pillars(), (s: string) => {
          Text(s)
            .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Theme.GREEN)
            .fontFamily(Theme.MONO)
            .textShadow({ radius: 12, color: '#6600FF9C', offsetX: 0, offsetY: 0 })
        }, (s: string) => s)
      }
      .width('100%')
      Text('> 今日干支 GANZHI_TODAY')
        .fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO)

      // 评分
      Row({ space: 8 }) {
        Text(this.bar())
          .fontSize(16).fontColor(this.scoreColor()).fontFamily(Theme.MONO)
          .textShadow({ radius: 14, color: this.scoreColor(), offsetX: 0, offsetY: 0 })
        Text(Math.round(this.shown).toString() + '/100')
          .fontSize(16).fontWeight(FontWeight.Bold).fontColor(this.scoreColor()).fontFamily(Theme.MONO)
        Text(this.fortune.label).fontSize(14).fontColor(this.scoreColor()).fontFamily(Theme.MONO)
        if (this.blink) {
          Text('▌').fontSize(13).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
        }
      }
      .width('100%')
      .padding({ top: 10, bottom: 10, left: 10, right: 10 })
      .backgroundColor(Theme.CARD2)
      .border({ width: 1, color: Theme.LINE_SOFT })
      .borderRadius(Theme.R_SM)

      // 数据读数
      Column({ space: 4 }) {
        this.row('大运 LUCK_CYCLE', this.fortune.curYunName.length > 0 ?
          this.fortune.curYunName + ' ' + this.fortune.curYunFrom.toFixed(1) + '-' +
          this.fortune.curYunTo.toFixed(1) + 'Y' : '—')
        this.row('节令 SEASON', this.fortune.today.jiePrev.name + ' → ' + this.fortune.today.jieNext.name)
        this.row('流年 YEAR', this.fortune.today.year.name + ' ' + this.fortune.today.year.god)
        this.row('日主 DAYMASTER', this.chart.day.ganChar + ' / ' + this.chart.dayWx + ' / ' +
          this.chart.strength.stateText)
        this.row('喜用神 FAVOR', this.chart.strength.favText)
        this.row('忌神 AVOID', this.chart.strength.unfavText)
      }
      .width('100%')

      // 宜忌
      Row({ space: 12 }) {
        Column({ space: 5 }) {
          Text('+ 宜 YI').fontSize(12).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
          ForEach(this.fortune.yi, (x: string) => {
            Text('· ' + x).fontSize(11).fontColor(Theme.TEXT2).fontFamily(Theme.MONO).lineHeight(17)
          }, (x: string) => x)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 5 }) {
          Text('- 忌 JI').fontSize(12).fontColor(Theme.RED).fontFamily(Theme.MONO)
          ForEach(this.fortune.ji, (x: string) => {
            Text('· ' + x).fontSize(11).fontColor(Theme.TEXT2).fontFamily(Theme.MONO).lineHeight(17)
          }, (x: string) => x)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // 解读
      Column({ space: 5 }) {
        Text('> 解读 NOTES').fontSize(11).fontColor(Theme.CYAN).fontFamily(Theme.MONO)
        ForEach(this.fortune.notes, (x: string) => {
          Text(x).fontSize(11).fontColor(Theme.DIM).fontFamily(Theme.MONO).lineHeight(17)
        }, (x: string) => x)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }

  @Builder
  private row(k: string, v: string) {
    Row({ space: 6 }) {
      Text(k).fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).width(148)
      Text(v).fontSize(11).fontColor(Theme.TEXT).fontFamily(Theme.MONO).layoutWeight(1)
    }
    .width('100%')
  }
}
