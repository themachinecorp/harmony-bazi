/**
 * 结果页：今日概览 / 命盘四柱 / 大运流年 / 真太阳时；左上角返回可重新输入
 */
import { BirthInput, FormData, Chart, Fortune, YearItem, buildChart, dailyFortune, yearList, beijingNow, pad2, formToBirth } from '../model/Bazi'
import { birthStore } from '../store/BirthStore'
import { TodayCard } from '../components/TodayCard'
import { ChartCard } from '../components/ChartCard'
import { YunCard } from '../components/YunCard'
import { CompassWheel } from '../components/CompassWheel'
import { Theme } from '../model/Theme'

@Entry
@Component
struct Result {
  @State private chart: Chart | null = null
  @State private fortune: Fortune | null = null
  @State private years: YearItem[] = []
  @State private summary: string = ''
  /** 入场动画开关 */
  @State private entered: boolean = false
  /** 背景光斑漂移开关 */
  @State private glow: boolean = false
  @State private cursor: boolean = false

  aboutToAppear(): void {
    setTimeout(() => { this.glow = true }, 120)
    const bl: () => void = (): void => {
      this.cursor = !this.cursor
      setTimeout(bl, 520)
    }
    setTimeout(bl, 300)
    this.load()
  }

  onPageShow(): void {
    this.load()
  }

  /** 返回时清空缓存，避免下次进来残留旧结果 */
  onPageHide(): void {
    this.chart = null
    this.fortune = null
    this.years = []
    this.summary = ''
  }

  async load(): Promise<void> {
    // 每次进入都重新取数并重算，杜绝显示上一次的旧结果
    this.chart = null
    this.fortune = null
    this.years = []
    let fd: FormData | null = birthStore.getQueried()
    if (fd === null) {
      fd = await birthStore.load()
    }
    if (fd === null) {
      this.getUIContext().getRouter().back()
      return
    }
    const parsed: BirthInput | null = formToBirth(fd)
    if (parsed === null) {
      this.getUIContext().getRouter().back()
      return
    }
    const o: BirthInput = parsed
    const c: Chart = buildChart(o)
    const spec = beijingNow()
    const ft: Fortune = dailyFortune(c, spec, o.lon, 8)
    this.chart = c
    this.fortune = ft
    this.years = yearList(c, spec.y - 2, spec.y + 5)
    this.summary = fd.dateStr + ' ' + fd.timeStr + '　经度 ' + fd.lonStr + '°E　真太阳时 ' +
      c.solar.trueStr.substring(0, 16)
    setTimeout(() => { this.entered = true }, 40)
  }

  /** 返回录入页：先打标记，让录入页回填最近一次查询的信息 */
  private goBack(): void {
    birthStore.markReturned()
    this.getUIContext().getRouter().back()
  }

  /** 扫描线行数（每 3px 一条） */
  private scanlines(): number[] {
    const out: number[] = []
    for (let i = 0; i < 220; i++) {
      out.push(i)
    }
    return out
  }

  private chartText(): string {
    const c: Chart = this.chart as Chart
    return c.year.name.substring(0, 1) + ''
  }

  private chartTime(): string {
    const c: Chart = this.chart as Chart
    return c.day.name + ''
  }

  private pillarsText(): string {
    const c: Chart = this.chart as Chart
    return c.year.name + ' ' + c.month.name + ' ' + c.day.name + ' ' + c.hour.name
  }

  private pillarsDetail(): string {
    const c: Chart = this.chart as Chart
    return c.year.name + '年 · ' + c.month.name + '月 · ' + c.day.name + '日 · ' + c.hour.name + '时'
  }

