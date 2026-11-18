/**
 * 大运 / 流年 / 真太阳时（终端风）：表格化读数
 */
import { Chart, YearItem, YunStep } from '../model/Bazi'
import { Theme } from '../model/Theme'
import { TermPanel } from './TermPanel'

@Component
export struct YunCard {
  @Prop chart: Chart
  @Prop years: YearItem[]
  @Prop currentYear: number

  private isCurrent(from: number, to: number): boolean {
    const age: number = this.ageNow()
    return age >= from && age < to
  }

  private ageNow(): number {
    const now: Date = new Date()
    return (now.getFullYear() - this.chart.input.y) + (now.getMonth() + 1 - this.chart.input.m) / 12
  }

  private relColor(rel: string): string {
    if (rel.indexOf('冲') >= 0 || rel.indexOf('害') >= 0) {
      return Theme.RED
    }
    if (rel.indexOf('合') >= 0) {
      return Theme.GREEN
    }
    if (rel.indexOf('刑') >= 0) {
      return Theme.AMBER
    }
    return Theme.DIM
  }

  build() {
    TermPanel({
      title: '03 / 大运流年 & 真太阳时',
      status: this.chart.yun.dirText,
      content: () => {
        this.body()
      }
    })
  }

  @Builder
  private body() {
    Column({ space: 14 }) {
      // 大运表
      Column({ space: 6 }) {
        Text('> 大运 LUCK_CYCLE').fontSize(11).fontColor(Theme.CYAN).fontFamily(Theme.MONO)
        Row({ space: 6 }) {
          Text('干支 GANZHI').fontSize(9).fontColor(Theme.DIM).fontFamily(Theme.MONO).width(62)
          Text('十神 GOD').fontSize(9).fontColor(Theme.DIM).fontFamily(Theme.MONO).width(46)
          Text('五行 WX').fontSize(9).fontColor(Theme.DIM).fontFamily(Theme.MONO).width(52)
          Text('年龄 AGE').fontSize(9).fontColor(Theme.DIM).fontFamily(Theme.MONO).layoutWeight(1)
          Text('年份 YEAR').fontSize(9).fontColor(Theme.DIM).fontFamily(Theme.MONO)
        }
        .width('100%')
        .padding({ top: 4, bottom: 4 })
        .border({ width: { bottom: 1 }, color: Theme.LINE })

        ForEach(this.chart.yun.list, (y: YunStep) => {
          Row({ space: 6 }) {
            Text((this.isCurrent(y.ageFrom, y.ageTo) ? '▶ ' : '  ') + y.name)
              .fontSize(15).fontWeight(FontWeight.Bold).fontFamily(Theme.MONO)
              .fontColor(this.isCurrent(y.ageFrom, y.ageTo) ? Theme.GREEN : Theme.TEXT).width(62)
            Text(y.god).fontSize(10).fontColor(Theme.TEXT2).fontFamily(Theme.MONO).width(46)
            Text(y.wx + '/' + y.zwx).fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).width(52)
            Text(y.ageFrom.toFixed(0) + '-' + y.ageTo.toFixed(0) + 'Y')
              .fontSize(10).fontColor(Theme.TEXT2).fontFamily(Theme.MONO).layoutWeight(1)
            Text(y.yearFrom.toString() + '-' + y.yearTo.toString())
              .fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO)
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
          .backgroundColor(this.isCurrent(y.ageFrom, y.ageTo) ? '#0E1A18' : '#00000000')
          .border({ width: { bottom: 1 }, color: Theme.LINE_SOFT })
        }, (y: YunStep) => y.name)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 流年表
      Column({ space: 6 }) {
        Text('> 流年 YEAR_STREAM').fontSize(11).fontColor(Theme.CYAN).fontFamily(Theme.MONO)
        ForEach(this.years, (y: YearItem) => {
          Row({ space: 6 }) {
            Text(y.year.toString()).fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).width(40)
            Text(y.name).fontSize(14).fontFamily(Theme.MONO)
              .fontColor(y.year === this.currentYear ? Theme.GREEN : Theme.TEXT)
              .fontWeight(y.year === this.currentYear ? FontWeight.Bold : FontWeight.Normal).width(52)
            Text(y.god).fontSize(10).fontColor(Theme.TEXT2).fontFamily(Theme.MONO).width(44)
            Text(y.rel).fontSize(10).fontColor(this.relColor(y.rel)).fontFamily(Theme.MONO).layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 5, bottom: 5 })
          .backgroundColor(y.year === this.currentYear ? '#0E1A18' : '#00000000')
        }, (y: YearItem) => y.year.toString())
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 真太阳时
      Column({ space: 6 }) {
        Text('> 真太阳时 TRUE_SOLAR').fontSize(11).fontColor(Theme.CYAN).fontFamily(Theme.MONO)
        this.row('钟表时间 CLOCK', this.chart.solar.clock + ' (UTC+8)')
        this.row('出生地经度 LONGITUDE', this.chart.input.lon.toFixed(2) + 'E')
        this.row('经度时差 LON_DIFF', (this.chart.solar.lonAdjMin >= 0 ? '+' : '') +
          this.chart.solar.lonAdjMin.toFixed(1) + ' min')
        this.row('均时差 EOT', (this.chart.solar.eotMin >= 0 ? '+' : '') +
          this.chart.solar.eotMin.toFixed(1) + ' min')
        Row({ space: 6 }) {
          Text('▶ 真太阳时 TRUE_SOLAR').fontSize(11).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
          Text(this.chart.solar.trueStr).fontSize(14).fontWeight(FontWeight.Bold)
            .fontColor(Theme.GREEN).fontFamily(Theme.MONO).layoutWeight(1)
            .textShadow({ radius: 12, color: '#6600FF9C', offsetX: 0, offsetY: 0 })
        }
        .width('100%')
        .padding({ top: 10, bottom: 10, left: 10, right: 10 })
        .backgroundColor('#0E1A18')
        .border({ width: 1, color: Theme.GREEN })
        .borderRadius(Theme.R_SM)
        this.row('所处节气 JIEQI', this.chart.jiePrev.name + ' → ' + this.chart.jieNext.name)
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
