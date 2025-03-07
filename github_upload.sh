#!/bin/bash
# GitHub上传脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    TikTok账号管理系统 - GitHub上传脚本    ${NC}"
echo -e "${BLUE}================================================${NC}"

# 检查是否提供了GitHub仓库URL
if [ -z "$1" ]; then
    echo -e "${RED}错误: 请提供GitHub仓库URL${NC}"
    echo -e "${YELLOW}用法: $0 <GitHub仓库URL>${NC}"
    echo -e "${YELLOW}例如: $0 https://github.com/username/repo.git${NC}"
    exit 1
fi

GITHUB_URL=$1

# 检查当前目录是否是Git仓库
if [ ! -d ".git" ]; then
    echo -e "${RED}错误: 当前目录不是Git仓库${NC}"
    exit 1
fi

# 添加远程仓库
echo -e "${YELLOW}正在添加GitHub远程仓库...${NC}"
git remote add origin $GITHUB_URL

# 检查是否成功添加
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}远程仓库可能已存在，尝试更新URL...${NC}"
    git remote set-url origin $GITHUB_URL
fi

# 显示远程仓库信息
echo -e "${YELLOW}远程仓库信息:${NC}"
git remote -v

# 推送代码到GitHub
echo -e "${YELLOW}正在推送代码到GitHub...${NC}"
git push -u origin main

# 推送所有标签
echo -e "${YELLOW}正在推送所有标签...${NC}"
git push origin --tags

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}    代码已成功上传到GitHub!    ${NC}"
echo -e "${GREEN}================================================${NC}"
echo -e "${YELLOW}仓库URL: $GITHUB_URL${NC}"
