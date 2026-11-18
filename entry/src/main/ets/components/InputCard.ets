/**
 * 生辰录入卡：性别 / 日期 / 时间 / 出生地经度 / 夏令时 / 时辰未知
 * 用 @Prop + onChange 回调（不使用 @Link/$$ 语法，跨组件更稳）
 */
import { BirthInput, CITIES, City, pad2 } from '../model/Bazi'
import { Theme } from '../model/Theme'

interface BirthPatch {
  y?: number
  m?: number
  d?: number
  h?: number
  mi?: number
  lon?: number
  gender?: string
  dst?: boolean
  unknownHour?: boolean
  cityIdx?: number
}

@Component
export struct InputCard {
  @Prop birth: BirthInput
  onChange: (b: BirthInput) => void = (b: BirthInput): void => {}

  /** 经度输入的初始文本。用普通字段而非 @State：输入过程中不回显、不与框架抢焦点，
   *  只有切换城市时才刷新（这正是此前「1065522222200001024」脏值的成因）。 */
  private lonInit: string = ''
  private rawLon: string = ''
  @State private lonWarn: string = ''

  aboutToAppear(): void {
    this.lonInit = this.birth.lon.toFixed(2)
    this.rawLon = this.lonInit
  }

  private commitLon(): void {
    const v: number = parseFloat(this.rawLon)
    if (isNaN(v)) {
      this.lonWarn = '经度无法识别，仍用 ' + this.birth.lon.toFixed(2) + '°E'
      return
    }
    if (v < -180 || v > 180) {
      this.lonWarn = '经度须在 -180~180 之间（东经为正），当前输入已忽略'
      return
    }
    this.lonWarn = ''
    if (Math.abs(v - this.birth.lon) > 0.0001) {
      this.patch({ lon: v })
    }
  }

  private cityOptions(): SelectOption[] {
    const opts: SelectOption[] = []
    for (let i = 0; i < CITIES.length; i++) {
      opts.push({ value: CITIES[i].name })
    }
    return opts
  }

  private cityIdx(): number {
    if (this.birth.cityIdx !== undefined) {
      return this.birth.cityIdx
    }
    return 0
  }

  private patch(changed: BirthPatch): void {
    const b: BirthInput = {
      y: this.birth.y,
      m: this.birth.m,
      d: this.birth.d,
      h: this.birth.h,
      mi: this.birth.mi,
      lon: this.birth.lon,
      tz: this.birth.tz,
      gender: this.birth.gender,
      dst: this.birth.dst,
      unknownHour: this.birth.unknownHour,
      cityIdx: this.birth.cityIdx
    }
    if (changed.y !== undefined) { b.y = changed.y }
    if (changed.m !== undefined) { b.m = changed.m }
    if (changed.d !== undefined) { b.d = changed.d }
    if (changed.h !== undefined) { b.h = changed.h }
    if (changed.mi !== undefined) { b.mi = changed.mi }
    if (changed.lon !== undefined) { b.lon = changed.lon }
    if (changed.gender !== undefined) { b.gender = changed.gender }
    if (changed.dst !== undefined) { b.dst = changed.dst }
    if (changed.unknownHour !== undefined) { b.unknownHour = changed.unknownHour }
    if (changed.cityIdx !== undefined) { b.cityIdx = changed.cityIdx }
    this.onChange(b)
  }

  private pickDate(): void {
    DatePickerDialog.show({
      start: new Date(1900, 0, 1),
      end: new Date(2100, 11, 31),
      selected: new Date(this.birth.y, this.birth.m - 1, this.birth.d),
      onDateAccept: (value: Date) => {
        this.patch({ y: value.getFullYear(), m: value.getMonth() + 1, d: value.getDate() })
      }
    })
  }

