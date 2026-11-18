/**
 * 生辰录入卡
 *
 * 关键设计：表单值由**本组件自己的 @State** 持有（不再从父组件 @Prop 回读），
 * 改动直接写本地状态 → 界面立刻更新，不依赖「父组件回传 → prop 变 → 框架重设输入框」
 * 这条容易出问题的链路。每次改动再把完整快照交给父组件，供排盘使用。
 *
 * 日期/时间：可点「选择」调系统选择器（结果直接写本地状态），也可直接编辑文本。
 */
import { CITIES, City, FormData } from '../model/Bazi'
import { Theme } from '../model/Theme'

@Component
export struct InputCard {
  /** 仅用于初始化本地状态（父组件后续变化不覆盖，避免冲掉正在填的值） */
  @Prop initDate: string = '1990-06-15'
  @Prop initTime: string = '14:30'
  @Prop initLon: string = '116.41'
  @Prop initGender: string = 'm'
  @Prop initDst: boolean = false
  @Prop initUnknownHour: boolean = false
  @Prop initCityIdx: number = 0
  onChange: (f: FormData) => void = (f: FormData): void => {}

  /* 本地状态：真正的表单值 */
  @State private dateStr: string = '1990-06-15'
  @State private timeStr: string = '14:30'
  @State private lonStr: string = '116.41'
  @State private gender: string = 'm'
  @State private dst: boolean = false
  @State private unknownHour: boolean = false
  @State private cityIdx: number = 0

  aboutToAppear(): void {
    this.dateStr = this.initDate
    this.timeStr = this.initTime
    this.lonStr = this.initLon
    this.gender = this.initGender
    this.dst = this.initDst
    this.unknownHour = this.initUnknownHour
    this.cityIdx = this.initCityIdx
  }

  /** 显式传值上抛。注意：**不能在这里回读 this.xxx** —— ArkUI 的 @State 赋值是批量的，
   *  在同一个回调里刚赋值就读取会拿到旧值（这正是「界面显示新值、查询用旧值」的根因）。 */
  private emitAll(dateStr: string, timeStr: string, lonStr: string, gender: string,
    dst: boolean, unknownHour: boolean, cityIdx: number): void {
    const f: FormData = {
      dateStr: dateStr,
      timeStr: timeStr,
      lonStr: lonStr,
      gender: gender,
      dst: dst,
      unknownHour: unknownHour,
      cityIdx: cityIdx
    }
    this.onChange(f)
  }

  private two(n: number): string {
    return (n < 10 ? '0' : '') + n.toString()
  }

  private pickDate(): void {
    const parts: string[] = this.dateStr.trim().split('-')
    let y: number = 1990
    let m: number = 1
    let d: number = 1
    if (parts.length === 3) {
      const py: number = parseInt(parts[0])
      const pm: number = parseInt(parts[1])
      const pd: number = parseInt(parts[2])
      if (!isNaN(py) && !isNaN(pm) && !isNaN(pd)) {
        y = py
        m = pm
        d = pd
      }
    }
    this.getUIContext().showDatePickerDialog({
      start: new Date(1900, 0, 1),
      end: new Date(2100, 11, 31),
      selected: new Date(y, m - 1, d),
      onDateAccept: (value: Date) => {
        const s: string = value.getFullYear().toString() + '-' + this.two(value.getMonth() + 1) + '-' +
          this.two(value.getDate())
        this.dateStr = s
        this.emitAll(s, this.timeStr, this.lonStr, this.gender, this.dst, this.unknownHour, this.cityIdx)
      }
    })
  }

  private pickTime(): void {
    const parts: string[] = this.timeStr.trim().split(':')
    let h: number = 12
    let mi: number = 0
    if (parts.length === 2) {
      const ph: number = parseInt(parts[0])
      const pm: number = parseInt(parts[1])
      if (!isNaN(ph) && !isNaN(pm)) {
        h = ph
        mi = pm
      }
    }
    this.getUIContext().showTimePickerDialog({
      selected: new Date(2020, 0, 1, h, mi),
      useMilitaryTime: true,
      onAccept: (value: TimePickerResult) => {
        const s: string = this.two(value.hour) + ':' + this.two(value.minute)
        this.timeStr = s
        this.emitAll(this.dateStr, s, this.lonStr, this.gender, this.dst, this.unknownHour, this.cityIdx)
      }
    })
  }

  private cityOptions(): SelectOption[] {
    const opts: SelectOption[] = []
    for (let i = 0; i < CITIES.length; i++) {
      opts.push({ value: CITIES[i].name })
    }
    return opts
  }

