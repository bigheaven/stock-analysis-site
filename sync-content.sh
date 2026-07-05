#!/bin/bash
# 从 vault 同步内容到 content/（之后 git commit + push 即可发布）
set -e
VAULT="/Users/spacey/Library/Mobile Documents/iCloud~md~obsidian/Documents/AIGC/StockAnalysis"
echo "同步 vault → content/ ..."
cp "$VAULT/INDEX.md" content/INDEX.md
for dir in stocks case-studies operators patterns playbooks; do
  rm -rf "content/$dir"
  cp -r "$VAULT/$dir" "content/$dir"
  echo "  ✓ $dir"
done
echo "完成。git add content/ && git commit -m 'sync vault content' && git push"
