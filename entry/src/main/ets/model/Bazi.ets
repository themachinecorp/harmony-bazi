/**
 * 八字排盘引擎（ArkTS 版，与 bazi-fortune/bazi.js 同算法）
 * 真太阳时 / 四柱 / 大运 / 流年 / 今日干支与运势
 * 纯计算，无 UI 依赖，可在 Node 中做类型擦除后单测
 */

export interface Term {
  name: string
  lon: number
  jd: number
}

export interface HiddenStem {
  g: string
  god: string
  wx: string
}

export interface Pillar {
  name: string
  gz: string
  gan: number
  zhi: number
  ganChar: string
  zhiChar: string
  god: string
  wx: string
  zwx: string
  hidden: HiddenStem[]
}

export interface BirthInput {
  y: number
  m: number
  d: number
  h: number
  mi: number
  lon: number
  tz: number
  gender: string
  dst: boolean
  unknownHour: boolean
}

export interface SolarInfo {
  clock: string
  lonAdjMin: number
  eotMin: number
  plain: string
  trueStr: string
  trueY: number
  trueM: number
  trueD: number
  trueH: number
  trueMi: number
}

export interface Strength {
  same: number
  other: number
  ratio: number
  state: string
  stateText: string
  fav: string[]
  unfav: string[]
  favText: string
  unfavText: string
  dayWx: string
  tiaohou: string
}

export interface YunStep {
  name: string
  gan: number
  zhi: number
  god: string
  wx: string
  zwx: string
  ageFrom: number
  ageTo: number
  yearFrom: number
  yearTo: number
}

export interface YunInfo {
  dir: number
  dirText: string
  days: number
  startAge: number
  startText: string
  qiuYun: string
  list: YunStep[]
}

export interface Chart {
  year: Pillar
  month: Pillar
  day: Pillar
  hour: Pillar
  dayGan: number
  dayWx: string
  strength: Strength
  yun: YunInfo
  solar: SolarInfo
  jiePrev: Term
  jieNext: Term
  input: BirthInput
}

export interface NowSpec {
  y: number
  m: number
  d: number
  h: number
  mi: number
}

export interface TodayInfo {
  year: Pillar
  month: Pillar
  day: Pillar
  hour: Pillar
  solarYear: number
  jiePrev: Term
  jieNext: Term
}

export interface Signal {
  label: string
  value: number
  weight: number
  detail: string
}

export interface Fortune {
  score: number
  label: string
  level: number
  sig: Signal[]
  notes: string[]
  yi: string[]
  ji: string[]
  today: TodayInfo
  curYunName: string
  curYunFrom: number
  curYunTo: number
  age: number
}

export interface YearItem {
  year: number
  name: string
  gan: number
  zhi: number
  god: string
  rel: string
}

export interface City {
  name: string
  lon: number
}

const PI: number = Math.PI
const D: number = PI / 180
const GAN: string[] = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸']
const ZHI: string[] = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥']
const GAN_WX: string[] = ['木', '木', '火', '火', '土', '土', '金', '金', '水', '水']
const ZHI_WX: string[] = ['水', '土', '木', '木', '土', '火', '火', '土', '金', '金', '土', '水']
const GYY: number[] = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1]
const HIDDEN: string[][] = [['癸'], ['己', '癸', '辛'], ['甲', '丙', '戊'], ['乙'], ['戊', '乙', '癸'], ['丙', '戊', '庚'],
  ['丁', '己'], ['己', '丁', '乙'], ['庚', '壬', '戊'], ['辛'], ['戊', '辛', '丁'], ['壬', '甲']]
const HIDDEN_W: number[][] = [[1], [1, 0.5, 0.3], [1, 0.5, 0.3], [1], [1, 0.5, 0.3], [1, 0.5, 0.3],
  [1, 0.5], [1, 0.5, 0.3], [1, 0.5, 0.3], [1], [1, 0.5, 0.3], [1, 0.3]]

// 关系表一律按地支序号（子0…亥11）索引
const LIUHE: number[] = [1, 0, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2]
const LIUCHONG: number[] = [6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5]
const LIUHAI: number[] = [7, 6, 5, 4, 3, 2, 1, 0, 11, 10, 9, 8]
const XING3: number[][] = [[2, 5, 8], [1, 10, 7]]
const ZIXING: number[] = [-1, -1, -1, -1, 4, -1, 6, -1, -1, 9, -1, 11]
const HONGLUAN: number[] = [3, 2, 1, 0, 11, 10, 9, 8, 7, 6, 5, 4]
const TIANXI: number[] = [6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5]
const TIANDE: string[] = ['壬', '庚', '丁', '壬', '甲', '丙', '壬', '庚', '壬', '甲', '丙', '壬']

