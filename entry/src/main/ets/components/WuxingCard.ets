/**
 * 五行补益板块：喜什么五行 → 做什么 / 不做什么
 */
import { Chart, WxGuide, WuxingPlan, wuxingPlan, wxGuide } from '../model/Bazi'
import { Theme } from '../model/Theme'
import { TermPanel } from './TermPanel'

@Component
export struct WuxingCard {
  @Prop chart: Chart
  @Prop plan: WuxingPlan

  private guide(wx: string): WxGuide {
    return wxGuide(wx)
  }

  build() {
    TermPanel({
      title: '04 / 五行补益 WUXING',
      status: '日主 ' + this.chart.day.ganChar + this.chart.dayWx,
      content: () => {
        this.body()
      }
    })
  }

  @Builder
  private body() {
    Column({ space: 14 }) {
      // 推导说明
      Column({ space: 4 }) {
        Text('> 推导：' + this.chart.strength.stateText + ' → 喜 ' + this.plan.favGods +
          ' → 补 ' + this.plan.favText + '　忌 ' + this.plan.unfavGods + ' → 少 ' + this.plan.unfavText)
          .fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).lineHeight(16)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 喜用五行大字
      Row({ space: 8 }) {
        Text('补').fontSize(12).fontColor(Theme.GREEN).fontFamily(Theme.MONO)
        ForEach(this.plan.favWx, (w: string) => {
          Text(w)
            .fontSize(34).fontWeight(FontWeight.Bold).fontColor(Theme.wxColor(w))
            .fontFamily(Theme.MONO)
            .textShadow({ radius: 14, color: Theme.wxColor(w), offsetX: 0, offsetY: 0 })
            .padding({ left: 12, right: 12, top: 2, bottom: 2 })
            .border({ width: 1, color: Theme.wxColor(w) })
            .borderRadius(Theme.R_SM)
        }, (w: string) => w)
      }
      .width('100%')

      // 每个喜用五行的补法
      ForEach(this.plan.favWx, (w: string) => {
        this.favBlock(w)
      }, (w: string) => w)

      // 忌神
      if (this.plan.unfavWx.length > 0) {
        Column({ space: 8 }) {
          Text('- 忌 ' + this.plan.unfavText + '（少用）')
            .fontSize(12).fontColor(Theme.RED).fontFamily(Theme.MONO)
          ForEach(this.plan.unfavWx, (w: string) => {
            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(w).fontSize(20).fontWeight(FontWeight.Bold).fontColor(Theme.wxColor(w)).fontFamily(Theme.MONO)
                Text(this.guide(w).tip).fontSize(10).fontColor(Theme.DIM).fontFamily(Theme.MONO).layoutWeight(1)
              }
              .width('100%')
              this.line('颜色', this.guide(w).color)
              this.line('方位', this.guide(w).dir)
              this.line('物品', this.guide(w).item)
              this.line('忌', this.guide(w).dont)
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#1A0E10')
            .border({ width: 1, color: '#3A1D22' })
            .borderRadius(Theme.R_SM)
            .alignItems(HorizontalAlign.Start)
          }, (w: string) => w)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
  }

  @Builder
  private favBlock(w: string) {
    Column({ space: 4 }) {
      Row({ space: 8 }) {
        Text(w).fontSize(22).fontWeight(FontWeight.Bold).fontColor(Theme.wxColor(w)).fontFamily(Theme.MONO)
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
    .width('100%')
    .padding(10)
    .backgroundColor('#0C1A14')
    .border({ width: 1, color: '#1D4A35' })
    .borderRadius(Theme.R_SM)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private line(k: string, v: string) {
    Row({ space: 6 }) {
      Text(k).fontSize(10).fontColor(Theme.GREEN).fontFamily(Theme.MONO).width(30)
      Text(v).fontSize(11).fontColor(Theme.TEXT2).fontFamily(Theme.MONO).layoutWeight(1).lineHeight(17)
    }
    .width('100%')
  }
}
