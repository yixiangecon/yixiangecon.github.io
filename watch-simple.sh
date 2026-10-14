#!/bin/bash

# 简化的自动监视脚本（使用轮询方式，无需额外依赖）
# 每 5 秒检查一次文件变化

set -e

WATCH_DIR="~/Documents/GitHub/yixiangecon.github.io"
CHECK_INTERVAL=5  # 检查间隔（秒）

echo "👀 开始监视网站文件变化（轮询模式）..."
echo "📁 监视目录: $WATCH_DIR"
echo "⏱️  检查间隔: ${CHECK_INTERVAL}秒"
echo "监视的文件类型: .qmd, images/, _quarto.yml, styles.scss"
echo "按 Ctrl+C 停止监视"
echo ""

cd "$WATCH_DIR"

# 获取初始的修改时间戳
get_latest_mtime() {
    # 找到最新的修改时间
    find . -type f \( -name "*.qmd" -o -name "_quarto.yml" -o -name "styles.scss" \) \
        -not -path "./.git/*" -not -path "./.quarto/*" -not -path "./docs/*" \
        2>/dev/null | xargs stat -f "%m" 2>/dev/null | sort -rn | head -1
}

# 获取 images 目录的最新修改时间
get_images_mtime() {
    if [ -d "images" ]; then
        find images -type f 2>/dev/null | xargs stat -f "%m" 2>/dev/null | sort -rn | head -1
    fi
}

LAST_QMD_TIME=$(get_latest_mtime)
LAST_IMAGES_TIME=$(get_images_mtime)

echo "初始时间戳记录完成，开始监视..."

while true; do
    sleep $CHECK_INTERVAL

    # 检查 qmd 文件
    CURRENT_QMD_TIME=$(get_latest_mtime)
    if [ "$CURRENT_QMD_TIME" != "$LAST_QMD_TIME" ] && [ -n "$CURRENT_QMD_TIME" ]; then
        echo ""
        echo "📝 检测到 .qmd 文件或配置文件变化 ($(date '+%Y-%m-%d %H:%M:%S'))"
        echo "----------------------------------------"

        LAST_QMD_TIME=$CURRENT_QMD_TIME

        # 执行部署
        if ./deploy.sh "自动更新 $(date '+%Y-%m-%d %H:%M:%S')"; then
            echo "✅ 自动部署成功"
        else
            echo "❌ 自动部署失败，请手动检查"
        fi

        echo "👀 继续监视中..."
        continue
    fi

    # 检查 images 目录
    CURRENT_IMAGES_TIME=$(get_images_mtime)
    if [ "$CURRENT_IMAGES_TIME" != "$LAST_IMAGES_TIME" ] && [ -n "$CURRENT_IMAGES_TIME" ]; then
        echo ""
        echo "🖼️  检测到 images 目录变化 ($(date '+%Y-%m-%d %H:%M:%S'))"
        echo "----------------------------------------"

        LAST_IMAGES_TIME=$CURRENT_IMAGES_TIME

        # 执行部署
        if ./deploy.sh "自动更新 - 图片变更 $(date '+%Y-%m-%d %H:%M:%S')"; then
            echo "✅ 自动部署成功"
        else
            echo "❌ 自动部署失败，请手动检查"
        fi

        echo "👀 继续监视中..."
    fi
done