export const CITIES: City[] = [
  { name: '北京', lon: 116.41 }, { name: '上海', lon: 121.47 }, { name: '广州', lon: 113.26 }, { name: '深圳', lon: 114.06 },
  { name: '天津', lon: 117.20 }, { name: '重庆', lon: 106.55 }, { name: '成都', lon: 104.07 }, { name: '杭州', lon: 120.15 },
  { name: '南京', lon: 118.80 }, { name: '武汉', lon: 114.31 }, { name: '西安', lon: 108.95 }, { name: '苏州', lon: 120.62 },
  { name: '长沙', lon: 112.94 }, { name: '青岛', lon: 120.38 }, { name: '沈阳', lon: 123.43 }, { name: '大连', lon: 121.62 },
  { name: '哈尔滨', lon: 126.53 }, { name: '长春', lon: 125.32 }, { name: '济南', lon: 117.00 }, { name: '郑州', lon: 113.63 },
  { name: '厦门', lon: 118.09 }, { name: '福州', lon: 119.30 }, { name: '昆明', lon: 102.83 }, { name: '贵阳', lon: 106.63 },
  { name: '南宁', lon: 108.37 }, { name: '海口', lon: 110.35 }, { name: '兰州', lon: 103.83 }, { name: '乌鲁木齐', lon: 87.62 },
  { name: '拉萨', lon: 91.11 }, { name: '西宁', lon: 101.78 }, { name: '银川', lon: 106.23 }, { name: '呼和浩特', lon: 111.75 },
  { name: '石家庄', lon: 114.52 }, { name: '太原', lon: 112.55 }, { name: '合肥', lon: 117.28 }, { name: '南昌', lon: 115.89 },
  { name: '宁波', lon: 121.55 }, { name: '无锡', lon: 120.30 }, { name: '东莞', lon: 113.75 }, { name: '佛山', lon: 113.12 },
  { name: '温州', lon: 120.70 }, { name: '金华', lon: 119.65 }, { name: '南通', lon: 120.86 }, { name: '常州', lon: 119.95 },
  { name: '徐州', lon: 117.18 }, { name: '汕头', lon: 116.68 }, { name: '烟台', lon: 121.39 }, { name: '桂林', lon: 110.29 },
  { name: '丽江', lon: 100.23 }, { name: '敦煌', lon: 94.66 }
]

/* ---------- 截断 VSOP87（地球日心黄经/黄纬，系数按千年 τ 标定） ---------- */
const L0: number[][] = [
  [175347046, 0, 0], [3341656, 4.6692568, 6283.07585], [34894, 4.6261, 12566.1517], [3497, 2.7441, 5753.3849],
  [3418, 2.8289, 3.5231], [3136, 3.6277, 77713.7715], [2676, 4.4181, 7860.4194], [2343, 6.1352, 3930.2097],
  [1324, 0.7425, 11506.7698], [1273, 2.0371, 529.691], [1199, 1.1096, 1577.3435], [990, 5.233, 5884.927],
  [902, 2.045, 26.298], [857, 3.508, 398.149], [780, 1.179, 5223.694], [753, 2.533, 5507.553],
  [505, 4.583, 18849.228], [492, 4.205, 775.523], [357, 2.92, 0.067], [317, 5.849, 11790.629],
  [284, 1.899, 796.298], [271, 0.315, 10977.079], [243, 0.345, 5486.778], [206, 4.806, 2544.314],
  [205, 1.869, 5573.143], [202, 2.458, 6069.777], [156, 0.833, 213.299], [132, 3.411, 2942.463],
  [126, 1.083, 20.775], [115, 0.645, 0.98], [103, 0.636, 4694.003], [102, 0.976, 15720.839],
  [102, 4.267, 7.114], [99, 6.21, 2146.17], [98, 0.68, 155.42], [86, 5.98, 161000.69],
  [85, 1.3, 6275.96], [85, 3.67, 71430.7], [80, 1.81, 17260.15], [79, 3.04, 12036.46],
  [75, 1.76, 5088.63], [74, 3.5, 3154.69], [74, 4.68, 801.82], [70, 0.83, 9437.76],
  [62, 3.98, 8827.39], [61, 1.82, 7084.9], [57, 2.78, 6286.6], [56, 4.39, 14143.5],
  [56, 3.47, 6279.55], [52, 0.19, 12139.55], [52, 1.33, 1748.02], [51, 0.28, 5856.48],
  [49, 0.49, 1194.45], [41, 5.37, 8429.24], [41, 2.4, 19651.05], [39, 6.17, 10447.39],
  [37, 6.04, 10213.29], [37, 2.57, 1059.38], [36, 1.71, 2352.87], [36, 1.78, 6812.77],
  [33, 0.59, 17789.85], [30, 0.44, 83996.85], [30, 2.74, 1349.87], [25, 3.16, 4690.48]]
const L1: number[][] = [
  [628331966747, 0, 0], [206059, 2.678235, 6283.07585], [4303, 2.6351, 12566.1517], [425, 1.59, 3.523],
  [119, 5.796, 26.298], [109, 2.966, 1577.344], [93, 2.59, 18849.23], [72, 1.14, 529.69],
  [68, 1.87, 398.15], [67, 4.41, 5507.55], [59, 2.89, 5223.69], [56, 2.17, 155.42],
  [45, 0.4, 796.3], [36, 0.47, 775.52], [29, 2.65, 7.11], [21, 5.34, 0.98],
  [19, 1.85, 5486.78], [19, 4.97, 213.3], [17, 2.99, 6275.96], [16, 0.03, 2544.31],
  [16, 1.43, 2146.17], [15, 1.21, 10977.08], [12, 2.83, 1748.02], [12, 3.26, 5088.63],
  [12, 5.27, 1194.45], [12, 2.08, 4694], [11, 0.77, 553.57], [10, 1.3, 6286.6],
  [10, 4.24, 1349.87], [9, 2.7, 242.73], [9, 5.64, 951.72], [8, 5.3, 2352.87],
  [6, 2.65, 9437.76], [6, 4.67, 4690.48]]
const L2: number[][] = [
  [52919, 0, 0], [8720, 1.0721, 6283.0758], [309, 0.867, 12566.152], [27, 0.05, 3.52],
  [16, 5.19, 26.3], [16, 3.68, 155.42], [10, 0.76, 18849.23], [9, 2.06, 77713.77],
  [7, 0.83, 775.52], [5, 4.66, 1577.34], [4, 1.03, 7.11], [4, 3.44, 5573.14],
  [3, 5.14, 796.3], [3, 6.05, 5507.55], [3, 1.19, 242.73], [3, 6.12, 529.69],
  [3, 0.31, 398.15], [3, 2.28, 553.57], [2, 4.38, 5223.69], [2, 3.75, 0.98]]
