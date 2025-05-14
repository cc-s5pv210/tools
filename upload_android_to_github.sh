#!/bin/bash

# 用法提示
usage() {
  echo "用法: $0 [--run] [--user your_github_username] [--prefix PREFIX]"
  echo "  --run            实际执行上传和创建仓库（不加则为 dry-run）"
  echo "  --user USER      指定 GitHub 用户名（默认: 当前环境变量 USER）"
  echo "  --prefix PREFIX  指定仓库名前缀（默认: s5pv210-）"
  exit 1
}
set -x
# 默认值
DO_RUN=false
GITHUB_USER="rstg00po54"
PREFIX="s5pv210-"
REPO_COUNT=0

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

SOURCE_DIR="$PWD"
MANIFEST_NAME="default.xml"
MANIFEST_BRANCH="main"

# 初始化 manifest 文件
cat > "$MANIFEST_NAME" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="github" fetch="git@github.com:$GITHUB_USER/" />
  <default revision="$MANIFEST_BRANCH" remote="github" sync-j="4" />
EOF

echo "Process ID: $$"

# 获取所有 .git 目录列表
mapfile -t GIT_DIRS < <(find "$SOURCE_DIR" -type d -name ".git")

for dir in "${GIT_DIRS[@]}"; do
  REL_PATH=$(realpath --relative-to="$SOURCE_DIR" "$dir")

#   在输入的文本中，每个斜杠（/）都将被替换为下划线（_）。
# 这个替换将 应用到整行（因为使用了 g，即全局替换）。
  REPO_NAME="${PREFIX}$(echo "$REL_PATH" | sed 's/\//-/g' | sed 's/.git$//')"

  # 去掉尾部的 _
#   _$ 表示匹配 位于字符串末尾的下划线。
    REPO_NAME=$(echo "$REPO_NAME" | sed 's/-$//')
    REL_PATH=$(echo "$REL_PATH" | sed 's|/\.git$||')

  echo "📁 检测到 Git 仓库: $REL_PATH ->"
  echo " 仓库名: $REPO_NAME"

  echo "  <project path=\"$REL_PATH\" name=\"$REPO_NAME\" />" >> "$MANIFEST_NAME"

  REPO_COUNT=$((REPO_COUNT + 1))

  if $DO_RUN; then
    echo "🚀 创建仓库并上传 $REPO_NAME ..."
    cd "$dir" || continue
    # 使用 gh 创建仓库
    gh repo create "$REPO_NAME" --public --description "Auto-uploaded repo: $REL_PATH" --confirm

    # 检查是否已有提交（仓库为空时需要初始化）
    if [ -z "$(git rev-parse --verify HEAD 2>/dev/null)" ]; then
        echo "# $REPO_NAME" > README.md   # 创建一个 README 文件
        git add README.md
        git commit -m "Initial commit"    # 做一次初始提交
    fi

    # 检查并创建分支，如果仓库为空且没有分支时
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
    
    # 如果当前分支不存在，创建它
    if ! git show-ref --quiet --verify refs/heads/"$CURRENT_BRANCH"; then
        git checkout -b "$CURRENT_BRANCH"  # 创建并切换到 main 分支
    fi

    # 添加远程并推送
    git remote remove origin 2>/dev/null
    git remote add origin "git@github.com:$GITHUB_USER/$REPO_NAME.git"
    git push -u origin "$CURRENT_BRANCH"   # 推送当前分支

    cd "$SOURCE_DIR" || exit
  else
    echo "🔎 Dry-run 模式（未执行上传）"
  fi

  echo "🔢 当前仓库计数: $REPO_COUNT"
  break;
done

# 结束 manifest 文件
echo "</manifest>" >> "$MANIFEST_NAME"

# 输出统计结果
echo "------------------------------------------------------------"
if $DO_RUN; then
  echo "✅ 所有仓库已上传。Manifest 写入 $MANIFEST_NAME"
else
  echo "✅ Dry-run 模式完成，生成了模拟 manifest：$MANIFEST_NAME"
  echo "   如需实际上传，请加上参数：--run"
fi
echo "✅ 共处理 $REPO_COUNT 个 Git 仓库。"

# 
# gh repo delete rstg00po54/s5pv210-no-os --confirm