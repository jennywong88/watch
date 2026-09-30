#!/usr/bin/env bash
# 更新並推送 watch-inventory 到 GitHub Pages
#
# 用法：
#   cd watch-deploy && ./deploy.sh
#   # 若這個資料夾不在原本位置，用環境變數指定來源檔：
#   WATCH_SRC="/path/to/watch/watch-inventory.html" ./deploy.sh
set -euo pipefail
cd "$(dirname "$0")"

SRC="${WATCH_SRC:-../watch/watch-inventory.html}"
if [ ! -f "$SRC" ]; then
  echo "❌ 找不到來源檔：$SRC"
  echo "   → 請用環境變數指定正確路徑，例如："
  echo "     WATCH_SRC=\"/Users/你的帳號/path/to/watch/watch-inventory.html\" ./deploy.sh"
  exit 1
fi

cp "$SRC" index.html
echo "✅ 已更新 index.html（$(wc -c < index.html | tr -d ' ') bytes）← $SRC"

if [ ! -d .git ]; then
  git init -b main >/dev/null
  echo "ℹ️  已初始化 git repository（分支 main）"
fi

if [ -z "$(git config user.email || true)" ]; then
  echo "⚠️  尚未設定 git 身分，請先執行這兩行（只需一次）："
  echo "    git config user.name  \"你的名字\""
  echo "    git config user.email \"你的Email\""
  exit 1
fi

git add -A
if git diff --cached --quiet; then
  echo "ℹ️  沒有變更，略過 commit"
else
  git commit -m "update watch inventory $(date '+%Y-%m-%d %H:%M')" >/dev/null
  echo "✅ 已建立 commit"
fi

if git remote get-url origin >/dev/null 2>&1; then
  git push
  echo "🚀 已推送完成。"
  echo "   Pages 網址：https://<你的帳號>.github.io/<repo名稱>/"
  echo "   （Pages 有快取，通常 1–10 分鐘生效；急用可加 ?v=$(date +%s)）"
else
  echo "ℹ️  尚未設定 remote，請執行（只需一次）："
  echo "    git remote add origin https://github.com/<你的帳號>/<repo名稱>.git"
  echo "    git push -u origin main"
fi