const L3: number[][] = [[289, 5.844, 6283.076], [35, 0, 0], [17, 5.49, 12566.15], [3, 5.2, 155.42], [1, 4.72, 3.52],
  [1, 5.3, 18849.23], [1, 5.97, 242.73]]
const L4: number[][] = [[114, 3.142, 0], [8, 4.13, 6283.08], [1, 3.84, 12566.15]]
const L5: number[][] = [[1, 3.14, 0]]
const B0: number[][] = [[280, 3.199, 84334.662], [102, 5.422, 5507.553], [80, 3.88, 5223.69], [44, 3.7, 2352.87],
  [32, 4.0, 1577.34]]
const B1: number[][] = [[9, 3.9, 5507.55], [6, 1.73, 5223.69]]

/* ---------- 基础历法 ---------- */
function norm(a: number): number {
  const x: number = a % 360
  return x < 0 ? x + 360 : x
}

function wrap180(a: number): number {
  const x: number = norm(a)
  return x > 180 ? x - 360 : x
}

function mod(a: number, n: number): number {
  return ((a % n) + n) % n
}

export function pad2(n: number): string {
  return (n < 10 ? '0' : '') + n.toString()
}

function jdFromUTC(y: number, m: number, d: number, h: number, mi: number): number {
  let yy: number = y
  let mm: number = m
  if (mm <= 2) {
    yy -= 1
    mm += 12
  }
  const A: number = Math.floor(yy / 100)
  const B: number = 2 - A + Math.floor(A / 4)
  return Math.floor(365.25 * (yy + 4716)) + Math.floor(30.6001 * (mm + 1)) + d + B - 1524.5
    + (h + mi / 60) / 24
}

export function jdnOf(y: number, m: number, d: number): number {
  let yy: number = y
  let mm: number = m
  if (mm <= 2) {
    yy -= 1
    mm += 12
  }
  const A: number = Math.floor(yy / 100)
  const B: number = 2 - A + Math.floor(A / 4)
  return Math.floor(365.25 * (yy + 4716)) + Math.floor(30.6001 * (mm + 1)) + d + B - 1524
}

export interface Cal {
  y: number
  m: number
  d: number
  h: number
  mi: number
}

export function jdToCal(jd: number): Cal {
  const z: number = Math.floor(jd + 0.5)
  const f: number = jd + 0.5 - z
  const alpha: number = Math.floor((z - 1867216.25) / 36524.25)
  const A: number = z + 1 + alpha - Math.floor(alpha / 4)
  const B: number = A + 1524
  const C: number = Math.floor((B - 122.1) / 365.25)
  const D: number = Math.floor(365.25 * C)
  const E: number = Math.floor((B - D) / 30.6001)
  const day: number = B - D - Math.floor(30.6001 * E)
  const month: number = E < 14 ? E - 1 : E - 13
  const year: number = month > 2 ? C - 4716 : C - 4715
  const hours: number = f * 24
  const hh: number = Math.floor(hours)
  const mi: number = Math.floor((hours - hh) * 60)
  return { y: year, m: month, d: day, h: hh, mi: mi }
}

export function jdToLocalStr(jd: number, tz: number): string {
  const c: Cal = jdToCal(jd + tz / 24)
  return c.y.toString() + '-' + pad2(c.m) + '-' + pad2(c.d) + ' ' + pad2(c.h) + ':' + pad2(c.mi)
}

/* ---------- 太阳视黄经 ---------- */
function vsop(terms: number[][], t: number): number {
  let s: number = 0
  for (let i = 0; i < terms.length; i++) {
    s += terms[i][0] * Math.cos(terms[i][1] + terms[i][2] * t)
  }
  return s * 1e-8
}

function earthL(tau: number): number {
  return vsop(L0, tau) + tau * (vsop(L1, tau) + tau * (vsop(L2, tau) + tau * (vsop(L3, tau)
    + tau * (vsop(L4, tau) + tau * vsop(L5, tau)))))
}

function earthB(tau: number): number {
  return vsop(B0, tau) + tau * vsop(B1, tau)
}

function nutation(T: number): number {
  const om: number = 125.04452 - 1934.136261 * T + 0.0020708 * T * T
  const Ls: number = 280.4665 + 36000.7698 * T
  const Lm: number = 218.3165 + 481267.8813 * T
  return (-17.20 * Math.sin(om * D) - 1.32 * Math.sin(2 * Ls * D) - 0.23 * Math.sin(2 * Lm * D)
    + 0.21 * Math.sin(2 * om * D)) / 3600
}

export function sunLon(jd: number): number {
  const T: number = (jd - 2451545) / 36525
  const tau: number = T / 10
  const th: number = (earthL(tau) + PI - earthB(tau)) * (180 / PI)
  return norm(th + nutation(T) - 0.0056916)
}

function obliquity(T: number): number {
  return 23.439291111 - 0.0130041667 * T - 1.6389e-7 * T * T + 5.036e-7 * T * T * T
}

/** 均时差（分钟）：真太阳时 - 平太阳时 */
export function eqOfTime(jd: number): number {
  const T: number = (jd - 2451545) / 36525
  const lam: number = sunLon(jd)
  const eps: number = obliquity(T) * D
  const ra: number = Math.atan2(Math.cos(eps) * Math.sin(lam * D), Math.cos(lam * D)) * (180 / PI)
  const L0m: number = 280.4665 + 36000.7698 * T
  const E: number = L0m - 0.0057183 - ra + nutation(T) * Math.cos(eps)
  return wrap180(E) * 4
}

