#!/bin/bash
# 在笔记本（鸿蒙电脑）上编译 HAP。用法：bash build-laptop.sh [工程目录]
set -e
PROJ=${1:-/storage/Users/currentUser/Documents/DevEcoStudioProjects/BaziFortune}
CLT=/data/service/hnp/hmos-clt.org/hmos-clt_1.0.0
cd "$PROJ"
printf 'sdk.dir=%s/sdk/default/hms\n' "$CLT" > local.properties
DEVECO_SDK_HOME="$CLT/sdk" "$CLT/hvigor/bin/hvigorw" assembleHap \
  --mode module -p product=default -p module=entry@default --no-daemon
ls -l entry/build/default/outputs/default/*.hap
