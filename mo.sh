#!/bin/bash

# 定义 GitHub 用户名、目标组织和访问令牌
GITHUB_USER="rstg00po54"
GITHUB_ORG="cc-s5pv210"
GITHUB_TOKEN="*********"



# 获取所有仓库并筛选出以 s5pv210 开头的仓库
REPOS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/users/$GITHUB_USER/repos?per_page=1000" | jq -r '.[] | .name')

# 遍历仓库并筛选出以 s5pv210 开头的仓库
for REPO in $REPOS; do
  if [[ $REPO == s5pv210* ]]; then
    echo "正在转移仓库: $REPO 到组织: $GITHUB_ORG"
    # curl -X PATCH -H "Authorization: token $GITHUB_TOKEN" \
    #   -d "{\"owner\":\"$GITHUB_ORG\"}" \
    #   "https://api.github.com/repos/$GITHUB_USER/$REPO"
    curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$GITHUB_USER/$REPO/transfer" \
      -d "{\"new_owner\":\"$GITHUB_ORG\"}"
  fi
done

echo "所有匹配的仓库已转移到组织: $GITHUB_ORG"


# curl -X PATCH -H "Authorization: token $GITHUB_TOKEN" -d '{"owner": "cc-s5pv210"}' "https://api.github.com/repos/rstg00po54/s5pv210-repo"


# curl -X POST \
#   -H "Authorization: token $GITHUB_TOKEN" \
#   -H "Accept: application/vnd.github.v3+json" \
#   https://api.github.com/repos/rstg00po54/s5pv210-repo/transfer \
#   -d '{"new_owner":"cc-s5pv210"}'