  private pickTime(): void {
    TimePickerDialog.show({
      selected: new Date(2020, 0, 1, this.birth.h, this.birth.mi),
      useMilitaryTime: true,
      onAccept: (value: TimePickerResult) => {
        this.patch({ h: value.hour, mi: value.minute })
      }
    })
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('生辰录入')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD)
        Blank()
        Text('真太阳时排盘')
          .fontSize(12)
          .fontColor(Theme.DIM)
      }
      .width('100%')

      // 性别
      Row({ space: 8 }) {
        Text('性别').fontSize(13).fontColor(Theme.DIM).width(56)
        Radio({ value: 'm', group: 'g' })
          .checked(this.birth.gender === 'm')
          .onChange((checked: boolean) => {
            if (checked) {
              this.patch({ gender: 'm' })
            }
          })
        Text('男').fontSize(14).fontColor(Theme.TEXT)
        Radio({ value: 'f', group: 'g' })
          .checked(this.birth.gender === 'f')
          .onChange((checked: boolean) => {
            if (checked) {
              this.patch({ gender: 'f' })
            }
          })
        Text('女').fontSize(14).fontColor(Theme.TEXT)
        Blank()
        Text('定大运顺逆').fontSize(12).fontColor(Theme.DIM)
      }
      .width('100%')

      // 日期 / 时间
      Row({ space: 10 }) {
        Column({ space: 6 }) {
          Text('出生日期').fontSize(12).fontColor(Theme.DIM)
          Text(this.birth.y.toString() + '-' + pad2(this.birth.m) + '-' + pad2(this.birth.d))
            .fontSize(15).fontColor(Theme.TEXT)
            .padding({ top: 6, bottom: 6, left: 10, right: 10 })
            .backgroundColor(Theme.CARD2).borderRadius(8).border({ width: 1, color: Theme.LINE })
            .onClick(() => this.pickDate())
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 6 }) {
          Text('出生时间（钟表时）').fontSize(12).fontColor(Theme.DIM)
          Text(pad2(this.birth.h) + ':' + pad2(this.birth.mi))
            .fontSize(15).fontColor(Theme.TEXT)
            .padding({ top: 6, bottom: 6, left: 10, right: 10 })
            .backgroundColor(Theme.CARD2).borderRadius(8).border({ width: 1, color: Theme.LINE })
            .onClick(() => this.pickTime())
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // 出生地
      Row({ space: 10 }) {
        Column({ space: 6 }) {
          Text('出生地').fontSize(12).fontColor(Theme.DIM)
          Select(this.cityOptions())
            .selected(this.cityIdx())
            .value(CITIES[this.cityIdx()].name)
            .menuBackgroundColor(Theme.CARD)
            .fontColor(Theme.TEXT)
            .backgroundColor(Theme.CARD2)
            .onSelect((index: number) => {
              const c: City = CITIES[index]
              this.lonInit = c.lon.toFixed(2)
              this.rawLon = this.lonInit
              this.lonWarn = ''
              this.patch({ cityIdx: index, lon: c.lon })
            })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 6 }) {
          Text('经度（东经，可改）').fontSize(12).fontColor(Theme.DIM)
          TextInput({ text: this.lonInit })
            .type(InputType.Number)
            .fontSize(15).fontColor(Theme.TEXT)
            .backgroundColor(Theme.CARD2)
            .onChange((value: string) => { this.rawLon = value })
            .onBlur(() => { this.commitLon() })
          if (this.lonWarn.length > 0) {
            Text(this.lonWarn).fontSize(11).fontColor(Theme.BAD).maxLines(2)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // 开关
      Row() {
        Toggle({ type: ToggleType.Switch, isOn: this.birth.dst })
          .selectedColor(Theme.RED)
          .onChange((v: boolean) => { this.patch({ dst: v }) })
        Text('出生时为夏令时（+1小时）').fontSize(13).fontColor(Theme.TEXT).margin({ left: 8 })
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.birth.unknownHour })
          .selectedColor(Theme.RED)
          .onChange((v: boolean) => { this.patch({ unknownHour: v }) })
        Text('时辰未知').fontSize(13).fontColor(Theme.TEXT).margin({ left: 8 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.CARD)
    .borderRadius(14)
    .border({ width: 1, color: Theme.LINE })
  }
}
