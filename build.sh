#!/bin/bash
# 构建 Quartz 站点并把 dashboard.html 拷到与 data.json、报告页同目录
# 用法: ./build.sh        # 一次性构建到 public/
#       ./serve.sh        # 构建 + 启动静态服务器 (推荐)
set -e
cd "$(dirname "$0")"

echo "==> 构建 Quartz..."
npx quartz build

echo "==> 拷贝 dashboard.html 到输出目录..."
# Quartz 把 quartz/static/ 原样复制到 public/static/，但 dashboard 需要
# 与 data.json、报告页同源（/stocks/tencent/）才能 fetch 数据 + 链接生效
mkdir -p public/stocks/tencent
cp public/static/stocks/tencent/dashboard.html public/stocks/tencent/dashboard.html

echo ""
echo "✓ 构建完成。产物在 public/"
echo "  腾讯仪表盘: http://localhost:8080/stocks/tencent/dashboard.html"
echo "  腾讯总纲:   http://localhost:8080/stocks/tencent/00-tencent-seven-questions-summary.html"
echo "  首页:       http://localhost:8080/"
echo ""
echo "启动服务器: ./serve.sh  或  python3 -m http.server 8080 -d public"
