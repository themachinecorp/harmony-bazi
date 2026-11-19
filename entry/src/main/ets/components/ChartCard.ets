/**
 * 命盘四柱（终端风）：等宽大字符四宫格 + 点选查看藏干
 */
import { Chart, Pillar } from '../model/Bazi'
import { Theme } from '../model/Theme'
import { TermPanel } from './TermPanel'

@Component
export struct ChartCard {
  @Prop chart: Chart
  /** 点柱子看藏干：-1 未选 */
  @State private sel: number = -1

  private pillars(): Pillar[] {
    return [this.chart.year, this.chart.month, this.chart.day, this.chart.hour]
  }

  private labels(): string[] {
    return ['YEAR', 'MONTH', 'DAY', 'HOUR']
  }

  private hiddenText(p: Pillar): string {
    let s: string = ''
    for (let i = 0; i < p.hidden.length; i++) {
      s += (i > 0 ? '  ' : '') + p.hidden[i].g + '(' + p.hidden[i].god + ')'
    }
    return s
  }

  build() {
    TermPanel({
      title: '02 / 命盘四柱 FOUR_PILLARS',
      status: 'DAYMASTER ' + this.chart.day.ganChar,
      content: () => {
        this.body()
      }
    })
  }

  @Builder
  private body() {
    Column({ space: 12 }) {
      Row({ space: 6 }) {
        ForEach(this.pillars(), (p: Pillar, idx: number) => {
          Column({ space: 4 }) {
            Text(this.labels()[idx])
              .fontSize(9).fontColor(Theme.DIM).fontFamily(Theme.MONO).letterSpacing(1)
            Text(p.ganChar)
              .fontSize(30).fontWeight(FontWeight.Bold).fontColor(Theme.wxColor(p.wx))
              .fontFamily(Theme.MONO)
            Text(p.zhiChar)
              .fontSize(30).fontWeight(FontWeight.Bold).fontColor(Theme.wxColor(p.zwx))
              .fontFamily(Theme.MONO)
            Text(p.god)
              .fontSize(10).fontColor(Theme.TEXT2).fontFamily(Theme.MONO)
            Column()
              .width(3).height(22).borderRadius(1)
              .backgroundColor(Theme.wxColor(p.wx))
              .shadow({ radius: 8, color: Theme.wxColor(p.wx), offsetY: 0 })
          }
          .layoutWeight(1)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.sel === idx ? '#0E1A18' : Theme.CARD2)
          .border({ width: 1, color: this.sel === idx ? Theme.GREEN : Theme.LINE_SOFT })
          .borderRadius(Theme.R_SM)
          .onClick(() => {
            this.sel = this.sel === idx ? -1 : idx
          })
          .alignItems(HorizontalAlign.Center)
        }, (p: Pillar, idx: number) => idx.toString())
      }
      .width('100%')

      if (this.sel >= 0) {
        Row({ space: 6 }) {
          Text('>' + this.labels()[this.sel] + '_HIDDEN')
            .fontSize(10).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
          Text(this.hiddenText(this.pillars()[this.sel]))
            .fontSize(10).fontColor(Theme.TEXT2).fontFamily(Theme.MONO).layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8, left: 10, right: 10 })
        .backgroundColor('#0E1A18')
        .border({ width: 1, color: Theme.GREEN })
        .borderRadius(Theme.R_SM)
      }

      Column({ space: 4 }) {
        this.row('月令 MONTH_CMD', this.chart.month.name + '（' + this.chart.month.god + '）')
        this.row('同党/异党 BALANCE', this.chart.strength.same.toFixed(1) + ' / ' +
          this.chart.strength.other.toFixed(1))
        this.row('调候 CLIMATE', this.chart.strength.tiaohou.length > 0 ? '喜' + this.chart.strength.tiaohou : '—')
        this.row('格局 GEJU', this.chart.strength.geJu)
        this.row('旺衰 SCORE', this.chart.strength.score.toString() + ' · ' + this.chart.strength.stateText)
        this.row('喜用 FAVOR', this.chart.strength.favWx.join('、') + '（' + this.chart.strength.favText + '）')
        this.row('忌神 AVOID', this.chart.strength.unfavWx.join('、') + '（' + this.chart.strength.unfavText + '）')
      }
      .width('100%')
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
