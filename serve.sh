#!/bin/bash
# 启动 Quartz 站点 (含仪表盘) — 推荐用法
# 一切同源: 仪表盘 + 报告页 + data.json，[[wikilink]] 双链可跳转
set -e
cd "$(dirname "$0")"

echo "==> 启动 Quartz (首次会构建, 约 5 秒)..."
npx quartz build --serve &
QUARTZ_PID=$!

# 等待初始构建完成
echo "==> 等待构建完成..."
for i in {1..40}; do
  [ -f public/stocks/tencent/00-tencent-seven-questions-summary.html ] && break
  sleep 1
done

# Quartz 把 dashboard.html 当内容页处理会破坏其自包含结构，
# 因此在 ignorePatterns 排除，并通过 quartz/static/ 复制后手动放到与报告同目录
cp public/static/stocks/tencent/dashboard.html public/stocks/tencent/dashboard.html 2>/dev/null || true

echo ""
echo "✓ 站点已启动: http://localhost:8080"
echo "  仪表盘:     http://localhost:8080/stocks/tencent/dashboard.html"
echo "  七问总纲:   http://localhost:8080/stocks/tencent/00-tencent-seven-questions-summary"
echo "  首页/导航:  http://localhost:8080/"
echo ""
echo "  按 Ctrl+C 停止"
echo "  注: 若编辑了 vault 内容触发重建, 仪表盘文件可能被清, 重跑 ./serve.sh 即可"

wait $QUARTZ_PID
