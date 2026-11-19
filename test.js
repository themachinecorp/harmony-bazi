/* 八字引擎自检：node test.js */
const B = require('./bazi.js');
let pass = 0, fail = 0;
const eq = (name, got, want) => {
  const ok = String(got) === String(want);
  ok ? pass++ : fail++;
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name.padEnd(26)} got=${got}${ok ? '' : '  want=' + want}`);
};
const near = (name, got, want, tol) => {
  const ok = Math.abs(got - want) <= tol;
  ok ? pass++ : fail++;
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name.padEnd(26)} got=${got} want=${want}±${tol}`);
};

/* 1. 天文：节气与视黄经 */
B.selftest().forEach(c => {
  c.ok ? pass++ : fail++;
  console.log(`${c.ok ? 'PASS' : 'FAIL'}  ${String(c.name).padEnd(26)} got=${c.got} want=${c.want}`);
});

/* 2. 干支历法 */
eq('1984=甲子年', B.gzName((1984 - 1984) % 60), '甲子');
eq('2024=甲辰年', B.gzName((2024 - 1984) % 60), '甲辰');
eq('日柱 2024-01-01', B.gzName((B.jdnOf(2024, 1, 1) + 49) % 60), '甲子');
eq('日柱 2000-01-01', B.gzName((B.jdnOf(2000, 1, 1) + 49) % 60), '戊午');
eq('日柱 1949-10-01', B.gzName((B.jdnOf(1949, 10, 1) + 49) % 60), '甲子');

/* 3. 年柱以立春为界 */
const before = B.buildChart({ y: 2024, m: 2, d: 4, h: 10, mi: 0, lon: 116.4, gender: 'm' });
const after = B.buildChart({ y: 2024, m: 2, d: 4, h: 20, mi: 0, lon: 116.4, gender: 'm' });
eq('立春前 年柱', before.pillars.year.name, '癸卯');
eq('立春前 月柱', before.pillars.month.name, '乙丑');
eq('立春后 年柱', after.pillars.year.name, '甲辰');
eq('立春后 月柱', after.pillars.month.name, '丙寅');

/* 4. 晚子时换日（23:00 归次日） */
const late = B.buildChart({ y: 2024, m: 3, d: 5, h: 23, mi: 30, lon: 120, gender: 'm' });
const early = B.buildChart({ y: 2024, m: 3, d: 5, h: 22, mi: 30, lon: 120, gender: 'm' });
eq('22:30 日柱', early.pillars.day.name, '戊辰');
eq('23:30 日柱(换日)', late.pillars.day.name, '己巳');
eq('23:30 时支', late.pillars.hour.name[1], '子');

/* 5. 真太阳时 */
// 真太阳时 = 钟表时 + 经度时差 + 均时差
[[116.4, '北京'], [87.62, '乌鲁木齐'], [91.11, '拉萨'], [121.47, '上海']].forEach(([lon, nm]) => {
  const s0 = B.solarTime(1990, 6, 15, 14, 30, lon, 8);
  const exp = 14 * 60 + 30 + (lon - 120) * 4 + s0.eotMin;
  near('真太阳时(' + nm + ')', s0.cal.h * 60 + s0.cal.mi, exp, 1.5);
});

/* 6. 五虎遁 / 五鼠遁 */
const c2 = B.buildChart({ y: 1990, m: 6, d: 15, h: 14, mi: 30, lon: 116.4, gender: 'm' });
eq('1990-06-15 四柱', [c2.pillars.year.name, c2.pillars.month.name, c2.pillars.day.name, c2.pillars.hour.name].join(' '), '庚午 壬午 辛亥 乙未');
eq('日主十神 年干', c2.pillars.year.god, '劫财');
eq('日主十神 月干', c2.pillars.month.god, '伤官');
eq('日主十神 时干', c2.pillars.hour.god, '偏财');

/* 7. 大运顺逆与起运 */
eq('阳年男 顺行', c2.yun.dirText, '顺行');
const c3 = B.buildChart({ y: 1990, m: 6, d: 15, h: 14, mi: 30, lon: 116.4, gender: 'f' });
eq('阳年女 逆行', c3.yun.dirText, '逆行');
near('起运岁数', c2.yun.startAge, 7.37, 0.05);
eq('交运日期', c2.yun.qiuYun, '1997-10-15');
eq('首步大运', c2.yun.list[0].name, '癸未');

