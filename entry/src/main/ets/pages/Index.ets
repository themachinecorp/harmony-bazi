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
  @State private birth: BirthInput = {
    y: 1990,
    m: 6,
    d: 15,
    h: 14,
    mi: 30,
    lon: 116.41,
    tz: 8,
    gender: 'm',
    dst: false,
    unknownHour: false,
    cityIdx: 0
  }
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
      // 自愈：存档里的经度若非法（旧版输入框 bug 可能存进脏值），退回北京并要求重填
      const lonBad: boolean = !isFinite(o.lon) || o.lon < -180 || o.lon > 180
      this.birth = {
        y: o.y,
        m: o.m,
        d: o.d,
        h: o.h,
        mi: o.mi,
        lon: lonBad ? 116.41 : o.lon,
        tz: o.tz > 0 ? o.tz : 8,
        gender: o.gender,
        dst: o.dst,
        unknownHour: o.unknownHour,
        cityIdx: lonBad ? 0 : (o.cityIdx === undefined ? 0 : o.cityIdx)
      }
      if (lonBad) {
        this.editing = true
      } else {
        this.compute()
      }
    }
    this.loaded = true
  }

  compute(): void {
    const o: BirthInput = this.birth
    const c: Chart = buildChart(o)
    const spec = beijingNow()
    const f: Fortune = dailyFortune(c, spec, o.lon, 8)
    this.chart = c
    this.fortune = f
    this.years = yearList(c, spec.y - 2, spec.y + 5)
    this.editing = false
    birthStore.save(o)
  }

  onBirthChange(b: BirthInput): void {
    this.birth = b
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
              birth: this.birth,
              onChange: (b: BirthInput) => { this.onBirthChange(b) }
            })
            Button('排 盘')
              .width('100%')
              .height(44)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor(Theme.RED)
              .borderRadius(10)
              .onClick(() => { this.compute() })
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
    return spec.y.toString() + '-' + pad2(spec.m) + '-' + pad2(spec.d) + ' 周' + wd[dow]
  }
}
