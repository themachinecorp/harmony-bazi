/**
 * 命盘四柱卡：年月日时四柱 + 十神 + 藏干 + 身强弱
 */
import { Chart, Pillar } from '../model/Bazi'
import { Theme } from '../model/Theme'

@Component
export struct ChartCard {
  @Prop chart: Chart

  private pillars(): Pillar[] {
    return [this.chart.year, this.chart.month, this.chart.day, this.chart.hour]
  }

  private header(): string[] {
    return ['年柱', '月柱', '日柱', '时柱']
  }

  private hiddenText(p: Pillar): string {
    let s: string = ''
    for (let i = 0; i < p.hidden.length; i++) {
      s += (i > 0 ? ' ' : '') + p.hidden[i].g + '(' + p.hidden[i].god + ')'
    }
    return s
  }

  @Builder
  cell(text: string, big: boolean) {
    Text(text)
      .fontSize(big ? 22 : 13)
      .fontColor(big ? Theme.TEXT : Theme.DIM)
      .fontWeight(big ? FontWeight.Medium : FontWeight.Normal)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
  }

  build() {
    Column({ space: 12 }) {
      Text('命盘四柱')
        .fontSize(17).fontWeight(FontWeight.Bold).fontColor(Theme.GOLD)
        .width('100%')

      Row() {
        this.cell('', false)
        ForEach(this.header(), (h: string) => {
          this.cell(h, false)
        }, (h: string) => h)
      }
      .width('100%')

      Row() {
        this.cell('', false)
        ForEach(this.pillars(), (p: Pillar) => {
          this.cell(p.name, true)
        }, (p: Pillar, idx: number) => idx.toString())
      }
      .width('100%')

      Row() {
        this.cell('', false)
        ForEach(this.pillars(), (p: Pillar) => {
          this.cell(p.god, false)
        }, (p: Pillar, idx: number) => idx.toString())
      }
      .width('100%')

      Row() {
        this.cell('', false)
        ForEach(this.pillars(), (p: Pillar) => {
          this.cell(p.wx + ' / ' + p.zwx, false)
        }, (p: Pillar, idx: number) => idx.toString())
      }
      .width('100%')

      Row() {
        this.cell('', false)
        ForEach(this.pillars(), (p: Pillar) => {
          this.cell(this.hiddenText(p), false)
        }, (p: Pillar, idx: number) => idx.toString())
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Column({ space: 8 }) {
        this.kv('日主', this.chart.day.ganChar + ' ' + this.chart.dayWx)
        this.kv('身强/身弱', this.chart.strength.stateText + '（同党 ' + this.chart.strength.same.toString() +
          ' / 异党 ' + this.chart.strength.other.toString() + '）')
        this.kv('喜用神', this.chart.strength.favText)
        this.kv('忌神', this.chart.strength.unfavText)
        this.kv('调候', this.chart.strength.tiaohou.length > 0 ? '喜' + this.chart.strength.tiaohou : '—')
        this.kv('月令', this.chart.month.name + '（' + this.chart.month.god + '）')
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

  @Builder
  kv(k: string, v: string) {
    Row() {
      Text(k).fontSize(13).fontColor(Theme.DIM).width(84)
      Text(v).fontSize(13).fontColor(Theme.TEXT).layoutWeight(1)
    }
    .width('100%')
  }
}
