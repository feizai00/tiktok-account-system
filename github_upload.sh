#!/bin/bash
# GitHub上传脚本 - 改进版

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
    echo -e "${YELLOW}用法: $0 <GitHub仓库URL> [GitHub用户名] [GitHub个人访问令牌]${NC}"
    echo -e "${YELLOW}例如: $0 https://github.com/username/repo.git username token${NC}"
    exit 1
fi

GITHUB_URL=$1
GITHUB_USERNAME=$2
GITHUB_TOKEN=$3

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

# 如果提供了用户名和令牌，则使用它们进行认证
if [ ! -z "$GITHUB_USERNAME" ] && [ ! -z "$GITHUB_TOKEN" ]; then
    # 构建带认证的URL
    AUTH_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/$(basename $GITHUB_URL)"
    echo -e "${YELLOW}使用提供的凭据进行认证...${NC}"
    
    # 更新远程URL以包含认证信息
    git remote set-url origin $AUTH_URL
    
    # 推送代码到GitHub
    echo -e "${YELLOW}正在推送代码到GitHub...${NC}"
    if git push -u origin main; then
        PUSH_SUCCESS=true
    else
        PUSH_SUCCESS=false
    fi
    
    # 推送所有标签
    echo -e "${YELLOW}正在推送所有标签...${NC}"
    git push origin --tags
    
    # 恢复原始URL（不包含凭据）
    git remote set-url origin $GITHUB_URL
else
    # 没有提供凭据，尝试常规推送
    echo -e "${YELLOW}正在推送代码到GitHub...${NC}"
    echo -e "${YELLOW}如果提示输入凭据，请输入您的GitHub用户名和密码或个人访问令牌${NC}"
    if git push -u origin main; then
        PUSH_SUCCESS=true
    else
        PUSH_SUCCESS=false
    fi
    
    # 推送所有标签
    echo -e "${YELLOW}正在推送所有标签...${NC}"
    git push origin --tags
fi

# 根据推送结果显示不同的消息
if [ "$PUSH_SUCCESS" = true ]; then
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}    代码已成功上传到GitHub!    ${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo -e "${YELLOW}仓库URL: $GITHUB_URL${NC}"
else
    echo -e "${RED}================================================${NC}"
    echo -e "${RED}    代码上传失败!    ${NC}"
    echo -e "${RED}================================================${NC}"
    echo -e "${YELLOW}请检查以下可能的原因:${NC}"
    echo -e "${YELLOW}1. GitHub用户名或密码/令牌不正确${NC}"
    echo -e "${YELLOW}2. 仓库URL不正确或仓库不存在${NC}"
    echo -e "${YELLOW}3. 没有仓库的访问权限${NC}"
    echo -e "${YELLOW}4. 网络连接问题${NC}"
    echo -e "${YELLOW}5. 尝试使用个人访问令牌:${NC}"
    echo -e "${YELLOW}   - 访问 https://github.com/settings/tokens 创建令牌${NC}"
    echo -e "${YELLOW}   - 然后运行: $0 $GITHUB_URL 您的用户名 您的令牌${NC}"
fi
