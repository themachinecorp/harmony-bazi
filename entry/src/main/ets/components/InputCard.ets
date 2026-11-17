/**
 * 生辰录入卡：性别 / 日期 / 时间 / 出生地经度 / 夏令时 / 时辰未知
 * 用 @Prop + onChange 回调（不使用 @Link/$$ 语法，跨组件更稳）
 */
import { promptAction } from '@kit.ArkUI'
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
    promptAction.showDatePicker({
      start: new Date(1900, 0, 1),
      end: new Date(2100, 11, 31),
      selected: new Date(this.birth.y, this.birth.m - 1, this.birth.d),
      onAccept: (value: Date) => {
        this.patch({ y: value.getFullYear(), m: value.getMonth() + 1, d: value.getDate() })
      }
    })
  }

  private pickTime(): void {
    promptAction.showTimePicker({
      selected: new Date(2020, 0, 1, this.birth.h, this.birth.mi),
      useMilitaryTime: true,
      onAccept: (value: Date) => {
        this.patch({ h: value.getHours(), mi: value.getMinutes() })
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
          .selectedColor(Theme.GOLD)
          .onChange((checked: boolean) => {
            if (checked) {
              this.patch({ gender: 'm' })
            }
          })
        Text('男').fontSize(14).fontColor(Theme.TEXT)
        Radio({ value: 'f', group: 'g' })
          .checked(this.birth.gender === 'f')
          .selectedColor(Theme.GOLD)
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
              this.patch({ cityIdx: index, lon: c.lon })
            })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 6 }) {
          Text('经度（东经）').fontSize(12).fontColor(Theme.DIM)
          TextInput({ text: this.birth.lon.toFixed(2) })
            .type(InputType.Number)
            .fontSize(15).fontColor(Theme.TEXT)
            .backgroundColor(Theme.CARD2)
            .onChange((value: string) => {
              const v: number = parseFloat(value)
              if (!isNaN(v)) {
                this.patch({ lon: v })
              }
            })
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