/* ---------- 节气 ---------- */
const TERM_LON: number[][] = [[285, 0], [300, 0], [315, 0], [330, 0], [345, 0], [360, 0], [375, 0], [390, 0],
  [405, 0], [420, 0], [435, 0], [450, 0], [465, 0], [480, 0], [495, 0], [510, 0], [525, 0], [540, 0],
  [555, 0], [570, 0], [585, 0], [600, 0], [615, 0], [630, 0]]
const TERM_NAME: string[] = ['小寒', '大寒', '立春', '雨水', '惊蛰', '春分', '清明', '谷雨', '立夏', '小满', '芒种', '夏至',
  '小暑', '大暑', '立秋', '处暑', '白露', '秋分', '寒露', '霜降', '立冬', '小雪', '大雪', '冬至']

// 十二节：名称、太阳黄经、月建地支
const JIE_NAME: string[] = ['立春', '惊蛰', '清明', '立夏', '芒种', '小暑', '立秋', '白露', '寒露', '立冬', '大雪', '小寒']
const JIE_LON: number[] = [315, 345, 15, 45, 75, 105, 135, 165, 195, 225, 255, 285]
const JIE_BRANCH: string[] = ['寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥', '子', '丑']

let termCache: Map<number, Term[]> = new Map()

export function termsOfYear(year: number): Term[] {
  const cached: Term[] | undefined = termCache.get(year)
  if (cached !== undefined) {
    return cached
  }
  const jd0: number = jdFromUTC(year, 1, 1, 0, 0)
  const l0: number = sunLon(jd0)
  const out: Term[] = []
  for (let i = 0; i < TERM_LON.length; i++) {
    const target: number = TERM_LON[i][0]
    let jd: number = jd0 + (target - l0) / 0.9856473
    for (let k = 0; k < 8; k++) {
      const diff: number = wrap180(sunLon(jd) - norm(target))
      if (Math.abs(diff) < 1e-9) {
        break
      }
      const der: number = (sunLon(jd + 0.02) - sunLon(jd - 0.02)) / 0.04
      jd -= diff / der
    }
    out.push({ name: TERM_NAME[i], lon: norm(target), jd: jd })
  }
  termCache.set(year, out)
  return out
}

function jieOfYear(year: number): Term[] {
  const all: Term[] = termsOfYear(year)
  const out: Term[] = []
  for (let i = 0; i < all.length; i++) {
    for (let j = 0; j < JIE_NAME.length; j++) {
      if (all[i].name === JIE_NAME[j]) {
        out.push({ name: JIE_NAME[j], lon: JIE_LON[j], jd: all[i].jd })
      }
    }
  }
  return out
}

/** 出生时刻所处的月令（前后节）。jdClock 为钟表读数帧，节气按北京时间比较 */
function jieBracket(jdClock: number, year: number, tz: number): Term[] {
  const all: Term[] = []
  const ys: number[] = [year - 1, year, year + 1]
  for (let i = 0; i < ys.length; i++) {
    const part: Term[] = jieOfYear(ys[i])
    for (let j = 0; j < part.length; j++) {
      all.push(part[j])
    }
  }
  all.sort((a: Term, b: Term): number => a.jd - b.jd)
  let prev: Term = all[0]
  let next: Term = all[all.length - 1]
  let found: boolean = false
  for (let i = 0; i < all.length; i++) {
    if (all[i].jd + tz / 24 <= jdClock) {
      prev = all[i]
    } else {
      next = all[i]
      found = true
      break
    }
  }
  if (!found) {
    next = all[all.length - 1]
  }
  return [prev, next]
}

/* ---------- 干支 ---------- */
export function gzName(idx: number): string {
  const i: number = mod(idx, 60)
  return GAN[i % 10] + ZHI[i % 12]
}

function gzIndex(gan: number, zhi: number): number {
  for (let i = 0; i < 60; i++) {
    if (i % 10 === gan && i % 12 === zhi) {
      return i
    }
  }
  return 0
}

export function ganIdx(ch: string): number {
  for (let i = 0; i < GAN.length; i++) {
    if (GAN[i] === ch) {
      return i
    }
  }
  return 0
}

function zhiIdx(ch: string): number {
  for (let i = 0; i < ZHI.length; i++) {
    if (ZHI[i] === ch) {
      return i
    }
  }
  return 0
}

/** 十神：以日干 day 为我，看 other（可为天干序号或天干字） */
export function tenGod(day: number, other: number): string {
  const dw: string = GAN_WX[day]
  const ow: string = GAN_WX[other]
  const same: boolean = GYY[day] === GYY[other]
  if (dw === ow) {
    return same ? '比肩' : '劫财'
  }
  if (sheng(dw) === ow) {
    return same ? '食神' : '伤官'
  }
  if (ke(dw) === ow) {
    return same ? '偏财' : '正财'
  }
  if (ke(ow) === dw) {
    return same ? '七杀' : '正官'
  }
  return same ? '偏印' : '正印'
}

function sheng(a: string): string {
  if (a === '木') {
    return '火'
  }
  if (a === '火') {
    return '土'
  }
  if (a === '土') {
    return '金'
  }
  if (a === '金') {
    return '水'
  }
  return '木'
}

function ke(a: string): string {
  if (a === '木') {
    return '土'
  }
  if (a === '土') {
    return '水'
  }
  if (a === '水') {
    return '火'
  }
  if (a === '火') {
    return '金'
  }
  return '木'
}

/** 十神归类：比 / 印 / 食 / 财 / 官 */
export function godGroup(god: string): string {
  if (god.length === 0) {
    return ''
  }
  if (god.indexOf('比') >= 0 || god.indexOf('劫') >= 0) {
    return '比'
  }
  if (god.indexOf('印') >= 0) {
    return '印'
  }
  if (god.indexOf('食') >= 0 || god.indexOf('伤') >= 0) {
    return '食'
  }
  if (god.indexOf('财') >= 0) {
    return '财'
  }
  if (god.indexOf('官') >= 0 || god.indexOf('杀') >= 0) {
    return '官'
  }
  return god.substring(0, 1)
}