  private todayText(): string {
    const spec = beijingNow()
    const wd: string[] = ['日', '一', '二', '三', '四', '五', '六']
    const dow: number = new Date(Date.now() + 8 * 3600 * 1000).getUTCDay()
    return spec.y.toString() + '-' + pad2(spec.m) + '-' + pad2(spec.d) + ' 周' + wd[dow]
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景光斑（大半径模糊，缓慢往复漂移）
      Column()
        .width(280).height(280).borderRadius(140)
        .backgroundColor('#26D9B36C')
        .blur(80)
        .translate({ x: this.glow ? -60 : -110, y: this.glow ? -40 : -90 })
        .opacity(this.glow ? 0.9 : 0.5)
        .animation({ duration: 5600, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate })
      Column()
        .width(240).height(240).borderRadius(120)
        .backgroundColor('#1FC2410C')
        .blur(90)
        .translate({ x: this.glow ? 210 : 260, y: this.glow ? 470 : 520 })
        .opacity(this.glow ? 0.7 : 0.35)
        .animation({ duration: 6800, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate })

      // 扫描线（细线堆叠，不依赖图片平铺 API）
      Column({ space: 2 }) {
        ForEach(this.scanlines(), (i: number) => {
          Row()
            .width('100%').height(1)
            .backgroundColor('#0AFF9C')
            .opacity(0.05)
        }, (i: number) => i.toString())
      }
      .width('100%')
      .hitTestBehavior(HitTestMode.None)

      Column() {
      // 顶栏：返回 + 标题 + 生辰摘要
      Row({ space: 10 }) {
        Text('‹')
          .fontSize(28).fontColor(Theme.GREEN)
          .width(26)
          .onClick(() => { this.goBack() })
        Column({ space: 2 }) {
          Text('时辰 // BAZI_ENGINE').fontSize(16).fontWeight(FontWeight.Bold)
            .fontColor(Theme.GREEN).fontFamily(Theme.MONO).letterSpacing(1)
          Text(this.summary).fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 14, bottom: 8 })
      Row().width('100%').height(1).backgroundColor(Theme.LINE)

      if (this.chart !== null && this.fortune !== null) {
        Scroll() {
          Column({ space: 14 }) {
            // 命盘在前：先看自己的八字，再看今天运势（避免把「今日干支」当成命盘）
            // 终端 banner
            Column({ space: 8 }) {
              Text('$ bazi --chart --date ' + this.chartText() + ' --time ' + this.chartTime())
                .fontSize(10).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
              Row({ space: 8 }) {
                Text(this.pillarsText())
                  .fontSize(22).fontWeight(FontWeight.Bold).fontColor(Theme.GREEN)
                  .fontFamily(Theme.MONO).letterSpacing(4)
                  .textShadow({ radius: 16, color: '#7700FF9C', offsetX: 0, offsetY: 0 })
                if (this.cursor) {
                  Text('▌').fontSize(20).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
                }
              }
              .width('100%')
              Row({ space: 10 }) {
                Text('CALC: VSOP87').fontSize(9).fontColor(Theme.DIM).fontFamily(Theme.MONO)
                Text('SOLAR: TRUE').fontSize(9).fontColor(Theme.DIM).fontFamily(Theme.MONO)
                Text('JIEQI: 24').fontSize(9).fontColor(Theme.DIM).fontFamily(Theme.MONO)
                Text('STATUS: OK').fontSize(9).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
              }
              .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Theme.CARD2)
            .border({ width: 1, color: Theme.GREEN })
            .borderRadius(Theme.R_CARD)
            .opacity(this.entered ? 1 : 0)
            .translate({ y: this.entered ? 0 : 20 })
            .animation({ duration: 420, curve: Curve.EaseOut, delay: 0 })

            Column() {
              ChartCard({ chart: this.chart as Chart })
            }
            .width('100%')
            .opacity(this.entered ? 1 : 0)
            .translate({ y: this.entered ? 0 : 22 })
            .animation({ duration: 420, curve: Curve.EaseOut, delay: 80 })

            Column() {
              TodayCard({
                fortune: this.fortune as Fortune,
                chart: this.chart as Chart,
                todayText: this.todayText()
              })
            }
            .width('100%')
            .opacity(this.entered ? 1 : 0)
            .translate({ y: this.entered ? 0 : 22 })
            .animation({ duration: 420, curve: Curve.EaseOut, delay: 90 })

            Column() {
              YunCard({
                chart: this.chart as Chart,
                years: this.years,
                currentYear: beijingNow().y
              })
            }
            .width('100%')
            .opacity(this.entered ? 1 : 0)
            .translate({ y: this.entered ? 0 : 22 })
            .animation({ duration: 420, curve: Curve.EaseOut, delay: 180 })

            Button('返回修改生辰')
              .width('100%')
              .height(46)
              .fontSize(14)
              .fontColor(Theme.GREEN)
              .backgroundColor(Theme.CARD)
              .borderRadius(14)
              .border({ width: 1, color: Theme.LINE })
              .onClick(() => { this.goBack() })
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 4, bottom: 30 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      } else {
        Column({ space: 10 }) {
          Text('正在读取生辰…').fontSize(14).fontColor(Theme.DIM)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }
}
