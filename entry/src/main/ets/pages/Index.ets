/**
 * 生辰录入页：填信息 → 排盘 → 跳转结果页
 */
import { FormData, CITIES, formToBirth } from '../model/Bazi'
import { birthStore } from '../store/BirthStore'
import { InputCard } from '../components/InputCard'
import { Theme } from '../model/Theme'

@Entry
@Component
struct Index {
  @State private form: FormData = {
    dateStr: '1990-06-15',
    timeStr: '14:30',
    lonStr: '116.41',
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
    let o: FormData | null = birthStore.getQueried()
    if (o === null) {
      o = await birthStore.load()
    }
    if (o !== null) {
      this.form = o
      this.hasSaved = true
      birthStore.setDraft(o)
    }
    this.loaded = true
  }

  onFormChange(f: FormData): void {
    // 内容完全相同就不更新（否则会与输入框的 onChange 形成回环，界面直接卡死）
    const o: FormData = this.form
    if (o.dateStr === f.dateStr && o.timeStr === f.timeStr && o.lonStr === f.lonStr &&
      o.gender === f.gender && o.dst === f.dst && o.unknownHour === f.unknownHour &&
      o.cityIdx === f.cityIdx) {
      return
    }
    this.form = f
    birthStore.setDraft(f)
  }

  /** 从结果页返回：不再回填表单。
   *  录入卡自己持有表单值，回填会造成「界面显示」与「查询所用状态」不一致；
   *  而返回时表单本来就是上次查询的那份，无需干预。 */
  onPageShow(): void {
    birthStore.consumeReturned()
  }

  async compute(): Promise<void> {
    // 提交前校验格式（日期 1994-06-14 / 时间 14:30 / 经度 -180~180）
    if (formToBirth(this.form) === null) {
      this.getUIContext().getPromptAction().showToast({ message: '出生地经度格式不对（应为 106.55 这类小数）' })
      return
    }
    // 记住「最近一次查询」：返回时表单据此回填，结果页也读它
    birthStore.setQueried(this.form)
    birthStore.setDraft(this.form)
    await birthStore.save(this.form)
    this.getUIContext().getRouter().pushUrl({ url: 'pages/Result' })
  }

  private formSummary(): string {
    const idx: number = this.form.cityIdx
    const city: string = (idx >= 0 && idx < CITIES.length) ? CITIES[idx].name : '自定义经度'
    return '表单当前：' + this.form.dateStr + ' ' + this.form.timeStr + '　' + city + ' ' +
      this.form.lonStr + '°E'
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
              initDate: this.form.dateStr,
              initTime: this.form.timeStr,
              initLon: this.form.lonStr,
              initGender: this.form.gender,
              initDst: this.form.dst,
              initUnknownHour: this.form.unknownHour,
              initCityIdx: this.form.cityIdx,
              onChange: (f: FormData) => { this.onFormChange(f) }
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
              .onClick(() => { this.getUIContext().getRouter().pushUrl({ url: 'pages/Result' }) })
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
