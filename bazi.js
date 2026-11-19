/* ===========================================================
 * 八字排盘引擎
 * 真太阳时 / 四柱 / 大运 / 流年 / 今日干支与运势
 * 纯函数、零依赖，浏览器与 Node 均可运行
 * 太阳视黄经采用截断 VSOP87（Meeus），节气误差 < 1 分钟
 * =========================================================== */
(function (root, factory) {
  var api = factory();
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.Bazi = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';

  var PI = Math.PI, D = PI / 180;
  var GAN = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
  var ZHI = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
  var GAN_WX = ['木', '木', '火', '火', '土', '土', '金', '金', '水', '水'];
  var ZHI_WX = ['水', '土', '木', '木', '土', '火', '火', '土', '金', '金', '土', '水'];
  var GYY = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1];            // 0 阳 1 阴
  var ZYY = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0];
  var SHENG = { '木': '火', '火': '土', '土': '金', '金': '水', '水': '木' };
  var KE = { '木': '土', '土': '水', '水': '火', '火': '金', '金': '木' };
  var HIDDEN = [['癸'], ['己', '癸', '辛'], ['甲', '丙', '戊'], ['乙'], ['戊', '乙', '癸'], ['丙', '戊', '庚'],
  ['丁', '己'], ['己', '丁', '乙'], ['庚', '壬', '戊'], ['辛'], ['戊', '辛', '丁'], ['壬', '甲']];
  var HIDDEN_W = [[1], [1, 0.5, 0.3], [1, 0.5, 0.3], [1], [1, 0.5, 0.3], [1, 0.5, 0.3],
  [1, 0.5], [1, 0.5, 0.3], [1, 0.5, 0.3], [1], [1, 0.5, 0.3], [1, 0.3]];   // 本气/中气/余气
  // 12 节：名称、太阳黄经（度）、月建地支
  var JIE = [
    ['立春', 315, '寅'], ['惊蛰', 345, '卯'], ['清明', 15, '辰'], ['立夏', 45, '巳'],
    ['芒种', 75, '午'], ['小暑', 105, '未'], ['立秋', 135, '申'], ['白露', 165, '酉'],
    ['寒露', 195, '戌'], ['立冬', 225, '亥'], ['大雪', 255, '子'], ['小寒', 285, '丑']
  ];
  var JIE_NAME = {};
  JIE.forEach(function (j) { JIE_NAME[j[0]] = j; });
  // 关系表一律按地支序号（子0…亥11）索引
  var LIUHE = [1, 0, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2];            // 六合
  var LIUCHONG = [6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5];        // 六冲
  var LIUHAI = [7, 6, 5, 4, 3, 2, 1, 0, 11, 10, 9, 8];           // 六害
  var XING3 = [[2, 5, 8], [1, 10, 7]];                           // 三刑：寅巳申 / 丑戌未
  var ZIXING = [null, null, null, null, 4, null, 6, null, null, 9, null, 11]; // 自刑：辰午酉亥
  var HONGLUAN = [3, 2, 1, 0, 11, 10, 9, 8, 7, 6, 5, 4];          // 红鸾
  var TIANXI = [6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5];            // 天喜（红鸾之冲）
  var TIANDE = ['壬', '庚', '丁', '壬', '甲', '丙', '壬', '庚', '壬', '甲', '丙', '壬']; // 天德贵人（按月支）
  var CITIES = [['北京', 116.41], ['上海', 121.47], ['广州', 113.26], ['深圳', 114.06], ['天津', 117.20], ['重庆', 106.55],
  ['成都', 104.07], ['杭州', 120.15], ['南京', 118.80], ['武汉', 114.31], ['西安', 108.95], ['苏州', 120.62],
  ['长沙', 112.94], ['青岛', 120.38], ['沈阳', 123.43], ['大连', 121.62], ['哈尔滨', 126.53], ['长春', 125.32],
  ['济南', 117.00], ['郑州', 113.63], ['洛阳', 112.45], ['厦门', 118.09], ['福州', 119.30], ['昆明', 102.83],
  ['贵阳', 106.63], ['南宁', 108.37], ['海口', 110.35], ['兰州', 103.83], ['乌鲁木齐', 87.62], ['拉萨', 91.11],
  ['西宁', 101.78], ['银川', 106.23], ['呼和浩特', 111.75], ['石家庄', 114.52], ['太原', 112.55], ['合肥', 117.28],
  ['南昌', 115.89], ['宁波', 121.55], ['无锡', 120.30], ['东莞', 113.75], ['佛山', 113.12], ['温州', 120.70],
  ['金华', 119.65], ['南通', 120.86], ['常州', 119.95], ['徐州', 117.18], ['汕头', 116.68], ['烟台', 121.39],
  ['洛阳', 112.45], ['呼和浩特', 111.75], ['桂林', 110.29], ['丽江', 100.23], ['敦煌', 94.66]];

  /* ---------- 截断 VSOP87（地球日心黄经/黄纬） ---------- */
  var L0 = [[175347046, 0, 0], [3341656, 4.6692568, 6283.07585], [34894, 4.6261, 12566.1517], [3497, 2.7441, 5753.3849],
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
  [33, 0.59, 17789.85], [30, 0.44, 83996.85], [30, 2.74, 1349.87], [25, 3.16, 4690.48]];
  var L1 = [[628331966747, 0, 0], [206059, 2.678235, 6283.07585], [4303, 2.6351, 12566.1517], [425, 1.59, 3.523],
  [119, 5.796, 26.298], [109, 2.966, 1577.344], [93, 2.59, 18849.23], [72, 1.14, 529.69],
  [68, 1.87, 398.15], [67, 4.41, 5507.55], [59, 2.89, 5223.69], [56, 2.17, 155.42],
  [45, 0.4, 796.3], [36, 0.47, 775.52], [29, 2.65, 7.11], [21, 5.34, 0.98],
  [19, 1.85, 5486.78], [19, 4.97, 213.3], [17, 2.99, 6275.96], [16, 0.03, 2544.31],
  [16, 1.43, 2146.17], [15, 1.21, 10977.08], [12, 2.83, 1748.02], [12, 3.26, 5088.63],
  [12, 5.27, 1194.45], [12, 2.08, 4694], [11, 0.77, 553.57], [10, 1.3, 6286.6],
  [10, 4.24, 1349.87], [9, 2.7, 242.73], [9, 5.64, 951.72], [8, 5.3, 2352.87],
  [6, 2.65, 9437.76], [6, 4.67, 4690.48]];
  var L2 = [[52919, 0, 0], [8720, 1.0721, 6283.0758], [309, 0.867, 12566.152], [27, 0.05, 3.52],
  [16, 5.19, 26.3], [16, 3.68, 155.42], [10, 0.76, 18849.23], [9, 2.06, 77713.77],
  [7, 0.83, 775.52], [5, 4.66, 1577.34], [4, 1.03, 7.11], [4, 3.44, 5573.14],
  [3, 5.14, 796.3], [3, 6.05, 5507.55], [3, 1.19, 242.73], [3, 6.12, 529.69],
  [3, 0.31, 398.15], [3, 2.28, 553.57], [2, 4.38, 5223.69], [2, 3.75, 0.98]];
  var L3 = [[289, 5.844, 6283.076], [35, 0, 0], [17, 5.49, 12566.15], [3, 5.2, 155.42], [1, 4.72, 3.52], [1, 5.3, 18849.23], [1, 5.97, 242.73]];
  var L4 = [[114, 3.142, 0], [8, 4.13, 6283.08], [1, 3.84, 12566.15]];
  var L5 = [[1, 3.14, 0]];
  var B0 = [[280, 3.199, 84334.662], [102, 5.422, 5507.553], [80, 3.88, 5223.69], [44, 3.7, 2352.87], [32, 4.0, 1577.34]];
  var B1 = [[9, 3.9, 5507.55], [6, 1.73, 5223.69]];

  function vsop(terms, T) {
    var s = 0;
    for (var i = 0; i < terms.length; i++) s += terms[i][0] * Math.cos(terms[i][1] + terms[i][2] * T);
    return s * 1e-8;
  }
  function earthL(tau) {
    return vsop(L0, tau) + tau * (vsop(L1, tau) + tau * (vsop(L2, tau) + tau * (vsop(L3, tau) + tau * (vsop(L4, tau) + tau * vsop(L5, tau)))));
  }
  function earthB(tau) { return vsop(B0, tau) + tau * vsop(B1, tau); }
  function nutation(T) {
    var om = 125.04452 - 1934.136261 * T + 0.0020708 * T * T;
    var Ls = 280.4665 + 36000.7698 * T, Lm = 218.3165 + 481267.8813 * T;
    return (-17.20 * Math.sin(om * D) - 1.32 * Math.sin(2 * Ls * D) - 0.23 * Math.sin(2 * Lm * D) + 0.21 * Math.sin(2 * om * D)) / 3600;
  }
  /** 太阳视黄经（度，0-360） */
  function sunLon(jd) {
    var T = (jd - 2451545) / 36525;      // 世纪（章动用）
    var tau = T / 10;                    // 千年（VSOP87 系数标定）
    var th = (earthL(tau) + PI - earthB(tau)) * (180 / PI);
    return norm(th + nutation(T) - 0.0056916);
  }
  function obliquity(T) { return 23.439291111 - 0.0130041667 * T - 1.6389e-7 * T * T + 5.036e-7 * T * T * T; }
  /** 均时差（分钟）：真太阳时 - 平太阳时 */
  function eqOfTime(jd) {
    var T = (jd - 2451545) / 36525;
    var lam = sunLon(jd), eps = obliquity(T) * D;
    var ra = Math.atan2(Math.cos(eps) * Math.sin(lam * D), Math.cos(lam * D)) * (180 / PI);
    var L0m = 280.4665 + 36000.7698 * T;
    var E = L0m - 0.0057183 - ra + nutation(T) * Math.cos(eps);
    return wrap180(E) * 4;
  }

  /* ---------- 基础历法 ---------- */
  function norm(a) { a = a % 360; return a < 0 ? a + 360 : a; }
  function wrap180(a) { a = norm(a); return a > 180 ? a - 360 : a; }
  function mod(a, n) { return ((a % n) + n) % n; }
  function jdFromUTC(y, m, d, h, mi, s) {
    h = h || 0; mi = mi || 0; s = s || 0;
    if (m <= 2) { y -= 1; m += 12; }
    var A = Math.floor(y / 100), B = 2 - A + Math.floor(A / 4);
    return Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + d + B - 1524.5 + (h + mi / 60 + s / 3600) / 24;
  }
  function jdnOf(y, m, d) {
    var Y = y, M = m;
    if (M <= 2) { Y -= 1; M += 12; }
    var A = Math.floor(Y / 100), B = 2 - A + Math.floor(A / 4);
    return Math.floor(365.25 * (Y + 4716)) + Math.floor(30.6001 * (M + 1)) + d + B - 1524;
  }
  function jdToCal(jd) {
    var z = Math.floor(jd + 0.5), f = jd + 0.5 - z;
    var alpha = Math.floor((z - 1867216.25) / 36524.25);
    var A = z + 1 + alpha - Math.floor(alpha / 4), B = A + 1524;
    var C = Math.floor((B - 122.1) / 365.25), D = Math.floor(365.25 * C), E = Math.floor((B - D) / 30.6001);
    var day = B - D - Math.floor(30.6001 * E), month = E < 14 ? E - 1 : E - 13;
    var year = month > 2 ? C - 4716 : C - 4715;
    var hh = Math.floor(f * 24), mi = Math.floor((f * 24 - hh) * 60), ss = Math.floor(((f * 24 - hh) * 60 - mi) * 60);
    return { y: year, m: month, d: day, h: hh, mi: mi, s: ss };
  }
  function jdToLocalStr(jd, tz) { // tz 为小时
    var c = jdToCal(jd + tz / 24);
    return c.y + '-' + pad(c.m) + '-' + pad(c.d) + ' ' + pad(c.h) + ':' + pad(c.mi) + ':' + pad(c.s);
  }
  function pad(n) { return (n < 10 ? '0' : '') + n; }

  /* ---------- 节气 ---------- */
  var TERM_LON = [[285, '小寒'], [300, '大寒'], [315, '立春'], [330, '雨水'], [345, '惊蛰'], [360, '春分'],
  [375, '清明'], [390, '谷雨'], [405, '立夏'], [420, '小满'], [435, '芒种'], [450, '夏至'],
  [465, '小暑'], [480, '大暑'], [495, '立秋'], [510, '处暑'], [525, '白露'], [540, '秋分'],
  [555, '寒露'], [570, '霜降'], [585, '立冬'], [600, '小雪'], [615, '大雪'], [630, '冬至']];
  var termCache = {};
  /** 某公历年 24 节气（儒略日 UT） */
  function termsOfYear(year) {
    if (termCache[year]) return termCache[year];
    var jd0 = jdFromUTC(year, 1, 1, 0, 0, 0);
    var l0 = sunLon(jd0);
    var out = TERM_LON.map(function (t) {
      var target = t[0] <= 360 ? t[0] : t[0]; // 目标黄经（递增展开）
      var est = jd0 + (target - l0) / 0.9856473;
      var jd = est;
      for (var i = 0; i < 8; i++) {
        var diff = wrap180(sunLon(jd) - norm(target));
        if (Math.abs(diff) < 1e-9) break;
        var der = (sunLon(jd + 0.02) - sunLon(jd - 0.02)) / 0.04;
        jd -= diff / der;
      }
      return { name: t[1], lon: norm(target), jd: jd };
    });
    termCache[year] = out;
    return out;
  }
  function jieOfYear(year) {
    return termsOfYear(year).filter(function (t) { return JIE_NAME[t.name]; })
      .map(function (t) { return { name: t.name, jd: t.jd, branch: JIE_NAME[t.name][2] }; })
      .sort(function (a, b) { return a.jd - b.jd; });
  }
  /** 出生时刻所处的月令（前后节）。jdClock 为钟表读数帧，节气按北京时间比较 */
  function jieBracket(jdClock, year, tz) {
    tz = tz || 8;
    var all = [];
    [year - 1, year, year + 1].forEach(function (y) { all = all.concat(jieOfYear(y)); });
    all.sort(function (a, b) { return a.jd - b.jd; });
    var prev = null, next = null;
    for (var i = 0; i < all.length; i++) {
      if (all[i].jd + tz / 24 <= jdClock) prev = all[i];
      else { next = all[i]; break; }
    }
    return { prev: prev, next: next };
  }

  /* ---------- 干支 ---------- */
  function gzIndex(gan, zhi) {
    for (var i = 0; i < 60; i++) if (i % 10 === gan && i % 12 === zhi) return i;
    return 0;
  }
  function gzName(idx) { idx = mod(idx, 60); return GAN[idx % 10] + ZHI[idx % 12]; }
  function ganIdx(ch) { return GAN.indexOf(ch); }
  function zhiIdx(ch) { return ZHI.indexOf(ch); }
  /** 十神：以日干 day 为我，看 other（入参可为天干序号或天干字） */
  function tenGod(day, other) {
    var d = (typeof day === 'string') ? ganIdx(day) : day;
    var o = (typeof other === 'string') ? ganIdx(other) : other;
    if (d == null || o == null) return '';
    var dw = GAN_WX[d], ow = GAN_WX[o];
    var same = GYY[d] === GYY[o];
    if (dw === ow) return same ? '比肩' : '劫财';
    if (SHENG[dw] === ow) return same ? '食神' : '伤官';
    if (KE[dw] === ow) return same ? '偏财' : '正财';
    if (KE[ow] === dw) return same ? '七杀' : '正官';
    return same ? '偏印' : '正印';
  }
  function godGroup(god) {
    if (!god) return '';
    if (god.indexOf('比') >= 0 || god.indexOf('劫') >= 0) return '比';
    if (god.indexOf('印') >= 0) return '印';
    if (god.indexOf('食') >= 0 || god.indexOf('伤') >= 0) return '食';
    if (god.indexOf('财') >= 0) return '财';
    if (god.indexOf('官') >= 0 || god.indexOf('杀') >= 0) return '官';
    return god[0];
  }

  /* ---------- 真太阳时 ---------- */
  /** 返回 {jdTrue, clockJd, lonAdjMin, eotMin, trueStr, plainStr} */
  function solarTime(y, m, d, h, mi, lon, tz) {
    tz = tz || 8;
    var clockJd = jdFromUTC(y, m, d, h, mi, 0);   // 钟表读数（当作本地钟面）
    var jdUTC = clockJd - tz / 24;
    var lonAdjMin = (lon - tz * 15) * 4;         // 经度时差
    var eotMin = eqOfTime(jdUTC);                // 均时差
    var jdTrue = clockJd + lonAdjMin / 1440 + eotMin / 1440;
    return { jdTrue: jdTrue, jdUTC: jdUTC, clockJd: clockJd, lonAdjMin: lonAdjMin, eotMin: eotMin, cal: jdToCal(jdTrue) };
  }

  /* ---------- 排盘 ---------- */
  /**
   * o = {y,m,d,h,mi, lon, tz=8, dst=false, gender:'m'|'f', unknownHour=false}
   */
  /** 经度脏值防御：非有限或越界按 120°E 处理，避免真太阳时溢出成年份级垃圾 */
  /* ---------- 五行喜忌与补益指南 ---------- */
  var WX_ORDER = ['木', '火', '土', '金', '水'];

  /** 生我者（印） */
  function producedBy(dayWx) {
    for (var i = 0; i < WX_ORDER.length; i++) if (SHENG[WX_ORDER[i]] === dayWx) return WX_ORDER[i];
    return dayWx;
  }
  /** 克我者（官杀） */
  function controlledBy(dayWx) {
    for (var i = 0; i < WX_ORDER.length; i++) if (KE[WX_ORDER[i]] === dayWx) return WX_ORDER[i];
    return dayWx;
  }
  /** 十神组 → 五行 */
  function godGroupToWx(group, dayWx) {
    if (group === '印') return producedBy(dayWx);
    if (group === '比') return dayWx;
    if (group === '食') return SHENG[dayWx];
    if (group === '财') return KE[dayWx];
    if (group === '官') return controlledBy(dayWx);
    return dayWx;
  }

  /**
   * 由喜用神推出「该补的五行」与「该忌的五行」
   */
  function wuxingPlan(strength, dayWx) {
    var fav = [], unfav = [], i, g, w;
    for (i = 0; i < strength.fav.length; i++) {
      w = godGroupToWx(strength.fav[i], dayWx);
      if (fav.indexOf(w) < 0) fav.push(w);
    }
    for (i = 0; i < strength.unfav.length; i++) {
      w = godGroupToWx(strength.unfav[i], dayWx);
      if (unfav.indexOf(w) < 0) unfav.push(w);
    }
    fav.sort(function (a, b) { return WX_ORDER.indexOf(a) - WX_ORDER.indexOf(b); });
    unfav.sort(function (a, b) { return WX_ORDER.indexOf(a) - WX_ORDER.indexOf(b); });
    return {
      favWx: fav, unfavWx: unfav,
      favText: fav.join('、'), unfavText: unfav.join('、'),
      favGods: strength.favText, unfavGods: strength.unfavText
    };
  }

  /** 五行调补指南：颜色 / 方位 / 数字 / 物品 / 饮食 / 宜 / 忌 */
  var WX_GUIDE = {
    '木': {
      color: '青、绿、竹青、橄榄绿', dir: '东方', num: '3、8',
      item: '绿植盆栽、原木与竹制品、纸质书、棉麻织物',
      diet: '深绿叶菜、芹菜、青瓜、绿茶、青梅',
      career: '教育、出版、文创、林业、医护',
      do: '多做规划与学习、早起、伸展运动、多与草木相处',
      dont: '忌熬夜耗木、忌怒火上头、忌大片红色与金属饰品',
      tip: '木主生发，宜静宜学，忌郁怒'
    },
    '火': {
      color: '红、橙、紫、酒红、暖粉', dir: '南方', num: '2、7',
      item: '暖光台灯、香薰炉、暖色挂画、红色饰物',
      diet: '羊肉、辣椒、荔枝、红枣、暖汤',
      career: '能源、演艺、餐饮、直播、推广',
      do: '多晒太阳、适度运动、热情社交、主动表达',
      dont: '忌过多黑色与冷水、忌过度克制、忌长期独处',
      tip: '火主礼明，宜动宜热，忌抑郁'
    },
    '土': {
      color: '黄、棕、卡其、米色、咖啡', dir: '中西东北方', num: '5、0',
      item: '陶瓷器、玉石、水晶、方形摆件、砂器',
      diet: '小米、山药、南瓜、牛肉、豆腐、薯类',
      career: '地产、建筑、农业、中介、仓储',
      do: '稳扎稳打、做好理财、规律作息、积少成多',
      dont: '忌频繁变动、忌高杠杆冒险、忌四处奔波',
      tip: '土主承载，宜稳宜藏，忌散漫'
    },
    '金': {
      color: '白、金、银、月白、浅灰', dir: '西方、西北方', num: '4、9',
      item: '金属饰品、金属笔、机械表、圆形摆件、白色家电',
      diet: '大米、山药、梨、白萝卜、菌菇、白色食材',
      career: '金融、机械、军警、律师、外科、五金',
      do: '断舍离、立规矩、做减法、断难处',
      dont: '忌过多红色、忌拖泥带水、忌优柔寡断',
      tip: '金主肃杀，宜决宜断，忌迟疑'
    },
    '水': {
      color: '黑、深蓝、藏青、灰蓝', dir: '北方', num: '1、6',
      item: '流水摆件、鱼缸、玻璃器皿、黑色皮具、圆珠',
      diet: '水产、汤羹、黑豆、海带、菌菇、浆果',
      career: '贸易、物流、旅游、传播、水产、咨询',
      do: '多喝水、早睡、灵活周旋、宽厚待人',
      dont: '忌过度辛劳、忌久坐不动、忌与人硬顶',
      tip: '水主智巧，宜柔宜动，忌枯竭'
    }
  };

  function wxGuide(wx) {
    return WX_GUIDE[wx] || { color: '—', dir: '—', num: '—', item: '—', diet: '—', career: '—', do: '—', dont: '—', tip: '—' };
  }

  function safeLon(lon) {
    var v = Number(lon);
    if (!isFinite(v) || v < -180 || v > 180) return 120;
    return v;
  }
  function buildChart(o) {
    var tz = o.tz || 8;
    o = Object.assign({}, o, { lon: safeLon(o.lon) });
    var h = o.h, mi = o.mi || 0;
    if (o.dst) { h -= 1; if (h < 0) { h += 24; } }
    var st = solarTime(o.y, o.m, o.d, h, mi, o.lon, tz);
    var cal = st.cal;                                  // 真太阳时的公历
    var jdTrue = st.jdTrue;
    var clockJd = st.clockJd;                          // 出生钟表读数（北京时间帧）

    // 年柱/月柱以「节」为界，按北京钟表时间比较（与国内万年历口径一致）
    var bracket = jieBracket(clockJd, cal.y, tz);
    var lichun = termsOfYear(cal.y).filter(function (t) { return t.name === '立春'; })[0];
    var solarYear = (clockJd < lichun.jd + tz / 24) ? cal.y - 1 : cal.y;
    var yGZ = mod(solarYear - 1984, 60);

    // 月柱
    var mBranch = zhiIdx(bracket.prev.branch);
    var yGan = yGZ % 10;
    var yinGan = mod((yGan % 5) * 2 + 2, 10);          // 五虎遁
    var mGan = mod(yinGan + ((mBranch - 2 + 12) % 12), 10);
    var mGZ = gzIndex(mGan, mBranch);

    // 日柱（23:00 换日）
    var jdn = jdnOf(cal.y, cal.m, cal.d);
    var lateZi = cal.h >= 23;
    if (lateZi) jdn += 1;
    var dGZ = mod(jdn + 49, 60);

    // 时柱
    var hourIdx = Math.floor(((cal.h + 1) % 24) / 2);
    var hGan = o.unknownHour ? -1 : mod((dGZ % 10 % 5) * 2 + hourIdx, 10);
    var hGZ = o.unknownHour ? -1 : gzIndex(hGan, hourIdx);

    var pillars = {
      year: { gz: yGZ, gan: yGZ % 10, zhi: yGZ % 12, name: gzName(yGZ) },
      month: { gz: mGZ, gan: mGan, zhi: mBranch, name: gzName(mGZ) },
      day: { gz: dGZ, gan: dGZ % 10, zhi: dGZ % 12, name: gzName(dGZ) },
      hour: hGZ < 0 ? null : { gz: hGZ, gan: hGan, zhi: hourIdx, name: gzName(hGZ) }
    };
    var dayGan = pillars.day.gan;
    Object.keys(pillars).forEach(function (k) {
      var p = pillars[k]; if (!p) return;
      p.god = tenGod(dayGan, GAN[p.gan]);
      p.wx = GAN_WX[p.gan]; p.zwx = ZHI_WX[p.zhi];
      p.hidden = HIDDEN[p.zhi].map(function (g) { return { g: g, god: tenGod(dayGan, g), wx: GAN_WX[ganIdx(g)] }; });
    });

    // 身强弱
    var strength = computeStrength(pillars);

    // 大运
    var dir = ((GYY[yGan] === 0) === (o.gender === 'm')) ? 1 : -1;
    var days = dir > 0 ? (bracket.next.jd + tz / 24 - clockJd) : (clockJd - (bracket.prev.jd + tz / 24));
    // 三天折一年：1 天 = 4 个月，1 个月 = 30 起运日（1 起运日 = 12 分钟）
    var yy = Math.floor(days / 3), rem = days - 3 * yy;
    var mm = Math.floor(rem * 4), rem2 = rem * 4 - mm;
    var ageDays = Math.floor(rem2 * 30);
    var dd = Math.round(rem2 / 4);                    // 折回真实天数（<0.25 天）
    var startAge = yy + mm / 12 + ageDays / 360;
    var qiuYun = addYMD(o.y, o.m, o.d, yy, mm, dd);
    var yunList = [];
    for (var i = 1; i <= 9; i++) {
      var gz = mod(mGZ + dir * i, 60);
      var g = gz % 10, z = gz % 12;
      yunList.push({
        gz: gz, name: gzName(gz), gan: g, zhi: z, wx: GAN_WX[g], zwx: ZHI_WX[z],
        god: tenGod(dayGan, GAN[g]),
        ageFrom: +(startAge + (i - 1) * 10).toFixed(1), ageTo: +(startAge + i * 10).toFixed(1),
        yearFrom: o.y + yy + (i - 1) * 10, yearTo: o.y + yy + i * 10
      });
    }
    // 大运干支组合（柱+干支）映射回 60 甲子以求十神
    yunList.forEach(function (y) { y.god = tenGod(dayGan, GAN[y.gan]); });

    return {
      input: o,
      solar: {
        clock: o.y + '-' + pad(o.m) + '-' + pad(o.d) + ' ' + pad(h) + ':' + pad(mi),
        lonAdjMin: st.lonAdjMin, eotMin: st.eotMin,
        plain: jdToCal(st.jdTrue - st.eotMin / 1440),
        true: cal
      },
      jdTrue: jdTrue,
      pillars: pillars, dayGan: dayGan,
      solarYear: solarYear,
      strength: strength,
      yun: { dir: dir, dirText: dir > 0 ? '顺行' : '逆行', days: days, startAge: startAge, startText: startAgeText(yy, mm, ageDays), qiuYun: qiuYun, list: yunList },
      jie: { prev: bracket.prev, next: bracket.next }
    };
  }
  function startAgeText(yy, mm, ageDays) { return yy + '岁' + (mm ? mm + '个月' : '') + (ageDays ? '零' + ageDays + '天' : ''); }
  function addYMD(y, m, d, dy, dm, dd) {
    var t = new Date(Date.UTC(y, m - 1, d));
    t.setUTCFullYear(t.getUTCFullYear() + dy);
    t.setUTCMonth(t.getUTCMonth() + dm);
    t.setUTCDate(t.getUTCDate() + dd);
    return t.getUTCFullYear() + '-' + pad(t.getUTCMonth() + 1) + '-' + pad(t.getUTCDate());
  }
  /* ================= 子平判盘：旺衰 / 格局 / 调候 / 病药 ================= */
  var LUS = { '甲': 2, '乙': 3, '丙': 5, '丁': 6, '戊': 5, '己': 6, '庚': 8, '辛': 9, '壬': 11, '癸': 0 };
  var RENS = { '甲': 3, '乙': 2, '丙': 6, '丁': 5, '戊': 6, '己': 5, '庚': 9, '辛': 8, '壬': 0, '癸': 11 };
  var SANHE = [[8, 0, 4, '水'], [11, 3, 7, '木'], [2, 6, 10, '火'], [5, 9, 1, '金']];
  var SANHUI = [[2, 3, 4, '木'], [5, 6, 7, '火'], [8, 9, 10, '金'], [11, 0, 1, '水']];
  var LIUHE_WX = [[0, 1, '土'], [2, 11, '木'], [3, 10, '火'], [4, 9, '金'], [5, 8, '水'], [6, 7, '火']];
  var SEASON_OF = { 2: '春', 3: '春', 5: '夏', 6: '夏', 8: '秋', 9: '秋', 11: '冬', 0: '冬', 1: '四季', 4: '四季', 7: '四季', 10: '四季' };
  var DE_LING = {
    '春': { '旺': '木', '相': '火', '休': '水', '囚': '金', '死': '土' },
    '夏': { '旺': '火', '相': '土', '休': '木', '囚': '水', '死': '金' },
    '秋': { '旺': '金', '相': '水', '休': '土', '囚': '火', '死': '木' },
    '冬': { '旺': '水', '相': '木', '休': '金', '囚': '土', '死': '火' },
    '四季': { '旺': '土', '相': '金', '休': '火', '囚': '木', '死': '水' }
  };
  var RANK_VAL = { '旺': 2, '相': 1, '休': 0, '囚': -1, '死': -2 };

  /** 调候用神表（穷通宝鉴通行表）：日干 × 月支序号 → 用神序列 */
  var TIAOHOU = {
    '甲': [['癸', '丙'], ['丙', '癸'], ['庚', '丙', '丁'], ['癸', '丁', '庚'], ['癸', '丁', '庚'], ['癸', '丁', '庚'], ['庚', '丁', '壬'], ['庚', '丙', '丁'], ['庚', '甲', '丁', '壬'], ['庚', '丁', '丙', '戊'], ['丁', '庚', '丙'], ['丁', '庚', '丙']],
    '乙': [['丙', '癸'], ['丙', '癸'], ['癸', '丙', '戊'], ['癸'], ['癸', '丙'], ['癸', '丙'], ['丙', '癸', '己'], ['癸', '丙', '丁'], ['癸', '辛'], ['丙', '戊'], ['丙'], ['丙']],
    '丙': [['壬', '庚'], ['壬', '己'], ['壬', '甲'], ['壬', '癸', '庚'], ['壬', '庚'], ['壬', '庚'], ['壬', '戊'], ['壬', '癸'], ['甲', '壬'], ['甲', '戊', '庚', '壬'], ['壬', '戊', '己'], ['壬', '甲']],
    '丁': [['甲', '庚'], ['庚', '甲'], ['甲', '庚'], ['甲', '庚'], ['壬', '庚', '癸'], ['甲', '壬', '庚'], ['甲', '庚', '丙', '戊'], ['甲', '庚', '丙', '戊'], ['甲', '庚', '戊'], ['甲', '庚'], ['甲', '庚'], ['甲', '庚']],
    '戊': [['丙', '甲', '癸'], ['丙', '甲', '癸'], ['甲', '丙', '癸'], ['甲', '丙', '癸'], ['壬', '甲', '丙'], ['癸', '丙', '甲'], ['丙', '癸', '甲'], ['丙', '癸'], ['甲', '丙', '癸'], ['甲', '丙'], ['丙', '甲'], ['丙', '甲']],
    '己': [['丙', '庚', '甲'], ['甲', '癸', '丙'], ['丙', '癸', '甲'], ['癸', '丙'], ['癸', '丙'], ['癸', '丙'], ['丙', '癸'], ['丙', '癸'], ['甲', '丙', '癸'], ['丙', '甲', '戊'], ['丙', '甲', '戊'], ['丙', '甲', '戊']],
    '庚': [['戊', '甲', '壬', '丙', '丁'], ['丁', '甲', '庚', '丙'], ['甲', '丁', '壬', '癸'], ['壬', '戊', '丙', '丁'], ['壬', '癸'], ['丁', '甲'], ['丁', '甲'], ['丁', '甲', '丙'], ['甲', '壬'], ['丁', '丙'], ['丁', '甲', '丙'], ['丙', '丁', '甲']],
    '辛': [['己', '壬', '庚'], ['壬', '甲'], ['壬', '甲'], ['壬', '甲', '癸'], ['壬', '己', '癸'], ['壬', '庚', '甲'], ['壬', '甲', '戊'], ['壬', '甲'], ['壬', '甲'], ['壬', '丙'], ['丙', '戊', '壬', '甲'], ['丙', '壬', '戊', '己']],
    '壬': [['庚', '丙', '戊'], ['戊', '辛', '庚'], ['甲', '庚'], ['壬', '辛', '庚', '癸'], ['癸', '庚', '辛'], ['辛', '甲'], ['戊', '丁'], ['甲', '庚'], ['甲', '丙'], ['戊', '丙', '庚'], ['戊', '丙'], ['丙', '丁', '甲']],
    '癸': [['辛', '丙'], ['庚', '辛'], ['丙', '辛', '甲'], ['辛'], ['庚', '辛', '壬', '癸'], ['庚', '辛', '壬', '癸'], ['丁'], ['辛', '丙'], ['辛', '甲', '壬', '癸'], ['庚', '辛', '戊', '丁'], ['丙', '辛'], ['丙', '丁']]
  };

  /** 合化/三会/三合/六合 修正 */
  function combineMods(pillars) {
    var z = [pillars.year.zhi, pillars.month.zhi, pillars.day.zhi, pillars.hour ? pillars.hour.zhi : -1];
    var mods = {};
    var notes = [];
    function add(wx, v, note) {
      mods[wx] = (mods[wx] || 0) + v;
      notes.push(note);
    }
    // 三会（力量最大）
    SANHUI.forEach(function (g) {
      var have = [g[0], g[1], g[2]].filter(function (x) { return z.indexOf(x) >= 0; });
      if (have.length === 3) {
        add(g[3], 3, ZHI[g[0]] + ZHI[g[1]] + ZHI[g[2]] + '三会' + g[3] + '局');
      }
    });
    // 三合
    SANHE.forEach(function (g) {
      var have = [g[0], g[1], g[2]].filter(function (x) { return z.indexOf(x) >= 0; });
      if (have.length === 3) {
        add(g[3], 2.2, ZHI[g[0]] + ZHI[g[1]] + ZHI[g[2]] + '三合' + g[3] + '局');
      }
    });
    // 六合（相邻两支都现即论）
    LIUHE_WX.forEach(function (g) {
      if (z.indexOf(g[0]) >= 0 && z.indexOf(g[1]) >= 0) {
        add(g[2], 0.6, ZHI[g[0]] + ZHI[g[1]] + '六合化' + g[2]);
      }
    });
    return { mods: mods, notes: notes };
  }

  /**
   * 旺衰：得令 + 得地 + 得势，含合化修正
   */
  function wangShuai(pillars) {
    var dg = GAN[pillars.day.gan];
    var dwx = GAN_WX[pillars.day.gan];
    var mzi = pillars.month.zhi;
    var season = SEASON_OF[mzi];
    var tbl = DE_LING[season];
    var lingRank = '', lingVal = 0;
    ['旺', '相', '休', '囚', '死'].forEach(function (k) {
      if (tbl[k] === dwx) { lingRank = k; lingVal = RANK_VAL[k]; }
    });

    var deDi = 0, deDiList = [];
    var zhis = [pillars.year.zhi, pillars.month.zhi, pillars.day.zhi, pillars.hour ? pillars.hour.zhi : -1];
    zhis.forEach(function (zi, idx) {
      if (zi < 0) return;
      var zwx = ZHI_WX[zi];
      var v = 0;
      if (zwx === dwx) v = 1.0;                       // 同我：比劫得地
      else if (SHENG[zwx] === dwx) {                   // 生我：印
        if (zi === 1 || zi === 4) v = 0.7;             // 湿土（丑辰）能生金
        else if (zi === 7 || zi === 10) v = 0.25;      // 燥土（未戌）生力弱
        else v = 0.6;
      }
      if (v > 0) { deDi += v; deDiList.push(ZHI[zi] + '+' + v); }
    });

    var deShi = 0, deShiList = [];
    [pillars.year.gan, pillars.month.gan, pillars.hour ? pillars.hour.gan : -1].forEach(function (gi) {
      if (gi < 0) return;
      var wx = GAN_WX[gi], v = 0;
      if (wx === dwx) v = 0.8;                         // 比劫
      else if (SHENG[wx] === dwx) v = 0.5;             // 印
      else if (KE[dwx] === wx) v = -0.4;               // 财
      else if (KE[wx] === dwx) v = -0.9;               // 官杀
      else if (SHENG[dwx] === wx) v = -0.4;            // 食伤
      deShi += v;
      deShiList.push(GAN[gi] + (v > 0 ? '+' : '') + v);
    });

    var cb = combineMods(pillars);
    var combineAdj = 0;
    var myWx = dwx, helpWx = { '木': '水', '火': '木', '土': '火', '金': '土', '水': '金' }[dwx];
    ['木', '火', '土', '金', '水'].forEach(function (w) {
      var m = cb.mods[w] || 0;
      if (m === 0) return;
      if (w === myWx) combineAdj += m * 0.5;
      else if (w === helpWx) combineAdj += m * 0.3;
      else if (w === SHENG[dwx]) combineAdj -= m * 0.35;   // 食伤
      else if (w === KE[dwx]) combineAdj -= m * 0.3;       // 财
      else combineAdj -= m * 0.45;                          // 官杀
    });

    var score = lingVal + deDi + deShi + combineAdj;
    var state = score > 1.5 ? 'strong' : (score < -1.0 ? 'weak' : 'mid');
    return {
      score: +score.toFixed(2),
      state: state,
      stateText: state === 'strong' ? '身强' : (state === 'weak' ? '身弱' : '中和'),
      lingRank: lingRank, lingVal: lingVal, season: season,
      deDi: +deDi.toFixed(2), deDiList: deDiList,
      deShi: +deShi.toFixed(2), deShiList: deShiList,
      combineAdj: +combineAdj.toFixed(2), combineNotes: cb.notes
    };
  }

  /** 格局：月令本气/中气透干 → 十神格；禄刃 → 建禄/月劫；极强弱 → 从格 */
  function geJu(pillars, ws) {
    var dg = GAN[pillars.day.gan];
    var mzi = pillars.month.zhi;
    var hidden = HIDDEN[mzi];
    // 禄 / 刃
    if (LUS[dg] === mzi) return { name: '建禄格', type: 'normal', basis: dg + '禄在' + ZHI[mzi] };
    if (RENS[dg] === mzi) return { name: '月劫(羊刃)格', type: 'normal', basis: dg + '刃在' + ZHI[mzi] };

    var gans = [pillars.year.gan, pillars.month.gan, pillars.day.gan].map(function (i) { return GAN[i]; });
    if (pillars.hour) gans.push(GAN[pillars.hour.gan]);
    var found = null;
    for (var i = 0; i < hidden.length; i++) {
      var g = hidden[i];
      var gi = GAN.indexOf(g);
      var god = tenGod(pillars.day.gan, gi);
      var tou = gans.indexOf(g) >= 0 && gi !== pillars.day.gan;
      if (tou && !found) {
        found = { god: god, gan: g, pos: i === 0 ? '本气' : (i === 1 ? '中气' : '余气') };
      }
    }
    if (!found) {
      var g0 = hidden[0];
      found = { god: tenGod(pillars.day.gan, GAN.indexOf(g0)), gan: g0, pos: '本气(未透)' };
    }
    var nameMap = {
      '正官': '正官格', '七杀': '七杀格', '正财': '正财格', '偏财': '偏财格',
      '正印': '正印格', '偏印': '偏印格', '食神': '食神格', '伤官': '伤官格',
      '比肩': '比肩格', '劫财': '月劫格'
    };
    return { name: nameMap[found.god] || '杂格', type: 'normal', basis: '月令' + ZHI[mzi] + '藏' + found.gan + '(' + found.god + ',' + found.pos + ')透干' };
  }

  /** 从格检测：极弱无根或极强无制 */
  function followCheck(pillars, ws) {
    var dg = pillars.day.gan;
    var dwx = GAN_WX[dg];
    var zhis = [pillars.year.zhi, pillars.month.zhi, pillars.day.zhi, pillars.hour ? pillars.hour.zhi : -1];
    zhis = zhis.filter(function (z) { return z >= 0; });
    var hasRoot = zhis.some(function (zi) { return ZHI_WX[zi] === dwx; });
    var hasYin = zhis.some(function (zi) { return SHENG[ZHI_WX[zi]] === dwx; });
    if (ws.score <= -3.2 && !hasRoot && !hasYin) {
      return { is: true, kind: '从弱', note: '日主无根无印、四柱一边倒，作从格论（不作身弱用印比）' };
    }
    if (ws.score >= 4.5 && !hasYin) {
      return { is: true, kind: '从强', note: '日主极旺无制，作从强（专旺）论' };
    }
    return { is: false, kind: '', note: '' };
  }

  /** 调候用神（穷通宝鉴） */
  function tiaoHou(dg, mzi) {
    var row = TIAOHOU[dg];
    if (!row || mzi < 0) return [];
    // 表按「寅月」起排，查表换算：(月支序号 - 2 + 12) % 12
    return row[(mzi - 2 + 12) % 12] || [];
  }

  /**
   * 综合判盘：返回 强弱/格局/调候/喜忌五行/病药/推导
   */
  function judgeChart(pillars) {
    var dg = GAN[pillars.day.gan];
    var dwx = GAN_WX[pillars.day.gan];
    var ws = wangShuai(pillars);
    var gj = geJu(pillars, ws);
    var fc = followCheck(pillars, ws);
    var th = tiaoHou(dg, pillars.month.zhi);

    var reasons = [];
    reasons.push('得令：月令' + ZHI[pillars.month.zhi] + '属' + ws.season + '，' +
      dg + dwx + '为「' + ws.lingRank + '」计 ' + (ws.lingVal > 0 ? '+' : '') + ws.lingVal);
    reasons.push('得地：' + (ws.deDiList.length ? ws.deDiList.join('、') : '无') + ' 合计 ' +
      (ws.deDi > 0 ? '+' : '') + ws.deDi);
    reasons.push('得势：' + ws.deShiList.join('、') + ' 合计 ' + (ws.deShi > 0 ? '+' : '') + ws.deShi);
    if (ws.combineNotes.length) {
      reasons.push('合化：' + ws.combineNotes.join('；') + '（修正 ' + (ws.combineAdj > 0 ? '+' : '') + ws.combineAdj + '）');
    }
    reasons.push('旺衰合计 ' + ws.score + ' → ' + ws.stateText);

    // 喜忌五行（有序）
    var favWx = [], unfavWx = [];
    var yongShenText = '';
    if (fc.is && fc.kind === '从弱') {
      // 从格：顺从旺势
      var cnt = {};
      [pillars.year, pillars.month, pillars.day, pillars.hour].forEach(function (p) {
        if (!p) return;
        cnt[p.wx] = (cnt[p.wx] || 0) + 1; cnt[p.zwx] = (cnt[p.zwx] || 0) + 0.8;
        p.hidden.forEach(function (h, i) { cnt[h.wx] = (cnt[h.wx] || 0) + (i === 0 ? 0.8 : 0.4); });
      });
      var dom = null, domV = -1;
      ['木', '火', '土', '金', '水'].forEach(function (w) { var v = cnt[w] || 0; if (v > domV) { domV = v; dom = w; } });
      favWx = [dom, SHENG[dom], KE[dom]];
      unfavWx = [dwx, { '木': '水', '火': '木', '土': '火', '金': '土', '水': '金' }[dwx]];
      yongShenText = '从格，顺' + dom + '之势';
      reasons.push('从格判定：' + fc.note + '；取' + dom + '及生助' + dom + '者为用');
    } else if (fc.is && fc.kind === '从强') {
      favWx = [dwx, { '木': '水', '火': '木', '土': '火', '金': '土', '水': '金' }[dwx], SHENG[dwx]];
      unfavWx = [KE[dwx], { '木': '金', '火': '水', '土': '木', '金': '火', '水': '土' }[dwx]];
      yongShenText = '从强，顺' + dwx + '之势';
      reasons.push('从强判定：' + fc.note);
    } else {
      // 正格：先按强弱定方向
      var baseFav = [], baseUnfav = [];
      if (ws.state === 'weak') {
        baseFav = [dwx, { '木': '水', '火': '木', '土': '火', '金': '土', '水': '金' }[dwx]];
        baseUnfav = [KE[dwx], { '木': '金', '火': '水', '土': '木', '金': '火', '水': '土' }[dwx], SHENG[dwx]];
      } else if (ws.state === 'strong') {
        baseFav = [SHENG[dwx], KE[dwx], { '木': '金', '火': '水', '土': '木', '金': '火', '水': '土' }[dwx]];
        baseUnfav = [dwx, { '木': '水', '火': '木', '土': '火', '金': '土', '水': '金' }[dwx]];
      } else {
        // 中和：按格局顺逆取用
        var inverse = gj.name.indexOf('七杀') >= 0 || gj.name.indexOf('伤官') >= 0;
        if (inverse) {
          baseFav = [SHENG[dwx], { '木': '金', '火': '水', '土': '木', '金': '火', '水': '土' }[dwx]];
          baseUnfav = [dwx, { '木': '水', '火': '木', '土': '火', '金': '土', '水': '金' }[dwx]];
        } else {
          baseFav = [KE[dwx], { '木': '金', '火': '水', '土': '木', '金': '火', '水': '土' }[dwx], SHENG[dwx]];
          baseUnfav = [dwx, { '木': '水', '火': '木', '土': '火', '金': '土', '水': '金' }[dwx]];
        }
      }
      // 调候叠加：调候用神若为五行且缺，提到最前
      var thWx = [];
      th.forEach(function (g) {
        var w = GAN_WX[GAN.indexOf(g)];
        if (thWx.indexOf(w) < 0) thWx.push(w);
      });
      var cnt2 = {};
      [pillars.year, pillars.month, pillars.day, pillars.hour].forEach(function (p) {
        if (!p) return;
        cnt2[p.wx] = (cnt2[p.wx] || 0) + 1; cnt2[p.zwx] = (cnt2[p.zwx] || 0) + 0.8;
      });
      favWx = baseFav.slice();
      thWx.forEach(function (w) {
        if ((cnt2[w] || 0) <= 0.9 && favWx.indexOf(w) < 0) favWx.unshift(w);
      });
      favWx = favWx.filter(function (w, i, a) { return a.indexOf(w) === i; });
      unfavWx = baseUnfav.filter(function (w, i, a) { return a.indexOf(w) === i && favWx.indexOf(w) < 0; });
      yongShenText = '正格，' + ws.stateText + '取用';
      reasons.push('格局：' + gj.name + '（' + gj.basis + '）');
      if (th.length) {
        reasons.push('调候：' + dg + '生' + ZHI[pillars.month.zhi] + '月，穷通宝鉴取 ' + th.join('、'));
      }
    }
    return {
      wangShuai: ws, geJu: gj, follow: fc, tiaohou: th,
      favWx: favWx, unfavWx: unfavWx, yongShenText: yongShenText,
      reasons: reasons
    };
  }

  /** 五行 → 十神组（相对日主五行） */
  function wxToGodGroup(wx, dayWx) {
    if (wx === dayWx) return '比';
    if (wx === SHENG[dayWx]) return '食';
    if (wx === KE[dayWx]) return '财';
    for (var i = 0; i < WX_ORDER.length; i++) {
      if (SHENG[WX_ORDER[i]] === dayWx && WX_ORDER[i] === wx) return '印';
      if (KE[WX_ORDER[i]] === dayWx && WX_ORDER[i] === wx) return '官';
    }
    return '比';
  }

  var GOD_TEXT = { '印': '印绶', '比': '比劫', '食': '食伤', '财': '财星', '官': '官杀' };

  function computeStrength(pillars) {
    var dayGan = pillars.day.gan, dwx = GAN_WX[dayGan];
    var same = 0, other = 0;
    function addGan(g, w) { var god = tenGod(dayGan, g), grp = godGroup(god); if (grp === '印' || grp === '比') same += w; else other += w; }
    addGan(pillars.year.gan, 1); addGan(pillars.month.gan, 1); addGan(pillars.day.gan, 1);
    if (pillars.hour) addGan(pillars.hour.gan, 1);
    function addZhi(z, w) {
      HIDDEN[z].forEach(function (g, i) {
        var god = tenGod(dayGan, GAN.indexOf(g)), grp = godGroup(god);
        if (grp === '印' || grp === '比') same += w * HIDDEN_W[z][i]; else other += w * HIDDEN_W[z][i];
      });
    }
    addZhi(pillars.year.zhi, 0.8); addZhi(pillars.month.zhi, 1.6);
    addZhi(pillars.day.zhi, 1.2); if (pillars.hour) addZhi(pillars.hour.zhi, 0.8);
    var ratio = same / (same + other);

    // 强弱与喜忌以子平判盘为准
    var j = judgeChart(pillars);
    var fav = [], unfav = [];
    j.favWx.forEach(function (w) { var g = wxToGodGroup(w, dwx); if (fav.indexOf(g) < 0) fav.push(g); });
    j.unfavWx.forEach(function (w) { var g = wxToGodGroup(w, dwx); if (unfav.indexOf(g) < 0) unfav.push(g); });
    return {
      same: +same.toFixed(2), other: +other.toFixed(2), ratio: +ratio.toFixed(3),
      score: j.wangShuai.score,
      state: j.wangShuai.state, stateText: j.wangShuai.stateText,
      fav: fav, unfav: unfav,
      favText: fav.map(function (g) { return GOD_TEXT[g]; }).join('、'),
      unfavText: unfav.map(function (g) { return GOD_TEXT[g]; }).join('、'),
      favWx: j.favWx, unfavWx: j.unfavWx,
      geJu: j.geJu.name, judge: j,
      tiaohou: null, dayWx: dwx
    };
  }

  function branchRel(a, b) {
    var r = [];
    if (LIUCHONG[a] === b) r.push('冲');
    if (LIUHAI[a] === b) r.push('害');
    if (LIUHE[a] === b) r.push('合');
    if (ZIXING[a] === b && a === b) r.push('自刑');
    if ((a === 0 && b === 3) || (a === 3 && b === 0)) r.push('刑');
    XING3.forEach(function (g) { if (g.indexOf(a) >= 0 && g.indexOf(b) >= 0 && a !== b) r.push('三刑'); });
    return r;
  }

  function branchValue(from, to) {
    if (LIUCHONG[from] === to) return -1;
    if (LIUHAI[from] === to) return -0.6;
    if (from === to) return (ZIXING[from] === from) ? -0.7 : 0;
    if ((from === 0 && to === 3) || (from === 3 && to === 0)) return -0.7;
    var t3 = false; XING3.forEach(function (g) { if (g.indexOf(from) >= 0 && g.indexOf(to) >= 0) t3 = true; });
    if (t3) return -0.7;
    if (LIUHE[from] === to) return 0.7;
    return 0;
  }

  function changshengState(dayGan, zhiIdx) {
    var start = CS_START[dayGan];
    var yang = GYY[dayGan] === 0;
    for (var i = 0; i < 12; i++) {
      var z = yang ? (start + i) % 12 : (start - i + 24) % 12;
      if (z === zhiIdx) return { name: CHANGSHENG[i], value: CS_VALUE[CHANGSHENG[i]] };
    }
    return { name: '—', value: 0 };
  }

  function godValue(god, state) {
    var g = godGroup(god);
    if (state === 'weak') { if (g === '印' || g === '比') return 1; if (g === '食') return -0.3; return -0.6; }
    if (state === 'strong') { if (g === '食') return 1; if (g === '财') return 0.8; if (g === '官') return 0.5; if (g === '印') return -0.7; return -0.4; }
    if (g === '财' || g === '官') return 0.5; if (g === '食') return 0.3; return 0;
  }

  function todayPillars(spec, lon, tz) {
    tz = tz || 8;
    var st = solarTime(spec.y, spec.m, spec.d, spec.h, spec.mi, safeLon(lon), tz);
    var cal = st.cal, clockJd = st.clockJd;
    var bracket = jieBracket(clockJd, cal.y, tz);
    var lichun = termsOfYear(cal.y).filter(function (t) { return t.name === '立春'; })[0];
    var solarYear = (clockJd < lichun.jd + tz / 24) ? cal.y - 1 : cal.y;
    var yGZ = mod(solarYear - 1984, 60);
    var mBranch = zhiIdx(bracket.prev.branch);
    var yinGan = mod((yGZ % 10 % 5) * 2 + 2, 10);
    var mGan = mod(yinGan + ((mBranch - 2 + 12) % 12), 10);
    var mGZ = gzIndex(mGan, mBranch);
    var jdn = jdnOf(cal.y, cal.m, cal.d) + (cal.h >= 23 ? 1 : 0);
    var dGZ = mod(jdn + 49, 60);
    var hourIdx = Math.floor(((cal.h + 1) % 24) / 2);
    var hGZ = gzIndex(mod((dGZ % 10 % 5) * 2 + hourIdx, 10), hourIdx);
    return {
      year: { gz: yGZ, name: gzName(yGZ), gan: yGZ % 10, zhi: yGZ % 12 },
      month: { gz: mGZ, name: gzName(mGZ), gan: mGan, zhi: mBranch },
      day: { gz: dGZ, name: gzName(dGZ), gan: dGZ % 10, zhi: dGZ % 12 },
      hour: { gz: hGZ, name: gzName(hGZ), gan: hGZ % 10, zhi: hourIdx },
      solarYear: solarYear, cal: cal, jie: bracket, trueSolar: st
    };
  }

  function wxValue(from, day) {
    if (from === day) return 0.6;
    if (SHENG[from] === day) return 0.6;
    if (SHENG[day] === from) return -0.2;
    if (KE[from] === day) return -0.4;
    return -0.5;
  }

  function xunKong(gzIdx) {
    var xunStart = Math.floor(gzIdx / 10) * 10;
    var z = xunStart % 12;
    return [(z + 10) % 12, (z + 11) % 12];
  }

  var CHANGSHENG = ['长生', '沐浴', '冠带', '临官', '帝旺', '衰', '病', '死', '墓', '绝', '胎', '养'];
  var CS_START = [11, 6, 2, 9, 2, 9, 5, 0, 8, 3];
  var CS_VALUE = { '长生': 1, '临官': 1, '帝旺': 1, '冠带': 0.6, '沐浴': 0.3,
    '养': -0.3, '胎': -0.3, '衰': -0.6, '病': -0.8, '绝': -0.8, '死': -1, '墓': -1 };

  /** 今日运势综合评分 */
  function dailyFortune(chart, spec, lon, tz) {
    var t = todayPillars(spec, lon, tz);
    var dayGan = chart.dayGan, dayWX = GAN_WX[dayGan], state = chart.strength.state;
    var mz = chart.pillars.month.zhi, dz = chart.pillars.day.zhi, yz = chart.pillars.year.zhi;
    var hz = (chart.pillars.hour && chart.pillars.hour.gan >= 0) ? chart.pillars.hour.zhi : -1;
    var sig = [];
    function push(label, value, weight, detail) { sig.push({ label: label, value: value, weight: weight, detail: detail || '' }); }

    // 今日维度：日干十神 + 日支与命局四柱的关系 + 五行 + 十二长生 + 空亡
    var tGod = tenGod(dayGan, GAN[t.day.gan]);
    push('今日日干 ' + GAN[t.day.gan] + '（' + tGod + '）', godValue(tGod, state), 14);
    var rel = branchRel(t.day.zhi, dz);
    push('今日日支 ' + ZHI[t.day.zhi] + ' 与命局日支', rel.length ? rel.reduce(function (s, r) { return s + branchValue(t.day.zhi, dz); }, 0) / rel.length : 0, 12, rel.join(''));
    var relM2 = branchRel(t.day.zhi, mz);
    push('今日日支 与命局月支', relM2.length ? relM2.reduce(function (s, r) { return s + branchValue(t.day.zhi, mz); }, 0) / relM2.length : 0, 6, relM2.join(''));
    var relY2 = branchRel(t.day.zhi, yz);
    push('今日日支 与命局年支', relY2.length ? relY2.reduce(function (s, r) { return s + branchValue(t.day.zhi, yz); }, 0) / relY2.length : 0, 5, relY2.join(''));
    var relH2 = hz >= 0 ? branchRel(t.day.zhi, hz) : [];
    push('今日日支 与命局时支', relH2.length ? relH2.reduce(function (s, r) { return s + branchValue(t.day.zhi, hz); }, 0) / relH2.length : 0, 5, relH2.join(''));
    push('今日日支五行', wxValue(ZHI_WX[t.day.zhi], dayWX), 7);
    var cs = changshengState(dayGan, t.day.zhi);
    push('今日日支 ' + ZHI[t.day.zhi] + ' 对日主为' + cs.name, cs.value, 10);
    var kong = xunKong(t.day.gz);
    var isKong = kong.indexOf(t.day.zhi) >= 0;
    push(isKong ? '今日日支落空亡' : '今日日支不落空亡', isKong ? -0.8 : 0.2, 8, isKong ? ZHI[kong[0]] + ZHI[kong[1]] : '');

    // 流年 / 大运 / 月令
    var lGod = tenGod(dayGan, GAN[t.year.gan]);
    push('流年 ' + t.year.name + ' 天干', godValue(lGod, state), 9);
    var relL = branchRel(t.year.zhi, dz);
    push('流年地支 ' + ZHI[t.year.zhi] + ' 与命局日支', relL.length ? relL.reduce(function (s) { return s + branchValue(t.year.zhi, dz); }, 0) / relL.length : 0, 10, relL.join(''));
    push('流年地支五行', wxValue(ZHI_WX[t.year.zhi], dayWX), 5);
    var relY = branchRel(t.year.zhi, yz);
    push('太岁与命局年支', relY.length ? relY.reduce(function (s) { return s + branchValue(t.year.zhi, yz); }, 0) / relY.length : 0, 4, relY.join(''));

    // 当前大运
    var age = (spec.y - chart.input.y) + (spec.m - chart.input.m) / 12;
    var cur = null;
    chart.yun.list.forEach(function (y) { if (age >= y.ageFrom && age < y.ageTo) cur = y; });
    if (cur) {
      var yGod = tenGod(dayGan, GAN[cur.gan]);
      push('大运 ' + cur.name + ' 天干', godValue(yGod, state), 7);
      var relD = branchRel(cur.zhi, dz);
      push('大运地支 ' + ZHI[cur.zhi] + ' 与命局日支', relD.length ? relD.reduce(function (s) { return s + branchValue(cur.zhi, dz); }, 0) / relD.length : 0, 7, relD.join(''));
    }
    var relM = branchRel(t.month.zhi, dz);
    push('本月月支 ' + ZHI[t.month.zhi] + ' 与命局日支', relM.length ? relM.reduce(function (s) { return s + branchValue(t.month.zhi, dz); }, 0) / relM.length : 0, 5, relM.join(''));

    var wsum = 0, vsum = 0;
    sig.forEach(function (s) { wsum += s.weight; vsum += s.value * s.weight; });
    var ratio = wsum ? vsum / wsum : 0;
    var score = Math.max(0, Math.min(100, Math.round(50 + 45 * ratio)));

    // 宜忌
    var yi = [], ji = [];
    yi.push('进修学习（今日 ' + GAN[t.day.gan] + ' 为' + tGod + '）');
    var hong = HONGLUAN[dz], tian = TIANXI[dz], tde = TIANDE[mz];
    yi.push('走' + ZHI[TIANXI[dz]] + '日（天喜）：喜庆、人缘、见喜');
    yi.push('谈合作签约（' + ZHI[HONGLUAN[dz]] + '日为红鸾，和合助缘）');
    yi.push('天德贵人在' + tde + '干，逢' + tde + '日/时办事顺遂');
    if (chart.strength.favText) yi.push('补' + chart.strength.favText.split('、')[0] + '：养精蓄锐');
    ji.push('忌' + ZHI[LIUCHONG[dz]] + '日冲本命（' + ZHI[LIUCHONG[dz]] + '）');
    ji.push('忌' + ZHI[LIUHAI[dz]] + '日害命，破财、口舌');
    var relYear = branchRel(t.year.zhi, dz);
    if (relYear.indexOf('冲') >= 0) ji.push('太岁冲日支（' + t.year.name + '）：变动之年，守成为上');
    ji.push('忌大额投资、冲动决策');
    if (cs.name !== '—') {
      yi.push('今日日支' + ZHI[t.day.zhi] + ' 对日主为' + cs.name + '：顺势而为');
    }
    if (isKong) {
      ji.push('今日日支落空亡（' + ZHI[kong[0]] + ZHI[kong[1]] + '）：事倍功半，宜低调守成');
    }

    // 评语
    var notes = [];
    sig.forEach(function (s) {
      if (Math.abs(s.value) < 0.35) return;
      var v = s.value > 0 ? '吉' : '凶';
      notes.push({ v: v, w: Math.abs(s.value * s.weight), text: s.label + (s.detail ? '（' + s.detail + '）' : '') + (v === '吉' ? '，为吉象' : '，为凶象') });
    });
    notes.sort(function (a, b) { return Math.abs(b.w) - Math.abs(a.w); });
    if (notes.length > 8) notes.length = 8;

    var label, level;
    if (score >= 85) { label = '大吉'; level = 5; }
    else if (score >= 72) { label = '吉'; level = 4; }
    else if (score >= 58) { label = '平'; level = 3; }
    else if (score >= 45) { label = '小凶'; level = 2; }
    else { label = '凶'; level = 1; }

    return {
      score: score, label: label, level: level, sig: sig, notes: notes, yi: yi, ji: ji,
      today: t, curYun: cur, age: +age.toFixed(1)
    };
  }

  /** 流年列表 */
  function yearList(from, to) {
    var out = [];
    for (var y = from; y <= to; y++) {
      var gz = mod(y - 1984, 60);
      out.push({ year: y, gz: gz, name: gzName(gz), gan: gz % 10, zhi: gz % 12 });
    }
    return out;
  }

  /* ---------- 自检 ---------- */
  function selftest() {
    var checks = [];
    function chk(name, got, want, tol) {
      var ok = (typeof got === 'string' || typeof want === 'string') ? (got === want) : (Math.abs(got - want) <= (tol || 0));
      checks.push({ name: name, got: got, want: want, ok: ok });
      return ok;
    }
    // 节气（对照香港天文台发布值；本引擎按 TT 计算，系统性偏晚约 ΔT≈69s）
    var cases = [
      ['2024立春', 2024, '立春', '2024-02-04 16:26:53'],
      ['2024春分', 2024, '春分', '2024-03-20 11:06:12'],
      ['2024立秋', 2024, '立秋', '2024-08-07 08:09:01'],
      ['2024冬至', 2024, '冬至', '2024-12-21 17:21:20'],
      ['2025立春', 2025, '立春', '2025-02-03 22:10:13'],
      ['2023冬至', 2023, '冬至', '2023-12-22 11:27:09'],
      ['2021冬至', 2021, '冬至', '2021-12-21 23:59:33'],
      ['2000春分', 2000, '春分', '2000-03-20 15:35:15']
    ];
    cases.forEach(function (c) {
      var t = termsOfYear(c[1]).filter(function (x) { return x.name === c[2]; })[0];
      var got = jdToLocalStr(t.jd, 8);
      var gd = Date.parse(got.replace(' ', 'T') + '+08:00');
      var wd = Date.parse(c[3].replace(' ', 'T') + '+08:00');
      chk(c[0], gd, wd, 150000);
    });
    // Meeus 例 25.a：1992-10-13.0 TD 太阳视黄经 = 199°54'21.82" = 199.90606°
    chk('Meeus25.a视黄经', +sunLon(2448908.5).toFixed(4), 199.9061, 0.001);
    // 日柱
    chk('2000-01-01日柱', gzName(mod(jdnOf(2000, 1, 1) + 49, 60)), '戊午');
    chk('1949-10-01日柱', gzName(mod(jdnOf(1949, 10, 1) + 49, 60)), '甲子');
    chk('2024-01-01日柱', gzName(mod(jdnOf(2024, 1, 1) + 49, 60)), '甲子');
    return checks;
  }

  return {
    GAN: GAN, ZHI: ZHI, GAN_WX: GAN_WX, ZHI_WX: ZHI_WX, HIDDEN: HIDDEN, CITIES: CITIES,
    JIE: JIE, TIANDE: TIANDE, HONGLUAN: HONGLUAN, TIANXI: TIANXI,
    sunLon: sunLon, eqOfTime: eqOfTime, termsOfYear: termsOfYear, jieOfYear: jieOfYear,
    jdFromUTC: jdFromUTC, jdnOf: jdnOf, jdToCal: jdToCal, jdToLocalStr: jdToLocalStr,
    safeLon: safeLon,
    wuxingPlan: wuxingPlan,
    judgeChart: judgeChart,
    wangShuai: wangShuai,
    tiaoHou: tiaoHou,
    wxGuide: wxGuide,
    gzName: gzName, gzIndex: gzIndex, tenGod: tenGod, godGroup: godGroup,
    solarTime: solarTime, buildChart: buildChart, todayPillars: todayPillars,
    dailyFortune: dailyFortune, branchRel: branchRel, yearList: yearList, selftest: selftest,
    LIUCHONG: LIUCHONG, LIUHE: LIUHE, LIUHAI: LIUHAI
  };
});