/* ---------- 真太阳时 ---------- */
export interface SolarTime {
  jdTrue: number
  clockJd: number
  lonAdjMin: number
  eotMin: number
  cal: Cal
}

export function solarTime(y: number, m: number, d: number, h: number, mi: number, lon: number, tz: number): SolarTime {
  const clockJd: number = jdFromUTC(y, m, d, h, mi)
  const jdUTC: number = clockJd - tz / 24
  const lonAdjMin: number = (lon - tz * 15) * 4
  const eotMin: number = eqOfTime(jdUTC)
  const jdTrue: number = clockJd + lonAdjMin / 1440 + eotMin / 1440
  return { jdTrue: jdTrue, clockJd: clockJd, lonAdjMin: lonAdjMin, eotMin: eotMin, cal: jdToCal(jdTrue) }
}

/* ---------- 排盘 ---------- */
function emptyPillar(): Pillar {
  return { name: '', gz: '', gan: -1, zhi: -1, ganChar: '', zhiChar: '', god: '', wx: '', zwx: '', hidden: [] }
}

function addYMD(y: number, m: number, d: number, dy: number, dm: number, dd: number): string {
  const t: Date = new Date(Date.UTC(y, m - 1, d))
  t.setUTCFullYear(t.getUTCFullYear() + dy)
  t.setUTCMonth(t.getUTCMonth() + dm)
  t.setUTCDate(t.getUTCDate() + dd)
  return t.getUTCFullYear().toString() + '-' + pad2(t.getUTCMonth() + 1) + '-' + pad2(t.getUTCDate())
}

function startAgeText(yy: number, mm: number, ageDays: number): string {
  let s: string = yy.toString() + '岁'
  if (mm > 0) {
    s += mm.toString() + '个月'
  }
  if (ageDays > 0) {
    s += '零' + ageDays.toString() + '天'
  }
  return s
}

function buildPillar(gz: number, dayGan: number): Pillar {
  const gan: number = gz % 10
  const zhi: number = gz % 12
  const hidden: HiddenStem[] = []
  const stems: string[] = HIDDEN[zhi]
  for (let i = 0; i < stems.length; i++) {
    hidden.push({ g: stems[i], god: tenGod(dayGan, ganIdx(stems[i])), wx: GAN_WX[ganIdx(stems[i])] })
  }
  return {
    name: gzName(gz),
    gz: gzName(gz),
    gan: gan,
    zhi: zhi,
    ganChar: GAN[gan],
    zhiChar: ZHI[zhi],
    god: tenGod(dayGan, gan),
    wx: GAN_WX[gan],
    zwx: ZHI_WX[zhi],
    hidden: hidden
  }
}

function computeStrength(year: Pillar, month: Pillar, day: Pillar, hour: Pillar, dayGan: number): Strength {
  let same: number = 0
  let other: number = 0
  const addGan: (g: number, w: number) => void = (g: number, w: number): void => {
    const grp: string = godGroup(tenGod(dayGan, g))
    if (grp === '印' || grp === '比') {
      same += w
    } else {
      other += w
    }
  }
  const addZhi: (z: number, w: number) => void = (z: number, w: number): void => {
    const stems: string[] = HIDDEN[z]
    for (let i = 0; i < stems.length; i++) {
      const grp: string = godGroup(tenGod(dayGan, ganIdx(stems[i])))
      const v: number = w * HIDDEN_W[z][i]
      if (grp === '印' || grp === '比') {
        same += v
      } else {
        other += v
      }
    }
  }
  addGan(year.gan, 1)
  addGan(month.gan, 1)
  addGan(day.gan, 1)
  if (hour.gan >= 0) {
    addGan(hour.gan, 1)
  }
  addZhi(year.zhi, 0.8)
  addZhi(month.zhi, 1.6)
  addZhi(day.zhi, 1.2)
  if (hour.zhi >= 0) {
    addZhi(hour.zhi, 0.8)
  }
  const ratio: number = same / (same + other)
  const state: string = ratio > 0.56 ? 'strong' : (ratio < 0.44 ? 'weak' : 'mid')
  const mz: number = month.zhi
  let tiaohou: string = ''
  if (mz === 11 || mz === 0 || mz === 1) {
    tiaohou = '火'
  } else if (mz === 5 || mz === 6 || mz === 7) {
    tiaohou = '水'
  }
  let fav: string[] = []
  let unfav: string[] = []
  if (state === 'weak') {
    fav = ['印', '比']
    unfav = ['食', '财', '官']
  } else if (state === 'strong') {
    fav = ['食', '财', '官']
    unfav = ['印', '比']
  } else {
    fav = ['财', '官', '食']
    unfav = ['比']
  }
  if (tiaohou.length > 0) {
    fav = fav.slice()
    const extra: string = tiaohou === '火' ? '食' : '财'
    if (fav.indexOf(extra) < 0) {
      fav.push(extra)
    }
  }
  const labelMap: Map<string, string> = new Map([
    ['印', '印绶'], ['比', '比劫'], ['食', '食伤'], ['财', '财星'], ['官', '官杀']
  ])
  const names: string[] = []
  for (let i = 0; i < fav.length; i++) {
    const v: string | undefined = labelMap.get(fav[i])
    names.push(v === undefined ? fav[i] : v)
  }
  const unames: string[] = []
  for (let i = 0; i < unfav.length; i++) {
    const v: string | undefined = labelMap.get(unfav[i])
    unames.push(v === undefined ? unfav[i] : v)
  }
  return {
    same: Math.round(same * 100) / 100,
    other: Math.round(other * 100) / 100,
    ratio: Math.round(ratio * 1000) / 1000,
    state: state,
    stateText: state === 'strong' ? '身强' : (state === 'weak' ? '身弱' : '中和'),
    fav: fav,
    unfav: unfav,
    favText: names.join('、'),
    unfavText: unames.join('、'),
    dayWx: GAN_WX[dayGan],
    tiaohou: tiaohou
  }
}

