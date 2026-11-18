# harmony-bazi —— 八字运势（鸿蒙手机端）

原生鸿蒙 ArkTS + ArkUI 应用「时辰」：设出生日期 / 时间 / 出生地 → 排八字、大运、流年 → 给当天干支与运势。

## 环境要求

| 项 | 版本 |
| --- | --- |
| DevEco Studio | 5.0 或更高（API 12 / HarmonyOS NEXT） |
| SDK | HarmonyOS NEXT API 12（`compatibleSdkVersion: 5.0.0(12)`） |
| 设备 | HarmonyOS NEXT 手机（API 12+） |

## 编译（笔记本上）

```bash
cd /storage/Users/currentUser/Documents/DevEcoStudioProjects/BaziFortune
printf 'sdk.dir=/data/service/hnp/hmos-clt.org/hmos-clt_1.0.0/sdk/default/hms\n' > local.properties
DEVECO_SDK_HOME=/data/service/hnp/hmos-clt.org/hmos-clt_1.0.0/sdk \
  /data/service/hnp/hmos-clt.org/hmos-clt_1.0.0/hvigor/bin/hvigorw assembleHap \
  --mode module -p product=default -p module=entry@default --no-daemon
```

产物：`entry/build/default/outputs/default/entry-default-unsigned.hap`
（未配签名时为 unsigned，签名在 DevEco 里勾「自动生成签名」后重新构建。）

在 DevEco Studio 里：`File → Open` 选本目录 → `Build → Build Hap(s)/APP(s) → Build Hap(s)`。

## 目录

```
AppScope/                       应用级配置（包名 com.dsh.bazi、名称、图标）
entry/src/main/
  ets/
    entryability/EntryAbility.ets   启动页 + 本地存储初始化
    model/Bazi.ets                   排盘引擎：真太阳时/四柱/大运/流年/运势评分
    model/Theme.ets                  配色
    store/BirthStore.ets             生辰本地存档（preferences）
    components/InputCard.ets         生辰录入
    components/TodayCard.ets         今日概览（评分/宜忌/解读）
    components/ChartCard.ets         命盘四柱
    components/YunCard.ets           大运 / 流年 / 真太阳时明细
    pages/Index.ets                  根页面
  resources/base/                    文案、配色、图标、页面路由
```

## 口径（与 bazi-fortune 网页版完全一致）

- **真太阳时** = 钟表时 + 经度时差 `(经度-120)×4 分` + 均时差（由太阳视黄经算）。真太阳时定日柱（跨日换日）与时柱；节令边界（年/月柱）按北京钟表时间与节气时刻比较，与国内万年历口径一致。
- **太阳视黄经**：截断 VSOP87（Meeus 附录 III，系数按千年 τ 标定）+ 章动 + 光行差。节气时刻与香港天文台发布值相差 3–100 秒（差值即 ΔT≈69s，本程序按 TT 计算）。
- **年柱**以立春换年，**月柱**以十二节换月，**日柱** 23:00 换日（晚子时归次日）。
- **大运**：阳年男 / 阴年女顺行，阴年男 / 阳年女逆行；三天折一年（1 天 = 4 个月），给出起运岁数与交运日期。
- **运势评分**：十神喜忌（身强/身弱 + 调候）× 地支刑冲合害 × 大运流年与命局互动，加权合成 0–100 分，并给出宜忌与逐条解读。

## 数据流（唯一真相源）

- `BirthStore.queried` = 最近一次**已查询**的生辰；`BirthStore.draft` = 表单草稿。
- 录入页：改表单 → `draft`；点「排盘」→ `queried` + 落盘 → 跳结果页。
- 结果页：读 `queried`（无则读存档）→ 每次进入都重算；返回时清空自己的状态（不影响 `queried`）。
- 录入页 `onPageShow`（从结果页返回）：用 `queried` **回填表单** —— 所以返回后表单显示的永远是最近一次查询的信息。
- 录入卡用 **JSON 字符串 prop** 接收生辰（原始类型，避免 @Prop 传对象时深拷贝导致显示与状态不一致）。

## 引擎验证

`entry/src/main/ets/model/Bazi.ets` 与网页版 `bazi-fortune/bazi.js` 同算法，两者已逐项对拍一致
（7 组生辰 × 四柱/十神/身强弱/大运/真太阳时/今日四支/评分/宜忌/解读 + 4 个年份的 24 节气时刻，偏差 0 秒）。

## 说明

属民俗算法，输出仅供娱乐参考，不作科学依据。
