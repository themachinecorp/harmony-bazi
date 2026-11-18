/**
 * 大运（横向滑卡）/ 流年（标签网格）/ 真太阳时（算式式展示）
 */
import { Chart, YearItem, YunStep } from '../model/Bazi'
import { Theme } from '../model/Theme'

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
      return Theme.BAD
    }
    if (rel.indexOf('合') >= 0) {
      return Theme.OK
    }
    if (rel.indexOf('刑') >= 0) {
      return Theme.GOLD
    }
    return Theme.DIM
  }

  build() {
    Column({ space: 16 }) {
      // 大运
      Column({ space: 10 }) {
        Row({ space: 8 }) {
          Text('大运').fontSize(15).fontWeight(FontWeight.Bold).fontColor(Theme.TEXT)
          Text(this.chart.yun.dirText + ' · ' + this.chart.yun.startText + '起运')
            .fontSize(11).fontColor(Theme.DIM)
          Blank()
        }
        .width('100%')

        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.chart.yun.list, (y: YunStep) => {
              Column({ space: 6 }) {
                Text(y.name)
                  .fontSize(20).fontWeight(FontWeight.Bold)
                  .fontColor(this.isCurrent(y.ageFrom, y.ageTo) ? Theme.GOLD : Theme.TEXT)
                Text(y.god).fontSize(11).fontColor(Theme.TEXT2)
                Text(y.wx + '·' + y.zwx).fontSize(10).fontColor(Theme.DIM)
                Text(y.ageFrom.toFixed(0) + '–' + y.ageTo.toFixed(0) + '岁')
                  .fontSize(10).fontColor(this.isCurrent(y.ageFrom, y.ageTo) ? Theme.GOLD : Theme.DIM)
                if (this.isCurrent(y.ageFrom, y.ageTo)) {
                  Text('当前').fontSize(9).fontColor(Theme.RED)
                }
              }
              .width(104)
              .padding({ top: 12, bottom: 12 })
              .backgroundColor(this.isCurrent(y.ageFrom, y.ageTo) ? '#1B1410' : Theme.CARD2)
              .borderRadius(Theme.R_SM)
              .border({ width: 1, color: this.isCurrent(y.ageFrom, y.ageTo) ? Theme.GOLD_DIM : Theme.LINE_SOFT })
              .alignItems(HorizontalAlign.Center)
            }, (y: YunStep) => y.name)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 流年
      Column({ space: 10 }) {
        Row({ space: 8 }) {
          Text('流年').fontSize(15).fontWeight(FontWeight.Bold).fontColor(Theme.TEXT)
          Text('与日支的关系').fontSize(11).fontColor(Theme.DIM)
          Blank()
        }
        .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.years, (y: YearItem) => {
            Column({ space: 3 }) {
              Text(y.year.toString()).fontSize(10).fontColor(Theme.DIM)
              Text(y.name).fontSize(16).fontWeight(FontWeight.Medium)
                .fontColor(y.year === this.currentYear ? Theme.GOLD : Theme.TEXT)
              Text(y.rel).fontSize(9).fontColor(this.relColor(y.rel))
            }
            .width('19%')
            .padding({ top: 8, bottom: 8 })
            .margin({ right: 2, bottom: 8 })
            .backgroundColor(y.year === this.currentYear ? '#1B1410' : Theme.CARD2)
            .borderRadius(Theme.R_SM)
            .border({ width: 1, color: y.year === this.currentYear ? Theme.GOLD_DIM : Theme.LINE_SOFT })
            .alignItems(HorizontalAlign.Center)
          }, (y: YearItem) => y.year.toString())
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 真太阳时：算式
      Column({ space: 10 }) {
        Row({ space: 8 }) {
          Text('真太阳时换算').fontSize(15).fontWeight(FontWeight.Bold).fontColor(Theme.TEXT)
          Blank()
        }
        .width('100%')

        Column({ space: 0 }) {
          this.kv('钟表时间', this.chart.solar.clock + '（UTC+8）')
          this.kv('出生地经度', this.chart.input.lon.toFixed(2) + '°E（东经为正）')
          this.kv('经度时差', (this.chart.solar.lonAdjMin >= 0 ? '+' : '') +
          this.chart.solar.lonAdjMin.toFixed(1) + ' 分钟')
          this.kv('均时差', (this.chart.solar.eotMin >= 0 ? '+' : '') +
          this.chart.solar.eotMin.toFixed(1) + ' 分钟')
        }
        .width('100%')

        // 换算结果
        Row({ space: 10 }) {
          Text('＝').fontSize(16).fontColor(Theme.GOLD)
          Column({ space: 3 }) {
            Text('真太阳时').fontSize(11).fontColor(Theme.DIM)
            Text(this.chart.solar.trueStr).fontSize(17).fontWeight(FontWeight.Bold).fontColor(Theme.GOLD)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#15130E')
        .borderRadius(Theme.R_SM)
        .border({ width: 1, color: Theme.GOLD_DIM })

        this.kv('所处节气', this.chart.jiePrev.name + ' → ' + this.chart.jieNext.name)
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
  kv(k: string, v: string) {
    Row() {
      Text(k).fontSize(12).fontColor(Theme.DIM).width(96)
      Text(v).fontSize(13).fontColor(Theme.TEXT2).layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 9, bottom: 9 })
    .border({ width: { bottom: 1 }, color: Theme.LINE_SOFT })
  }
}
