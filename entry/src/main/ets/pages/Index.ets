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
  @State private entered: boolean = false
  @State private pressed: boolean = false

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
    setTimeout(() => { this.entered = true }, 40)
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
            Text('$ bazi --init')
              .fontSize(11).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
            Text('时 辰 // BAZI_ENGINE')
              .fontSize(22).fontWeight(FontWeight.Bold).fontColor(Theme.GREEN)
              .fontFamily(Theme.MONO).letterSpacing(2)
              .textShadow({ radius: 14, color: '#6600FF9C', offsetX: 0, offsetY: 0 })
            Text('真太阳时排盘 · 八字 / 大运 / 流年 · 今日运势')
              .fontSize(11).fontColor(Theme.DIM).fontFamily(Theme.MONO)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 4 })

          if (this.loaded) {
            Column() {
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
            .width('100%')
            .opacity(this.entered ? 1 : 0)
            .translate({ y: this.entered ? 0 : 22 })
            .animation({ duration: 420, curve: Curve.EaseOut, delay: 40 })
          }

          Button('> 排 盘  [RUN]')
            .width('100%')
            .height(48)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontFamily(Theme.MONO)
            .fontColor('#001208')
            .backgroundColor(Theme.GREEN)
            .borderRadius(14)
            .shadow({ radius: this.pressed ? 6 : 16, color: '#3300FF9C', offsetY: this.pressed ? 1 : 4 })
            .scale({ x: this.pressed ? 0.96 : 1, y: this.pressed ? 0.96 : 1 })
            .animation({ duration: 130, curve: Curve.EaseOut })
            .onTouch((e: TouchEvent) => {
              if (e.type === TouchType.Down) {
                this.pressed = true
              } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
                this.pressed = false
              }
            })
            .opacity(this.entered ? 1 : 0)
            .translate({ y: this.entered ? 0 : 18 })
            .animation({ duration: 420, curve: Curve.EaseOut, delay: 120 })
            .onClick(() => { this.compute() })

          Text('> ' + this.formSummary())
            .fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO)
            .width('100%')
            .opacity(this.entered ? 1 : 0)
            .animation({ duration: 420, curve: Curve.EaseOut, delay: 200 })

          if (this.hasSaved) {
            Button('> 查看上次结果  [LAST]')
              .width('100%')
              .height(42)
              .fontSize(13)
              .fontFamily(Theme.MONO)
              .fontColor(Theme.GREEN)
              .backgroundColor(Theme.CARD)
              .borderRadius(Theme.R_SM)
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
