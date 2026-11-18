/**
 * 设计令牌：暗墨底 + 金/朱红单强色 + 五行语义色
 * 间距用 4/8/12/16/24/32 网格；卡片只用描边不用阴影（阴影只留给主按钮和评分块）
 */
export class Theme {
  // 背景层
  static readonly BG: string = '#0B0D12'
  static readonly CARD: string = '#141821'
  static readonly CARD2: string = '#10131A'
  static readonly LINE: string = '#222836'
  static readonly LINE_SOFT: string = '#1A1F29'

  // 文字
  static readonly TEXT: string = '#ECE9E4'
  static readonly TEXT2: string = '#A8AEBE'
  static readonly DIM: string = '#767D8E'

  // 强调色（单一强色：金）
  static readonly GOLD: string = '#D9B36C'
  static readonly GOLD_DIM: string = '#8C7546'
  static readonly RED: string = '#C2410C'
  static readonly RED_SOFT: string = '#8A2F08'
  static readonly OK: string = '#5FB88A'
  static readonly BAD: string = '#E0654F'

  // 五行语义色（只用于干支文字与色条，承载含义不是装饰）
  static readonly WX: Map<string, string> = new Map([
    ['木', '#5FB88A'],
    ['火', '#E0654F'],
    ['土', '#D9B36C'],
    ['金', '#E6E2D8'],
    ['水', '#6E9BD8']
  ])

  static wxColor(wx: string): string {
    const c: string | undefined = Theme.WX.get(wx)
    return c === undefined ? Theme.TEXT : c
  }

  // 主按钮渐变
  static readonly RED_GRADIENT: Array<[ResourceColor, number]> = [['#C2410C', 0.0], ['#8A2F08', 1.0]]

  // 间距
  static readonly S1: number = 4
  static readonly S2: number = 8
  static readonly S3: number = 12
  static readonly S4: number = 16
  static readonly S6: number = 24
  static readonly S8: number = 32

  // 圆角
  static readonly R_CARD: number = 20
  static readonly R_SM: number = 12
  static readonly R_PILL: number = 999
}
