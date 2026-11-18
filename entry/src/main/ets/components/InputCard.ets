/**
 * 生辰录入卡：分段选择 + 按钮式输入行 + 右侧开关
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
  /** 生辰用 JSON 字符串传入：字符串是原始类型，父组件一改就会同步，不受 @Prop 深拷贝语义影响 */
  @Prop birthJson: string
  @State private lonWarn: string = ''
  onChange: (b: BirthInput) => void = (b: BirthInput): void => {}

  /** 经度输入的初始文本。用普通字段而非 @State：输入过程中不回显、不与框架抢焦点，
   *  只有切换城市时才刷新（这正是此前「1065522222200001024」脏值的成因）。 */
  private lonInit: string = ''
  private rawLon: string = ''

  aboutToAppear(): void {
    this.lonInit = this.cur().lon.toFixed(2)
    this.rawLon = this.lonInit
  }

  /** 当前表单值（由 JSON prop 解析而来，始终与父组件一致） */
  private cur(): BirthInput {
    return JSON.parse(this.birthJson) as BirthInput
  }

  private commitLon(): void {
    const v: number = parseFloat(this.rawLon)
    if (isNaN(v)) {
      this.lonWarn = '经度无法识别，仍用 ' + this.cur().lon.toFixed(2) + '°E'
      return
    }
    if (v < -180 || v > 180) {
      this.lonWarn = '经度须在 -180~180 之间（东经为正），当前输入已忽略'
      return
    }
    this.lonWarn = ''
    if (Math.abs(v - this.cur().lon) > 0.0001) {
      this.patch({ lon: v })
    }
  }

  private cityIdx(): number {
    if (this.cur().cityIdx !== undefined) {
      return this.cur().cityIdx
    }
    return 0
  }

  private patch(changed: BirthPatch): void {
    const b: BirthInput = {
      y: this.cur().y,
      m: this.cur().m,
      d: this.cur().d,
      h: this.cur().h,
      mi: this.cur().mi,
      lon: this.cur().lon,
      tz: src.tz,
      gender: this.cur().gender,
      dst: this.cur().dst,
      unknownHour: this.cur().unknownHour,
      cityIdx: this.cur().cityIdx
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
      selected: new Date(this.cur().y, this.cur().m - 1, this.cur().d),
      onDateAccept: (value: Date) => {
        this.patch({ y: value.getFullYear(), m: value.getMonth() + 1, d: value.getDate() })
      }
    })
  }

  private pickTime(): void {
    TimePickerDialog.show({
      selected: new Date(2020, 0, 1, this.cur().h, this.cur().mi),
      useMilitaryTime: true,
      onAccept: (value: TimePickerResult) => {
        this.patch({ h: value.hour, mi: value.minute })
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
      // 性别：分段控件
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

      // 日期 / 时间：按钮式输入行
      Row({ space: 10 }) {
        this.pickBox('出生日期',
          this.cur().y.toString() + '-' + pad2(this.cur().m) + '-' + pad2(this.cur().d),
          () => { this.pickDate() })
        this.pickBox('出生时间', pad2(this.cur().h) + ':' + pad2(this.cur().mi),
          () => { this.pickTime() })
      }
      .width('100%')

      // 出生地
      Column({ space: 8 }) {
        Text('出生地点').fontSize(12).fontColor(Theme.DIM)
        Row() {
          Select(this.cityOptions())
            .selected(this.cityIdx())
            .value(CITIES[this.cityIdx()].name)
            .menuBackgroundColor(Theme.CARD)
            .fontColor(Theme.TEXT)
            .backgroundColor(Theme.CARD2)
            .layoutWeight(1)
            .onSelect((index: number) => {
              const c: City = CITIES[index]
              this.lonInit = c.lon.toFixed(2)
              this.rawLon = this.lonInit
              this.lonWarn = ''
              this.patch({ cityIdx: index, lon: c.lon })
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
        TextInput({ text: this.lonInit })
          .type(InputType.Number)
          .fontSize(15).fontColor(Theme.TEXT)
          .backgroundColor(Theme.CARD2)
          .borderRadius(Theme.R_SM)
          .onChange((value: string) => { this.rawLon = value })
          .onBlur(() => { this.commitLon() })
        if (this.lonWarn.length > 0) {
          Text(this.lonWarn).fontSize(11).fontColor(Theme.BAD).maxLines(2)
        } else {
          Text('用于换算真太阳时，直接决定时柱与月柱边界').fontSize(11).fontColor(Theme.DIM)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 开关
      Column({ space: 0 }) {
        this.switchRow('出生时为夏令时（+1 小时）', '中国 1986–1991 年实行', this.cur().dst,
          (v: boolean) => { this.patch({ dst: v }) })
        this.switchRow('时辰未知', '未知则不排时柱', this.cur().unknownHour,
          (v: boolean) => { this.patch({ unknownHour: v }) })
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
      .fontColor(this.cur().gender === value ? '#1A1206' : Theme.TEXT2)
      .width(76)
      .height(36)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.cur().gender === value ? Theme.GOLD : Theme.CARD2)
      .borderRadius(Theme.R_PILL)
      .border({ width: 1, color: this.cur().gender === value ? Theme.GOLD : Theme.LINE_SOFT })
      .onClick(() => { this.patch({ gender: value }) })
  }

  @Builder
  pickBox(label: string, value: string, action: () => void) {
    Column({ space: 6 }) {
      Text(label).fontSize(12).fontColor(Theme.DIM)
      Row({ space: 8 }) {
        Text(value).fontSize(15).fontColor(Theme.TEXT).layoutWeight(1)
        Text('›').fontSize(16).fontColor(Theme.DIM)
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 11, bottom: 11 })
      .backgroundColor(Theme.CARD2)
      .borderRadius(Theme.R_SM)
      .border({ width: 1, color: Theme.LINE_SOFT })
      .onClick(() => { action() })
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
