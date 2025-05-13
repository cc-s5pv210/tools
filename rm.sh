#!/bin/bash

GERRIT_USER="rstg00po54"
GERRIT_PASS="0L9zGMjbKvP7g19lY/xSwckwByEOsljeONC8tjgcrw"

set -x




# 仓库前缀
PREFIX="cc-s5pv210"

# 从 GitHub 拉取所有相关 repo（你也可以写死）
REPOS=$(curl -s -H "Authorization: token *****" \
  "https://api.github.com/orgs/cc-s5pv210/repos?per_page=100" | jq -r '.[].name')

for REPO in $REPOS; do
  GERRIT_REPO="${REPO}"
  ENCODED_REPO=$(echo "$GERRIT_REPO" | sed 's/\//%2F/g')
  echo "Deleting $GERRIT_REPO from GerritHub..."

  curl -s -u "$GERRIT_USER:$GERRIT_PASS" -X DELETE  "https://review.gerrithub.io/a/projects/rstg00po54%2F$ENCODED_REPO"

  echo ""
done


# curl -X DELETE   -u rstg00po54:0L9zGMjbKvP7g19lY/xSwckwByEOsljeONC8tjgcrw "https://review.gerrithub.io/a/projects/rstg00po54%2Fs5pv210-system_embedsky_4.4.6"

# curl -s -u rstg00po54:0L9zGMjbKvP7g19lY/xSwckwByEOsljeONC8tjgcrw -X DELETE https://review.gerrithub.io/a/projects/s5pv210-system_embedsky_4.4.6

# curl -s -u rstg00po54:0L9zGMjbKvP7g19lY/xSwckwByEOsljeONC8tjgcrw -X DELETE https://review.gerrithub.io/a/projects/rstg00po54%2Fs5pv210-system_embedsky_4.4.6