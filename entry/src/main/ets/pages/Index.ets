/**
 * 今日运势 · 八字排盘（鸿蒙手机端）
 */
import { BirthInput, Chart, Fortune, YearItem, buildChart, dailyFortune, yearList, beijingNow, pad2 } from '../model/Bazi'
import { birthStore } from '../store/BirthStore'
import { InputCard } from '../components/InputCard'
import { TodayCard } from '../components/TodayCard'
import { ChartCard } from '../components/ChartCard'
import { YunCard } from '../components/YunCard'
import { Theme } from '../model/Theme'

@Entry
@Component
struct Index {
  @State private gender: string = 'm'
  @State private birthY: number = 1990
  @State private birthM: number = 6
  @State private birthD: number = 15
  @State private birthH: number = 14
  @State private birthMi: number = 30
  @State private lon: number = 116.41
  @State private lonText: string = '116.41'
  @State private cityIdx: number = 0
  @State private dst: boolean = false
  @State private unknownHour: boolean = false
  @State private chart: Chart | null = null
  @State private fortune: Fortune | null = null
  @State private years: YearItem[] = []
  @State private editing: boolean = false
  @State private loaded: boolean = false

  aboutToAppear(): void {
    this.restore()
  }

  async restore(): Promise<void> {
    const o: BirthInput | null = await birthStore.load()
    if (o !== null) {
      this.gender = o.gender
      this.birthY = o.y
      this.birthM = o.m
      this.birthD = o.d
      this.birthH = o.h
      this.birthMi = o.mi
      this.lon = o.lon
      this.lonText = o.lon.toFixed(2)
      this.dst = o.dst
      this.unknownHour = o.unknownHour
      this.compute()
    }
    this.loaded = true
  }

  compute(): void {
    const o: BirthInput = {
      y: this.birthY,
      m: this.birthM,
      d: this.birthD,
      h: this.birthH,
      mi: this.birthMi,
      lon: this.lon,
      tz: 8,
      gender: this.gender,
      dst: this.dst,
      unknownHour: this.unknownHour
    }
    const c: Chart = buildChart(o)
    const spec = beijingNow()
    const f: Fortune = dailyFortune(c, spec, o.lon, 8)
    this.chart = c
    this.fortune = f
    this.years = yearList(c, spec.y - 2, spec.y + 5)
    this.editing = false
    birthStore.save(o)
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 14 }) {
          // 标题
          Column({ space: 4 }) {
            Text('今 日 运 势')
              .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Theme.GOLD)
              .letterSpacing(6)
            Text('真太阳时排盘 · 八字 / 大运 / 流年')
              .fontSize(12).fontColor(Theme.DIM)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 4 })

          if (this.chart !== null && this.fortune !== null) {
            TodayCard({
              fortune: this.fortune as Fortune,
              chart: this.chart as Chart,
              todayText: this.todayText()
            })
            ChartCard({ chart: this.chart as Chart })
            YunCard({
              chart: this.chart as Chart,
              years: this.years,
              currentYear: beijingNow().y
            })

            if (!this.editing) {
              Button('修改生辰')
                .width('100%')
                .height(40)
                .fontSize(14)
                .fontColor(Theme.GOLD)
                .backgroundColor(Theme.CARD)
                .borderRadius(10)
                .border({ width: 1, color: Theme.LINE })
                .onClick(() => { this.editing = true })
            }
          }

          if (this.chart === null || this.editing) {
            InputCard({
              gender: $$this.gender,
              birthY: $$this.birthY,
              birthM: $$this.birthM,
              birthD: $$this.birthD,
              birthH: $$this.birthH,
              birthMi: $$this.birthMi,
              lon: $$this.lon,
              lonText: $$this.lonText,
              cityIdx: $$this.cityIdx,
              dst: $$this.dst,
              unknownHour: $$this.unknownHour,
              onCompute: () => { this.compute() }
            })
          }

          Text('算法：太阳视黄经用截断 VSOP87 计算，节气时刻误差 < 2 分钟；日柱 23:00 换日，年柱以立春为界，月柱以十二节为界。运势评分属民俗算法，仅供娱乐参考。')
            .fontSize(11).fontColor(Theme.DIM).lineHeight(17)
            .width('100%')
            .margin({ top: 6 })
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 18, bottom: 30 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  private todayText(): string {
    const spec = beijingNow()
    const wd: string[] = ['日', '一', '二', '三', '四', '五', '六']
    const dow: number = new Date(Date.now() + 8 * 3600 * 1000).getUTCDay()
    return spec.y.toString() + '-' + pad2(spec.m) + '-' + pad2(spec.d) +
      ' 周' + wd[dow]
  }
}
