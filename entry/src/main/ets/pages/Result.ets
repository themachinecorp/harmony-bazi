/**
 * 结果页：今日概览 / 命盘四柱 / 大运流年 / 真太阳时；左上角返回可重新输入
 */
import { BirthInput, FormData, Chart, Fortune, YearItem, buildChart, dailyFortune, yearList, beijingNow, pad2, formToBirth } from '../model/Bazi'
import { birthStore } from '../store/BirthStore'
import { TodayCard } from '../components/TodayCard'
import { ChartCard } from '../components/ChartCard'
import { YunCard } from '../components/YunCard'
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

  aboutToAppear(): void {
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

  private todayText(): string {
    const spec = beijingNow()
    const wd: string[] = ['日', '一', '二', '三', '四', '五', '六']
    const dow: number = new Date(Date.now() + 8 * 3600 * 1000).getUTCDay()
    return spec.y.toString() + '-' + pad2(spec.m) + '-' + pad2(spec.d) + ' 周' + wd[dow]
  }

  build() {
    Column() {
      // 顶栏：返回 + 标题 + 生辰摘要
      Row({ space: 10 }) {
        Text('‹')
          .fontSize(28).fontColor(Theme.GOLD)
          .width(26)
          .onClick(() => { this.goBack() })
        Column({ space: 2 }) {
          Text('命盘总览').fontSize(19).fontWeight(FontWeight.Bold).fontColor(Theme.GOLD)
          Text(this.summary).fontSize(11).fontColor(Theme.DIM).maxLines(1)
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
            Column() {
              ChartCard({ chart: this.chart as Chart })
            }
            .width('100%')
            .opacity(this.entered ? 1 : 0)
            .translate({ y: this.entered ? 0 : 22 })
            .animation({ duration: 420, curve: Curve.EaseOut, delay: 0 })

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
              .fontColor(Theme.GOLD)
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
    .backgroundColor(Theme.BG)
  }
}
