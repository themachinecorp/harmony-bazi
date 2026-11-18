/**
 * 今日运势卡：环形评分 + 宜忌双列 + 逐条解读
 */
import { Chart, Fortune } from '../model/Bazi'
import { Theme } from '../model/Theme'

@Component
export struct TodayCard {
  @Prop fortune: Fortune
  @Prop chart: Chart
  @Prop todayText: string

  /** 分数从 0 涨到目标值（配合环形进度一起动） */
  @State private shown: number = 0
  @State private pulse: boolean = false

  aboutToAppear(): void {
    const target: number = this.fortune.score
    const steps: number = 18
    let i: number = 0
    const tick: () => void = (): void => {
      i += 1
      this.shown = target * i / steps
      if (i < steps) {
        setTimeout(tick, 26)
      } else {
        this.shown = target
      }
    }
    setTimeout(tick, 120)
    setTimeout(() => { this.pulse = true }, 200)
  }

  private scoreColor(): string {
    if (this.fortune.score >= 72) {
      return Theme.OK
    }
    if (this.fortune.score >= 58) {
      return Theme.GOLD
    }
    return Theme.BAD
  }

  private pillars(): string[] {
    const t: string = this.fortune.today.year.name + ' ' + this.fortune.today.month.name + ' ' +
      this.fortune.today.day.name + ' ' + this.fortune.today.hour.name
    return t.split(' ')
  }

  build() {
    Column({ space: 16 }) {
      // 标题行
      Row({ space: 8 }) {
        Text('今日运势').fontSize(15).fontWeight(FontWeight.Bold).fontColor(Theme.TEXT)
        Blank()
        Text(this.todayText).fontSize(11).fontColor(Theme.DIM)
      }
      .width('100%')

      // 今日干支
      Column({ space: 4 }) {
        Row({ space: 10 }) {
          ForEach(this.pillars(), (s: string) => {
            Text(s).fontSize(19).fontWeight(FontWeight.Medium).fontColor(Theme.TEXT)
          }, (s: string) => s)
        }
        Text('今日干支（今天这一天的，不是你的命盘）')
          .fontSize(10).fontColor(Theme.DIM)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 评分块：大数字 + 环形进度 + 元信息
      Row({ space: 16 }) {
        Column({ space: 2 }) {
          Text(Math.round(this.shown).toString())
            .fontSize(52).fontWeight(FontWeight.Bold).fontColor(this.scoreColor())
          Text(this.fortune.label)
            .fontSize(15).fontColor(this.scoreColor()).fontWeight(FontWeight.Medium)
        }
        .alignItems(HorizontalAlign.Start)

        Progress({ value: this.shown, total: 100, type: ProgressType.Ring })
          .width(74).height(74)
          .color(this.scoreColor())
          .style({ strokeWidth: 6 })
          .shadow({ radius: 14, color: this.scoreColor(), offsetY: 0 })
          .opacity(this.pulse ? 1 : 0.55)
          .animation({ duration: 1500, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate })

        Column({ space: 5 }) {
          this.meta('大运', this.fortune.curYunName.length > 0 ?
          this.fortune.curYunName + ' ' + this.fortune.curYunFrom.toFixed(1) + '–' +
          this.fortune.curYunTo.toFixed(1) + '岁' : '—')
          this.meta('节令', this.fortune.today.jiePrev.name + '后 · ' + this.fortune.today.jieNext.name + '前')
          this.meta('流年', this.fortune.today.year.name + ' ' + this.fortune.today.year.god)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding(14)
      .backgroundColor(Theme.CARD2)
      .borderRadius(Theme.R_SM)
      .border({ width: 1, color: Theme.LINE_SOFT })

      // 宜 / 忌
      Row({ space: 12 }) {
        Column({ space: 7 }) {
          Text('宜').fontSize(13).fontWeight(FontWeight.Bold).fontColor(Theme.OK)
          ForEach(this.fortune.yi, (x: string) => {
            Row({ space: 6 }) {
              Text('·').fontSize(11).fontColor(Theme.OK)
              Text(x).fontSize(12).fontColor(Theme.TEXT2).layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
          }, (x: string) => x)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 7 }) {
          Text('忌').fontSize(13).fontWeight(FontWeight.Bold).fontColor(Theme.BAD)
          ForEach(this.fortune.ji, (x: string) => {
            Row({ space: 6 }) {
              Text('·').fontSize(11).fontColor(Theme.BAD)
              Text(x).fontSize(12).fontColor(Theme.TEXT2).layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
          }, (x: string) => x)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // 解读
      Column({ space: 7 }) {
        Text('今日解读').fontSize(13).fontWeight(FontWeight.Bold).fontColor(Theme.GOLD)
        ForEach(this.fortune.notes, (x: string) => {
          Text(x).fontSize(12).fontColor(Theme.DIM).lineHeight(19)
        }, (x: string) => x)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.CARD)
    .borderRadius(Theme.R_CARD)
    .border({ width: 1, color: Theme.LINE })
  }

  @Builder
  meta(k: string, v: string) {
    Row({ space: 6 }) {
      Text(k).fontSize(11).fontColor(Theme.DIM)
      Text(v).fontSize(11).fontColor(Theme.TEXT2)
    }
    .width('100%')
  }
}
