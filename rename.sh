#!/bin/bash

GITHUB_TOKEN="***"
ORG="cc-s5pv210"

PER_PAGE=10
PAGE=1
PREFIX="system_embedsky_"



set -x
while :; do
  # 获取分页仓库列表
  REPOS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORG/repos?per_page=$PER_PAGE&page=$PAGE" \
    | jq -r '.[].name')

  # 如果没有更多仓库，结束循环
  if [[ -z "$REPOS" ]]; then
    break
  fi

  for REPO in $REPOS; do
    if [[ $REPO == ${PREFIX}* ]]; then
        NEW_REPO="${REPO#$PREFIX}"

      API_URL="https://api.github.com/repos/$ORG/$REPO"

      # 注意这里要用双引号，变量才能替换
      RESPONSE=$(curl -s -X PATCH -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" \
        "$API_URL" \
        -d "{\"name\": \"$NEW_REPO\"}")

      # 检查是否修改成功
      if [[ $(echo "$RESPONSE" | jq -r .name) == "$NEW_REPO" ]]; then
        echo "$REPO 修改成功为 $NEW_REPO"
      else
        echo "修改 $REPO 失败：$(echo "$RESPONSE" | jq -r .message)"
      fi
    #   break  # 取消这一行注释继续处理更多仓库
    fi
  done

  ((PAGE++))
done


        RESPONSE=$(curl -s -X PATCH -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json"  $API_URL -d '{"name": "$NEW_REPO"}')