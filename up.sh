#!/bin/bash

# 用法提示
usage() {
  echo "用法: $0 [--run] [--user your_github_username] [--prefix PREFIX]"
  echo "  --run          实际执行上传和创建仓库（不加则为 dry-run）"
  echo "  --user USER    指定 GitHub 用户名（默认: 当前环境变量 USER）"
  echo "  --prefix PREFIX 指定仓库名的前缀（默认为空）"
  exit 1
}
set -x
# 默认值
DO_RUN=false
GITHUB_USER="rstg00po54"
PREFIX="s5pv210-"
REPO_COUNT=0
REPO_COUNT1=0

# 参数解析
while [[ $# -gt 0 ]]; do
  case "$1" in
    --run)
      DO_RUN=true
      shift
      ;;
    --user)
      GITHUB_USER="$2"
      shift 2
      ;;
    --prefix)
      PREFIX="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

# 本地源码根目录
SOURCE_DIR="$PWD"
MANIFEST_NAME="./up.xml"
MANIFEST_OUT="./default.xml"
MANIFEST_BRANCH="main"

# 解析 manifest 文件并处理项目
if [[ ! -f "$MANIFEST_NAME" ]]; then
  echo "错误: 找不到 manifest 文件 ($MANIFEST_NAME)"
  exit 1
fi

# 清空/写入 manifest 头
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $MANIFEST_OUT
echo "<manifest>" >> $MANIFEST_OUT
echo "  <remote name=\"github\" fetch=\"git@github.com:$GITHUB_USER/\" />" >> $MANIFEST_OUT
echo "  <default revision=\"$MANIFEST_BRANCH\" remote=\"github\" sync-j=\"4\" />" >> $MANIFEST_OUT

echo "Process ID: $$"

# 解析 XML 文件，提取 project 路径和名称
grep -oP '(?<=<project name=")[^"]+' $MANIFEST_NAME | while read -r REPO_NAME; do
  # 读取路径
  REL_PATH=$(grep -oP "(?<=<project name=\"$REPO_NAME\" path=\")[^\"]+" $MANIFEST_NAME)

  # 使用 / 替换为 _，避免 GitHub 不允许的字符
  REPO_NAME="${PREFIX}$(echo "$REPO_NAME" | sed 's/\//_/g')"

  # 打印调试信息
  echo "📁 检测到 Git 仓库路径: $REL_PATH -> 仓库名: $REPO_NAME"
  
  # 写入 manifest 文件
  echo "  <project path=\"$REL_PATH\" name=\"$REPO_NAME\" />" >> $MANIFEST_OUT
  
  # 增加仓库计数
  REPO_COUNT=$((REPO_COUNT+1))
  REPO_COUNT1=$((REPO_COUNT1+1))

  if $DO_RUN; then
    echo "🚀 创建仓库并上传 $REPO_NAME ..."
    
    # 在本地路径创建仓库
    cd "$REL_PATH"
    gh repo create "$REPO_NAME" --public --description "Auto-uploaded repo: $REL_PATH" --confirm

    # 确保仓库已初始化
    if [ -z "$(git rev-parse --verify HEAD 2>/dev/null)" ]; then
      echo "# $REPO_NAME" > README.md
      git add README.md
      git commit -m "Initial commit"
    fi
    
    # 检查并创建分支，如果没有 main 则创建
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
    if ! git show-ref --quiet --verify refs/heads/"$CURRENT_BRANCH"; then
      git checkout -b "$CURRENT_BRANCH"
    fi
    
    # 添加远程并推送
    git remote remove origin 2>/dev/null
    git remote add origin "git@github.com:$GITHUB_USER/$REPO_NAME.git"
    git push -u origin "$CURRENT_BRANCH"
    
    cd "$SOURCE_DIR"
  else
    echo "🔎 Dry-run 模式（未执行上传）"
  fi
  echo "🔢 当前仓库计数: $REPO_COUNT"
  echo "Process ID: $$"
#   break;
done

REPO_COUNT1=$((REPO_COUNT1+1))
REPO_COUNT=$((REPO_COUNT+1))
echo "Process ID: $$"
echo "✅ 共有 $REPO_COUNT 个仓库将被上传/已生成。"
echo "✅ 共有 $REPO_COUNT1 个仓库将被上传/已生成。"

# 完成 manifest 文件
echo "</manifest>" >> $MANIFEST_OUT

# 输出仓库数目统计
echo "------------------------------------------------------------"
if $DO_RUN; then
  echo "✅ 所有仓库已上传。Manifest 写入 $MANIFEST_OUT"
else
  echo "✅ Dry-run 模式完成，生成了模拟 manifest：$MANIFEST_OUT"
  echo "   如需实际上传，请加上参数：--run"
fi
echo "✅ 共有 $((REPO_COUNT)) 个仓库将被上传/已生成。"
