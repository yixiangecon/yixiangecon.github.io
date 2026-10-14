#!/bin/bash

# 网站部署脚本 - 自动构建、提交并推送网站更新

set -e  # 遇到错误时停止执行

echo "🚀 开始部署网站..."

# 1. 构建网站
echo "📦 正在构建网站..."
quarto render

# 2. 检查 git 状态
if git diff --quiet && git diff --cached --quiet; then
    echo "ℹ️  没有检测到修改"
    exit 0
fi

# 3. 添加所有修改
echo "📝 添加文件到暂存区..."
git add .

# 4. 提交（如果提供了提交信息则使用，否则使用默认信息）
COMMIT_MSG=${1:-"更新网站内容 $(date '+%Y-%m-%d %H:%M:%S')"}
echo "💾 提交修改: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

# 5. 推送到远程仓库
echo "☁️  推送到 GitHub..."
git push origin main

echo "✅ 部署完成！网站将在几分钟内生效。"
echo "🌐 访问地址: https://yixiangecon.github.io"
