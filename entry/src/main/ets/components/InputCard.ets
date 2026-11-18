/**
 * 生辰录入卡：性别 / 日期 / 时间 / 出生地经度 / 夏令时 / 时辰未知
 *
 * 数据流约定（踩坑换来的）：
 * - 父组件只用**原始类型** prop 传值（string/number/boolean），子组件每次改动都把
 *   **原始文本**回传，父组件原样存下并回显 —— 没有对象、没有 JSON.parse、
 *   没有「规范化回写」，所以不会出现回显循环或界面与状态分裂。
 * - 日期/时间既能点选择器，也能直接手输；两者都写原始文本。
 */
import { CITIES, City, FormData } from '../model/Bazi'
import { Theme } from '../model/Theme'

@Component
export struct InputCard {
  @Prop dateStr: string = '1990-06-15'
  @Prop timeStr: string = '14:30'
  @Prop lonStr: string = '116.41'
  @Prop gender: string = 'm'
  @Prop dst: boolean = false
  @Prop unknownHour: boolean = false
  @Prop cityIdx: number = 0
  onChange: (f: FormData) => void = (f: FormData): void => {}

  /** 以当前值为底，回传改动后的原始数据 */
  private emit(dateStr: string, timeStr: string, lonStr: string, gender: string,
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

  private pickDate(): void {
    const parts: string[] = this.dateStr.trim().split('-')
    let y: number = 1990, m: number = 1, d: number = 1
    if (parts.length === 3) {
      const py: number = parseInt(parts[0])
      const pm: number = parseInt(parts[1])
      const pd: number = parseInt(parts[2])
      if (!isNaN(py) && !isNaN(pm) && !isNaN(pd)) {
        y = py; m = pm; d = pd
      }
    }
    DatePickerDialog.show({
      start: new Date(1900, 0, 1),
      end: new Date(2100, 11, 31),
      selected: new Date(y, m - 1, d),
      onDateAccept: (value: Date) => {
        const s: string = value.getFullYear().toString() + '-' + this.two(value.getMonth() + 1) + '-' +
          this.two(value.getDate())
        this.emit(s, this.timeStr, this.lonStr, this.gender, this.dst, this.unknownHour, this.cityIdx)
      }
    })
  }

  private pickTime(): void {
    const parts: string[] = this.timeStr.trim().split(':')
    let h: number = 12, mi: number = 0
    if (parts.length === 2) {
      const ph: number = parseInt(parts[0])
      const pm: number = parseInt(parts[1])
      if (!isNaN(ph) && !isNaN(pm)) {
        h = ph; mi = pm
      }
    }
    TimePickerDialog.show({
      selected: new Date(2020, 0, 1, h, mi),
      useMilitaryTime: true,
      onAccept: (value: TimePickerResult) => {
        const s: string = this.two(value.hour) + ':' + this.two(value.minute)
        this.emit(this.dateStr, s, this.lonStr, this.gender, this.dst, this.unknownHour, this.cityIdx)
      }
    })
  }

  private two(n: number): string {
    return (n < 10 ? '0' : '') + n.toString()
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
        Text('性别').fontSize(12).fontColor(Theme.DIM)
        Row({ space: 8 }) {
          this.sex('男', 'm')
          this.sex('女', 'f')
          Blank()
          Text('决定大运顺逆').fontSize(11).fontColor(Theme.DIM)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 日期 / 时间
      Row({ space: 10 }) {
        this.dateBox('出生日期', this.dateStr, () => { this.pickDate() })
        this.timeBox('出生时间', this.timeStr, () => { this.pickTime() })
      }
      .width('100%')

      // 出生地
      Column({ space: 8 }) {
        Text('出生地点').fontSize(12).fontColor(Theme.DIM)
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
              this.emit(this.dateStr, this.timeStr, c.lon.toFixed(2), this.gender, this.dst,
                this.unknownHour, index)
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
        Text('出生地经度（东经为正）').fontSize(12).fontColor(Theme.DIM)
        TextInput({ text: this.lonStr })
          .type(InputType.Number)
          .fontSize(15).fontColor(Theme.TEXT)
          .backgroundColor(Theme.CARD2)
          .borderRadius(Theme.R_SM)
          .onChange((v: string) => {
            this.emit(this.dateStr, this.timeStr, v, this.gender, this.dst, this.unknownHour, this.cityIdx)
          })
        Text('用于换算真太阳时，直接决定时柱与月柱边界').fontSize(11).fontColor(Theme.DIM)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 开关
      Column({ space: 0 }) {
        this.switchRow('出生时为夏令时（+1 小时）', '中国 1986–1991 年实行', this.dst,
          (v: boolean) => {
            this.emit(this.dateStr, this.timeStr, this.lonStr, this.gender, v, this.unknownHour, this.cityIdx)
          })
        this.switchRow('时辰未知', '未知则不排时柱', this.unknownHour,
          (v: boolean) => {
            this.emit(this.dateStr, this.timeStr, this.lonStr, this.gender, this.dst, v, this.cityIdx)
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
      .fontColor(this.gender === value ? '#1A1206' : Theme.TEXT2)
      .width(76)
      .height(36)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.gender === value ? Theme.GOLD : Theme.CARD2)
      .borderRadius(Theme.R_PILL)
      .border({ width: 1, color: this.gender === value ? Theme.GOLD : Theme.LINE_SOFT })
      .onClick(() => {
        this.emit(this.dateStr, this.timeStr, this.lonStr, value, this.dst, this.unknownHour, this.cityIdx)
      })
  }

  @Builder
  dateBox(label: string, value: string, pick: () => void) {
    Column({ space: 6 }) {
      Row({ space: 6 }) {
        Text(label).fontSize(12).fontColor(Theme.DIM).layoutWeight(1)
        Text('选择').fontSize(11).fontColor(Theme.GOLD).onClick(() => { pick() })
      }
      .width('100%')
      TextInput({ text: value })
        .fontSize(15).fontColor(Theme.TEXT)
        .backgroundColor(Theme.CARD2)
        .borderRadius(Theme.R_SM)
        .onChange((v: string) => {
          this.emit(v, this.timeStr, this.lonStr, this.gender, this.dst, this.unknownHour, this.cityIdx)
        })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  timeBox(label: string, value: string, pick: () => void) {
    Column({ space: 6 }) {
      Row({ space: 6 }) {
        Text(label).fontSize(12).fontColor(Theme.DIM).layoutWeight(1)
        Text('选择').fontSize(11).fontColor(Theme.GOLD).onClick(() => { pick() })
      }
      .width('100%')
      TextInput({ text: value })
        .fontSize(15).fontColor(Theme.TEXT)
        .backgroundColor(Theme.CARD2)
        .borderRadius(Theme.R_SM)
        .onChange((v: string) => {
          this.emit(this.dateStr, v, this.lonStr, this.gender, this.dst, this.unknownHour, this.cityIdx)
        })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  switchRow(title: string, sub: string, on: boolean, cb: (v: boolean) => void) {
    Row({ space: 10 }) {
      Column({ space: 2 }) {
        Text(title).fontSize(13).fontColor(Theme.TEXT)
        Text(sub).fontSize(11).fontColor(Theme.DIM)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: on })
        .selectedColor(Theme.RED)
        .onChange((v: boolean) => { cb(v) })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: 1 }, color: Theme.LINE_SOFT })
  }
}
