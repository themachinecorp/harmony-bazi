/**
 * 今日概览卡：今日干支、综合评分、宜忌、解读
 */
import { Chart, Fortune, jdToLocalStr } from '../model/Bazi'
import { Theme } from '../model/Theme'

@Component
export struct TodayCard {
  @Prop fortune: Fortune
  @Prop chart: Chart
  @Prop todayText: string

  private scoreColor(): string {
    if (this.fortune.score >= 72) {
      return Theme.OK
    }
    if (this.fortune.score >= 58) {
      return Theme.GOLD
    }
    return Theme.BAD
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Text('今日概览')
          .fontSize(17).fontWeight(FontWeight.Bold).fontColor(Theme.GOLD)
        Blank()
        Text(this.todayText).fontSize(12).fontColor(Theme.DIM)
      }
      .width('100%')

      Column({ space: 4 }) {
        Text(this.fortune.today.year.name + ' ' + this.fortune.today.month.name + ' ' +
        this.fortune.today.day.name + ' ' + this.fortune.today.hour.name)
          .fontSize(20).fontColor(Theme.TEXT).fontWeight(FontWeight.Medium)
        Text('↑ 今日干支（今天这一天的，不是你的命盘）')
          .fontSize(10).fontColor(Theme.DIM)
        Text('干支纪年 ' + this.fortune.today.solarYear.toString() + ' 年　节令：' +
        this.fortune.today.jiePrev.name + ' 后 · ' + this.fortune.today.jieNext.name + ' 前')
          .fontSize(12).fontColor(Theme.DIM)
        Text('当前大运 ' + (this.fortune.curYunName.length > 0 ?
          this.fortune.curYunName + '　' + this.fortune.curYunFrom.toString() + '–' + this.fortune.curYunTo.toString() + ' 岁' : '—'))
          .fontSize(12).fontColor(Theme.DIM)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 评分
      Row({ space: 14 }) {
        Text(this.fortune.score.toString())
          .fontSize(52)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.scoreColor())
        Column({ space: 4 }) {
          Text(this.fortune.label)
            .fontSize(20).fontColor(this.scoreColor()).fontWeight(FontWeight.Medium)
          Progress({ value: this.fortune.score, total: 100, type: ProgressType.Linear })
            .width('100%')
            .height(6)
            .color(this.scoreColor())
            .backgroundColor(Theme.CARD2)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // 标签
      Flex({ wrap: FlexWrap.Wrap }) {
        Text('日主 ' + this.chart.day.ganChar + '（' + this.chart.dayWx + '）')
          .fontSize(11).fontColor(Theme.DIM).padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(Theme.CARD2).borderRadius(10).border({ width: 1, color: Theme.LINE }).margin(4)
        Text(this.chart.strength.stateText)
          .fontSize(11).fontColor(Theme.DIM).padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(Theme.CARD2).borderRadius(10).border({ width: 1, color: Theme.LINE }).margin(4)
        Text('喜 ' + this.chart.strength.favText)
          .fontSize(11).fontColor(Theme.GOLD).padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(Theme.CARD2).borderRadius(10).border({ width: 1, color: Theme.LINE }).margin(4)
        Text('忌 ' + this.chart.strength.unfavText)
          .fontSize(11).fontColor(Theme.DIM).padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(Theme.CARD2).borderRadius(10).border({ width: 1, color: Theme.LINE }).margin(4)
        Text('流年 ' + this.fortune.today.year.name + ' ' + this.fortune.today.year.god)
          .fontSize(11).fontColor(Theme.DIM).padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(Theme.CARD2).borderRadius(10).border({ width: 1, color: Theme.LINE }).margin(4)
        Text('今日 ' + this.fortune.today.day.name + ' ' + this.fortune.today.day.god)
          .fontSize(11).fontColor(Theme.DIM).padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(Theme.CARD2).borderRadius(10).border({ width: 1, color: Theme.LINE }).margin(4)
      }
      .width('100%')

      // 宜 / 忌
      Row({ space: 12 }) {
        Column({ space: 6 }) {
          Text('宜').fontSize(14).fontColor(Theme.OK).fontWeight(FontWeight.Medium)
          ForEach(this.fortune.yi, (x: string) => {
            Text('· ' + x).fontSize(12).fontColor(Theme.TEXT)
          }, (x: string) => x)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 6 }) {
          Text('忌').fontSize(14).fontColor(Theme.BAD).fontWeight(FontWeight.Medium)
          ForEach(this.fortune.ji, (x: string) => {
            Text('· ' + x).fontSize(12).fontColor(Theme.TEXT)
          }, (x: string) => x)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // 解读
      Column({ space: 4 }) {
        Text('今日解读').fontSize(14).fontColor(Theme.GOLD).fontWeight(FontWeight.Medium)
        ForEach(this.fortune.notes, (x: string) => {
          Text('· ' + x).fontSize(12).fontColor(Theme.DIM)
        }, (x: string) => x)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.CARD)
    .borderRadius(14)
    .border({ width: 1, color: Theme.LINE })
  }
}
