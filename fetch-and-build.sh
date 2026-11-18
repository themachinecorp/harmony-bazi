#!/bin/bash
# 一条命令：拉取源码并编译（笔记本上执行）
# 注意：保留本地 build-profile.json5（DevEco 自动签名写在里面），只覆盖代码
set -e
BASE=/storage/Users/currentUser/Documents/DevEcoStudioProjects
PROJ="$BASE/BaziFortune"
URL=https://github.com/themachinecorp/harmony-bazi/archive/refs/heads/main.tar.gz
mkdir -p "$BASE"
cd "$BASE"

# 下载（TLS 偶发失败，重试 3 次；绕过本机代理）
for i in 1 2 3; do
  if env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY \
      curl -fsSL --noproxy '*' -o bazi.tgz "$URL"; then
    break
  fi
  echo "下载失败，第 $i 次重试…"
  sleep 3
done
[ -s bazi.tgz ] || { echo "下载失败，请检查网络或代理"; exit 1; }

# 保住本地签名配置
mkdir -p "$PROJ"
if [ -f "$PROJ/build-profile.json5" ]; then
  cp "$PROJ/build-profile.json5" /tmp/bp_keep.json5
fi
tar xzf bazi.tgz --strip-components=1 -C "$PROJ"
if [ -f /tmp/bp_keep.json5 ]; then
  cp /tmp/bp_keep.json5 "$PROJ/build-profile.json5"
  echo "已保留本地签名配置"
fi

cd "$PROJ"
bash build-laptop.sh "$PROJ"

# 装到已连接的手机
if command -v hdc >/dev/null 2>&1 && hdc list targets 2>/dev/null | grep -q .; then
  echo "=== 安装到手机 ==="
  hdc install "$PROJ/entry/build/default/outputs/default/entry-default-signed.hap" || \
  hdc install "$PROJ/entry/build/default/outputs/default/entry-default-unsigned.hap"
fi
