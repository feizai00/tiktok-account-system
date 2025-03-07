#!/bin/bash
# TikTok账号管理系统 - Docker一键部署脚本
# 作者：肥仔
# 版本：v0.0.2
# 日期：2025-03-08

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

# 显示欢迎信息
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    TikTok账号管理系统 - Docker一键部署脚本    ${NC}"
echo -e "${BLUE}    版本: v0.0.2                              ${NC}"
echo -e "${BLUE}    日期: 2025-03-08                          ${NC}"
echo -e "${BLUE}================================================${NC}"

# 检查是否以root用户运行
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}错误: 请以root用户运行此脚本${NC}"
  exit 1
fi

# 检查Docker是否已安装
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker未安装，正在安装Docker...${NC}"
    
    # 安装Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    
    # 启动Docker服务
    systemctl enable docker
    systemctl start docker
else
    echo -e "${GREEN}Docker已安装${NC}"
fi

# 检查Docker Compose是否已安装
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Docker Compose未安装，正在安装Docker Compose...${NC}"
    
    # 安装Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
else
    echo -e "${GREEN}Docker Compose已安装${NC}"
fi

# 创建项目目录
PROJECT_DIR="/opt/tiktok-account-system"
echo -e "${YELLOW}正在创建项目目录: $PROJECT_DIR${NC}"
mkdir -p $PROJECT_DIR
mkdir -p $PROJECT_DIR/instance

# 复制项目文件到目标目录
echo -e "${YELLOW}正在复制项目文件...${NC}"
cp -r . $PROJECT_DIR/

# 进入项目目录
cd $PROJECT_DIR

# 构建并启动Docker容器
echo -e "${YELLOW}正在构建并启动Docker容器...${NC}"
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 等待容器启动
echo -e "${YELLOW}等待容器启动...${NC}"
sleep 10

# 检查容器状态
echo -e "${YELLOW}检查容器状态...${NC}"
docker-compose ps

# 显示部署成功信息
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}    TikTok账号管理系统Docker部署完成!    ${NC}"
echo -e "${GREEN}------------------------------------------------${NC}"
echo -e "${GREEN}应用目录: $PROJECT_DIR${NC}"
echo -e "${GREEN}应用URL: http://服务器IP${NC}"
echo -e "${GREEN}================================================${NC}"
echo -e "${YELLOW}常用命令:${NC}"
echo -e "${YELLOW}- 查看容器状态: docker-compose ps${NC}"
echo -e "${YELLOW}- 查看应用日志: docker-compose logs -f${NC}"
echo -e "${YELLOW}- 重启应用: docker-compose restart${NC}"
echo -e "${YELLOW}- 停止应用: docker-compose down${NC}"
echo -e "${YELLOW}注意: 请确保防火墙已开放80端口${NC}"
echo -e "${YELLOW}如需配置HTTPS，请修改nginx.conf并重新部署${NC}"