export function buildChart(o: BirthInput): Chart {
  const tz: number = o.tz > 0 ? o.tz : 8
  let h: number = o.h
  const mi: number = o.mi
  if (o.dst) {
    h -= 1
    if (h < 0) {
      h += 24
    }
  }
  const st: SolarTime = solarTime(o.y, o.m, o.d, h, mi, o.lon, tz)
  const cal: Cal = st.cal
  const clockJd: number = st.clockJd
  const bracket: Term[] = jieBracket(clockJd, cal.y, tz)
  const prev: Term = bracket[0]
  const next: Term = bracket[1]
  const lichun: Term = termsOfYear(cal.y).filter((t: Term): boolean => t.name === '立春')[0]
  const solarYear: number = clockJd < lichun.jd + tz / 24 ? cal.y - 1 : cal.y
  const yGZ: number = mod(solarYear - 1984, 60)
  const mBranch: number = zhiIdx(jieBranchOf(prev.name))
  const yGan: number = yGZ % 10
  const yinGan: number = mod((yGan % 5) * 2 + 2, 10)
  const mGan: number = mod(yinGan + ((mBranch - 2 + 12) % 12), 10)
  const mGZ: number = gzIndex(mGan, mBranch)
  const jdn: number = jdnOf(cal.y, cal.m, cal.d) + (cal.h >= 23 ? 1 : 0)
  const dGZ: number = mod(jdn + 49, 60)
  const hourIdx: number = Math.floor(((cal.h + 1) % 24) / 2)
  const dGan: number = dGZ % 10
  const hGan: number = o.unknownHour ? -1 : mod((dGan % 5) * 2 + hourIdx, 10)

  const year: Pillar = buildPillar(yGZ, dGan)
  const month: Pillar = buildPillar(mGZ, dGan)
  const day: Pillar = buildPillar(dGZ, dGan)
  const hour: Pillar = o.unknownHour ? emptyPillar() : buildPillar(gzIndex(hGan, hourIdx), dGan)
  const strength: Strength = computeStrength(year, month, day, hour, dGan)

  const dir: number = ((GYY[yGan] === 0) === (o.gender === 'm')) ? 1 : -1
  const days: number = dir > 0 ? (next.jd + tz / 24 - clockJd) : (clockJd - (prev.jd + tz / 24))
  const yy: number = Math.floor(days / 3)
  const rem: number = days - 3 * yy
  const mm: number = Math.floor(rem * 4)
  const rem2: number = rem * 4 - mm
  const ageDays: number = Math.floor(rem2 * 30)
  const dd: number = Math.round(rem2 / 4)
  const startAge: number = yy + mm / 12 + ageDays / 360
  const qiuYun: string = addYMD(o.y, o.m, o.d, yy, mm, dd)
  const list: YunStep[] = []
  for (let i = 1; i <= 9; i++) {
    const gz: number = mod(mGZ + dir * i, 60)
    const g: number = gz % 10
    const z: number = gz % 12
    list.push({
      name: gzName(gz),
      gan: g,
      zhi: z,
      god: tenGod(dGan, g),
      wx: GAN_WX[g],
      zwx: ZHI_WX[z],
      ageFrom: Math.round((startAge + (i - 1) * 10) * 10) / 10,
      ageTo: Math.round((startAge + i * 10) * 10) / 10,
      yearFrom: o.y + yy + (i - 1) * 10,
      yearTo: o.y + yy + i * 10
    })
  }

  const plain: Cal = jdToCal(st.jdTrue - st.eotMin / 1440)
  const solar: SolarInfo = {
    clock: o.y.toString() + '-' + pad2(o.m) + '-' + pad2(o.d) + ' ' + pad2(h) + ':' + pad2(mi),
    lonAdjMin: st.lonAdjMin,
    eotMin: st.eotMin,
    plain: plain.y.toString() + '-' + pad2(plain.m) + '-' + pad2(plain.d) + ' ' + pad2(plain.h) + ':' + pad2(plain.mi),
    trueStr: cal.y.toString() + '-' + pad2(cal.m) + '-' + pad2(cal.d) + ' ' + pad2(cal.h) + ':' + pad2(cal.mi),
    trueY: cal.y,
    trueM: cal.m,
    trueD: cal.d,
    trueH: cal.h,
    trueMi: cal.mi
  }

  return {
    year: year,
    month: month,
    day: day,
    hour: hour,
    dayGan: dGan,
    dayWx: GAN_WX[dGan],
    strength: strength,
    yun: {
      dir: dir,
      dirText: dir > 0 ? '顺行' : '逆行',
      days: days,
      startAge: startAge,
      startText: startAgeText(yy, mm, ageDays),
      qiuYun: qiuYun,
      list: list
    },
    solar: solar,
    jiePrev: prev,
    jieNext: next,
    input: o
  }
}

function jieBranchOf(name: string): string {
  for (let i = 0; i < JIE_NAME.length; i++) {
    if (JIE_NAME[i] === name) {
      return JIE_BRANCH[i]
    }
  }
  return '子'
}

