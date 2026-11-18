/**
 * 终端面板：等宽标题条 + 1px 描边 + 可选扫描线
 */
import { Theme } from '../model/Theme'

@Component
export struct TermPanel {
  /** 面板编号/标签，如 "01 / 命盘四柱" */
  title: string = ''
  /** 右上角状态，如 "READY" */
  status: string = ''
  @BuilderParam content: () => void

  build() {
    Column({ space: 0 }) {
      // 标题条
      Row({ space: 6 }) {
        Text('┌─').fontSize(11).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
        Text(this.title).fontSize(12).fontColor(Theme.GREEN).fontFamily(Theme.MONO).letterSpacing(1)
        Blank()
        if (this.status.length > 0) {
          Text('[' + this.status + ']')
            .fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO)
        }
        Text('┐').fontSize(11).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
      }
      .width('100%')
      .padding({ left: 2, right: 2, top: 4, bottom: 4 })

      Row() {
        Text('│').fontSize(11).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
        Column({ space: 10 }) {
          this.content()
        }
        .layoutWeight(1)
        .padding({ left: 10, right: 10, top: 4, bottom: 10 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row() {
        Text('└' + '─'.repeat(28) + '┘').fontSize(11).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
      }
      .width('100%')
      .padding({ left: 2, right: 2, top: 0, bottom: 4 })
    }
    .width('100%')
    .backgroundColor(Theme.CARD)
    .border({ width: 1, color: Theme.LINE })
    .borderRadius(Theme.R_CARD)
  }
}
