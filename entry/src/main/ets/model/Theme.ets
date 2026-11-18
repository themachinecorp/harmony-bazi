/**
 * 设计令牌：极客终端风（近黑底 + 荧光绿/青 + 等宽字体）
 * 间距 4/8/12/16/24/32；面板只描边不投影；数字一律等宽对齐
 */
export class Theme {
  // 背景层
  static readonly BG: string = '#04070A'
  static readonly CARD: string = '#090D13'
  static readonly CARD2: string = '#0C1219'
  static readonly LINE: string = '#1B2733'
  static readonly LINE_SOFT: string = '#131C25'

  // 文字
  static readonly TEXT: string = '#C9D6E2'
  static readonly TEXT2: string = '#8FA3B5'
  static readonly DIM: string = '#54677A'

  // 强调（终端荧光）
  static readonly GREEN: string = '#00FF9C'
  static readonly CYAN: string = '#33E0FF'
  static readonly AMBER: string = '#FFB000'
  static readonly RED: string = '#FF4D5A'

  /** 等宽字体（缺失时自动回退系统默认） */
  static readonly MONO: string = 'HarmonyOS Sans Mono'

  /** 五行色：木=绿 火=红 土=琥珀 金=白 水=青 */
  static readonly WX: Map<string, string> = new Map([
    ['木', '#00FF9C'],
    ['火', '#FF4D5A'],
    ['土', '#FFB000'],
    ['金', '#E6EDF3'],
    ['水', '#33E0FF']
  ])

  static wxColor(wx: string): string {
    const c: string | undefined = Theme.WX.get(wx)
    return c === undefined ? Theme.TEXT : c
  }

  // 间距
  static readonly S1: number = 4
  static readonly S2: number = 8
  static readonly S3: number = 12
  static readonly S4: number = 16
  static readonly S6: number = 24
  static readonly S8: number = 32

  // 圆角（终端风用小圆角，更硬朗）
  static readonly R_CARD: number = 4
  static readonly R_SM: number = 3
  static readonly R_PILL: number = 2
}
