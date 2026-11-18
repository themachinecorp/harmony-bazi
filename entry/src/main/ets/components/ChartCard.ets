/**
 * 命盘四柱卡：四宫格（每柱一个方块，天干地支按五行着色），日柱为主气高亮
 */
import { Chart, Pillar } from '../model/Bazi'
import { Theme } from '../model/Theme'

@Component
export struct ChartCard {
  @Prop chart: Chart

  private pillars(): Pillar[] {
    return [this.chart.year, this.chart.month, this.chart.day, this.chart.hour]
  }

  private labels(): string[] {
    return ['年柱', '月柱', '日柱', '时柱']
  }

  build() {
    Column({ space: 14 }) {
      Row({ space: 8 }) {
        Text('命盘四柱').fontSize(15).fontWeight(FontWeight.Bold).fontColor(Theme.TEXT)
        Text('你的本命四柱').fontSize(11).fontColor(Theme.DIM)
        Blank()
      }
      .width('100%')

      // 四宫格
      Row({ space: 8 }) {
        ForEach(this.pillars(), (p: Pillar, idx: number) => {
          Column({ space: 4 }) {
            Text(this.labels()[idx])
              .fontSize(11).fontColor(Theme.GOLD_DIM)
            Text(p.ganChar)
              .fontSize(30).fontWeight(FontWeight.Bold)
              .fontColor(Theme.wxColor(p.wx))
            Text(p.zhiChar)
              .fontSize(30).fontWeight(FontWeight.Bold)
              .fontColor(Theme.wxColor(p.zwx))
            Text(p.god)
              .fontSize(11).fontColor(Theme.TEXT2)
            Row()
              .width(26).height(3).borderRadius(2)
              .backgroundColor(Theme.wxColor(p.wx))
          }
          .layoutWeight(1)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(idx === 2 ? '#1B1410' : Theme.CARD2)
          .borderRadius(Theme.R_SM)
          .border({ width: 1, color: idx === 2 ? Theme.RED_SOFT : Theme.LINE_SOFT })
          .alignItems(HorizontalAlign.Center)
        }, (p: Pillar, idx: number) => idx.toString())
      }
      .width('100%')

      // 日主与喜忌：胶囊标签
      Flex({ wrap: FlexWrap.Wrap }) {
        this.pill('日主 ' + this.chart.day.ganChar + ' · ' + this.chart.dayWx, Theme.TEXT, Theme.LINE)
        this.pill(this.chart.strength.stateText, Theme.GOLD, Theme.GOLD_DIM)
        this.pill('喜 ' + this.chart.strength.favText, Theme.OK, Theme.LINE)
        this.pill('忌 ' + this.chart.strength.unfavText, Theme.DIM, Theme.LINE)
      }
      .width('100%')

      // 明细行
      Column({ space: 0 }) {
        this.kv('月令', this.chart.month.name + '（' + this.chart.month.god + '）')
        this.kv('同党 / 异党', this.chart.strength.same.toFixed(1) + ' / ' + this.chart.strength.other.toFixed(1))
        this.kv('调候', this.chart.strength.tiaohou.length > 0 ? '喜' + this.chart.strength.tiaohou : '—')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.CARD)
    .borderRadius(Theme.R_CARD)
    .border({ width: 1, color: Theme.LINE })
  }

  @Builder
  pill(text: string, color: string, borderColor: string) {
    Text(text)
      .fontSize(11).fontColor(color)
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .backgroundColor(Theme.CARD2)
      .borderRadius(Theme.R_PILL)
      .border({ width: 1, color: borderColor })
      .margin({ right: 6, top: 6 })
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
