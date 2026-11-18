/**
 * 结果页：今日概览 / 命盘四柱 / 大运流年 / 真太阳时；左上角返回可重新输入
 */
import { router } from '@kit.ArkUI'
import { BirthInput, Chart, Fortune, YearItem, buildChart, dailyFortune, yearList, beijingNow, pad2 } from '../model/Bazi'
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
    let o: BirthInput | null = birthStore.getQueried()
    if (o === null) {
      o = await birthStore.load()
    }
    if (o === null) {
      router.back()
      return
    }
    const c: Chart = buildChart(o)
    const spec = beijingNow()
    const f: Fortune = dailyFortune(c, spec, o.lon, 8)
    this.chart = c
    this.fortune = f
    this.years = yearList(c, spec.y - 2, spec.y + 5)
    this.summary = o.y.toString() + '-' + pad2(o.m) + '-' + pad2(o.d) + ' ' + pad2(o.h) + ':' + pad2(o.mi) +
      '　经度 ' + o.lon.toFixed(2) + '°E　真太阳时 ' + c.solar.trueStr.substring(0, 16)
  }

  /** 返回录入页：先打标记，让录入页回填最近一次查询的信息 */
  private goBack(): void {
    birthStore.markReturned()
    router.back()
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
            ChartCard({ chart: this.chart as Chart })
            TodayCard({
              fortune: this.fortune as Fortune,
              chart: this.chart as Chart,
              todayText: this.todayText()
            })
            YunCard({
              chart: this.chart as Chart,
              years: this.years,
              currentYear: beijingNow().y
            })

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
