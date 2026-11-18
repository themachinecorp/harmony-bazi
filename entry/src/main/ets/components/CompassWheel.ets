/**
 * 罗盘轮盘（装饰）：12 地支刻度缓慢自转 + 内圈呼吸
 * 纯 border/rotate/animation，无图片资源
 */
import { Theme } from '../model/Theme'

@Component
export struct CompassWheel {
  @Prop wheelSize: number = 220
  @State private spin: boolean = false

  aboutToAppear(): void {
    setTimeout(() => { this.spin = true }, 60)
  }

  private ticks(): number[] {
    return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 外光晕（呼吸）
      Column()
        .width('92%').height('92%').borderRadius('50%')
        .border({ width: 1, color: '#33D9B36C' })
        .scale({ x: this.spin ? 1.14 : 0.98, y: this.spin ? 1.14 : 0.98 })
        .opacity(this.spin ? 0.28 : 0.75)
        .animation({ duration: 3200, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate })

      // 刻度环（自转）
      Stack({ alignContent: Alignment.Center }) {
        ForEach(this.ticks(), (i: number) => {
          Stack({ alignContent: Alignment.Top }) {
            Column()
              .width(i % 3 === 0 ? 2.5 : 1.5)
              .height(i % 3 === 0 ? 15 : 8)
              .borderRadius(2)
              .backgroundColor(i % 3 === 0 ? '#D9B36C' : '#6B5730')
          }
          .width('100%').height('100%')
          .rotate({ angle: i * 30 })
        }, (i: number) => i.toString())
      }
      .width('100%').height('100%')
      .rotate({ angle: this.spin ? 360 : 0, x: 0, y: 0, z: 1 })
      .animation({ duration: 48000, curve: Curve.Linear, iterations: -1 })

      // 内圈
      Column()
        .width('62%').height('62%').borderRadius('50%')
        .border({ width: 1, color: '#4DD9B36C' })
      Column()
        .width('46%').height('46%').borderRadius('50%')
        .border({ width: 1, color: '#22D9B36C' })
    }
    .width(this.wheelSize)
    .height(this.wheelSize)
  }
}
