/**
 * 生辰录入页：填信息 → 排盘 → 跳转结果页
 */
import { router, promptAction } from '@kit.ArkUI'
import { BirthInput, CITIES, City, pad2 } from '../model/Bazi'
import { birthStore } from '../store/BirthStore'
import { InputCard } from '../components/InputCard'
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
  @State private hasSaved: boolean = false
  @State private loaded: boolean = false

  aboutToAppear(): void {
    this.restore()
  }

  async restore(): Promise<void> {
    // 优先用内存里的「最近一次查询」；没有（冷启动）才读存档。
    // 这样无论页面是被重建还是被回填，显示的都是最新查询的那份。
    let o: BirthInput | null = birthStore.getQueried()
    if (o === null) {
      o = await birthStore.load()
    }
    if (o !== null) {
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
      this.hasSaved = true
      birthStore.setDraft(this.birth)
    }
    this.loaded = true
  }

  onBirthChange(b: BirthInput): void {
    this.birth = b
    birthStore.setDraft(b)
  }

  /** 从结果页返回：表单回填「最近一次查询」的信息。
   *  必须靠 store 的返回标记判断——日期/时间选择器关闭时也会触发 onPageShow，
   *  那样回填会把用户刚选的值弹回旧值。 */
  onPageShow(): void {
    if (!birthStore.consumeReturned()) {
      return
    }
    const q: BirthInput | null = birthStore.getQueried()
    if (q !== null) {
      this.birth = q
      birthStore.setDraft(q)
    }
  }

  async compute(): Promise<void> {
    // 提交前再校验一次经度（输入框可能还没失焦提交）
    if (!isFinite(this.birth.lon) || this.birth.lon < -180 || this.birth.lon > 180) {
      promptAction.showToast({ message: '出生地经度须在 -180~180 之间（东经为正）' })
      return
    }
    // 记住「最近一次查询」：返回时表单据此回填，结果页也读它
    birthStore.setQueried(this.birth)
    birthStore.setDraft(this.birth)
    await birthStore.save(this.birth)
    router.pushUrl({ url: 'pages/Result' })
  }

  private formSummary(): string {
    const idx: number = this.birth.cityIdx === undefined ? -1 : this.birth.cityIdx
    const city: string = (idx >= 0 && idx < CITIES.length) ? CITIES[idx].name : '自定义经度'
    return '表单当前：' + this.birth.y.toString() + '-' + pad2(this.birth.m) + '-' + pad2(this.birth.d) +
      ' ' + pad2(this.birth.h) + ':' + pad2(this.birth.mi) + '　' + city + ' ' + this.birth.lon.toFixed(2) + '°E'
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 6 }) {
            Text('时 辰')
              .fontSize(28).fontWeight(FontWeight.Bold).fontColor(Theme.GOLD)
              .letterSpacing(8)
            Row({ space: 8 }) {
              Row().width(28).height(2).backgroundColor(Theme.RED).borderRadius(1)
              Text('真太阳时排盘 · 八字 / 大运 / 流年 · 今日运势')
                .fontSize(12).fontColor(Theme.DIM)
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 4 })

          if (this.loaded) {
            InputCard({
              birthJson: JSON.stringify(this.birth),
              onChange: (b: BirthInput) => { this.onBirthChange(b) }
            })
          }

          Button('排 盘')
            .width('100%')
            .height(50)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFF6E8')
            .linearGradient({ angle: 90, colors: Theme.RED_GRADIENT })
            .borderRadius(14)
            .shadow({ radius: 18, color: '#33C2410C', offsetY: 6 })
            .onClick(() => { this.compute() })

          Text(this.formSummary())
            .fontSize(11).fontColor(Theme.DIM)
            .width('100%')

          if (this.hasSaved) {
            Button('查看上次结果')
              .width('100%')
              .height(42)
              .fontSize(14)
              .fontColor(Theme.GOLD)
              .backgroundColor(Theme.CARD)
              .borderRadius(10)
              .border({ width: 1, color: Theme.LINE })
              .onClick(() => { router.pushUrl({ url: 'pages/Result' }) })
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
}
