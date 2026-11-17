#!/bin/bash
# 一条命令：拉取源码并编译（在笔记本上执行）
set -e
BASE=/storage/Users/currentUser/Documents/DevEcoStudioProjects
mkdir -p "$BASE"
cd "$BASE"
rm -rf harmony-bazi-main BaziFortune
curl -fsSL -o bazi.tgz https://github.com/themachinecorp/harmony-bazi/archive/refs/heads/main.tar.gz
tar xzf bazi.tgz
mv harmony-bazi-main BaziFortune
cd BaziFortune
bash build-laptop.sh "$BASE/BaziFortune"