/* ---------- 今日 ---------- */
export function todayPillars(spec: NowSpec, lon: number, tz: number): TodayInfo {
  const st: SolarTime = solarTime(spec.y, spec.m, spec.d, spec.h, spec.mi, lon, tz)
  const cal: Cal = st.cal
  const clockJd: number = st.clockJd
  const bracket: Term[] = jieBracket(clockJd, cal.y, tz)
  const prev: Term = bracket[0]
  const next: Term = bracket[1]
  const lichun: Term = termsOfYear(cal.y).filter((t: Term): boolean => t.name === '立春')[0]
  const solarYear: number = clockJd < lichun.jd + tz / 24 ? cal.y - 1 : cal.y
  const yGZ: number = mod(solarYear - 1984, 60)
  const mBranch: number = zhiIdx(jieBranchOf(prev.name))
  const yinGan: number = mod((yGZ % 10 % 5) * 2 + 2, 10)
  const mGan: number = mod(yinGan + ((mBranch - 2 + 12) % 12), 10)
  const mGZ: number = gzIndex(mGan, mBranch)
  const jdn: number = jdnOf(cal.y, cal.m, cal.d) + (cal.h >= 23 ? 1 : 0)
  const dGZ: number = mod(jdn + 49, 60)
  const hourIdx: number = Math.floor(((cal.h + 1) % 24) / 2)
  const dGan: number = dGZ % 10
  const hGZ: number = gzIndex(mod((dGan % 5) * 2 + hourIdx, 10), hourIdx)
  return {
    year: buildPillar(yGZ, dGan),
    month: buildPillar(mGZ, dGan),
    day: buildPillar(dGZ, dGan),
    hour: buildPillar(hGZ, dGan),
    solarYear: solarYear,
    jiePrev: prev,
    jieNext: next
  }
}

export function branchRel(a: number, b: number): string[] {
  const r: string[] = []
  if (LIUCHONG[a] === b) {
    r.push('冲')
  }
  if (LIUHAI[a] === b) {
    r.push('害')
  }
  if (LIUHE[a] === b) {
    r.push('合')
  }
  if (ZIXING[a] === b && a === b) {
    r.push('自刑')
  }
  if ((a === 0 && b === 3) || (a === 3 && b === 0)) {
    r.push('刑')
  }
  for (let i = 0; i < XING3.length; i++) {
    if (XING3[i].indexOf(a) >= 0 && XING3[i].indexOf(b) >= 0 && a !== b) {
      r.push('三刑')
    }
  }
  return r
}

function godValue(god: string, state: string): number {
  const g: string = godGroup(god)
  if (state === 'weak') {
    if (g === '印' || g === '比') {
      return 1
    }
    if (g === '食') {
      return -0.3
    }
    return -0.6
  }
  if (state === 'strong') {
    if (g === '食') {
      return 1
    }
    if (g === '财') {
      return 0.8
    }
    if (g === '官') {
      return 0.5
    }
    if (g === '印') {
      return -0.7
    }
    return -0.4
  }
  if (g === '财' || g === '官') {
    return 0.5
  }
  if (g === '食') {
    return 0.3
  }
  return 0
}

function branchValue(from: number, to: number): number {
  if (LIUCHONG[from] === to) {
    return -1
  }
  if (LIUHAI[from] === to) {
    return -0.6
  }
  if (from === to) {
    return ZIXING[from] === from ? -0.7 : 0
  }
  if ((from === 0 && to === 3) || (from === 3 && to === 0)) {
    return -0.7
  }
  let t3: boolean = false
  for (let i = 0; i < XING3.length; i++) {
    if (XING3[i].indexOf(from) >= 0 && XING3[i].indexOf(to) >= 0) {
      t3 = true
    }
  }
  if (t3) {
    return -0.7
  }
  if (LIUHE[from] === to) {
    return 0.7
  }
  return 0
}

function wxValue(from: string, day: string): number {
  if (from === day) {
    return 0.6
  }
  if (sheng(from) === day) {
    return 0.6
  }
  if (sheng(day) === from) {
    return -0.2
  }
  if (ke(from) === day) {
    return -0.4
  }
  return -0.5
}