/* 8. 今日干支与运势 */
const spec = { y: 2024, m: 3, d: 1, h: 12, mi: 0 };
const f = B.dailyFortune(c2, spec, 116.4, 8);
eq('今日年柱', f.today.year.name, '甲辰');
eq('今日月柱(惊蛰前)', f.today.month.name, '丙寅');
eq('今日日柱', f.today.day.name, '丙寅'.slice(0, 0) + '丙寅' === '' ? '' : B.gzName((B.jdnOf(2024, 3, 1) + 49) % 60));
const f2 = B.dailyFortune(c2, { y: 2024, m: 3, d: 5, h: 12, mi: 0 }, 116.4, 8);
eq('今日月柱(惊蛰后)', f2.today.month.name, '丁卯');
eq('今日日柱(03-05)', f2.today.day.name, '戊辰');
near('评分范围', f.score >= 0 && f.score <= 100 ? 1 : 0, 1, 0);
eq('评分标签', ['大吉', '吉', '平', '小凶', '凶'].includes(f.label) ? 1 : 0, 1);

/* 9. 地支关系 */
eq('子午冲', B.branchRel(0, 6).join(''), '冲');
eq('寅亥合', B.branchRel(2, 11).join(''), '合');
eq('子卯刑', B.branchRel(0, 3).join(''), '刑');
eq('辰辰自刑', B.branchRel(4, 4).join(''), '自刑');
eq('寅巳(害+三刑)', B.branchRel(2, 5).join(''), '害三刑');

/* 时辰未知 / 夏令时 / 女命：不得抛异常 */
{
  const base = { y: 1994, m: 6, d: 14, h: 15, mi: 29, lon: 106.55, gender: 'm', tz: 8, dst: false, unknownHour: false };
  [['时辰未知', { unknownHour: true }], ['夏令时', { dst: true }],
   ['未知+夏令时', { unknownHour: true, dst: true }], ['女命', { gender: 'f' }]].forEach(v => {
    let res = 'ok';
    try {
      const o = Object.assign({}, base, v[1]);
      const c = B.buildChart(o);
      B.dailyFortune(c, { y: 2026, m: 11, d: 19, h: 9, mi: 0 }, o.lon, 8);
      B.yearList(c, 2024, 2031);
    } catch (e) { res = e.message; }
    eq(v[0] + ' 不抛异常', res, 'ok');
  });
}

/* 判盘稳定性：同一天不同时刻，喜忌/格局/强弱不应翻转 */
{
  const times = [[3, 0], [5, 30], [8, 0], [11, 30], [15, 29], [18, 0], [20, 0], [22, 0]];
  const keys = new Set();
  let first = null;
  times.forEach(t => {
    const c = B.buildChart({ y: 1994, m: 6, d: 14, h: t[0], mi: t[1], lon: 106.55, gender: 'm', tz: 8 });
    const j = c.strength.judge;
    const k = [j.wangShuai.stateText, j.geJu.name, j.favWx.join(''), j.unfavWx.join('')].join('|');
    keys.add(k);
    if (first === null) first = k;
  });
  eq('同日喜忌稳定(8个时辰)', keys.size, 1);
  eq('本日喜忌内容', Array.from(keys)[0], '身弱|七杀格|水土金|木火');
}

/* 调候优先：辛金午月须取水（壬己癸），且水必在喜用 */
{
  const c = B.buildChart({ y: 1994, m: 6, d: 14, h: 15, mi: 29, lon: 106.55, gender: 'm', tz: 8 });
  const j = c.strength.judge;
  eq('辛午月调候', j.tiaohou.join(''), '壬己癸');
  eq('调候水入喜用', j.favWx.indexOf('水') >= 0, true);
}

/* 冬生戊土（1994-12-28 女 重庆）：两子当头身弱，喜火土忌水木金，木为佐用 */
{
  const times = [[8, 0], [12, 0], [20, 0]];
  const keys = new Set();
  times.forEach(t => {
    const c = B.buildChart({ y: 1994, m: 12, d: 28, h: t[0], mi: t[1], lon: 106.55, gender: 'f', tz: 8 });
    const j = c.strength.judge;
    keys.add([j.wangShuai.stateText, j.geJu.name, j.favWx.join(''), j.unfavWx.join('')].join('|'));
  });
  eq('冬戊土结论稳定', keys.size, 1);
  eq('冬戊土喜忌', Array.from(keys)[0], '身弱|正财格|火土|水木金');
}

/* 冬生戊土不能判成「身强喜财」：地支两子（财）必须计力 */
{
  const c = B.buildChart({ y: 1994, m: 12, d: 28, h: 12, mi: 0, lon: 106.55, gender: 'f', tz: 8 });
  eq('冬戊土判身弱', c.strength.stateText, '身弱');
  eq('冬戊土喜火', c.strength.judge.favWx.indexOf('火') >= 0, true);
  eq('冬戊土忌水', c.strength.judge.unfavWx.indexOf('水') >= 0, true);
}

console.log(`\n${fail === 0 ? '全部通过' : '有失败项'}：${pass} 通过 / ${fail} 失败`);
process.exit(fail ? 1 : 0);
