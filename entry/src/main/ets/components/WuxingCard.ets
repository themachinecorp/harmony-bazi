/**
 * 五行补益（子平判盘版）：格局 / 旺衰推导 / 喜忌五行 / 补法
 */
import { Chart, JudgeResult, WxGuide, wxGuide } from '../model/Bazi'
import { Theme } from '../model/Theme'
import { TermPanel } from './TermPanel'

@Component
export struct WuxingCard {
  @Prop chart: Chart

  private judge(): JudgeResult {
    return this.chart.strength.judge
  }

  private guide(wx: string): WxGuide {
    return wxGuide(wx)
  }

  build() {
    TermPanel({
      title: '04 / 五行补益 WUXING',
      status: this.chart.strength.geJu,
      content: () => {
        this.body()
      }
    })
  }

  @Builder
  private body() {
    Column({ space: 14 }) {
      // 判盘推导
      Column({ space: 3 }) {
        Text('> 判盘 DERIVATION').fontSize(10).fontColor(Theme.CYAN).fontFamily(Theme.MONO)
        ForEach(this.judge().reasons, (r: string) => {
          Text('· ' + r).fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).lineHeight(15)
        }, (r: string) => r)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      if (this.judge().follow.isFollow) {
        Row() {
          Text('⚠ ' + this.judge().follow.kind + '：' + this.judge().follow.note)
            .fontSize(10).fontColor(Theme.AMBER).fontFamily(Theme.MONO).lineHeight(15)
        }
        .width('100%').padding(8)
        .backgroundColor('#1A1508')
        .border({ width: 1, color: Theme.AMBER })
        .borderRadius(Theme.R_SM)
      }

      // 喜用五行
      Row({ space: 8 }) {
        Text('补').fontSize(12).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
        ForEach(this.judge().favWx, (w: string) => {
          Text(w)
            .fontSize(32).fontWeight(FontWeight.Bold).fontColor(Theme.wxColor(w)).fontFamily(Theme.MONO)
            .textShadow({ radius: 12, color: Theme.wxColor(w), offsetX: 0, offsetY: 0 })
            .padding({ left: 12, right: 12, top: 2, bottom: 2 })
            .border({ width: 1, color: Theme.wxColor(w) })
            .borderRadius(Theme.R_SM)
        }, (w: string) => w)
      }
      .width('100%')

      // 每个喜用五行的补法
      ForEach(this.judge().favWx, (w: string) => {
        this.favBlock(w)
      }, (w: string) => w)

      // 土的特殊说明
      if (this.judge().favWx.indexOf('土') >= 0 || this.judge().unfavWx.indexOf('土') >= 0) {
        Column({ space: 3 }) {
          Text('> 土分燥湿 SOIL').fontSize(10).fontColor(Theme.AMBER).fontFamily(Theme.MONO)
          Text('· 湿土（辰、丑）能蓄水生金，可取；燥土（未、戌）埋金，慎之').fontSize(10)
            .fontColor(Theme.TEXT2).fontFamily(Theme.MONO).lineHeight(15)
          Text('· 本局地支：' + this.zhisText()).fontSize(10)
            .fontColor(Theme.DIM).fontFamily(Theme.MONO).lineHeight(15)
        }
        .width('100%').padding(8)
        .backgroundColor('#12100A')
        .border({ width: 1, color: '#3A3118' })
        .borderRadius(Theme.R_SM)
        .alignItems(HorizontalAlign.Start)
      }

      // 忌神
      if (this.judge().unfavWx.length > 0) {
        Column({ space: 8 }) {
          Text('- 忌 ' + this.judge().unfavWx.join('、') + '（少用）')
            .fontSize(12).fontColor(Theme.RED).fontFamily(Theme.MONO)
          ForEach(this.judge().unfavWx, (w: string) => {
            Column({ space: 3 }) {
              Row({ space: 8 }) {
                Text(w).fontSize(18).fontWeight(FontWeight.Bold).fontColor(Theme.wxColor(w)).fontFamily(Theme.MONO)
                Text(this.guide(w).tip).fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).layoutWeight(1)
              }
              .width('100%')
              this.line('颜色', this.guide(w).color)
              this.line('方位', this.guide(w).dir)
              this.line('物品', this.guide(w).item)
              this.line('忌', this.guide(w).dont)
            }
            .width('100%').padding(10)
            .backgroundColor('#160E10')
            .border({ width: 1, color: '#3A1D22' })
            .borderRadius(Theme.R_SM)
            .alignItems(HorizontalAlign.Start)
          }, (w: string) => w)
        }
        .width('100%').alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
  }

  private zhisText(): string {
    const c: Chart = this.chart
    return c.year.zhiChar + '、' + c.month.zhiChar + '、' + c.day.zhiChar + '、' + c.hour.zhiChar
  }

  @Builder
  private favBlock(w: string) {
    Column({ space: 3 }) {
      Row({ space: 8 }) {
        Text(w).fontSize(20).fontWeight(FontWeight.Bold).fontColor(Theme.wxColor(w)).fontFamily(Theme.MONO)
        Text(this.guide(w).tip).fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).layoutWeight(1)
      }
      .width('100%')
      this.line('颜色', this.guide(w).color)
      this.line('方位', this.guide(w).dir)
      this.line('数字', this.guide(w).num)
      this.line('物品', this.guide(w).item)
      this.line('饮食', this.guide(w).diet)
      this.line('行业', this.guide(w).career)
      this.line('宜', this.guide(w).do)
    }
    .width('100%').padding(10)
    .backgroundColor('#0C1A14')
    .border({ width: 1, color: '#1D4A35' })
    .borderRadius(Theme.R_SM)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private line(k: string, v: string) {
    Row({ space: 6 }) {
      Text(k).fontSize(10).fontColor(Theme.GREEN).fontFamily(Theme.MONO).width(30)
      Text(v).fontSize(11).fontColor(Theme.TEXT2).fontFamily(Theme.MONO).layoutWeight(1).lineHeight(16)
    }
    .width('100%')
  }
}