/** 今日运势综合评分 */
export function dailyFortune(chart: Chart, spec: NowSpec, lon: number, tz: number): Fortune {
  const t: TodayInfo = todayPillars(spec, lon, tz)
  const dayGan: number = chart.dayGan
  const dayWX: string = GAN_WX[dayGan]
  const state: string = chart.strength.state
  const mz: number = chart.month.zhi
  const dz: number = chart.day.zhi
  const yz: number = chart.year.zhi
  const sig: Signal[] = []
  const push: (label: string, value: number, weight: number, detail: string) => void =
    (label: string, value: number, weight: number, detail: string): void => {
      sig.push({ label: label, value: value, weight: weight, detail: detail })
    }
  const relValue: (rel: string[], from: number, to: number) => number =
    (rel: string[], from: number, to: number): number => {
      if (rel.length === 0) {
        return 0
      }
      let sum: number = 0
      for (let i = 0; i < rel.length; i++) {
        sum += branchValue(from, to)
      }
      return sum / rel.length
    }

  const tGod: string = tenGod(dayGan, t.day.gan)
  push('今日日干 ' + t.day.ganChar + '（' + tGod + '）', godValue(tGod, state), 12, '')
  push('今日日支 ' + t.day.zhiChar + ' 与命局日支', relValue(branchRel(t.day.zhi, dz), t.day.zhi, dz), 10,
    branchRel(t.day.zhi, dz).join(''))
  push('今日日支五行', wxValue(ZHI_WX[t.day.zhi], dayWX), 6, '')
  const lGod: string = tenGod(dayGan, t.year.gan)
  push('流年 ' + t.year.name + ' 天干', godValue(lGod, state), 10, '')
  push('流年地支 ' + t.year.zhiChar + ' 与命局日支', relValue(branchRel(t.year.zhi, dz), t.year.zhi, dz), 12,
    branchRel(t.year.zhi, dz).join(''))
  push('流年地支五行', wxValue(ZHI_WX[t.year.zhi], dayWX), 6, '')
  push('太岁与命局年支', relValue(branchRel(t.year.zhi, yz), t.year.zhi, yz), 6, branchRel(t.year.zhi, yz).join(''))

  const age: number = (spec.y - chart.input.y) + (spec.m - chart.input.m) / 12
  let curName: string = ''
  let curFrom: number = 0
  let curTo: number = 0
  let curGan: number = -1
  let curZhi: number = -1
  for (let i = 0; i < chart.yun.list.length; i++) {
    const y: YunStep = chart.yun.list[i]
    if (age >= y.ageFrom && age < y.ageTo) {
      curName = y.name
      curFrom = y.ageFrom
      curTo = y.ageTo
      curGan = y.gan
      curZhi = y.zhi
    }
  }
  if (curGan >= 0) {
    const yGod: string = tenGod(dayGan, curGan)
    push('大运 ' + curName + ' 天干', godValue(yGod, state), 8, '')
    push('大运地支 ' + ZHI[curZhi] + ' 与命局日支', relValue(branchRel(curZhi, dz), curZhi, dz), 10,
      branchRel(curZhi, dz).join(''))
  }
  push('本月月支 ' + ZHI[t.month.zhi] + ' 与命局日支', relValue(branchRel(t.month.zhi, dz), t.month.zhi, dz), 6,
    branchRel(t.month.zhi, dz).join(''))

  let wsum: number = 0
  let vsum: number = 0
  for (let i = 0; i < sig.length; i++) {
    wsum += sig[i].weight
    vsum += sig[i].value * sig[i].weight
  }
  const ratio: number = wsum > 0 ? vsum / wsum : 0
  let score: number = Math.round(50 + 45 * ratio)
  if (score < 0) {
    score = 0
  }
  if (score > 100) {
    score = 100
  }

  const yi: string[] = []
  const ji: string[] = []
  yi.push('进修学习（今日 ' + t.day.ganChar + ' 为' + tGod + '）')
  yi.push('走' + ZHI[TIANXI[dz]] + '日（天喜）：喜庆、人缘、见喜')
  yi.push('谈合作签约（' + ZHI[HONGLUAN[dz]] + '日为红鸾，和合助缘）')
  yi.push('天德贵人在' + TIANDE[mz] + '干，逢' + TIANDE[mz] + '日/时办事顺遂')
  if (chart.strength.favText.length > 0) {
    yi.push('补' + chart.strength.favText.split('、')[0] + '：养精蓄锐')
  }
  ji.push('忌' + ZHI[LIUCHONG[dz]] + '日冲本命（' + ZHI[LIUCHONG[dz]] + '）')
  if (LIUHAI[dz] >= 0) {
    ji.push('忌' + ZHI[LIUHAI[dz]] + '日害命，破财、口舌')
  }
  const relYear: string[] = branchRel(t.year.zhi, dz)
  if (relYear.indexOf('冲') >= 0) {
    ji.push('太岁冲日支（' + t.year.name + '）：变动之年，守成为上')
  }
  ji.push('忌大额投资、冲动决策')

  const notes: string[] = []
  const scored: number[] = []
  for (let i = 0; i < sig.length; i++) {
    if (Math.abs(sig[i].value) < 0.35) {
      continue
    }
    scored.push(i)
  }
  scored.sort((a: number, b: number): number =>
    Math.abs(sig[b].value * sig[b].weight) - Math.abs(sig[a].value * sig[a].weight))
  for (let i = 0; i < scored.length && notes.length < 8; i++) {
    const s: Signal = sig[scored[i]]
    const v: string = s.value > 0 ? '吉' : '凶'
    notes.push(s.label + (s.detail.length > 0 ? '（' + s.detail + '）' : '') + (v === '吉' ? '，为吉象' : '，为凶象'))
  }

  let label: string = '平'
  let level: number = 3
  if (score >= 85) {
    label = '大吉'
    level = 5
  } else if (score >= 72) {
    label = '吉'
    level = 4
  } else if (score >= 58) {
    label = '平'
    level = 3
  } else if (score >= 45) {
    label = '小凶'
    level = 2
  } else {
    label = '凶'
    level = 1
  }

  return {
    score: score,
    label: label,
    level: level,
    sig: sig,
    notes: notes,
    yi: yi,
    ji: ji,
    today: t,
    curYunName: curName,
    curYunFrom: curFrom,
    curYunTo: curTo,
    age: Math.round(age * 10) / 10
  }
}

/** 流年列表（含十神与与日支关系） */
export function yearList(chart: Chart, from: number, to: number): YearItem[] {
  const out: YearItem[] = []
  for (let y = from; y <= to; y++) {
    const gz: number = mod(y - 1984, 60)
    const g: number = gz % 10
    const z: number = gz % 12
    const rel: string[] = branchRel(z, chart.day.zhi)
    out.push({
      year: y,
      name: gzName(gz),
      gan: g,
      zhi: z,
      god: tenGod(chart.dayGan, g),
      rel: rel.length > 0 ? rel.join('·') : '平'
    })
  }
  return out
}

/** 北京时间（UTC+8）的日期与时刻 */
export function beijingNow(): NowSpec {
  const d: Date = new Date(Date.now() + 8 * 3600 * 1000)
  return { y: d.getUTCFullYear(), m: d.getUTCMonth() + 1, d: d.getUTCDate(), h: d.getUTCHours(), mi: d.getUTCMinutes() }
}
