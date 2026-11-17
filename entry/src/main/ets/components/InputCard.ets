/**
 * 生辰录入卡：性别 / 日期 / 时间 / 出生地经度 / 夏令时 / 时辰未知
 */
import { BirthInput, CITIES, City, pad2 } from '../model/Bazi'
import { Theme } from '../model/Theme'

@Component
export struct InputCard {
  @Link gender: string
  @Link birthY: number
  @Link birthM: number
  @Link birthD: number
  @Link birthH: number
  @Link birthMi: number
  @Link lon: number
  @Link lonText: string
  @Link cityIdx: number
  @Link dst: boolean
  @Link unknownHour: boolean
  onCompute: () => void

  private cityOptions(): SelectOption[] {
    const opts: SelectOption[] = []
    for (let i = 0; i < CITIES.length; i++) {
      opts.push({ value: CITIES[i].name })
    }
    return opts
  }

  private pickDate(): void {
    DatePickerDialog.show({
      start: new Date(1900, 0, 1),
      end: new Date(2100, 11, 31),
      selected: new Date(this.birthY, this.birthM - 1, this.birthD),
      lunar: false,
      onDateAccept: (value: Date) => {
        this.birthY = value.getFullYear()
        this.birthM = value.getMonth() + 1
        this.birthD = value.getDate()
      }
    })
  }

  private pickTime(): void {
    TimePickerDialog.show({
      selected: new Date(2020, 0, 1, this.birthH, this.birthMi),
      useMilitaryTime: true,
      onTimeAccept: (value: Date) => {
        this.birthH = value.getHours()
        this.birthMi = value.getMinutes()
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
          .select(this.gender === 'm')
          .onChange((checked: boolean) => { if (checked) { this.gender = 'm' } })
          .selectedColor(Theme.GOLD)
        Text('男').fontSize(14).fontColor(Theme.TEXT)
        Radio({ value: 'f', group: 'g' })
          .select(this.gender === 'f')
          .onChange((checked: boolean) => { if (checked) { this.gender = 'f' } })
          .selectedColor(Theme.GOLD)
        Text('女').fontSize(14).fontColor(Theme.TEXT)
        Blank()
        Text('定大运顺逆').fontSize(12).fontColor(Theme.DIM)
      }
      .width('100%')

      // 日期 / 时间
      Row({ space: 10 }) {
        Column({ space: 6 }) {
          Text('出生日期').fontSize(12).fontColor(Theme.DIM)
          Text(this.birthY.toString() + '-' + pad2(this.birthM) + '-' +
          pad2(this.birthD))
            .fontSize(15).fontColor(Theme.TEXT)
            .padding({ top: 6, bottom: 6, left: 10, right: 10 })
            .backgroundColor(Theme.CARD2).borderRadius(8).border({ width: 1, color: Theme.LINE })
            .onClick(() => this.pickDate())
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 6 }) {
          Text('出生时间（钟表时）').fontSize(12).fontColor(Theme.DIM)
          Text(pad2(this.birthH) + ':' + pad2(this.birthMi))
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
            .selected(this.cityIdx)
            .value(CITIES[this.cityIdx < 0 ? 0 : this.cityIdx].name)
            .menuBackgroundColor(Theme.CARD)
            .fontColor(Theme.TEXT)
            .backgroundColor(Theme.CARD2)
            .onSelect((index: number) => {
              this.cityIdx = index
              const c: City = CITIES[index]
              this.lon = c.lon
              this.lonText = c.lon.toFixed(2)
            })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 6 }) {
          Text('经度（东经）').fontSize(12).fontColor(Theme.DIM)
          TextInput({ text: this.lonText })
            .type(InputType.Number)
            .fontSize(15).fontColor(Theme.TEXT)
            .backgroundColor(Theme.CARD2)
            .onChange((value: string) => {
              this.lonText = value
              const v = parseFloat(value)
              this.lon = isNaN(v) ? this.lon : v
            })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // 开关
      Row() {
        Toggle({ type: ToggleType.Switch, isOn: this.dst })
          .selectedColor(Theme.RED)
          .onChange((v: boolean) => { this.dst = v })
        Text('出生时为夏令时（+1小时）').fontSize(13).fontColor(Theme.TEXT).margin({ left: 8 })
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.unknownHour })
          .selectedColor(Theme.RED)
          .onChange((v: boolean) => { this.unknownHour = v })
        Text('时辰未知').fontSize(13).fontColor(Theme.TEXT).margin({ left: 8 })
      }
      .width('100%')

      Button('排 盘')
        .width('100%')
        .height(42)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor(Theme.RED)
        .borderRadius(10)
        .onClick(() => this.onCompute())
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.CARD)
    .borderRadius(14)
    .border({ width: 1, color: Theme.LINE })
  }
}
