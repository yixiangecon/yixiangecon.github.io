#!/bin/bash

# 自动监视并部署网站脚本
# 当 .qmd 文件或 images 目录发生变化时，自动构建并推送到 GitHub

set -e

WATCH_DIR="~/Documents/GitHub/yixiangecon.github.io"
DEBOUNCE_TIME=5  # 防抖时间（秒），避免频繁触发

echo "👀 开始监视网站文件变化..."
echo "📁 监视目录: $WATCH_DIR"
echo "⏱️  防抖延迟: ${DEBOUNCE_TIME}秒"
echo "按 Ctrl+C 停止监视"
echo ""

cd "$WATCH_DIR"

# 检查依赖
if ! command -v fswatch &> /dev/null; then
    echo "⚠️  需要安装 fswatch 工具"
    echo "请使用 Homebrew 安装: brew install fswatch"
    exit 1
fi

# 上次构建时间
LAST_BUILD=0

# 处理文件变化的函数
handle_change() {
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - LAST_BUILD))

    # 防抖：距离上次构建至少等待 DEBOUNCE_TIME 秒
    if [ $TIME_DIFF -lt $DEBOUNCE_TIME ]; then
        return
    fi

    LAST_BUILD=$CURRENT_TIME

    echo ""
    echo "📝 检测到文件变化 ($(date '+%Y-%m-%d %H:%M:%S'))"
    echo "----------------------------------------"

    # 执行部署
    if ./deploy.sh "自动更新 $(date '+%Y-%m-%d %H:%M:%S')"; then
        echo "✅ 自动部署成功"
    else
        echo "❌ 自动部署失败，请手动检查"
    fi

    echo "👀 继续监视中..."
}

# 监视的文件和目录
# - .qmd 文件
# - images 目录
# - _quarto.yml 配置文件
# - styles.scss 样式文件
# - docs 目录（构建输出，可选）

fswatch -0 -r -e "\\.git/" -e "\\.DS_Store" -e "docs/" \
    -e "\\.Rhistory" -e "\\.RData" -e "\\.quarto/" \
    -i "\\.qmd$" \
    -i "images/" \
    -i "_quarto\\.yml$" \
    -i "styles\\.scss$" \
    "$WATCH_DIR" | while read -d "" event; do
    handle_change
done
