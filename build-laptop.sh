#!/bin/bash
# 在笔记本（鸿蒙电脑）上编译 HAP。用法：bash build-laptop.sh [工程目录]
# 日志同时写入 build.log，便于事后排查（笔记本内存紧，编译可能是 OOM 被杀）。
set -e
PROJ=${1:-/storage/Users/currentUser/Documents/DevEcoStudioProjects/BaziFortune}
CLT=/data/service/hnp/hmos-clt.org/hmos-clt_1.0.0
cd "$PROJ"
printf 'sdk.dir=%s/sdk/default/hms\n' "$CLT" > local.properties
LOG="$PROJ/build.log"
echo "== 开始编译 $(date '+%F %T') ==" | tee "$LOG"
# 限制 node 堆，避免把机器内存吃满导致 agent/IDE 被 OOM 杀掉
export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=1536}"
DEVECO_SDK_HOME="$CLT/sdk" "$CLT/hvigor/bin/hvigorw" assembleHap \
  --mode module -p product=default -p module=entry@default --no-daemon 2>&1 | tee -a "$LOG"
ls -l entry/build/default/outputs/default/*.hap 2>&1 | tee -a "$LOG"
echo "== 结束 $(date '+%F %T') ==" | tee -a "$LOG"
