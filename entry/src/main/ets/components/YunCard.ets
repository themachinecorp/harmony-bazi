/**
 * 大运 / 流年 / 真太阳时明细
 */
import { Chart, YearItem, YunStep } from '../model/Bazi'
import { Theme } from '../model/Theme'

@Component
export struct YunCard {
  @Prop chart: Chart
  @Prop years: YearItem[]
  @Prop currentYear: number

  build() {
    Column({ space: 12 }) {
      // 大运
      Text('大运')
        .fontSize(17).fontWeight(FontWeight.Bold).fontColor(Theme.GOLD)
        .width('100%')
      Text(this.chart.yun.dirText + '　距节 ' + this.chart.yun.days.toFixed(2) + ' 天　起运 ' +
      this.chart.yun.startText + '（约 ' + this.chart.yun.startAge.toFixed(1) + ' 岁）　交运 ' + this.chart.yun.qiuYun)
        .fontSize(12).fontColor(Theme.DIM)
        .width('100%')

      ForEach(this.chart.yun.list, (y: YunStep) => {
        Row({ space: 8 }) {
          Text(y.name)
            .fontSize(18).fontColor(this.isCurrent(y.ageFrom, y.ageTo) ? Theme.GOLD : Theme.TEXT)
            .fontWeight(FontWeight.Medium)
            .width(62)
          Text(y.god).fontSize(12).fontColor(Theme.DIM).width(40)
          Text(y.wx + '/' + y.zwx).fontSize(12).fontColor(Theme.DIM).width(56)
          Text(y.ageFrom.toFixed(1) + '–' + y.ageTo.toFixed(1) + '岁')
            .fontSize(12).fontColor(Theme.DIM).layoutWeight(1)
          Text(y.yearFrom.toString() + '–' + y.yearTo.toString())
            .fontSize(12).fontColor(Theme.DIM)
          if (this.isCurrent(y.ageFrom, y.ageTo)) {
            Text('当前').fontSize(10).fontColor(Theme.RED)
              .padding({ left: 5, right: 5, top: 1, bottom: 1 })
              .backgroundColor(Theme.CARD2).borderRadius(6)
          }
        }
        .width('100%')
        .padding({ top: 7, bottom: 7 })
        .border({ width: { bottom: 1 }, color: Theme.LINE })
      }, (y: YunStep) => y.name)

      // 流年
      Text('流年')
        .fontSize(17).fontWeight(FontWeight.Bold).fontColor(Theme.GOLD)
        .width('100%')
        .margin({ top: 10 })
      ForEach(this.years, (y: YearItem) => {
        Row({ space: 10 }) {
          Text(y.year.toString()).fontSize(13).fontColor(Theme.DIM).width(48)
          Text(y.name).fontSize(16).fontColor(y.year === this.currentYear ? Theme.GOLD : Theme.TEXT)
            .fontWeight(FontWeight.Medium).width(56)
          Text(y.god).fontSize(12).fontColor(Theme.DIM).width(44)
          Text(y.rel).fontSize(12).fontColor(Theme.DIM)
        }
        .width('100%')
        .padding({ top: 6, bottom: 6 })
        .border({ width: { bottom: 1 }, color: Theme.LINE })
      }, (y: YearItem) => y.year.toString())

      // 真太阳时
      Text('真太阳时换算')
        .fontSize(17).fontWeight(FontWeight.Bold).fontColor(Theme.GOLD)
        .width('100%')
        .margin({ top: 10 })
      this.kv('钟表时间', this.chart.solar.clock + '（UTC+8）')
      this.kv('出生地经度', this.chart.input.lon.toFixed(2) + '°E（东经为正）')
      this.kv('经度时差', (this.chart.solar.lonAdjMin >= 0 ? '+' : '') +
        this.chart.solar.lonAdjMin.toFixed(1) + ' 分钟')
      this.kv('均时差', (this.chart.solar.eotMin >= 0 ? '+' : '') + this.chart.solar.eotMin.toFixed(1) + ' 分钟')
      this.kv('平太阳时', this.chart.solar.plain)
      this.kv('真太阳时', this.chart.solar.trueStr)
      this.kv('所处节气', this.chart.jiePrev.name + ' → ' + this.chart.jieNext.name)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.CARD)
    .borderRadius(14)
    .border({ width: 1, color: Theme.LINE })
  }

  private isCurrent(from: number, to: number): boolean {
    return this.chart.yun.list.length > 0 && this.ageNow() >= from && this.ageNow() < to
  }

  private ageNow(): number {
    const now: Date = new Date()
    return (now.getFullYear() - this.chart.input.y) + (now.getMonth() + 1 - this.chart.input.m) / 12
  }

  @Builder
  private kv(k: string, v: string) {
    Row() {
      Text(k).fontSize(13).fontColor(Theme.DIM).width(84)
      Text(v).fontSize(13).fontColor(Theme.TEXT).layoutWeight(1)
    }
    .width('100%')
  }
}