  build() {
    Column({ space: 14 }) {
      // 性别
      Column({ space: 8 }) {
        Text('性别').fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).fontFamily(Theme.MONO)
        Row({ space: 8 }) {
          this.sex('男', 'm')
          this.sex('女', 'f')
          Blank()
          Text('决定大运顺逆').fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 日期 / 时间
      Row({ space: 10 }) {
        this.dateBox()
        this.timeBox()
      }
      .width('100%')

      // 出生地
      Column({ space: 8 }) {
        Text('出生地点').fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).fontFamily(Theme.MONO)
        Row() {
          Select(this.cityOptions())
            .selected(this.cityIdx)
            .value(CITIES[this.cityIdx < 0 ? 0 : this.cityIdx].name)
            .menuBackgroundColor(Theme.CARD)
            .fontColor(Theme.TEXT)
            .backgroundColor(Theme.CARD2)
            .layoutWeight(1)
            .onSelect((index: number) => {
              const c: City = CITIES[index]
              const lon: string = c.lon.toFixed(2)
              this.cityIdx = index
              this.lonStr = lon
              this.emitAll(this.dateStr, this.timeStr, lon, this.gender, this.dst, this.unknownHour, index)
            })
          Text('›').fontSize(16).fontColor(Theme.DIM).margin({ left: 8 })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 12, bottom: 12 })
        .backgroundColor(Theme.CARD2)
        .borderRadius(Theme.R_SM)
        .border({ width: 1, color: Theme.LINE_SOFT })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 经度
      Column({ space: 8 }) {
        Text('出生地经度（东经为正）').fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).fontFamily(Theme.MONO)
        TextInput({ text: this.lonStr })
          .type(InputType.Normal)
          .fontSize(15).fontColor(Theme.TEXT).fontFamily(Theme.MONO)
          .backgroundColor(Theme.CARD2)
          .borderRadius(Theme.R_SM)
          .onChange((v: string) => {
            this.lonStr = v
            this.emitAll(this.dateStr, this.timeStr, v, this.gender, this.dst, this.unknownHour, this.cityIdx)
          })
        Text('用于换算真太阳时，直接决定时柱与月柱边界').fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 开关
      Column({ space: 0 }) {
        this.switchRow('出生时为夏令时（+1 小时）', '中国 1986–1991 年实行', this.dst,
          (v: boolean) => {
            this.dst = v
            this.emitAll(this.dateStr, this.timeStr, this.lonStr, this.gender, v, this.unknownHour, this.cityIdx)
          })
        this.switchRow('时辰未知', '未知则不排时柱', this.unknownHour,
          (v: boolean) => {
            this.unknownHour = v
            this.emitAll(this.dateStr, this.timeStr, this.lonStr, this.gender, this.dst, v, this.cityIdx)
          })
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
  sex(label: string, value: string) {
    Text(label)
      .fontSize(14)
      .fontFamily(Theme.MONO)
      .fontColor(this.gender === value ? '#001208' : Theme.TEXT2)
      .width(76)
      .height(36)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.gender === value ? Theme.GREEN : Theme.CARD2)
      .borderRadius(Theme.R_PILL)
      .border({ width: 1, color: this.gender === value ? Theme.GREEN : Theme.LINE_SOFT })
      .onClick(() => {
        this.gender = value
        this.emitAll(this.dateStr, this.timeStr, this.lonStr, value, this.dst, this.unknownHour, this.cityIdx)
      })
  }

  @Builder
  dateBox() {
    Column({ space: 6 }) {
      Row({ space: 6 }) {
        Text('出生日期').fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).fontFamily(Theme.MONO).layoutWeight(1)
        Text('PICK').fontSize(10).fontColor(Theme.CYAN).fontFamily(Theme.MONO).onClick(() => { this.pickDate() })
      }
      .width('100%')
      TextInput({ text: this.dateStr })
        .type(InputType.Normal)
        .fontSize(15).fontColor(Theme.TEXT).fontFamily(Theme.MONO)
        .backgroundColor(Theme.CARD2)
        .borderRadius(Theme.R_SM)
        .onChange((v: string) => {
          this.dateStr = v
          this.emitAll(v, this.timeStr, this.lonStr, this.gender, this.dst, this.unknownHour, this.cityIdx)
        })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  timeBox() {
    Column({ space: 6 }) {
      Row({ space: 6 }) {
        Text('出生时间').fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).fontFamily(Theme.MONO).layoutWeight(1)
        Text('PICK').fontSize(10).fontColor(Theme.CYAN).fontFamily(Theme.MONO).onClick(() => { this.pickTime() })
      }
      .width('100%')
      TextInput({ text: this.timeStr })
        .type(InputType.Normal)
        .fontSize(15).fontColor(Theme.TEXT).fontFamily(Theme.MONO)
        .backgroundColor(Theme.CARD2)
        .borderRadius(Theme.R_SM)
        .onChange((v: string) => {
          this.timeStr = v
          this.emitAll(this.dateStr, v, this.lonStr, this.gender, this.dst, this.unknownHour, this.cityIdx)
        })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  switchRow(title: string, sub: string, on: boolean, cb: (v: boolean) => void) {
    Row({ space: 10 }) {
      Column({ space: 2 }) {
        Text(title).fontSize(12).fontColor(Theme.TEXT).fontFamily(Theme.MONO)
        Text(sub).fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: on })
        .selectedColor(Theme.GREEN)
        .onChange((v: boolean) => { cb(v) })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: 1 }, color: Theme.LINE_SOFT })
  }
}
