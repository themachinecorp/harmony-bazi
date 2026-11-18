/**
 * 命盘四柱卡：四宫格（每柱一个方块，天干地支按五行着色），日柱为主气高亮
 */
import { Chart, Pillar } from '../model/Bazi'
import { Theme } from '../model/Theme'

@Component
export struct ChartCard {
  @Prop chart: Chart
  /** 点柱子看藏干：-1 未选 */
  @State private sel: number = -1
  /** 翻牌入场开关 */
  @State private flipped: boolean = false

  aboutToAppear(): void {
    setTimeout(() => { this.flipped = true }, 60)
  }

  private pillars(): Pillar[] {
    return [this.chart.year, this.chart.month, this.chart.day, this.chart.hour]
  }

  /** 藏干文本：戊(正印) 辛(比肩) 丁(七杀) */
  private hiddenText(p: Pillar): string {
    let s: string = ''
    for (let i = 0; i < p.hidden.length; i++) {
      s += (i > 0 ? '  ' : '') + p.hidden[i].g + '(' + p.hidden[i].god + ')'
    }
    return s
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
            Column()
              .width(3).height(26).borderRadius(2)
              .backgroundColor(Theme.wxColor(p.wx))
              .shadow({ radius: 10, color: Theme.wxColor(p.wx), offsetY: 0 })
          }
          .layoutWeight(1)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.sel === idx ? '#221A10' : (idx === 2 ? '#1B1410' : Theme.CARD2))
          .borderRadius(Theme.R_SM)
          .border({
            width: this.sel === idx ? 1.6 : 1,
            color: this.sel === idx ? Theme.GOLD : (idx === 2 ? Theme.RED_SOFT : Theme.LINE_SOFT)
          })
          .scale({ x: this.sel === idx ? 1.06 : 1, y: this.sel === idx ? 1.06 : 1 })
          .rotate({
            angle: this.flipped ? 0 : 92,
            x: 0,
            y: 1,
            z: 0,
            centerX: '50%',
            centerY: '50%',
            perspective: 600
          })
          .opacity(this.flipped ? 1 : 0)
          .shadow({
            radius: this.sel === idx ? 16 : 0,
            color: '#66D9B36C',
            offsetY: 4
          })
          .animation({ duration: 200, curve: Curve.EaseOut })
          .onClick(() => {
            this.sel = this.sel === idx ? -1 : idx
            this.getUIContext().getPromptAction().showToast({
              message: '第 ' + (idx + 1) + ' 柱：' + p.name + '（' + p.god + '）'
            })
          })
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

      // 点柱子后的明细
      if (this.sel >= 0) {
        Row({ space: 8 }) {
          Text(this.labels()[this.sel] + ' 藏干').fontSize(11).fontColor(Theme.GOLD)
          Text(this.hiddenText(this.pillars()[this.sel])).fontSize(11).fontColor(Theme.TEXT2)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8, left: 10, right: 10 })
        .backgroundColor('#1D1609')
        .borderRadius(Theme.R_SM)
        .border({ width: 1, color: Theme.GOLD_DIM })
        .animation({ duration: 220, curve: Curve.EaseOut })
      }

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
