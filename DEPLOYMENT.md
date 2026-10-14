# 网站部署指南

## 文件说明

- `deploy.sh` - 手动部署脚本：一次性构建、提交并推送网站
- `watch.sh` - 自动监视脚本：监视文件变化并自动部署（需要 `fswatch`）
- `watch-simple.sh` - 简化监视脚本：使用轮询方式，无需额外依赖

## 快速开始

### 方法 1: 手动部署（推荐用于偶尔更新）

```bash
cd ~/Documents/GitHub/yixiangecon.github.io
./deploy.sh "提交信息"
```

如果不提供提交信息，会使用默认信息："更新网站内容 时间戳"

示例：
```bash
./deploy.sh "更新 research.qmd - 添加新的会议报告"
```

### 方法 2: 自动监视部署（推荐用于频繁更新）

**启动监视**：
```bash
cd ~/Documents/GitHub/yixiangecon.github.io
./watch-simple.sh
```

然后在另一个终端窗口中编辑您的 `.qmd` 文件或添加图片到 `images/` 目录。保存后，脚本会自动检测变化并执行部署。

**停止监视**：在运行监视脚本的终端中按 `Ctrl+C`

## 安装依赖（可选）

如果您想使用 `watch.sh`（基于事件而非轮询，更高效），需要先安装 `fswatch`：

```bash
brew install fswatch
```

然后运行：
```bash
./watch.sh
```

## 监视的文件类型

自动监视模式会检测以下变化：
- 所有 `.qmd` 文件（包括 `index.qmd`, `research.qmd`, `personal.qmd` 等）
- `images/` 目录中的任何文件（新增、修改、删除）
- `_quarto.yml` 配置文件
- `styles.scss` 样式文件

## 部署流程

1. **构建**：`quarto render` 将 `.qmd` 转换为 HTML
2. **提交**：自动 `git add .` 并提交
3. **推送**：`git push origin main`
4. **生效**：GitHub Pages 会在 1-3 分钟内自动更新

## 故障排除

### 问题：权限被拒绝
解决方案：
```bash
chmod +x deploy.sh watch.sh watch-simple.sh
```

### 问题：没有检测到修改
- 确保文件在正确的目录中
- 检查 `_quarto.yml` 中的设置
- 确保文件类型在被监视的列表中

### 问题：部署失败
- 检查网络连接
- 确认已配置 git 远程仓库：`git remote -v`
- 确认有推送权限
- 查看错误信息并手动运行部署步骤排查

## 进阶技巧

### 1. 创建别名（更方便）

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
alias site-deploy='cd ~/Documents/GitHub/yixiangecon.github.io && ./deploy.sh'
alias site-watch='cd ~/Documents/GitHub/yixiangecon.github.io && ./watch-simple.sh'
```

然后使用：
```bash
site-deploy "更新内容"
site-watch
```

### 2. 后台运行监视

```bash
nohup ~/Documents/GitHub/yixiangecon.github.io/watch-simple.sh > ~/site-watch.log 2>&1 &
```

查看日志：
```bash
tail -f ~/site-watch.log
```

停止后台进程：
```bash
pkill -f watch-simple.sh
```

### 3. 只构建不推送（测试用）

```bash
cd ~/Documents/GitHub/yixiangecon.github.io
quarto render
# 检查和预览 docs/ 目录中的 HTML 文件
```

## 注意事项

- 确保 `quarto` 命令可用：运行 `quarto --version` 检查
- 第一次使用前建议先手动测试一次 `./deploy.sh` 确认一切正常
- 自动监视脚本会持续运行，请确保终端窗口保持打开
- 如果同时有多个终端修改文件，可能会触发多次提交（脚本有 5 秒防抖）
