#!/bin/bash
# 修复账号管理页面按钮显示问题的脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    修复账号管理页面按钮显示问题    ${NC}"
echo -e "${BLUE}================================================${NC}"

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}错误: 此脚本必须以root用户身份运行${NC}" 
   echo -e "${YELLOW}请使用 sudo ./fix_buttons.sh 运行此脚本${NC}"
   exit 1
fi

# 设置应用目录
APP_DIR="/opt/tiktok-account-system"
BACKUP_DIR="/opt/backups/$(date +%Y%m%d_%H%M%S)"

# 创建备份目录
mkdir -p $BACKUP_DIR
echo -e "${YELLOW}创建备份目录: $BACKUP_DIR${NC}"

# 备份当前文件
echo -e "${YELLOW}步骤1: 备份当前文件${NC}"
cp -f $APP_DIR/templates/accounts.html $BACKUP_DIR/ 2>/dev/null || echo "accounts.html 不存在，跳过备份"
cp -f $APP_DIR/static/css/accounts.css $BACKUP_DIR/ 2>/dev/null || echo "accounts.css 不存在，跳过备份"
cp -f $APP_DIR/static/js/accounts.js $BACKUP_DIR/ 2>/dev/null || echo "accounts.js 不存在，跳过备份"

# 创建临时目录
TMP_DIR=$(mktemp -d)
echo -e "${YELLOW}步骤2: 创建临时目录: $TMP_DIR${NC}"

# 创建修复后的accounts.html文件
echo -e "${YELLOW}步骤3: 创建修复后的accounts.html文件${NC}"
