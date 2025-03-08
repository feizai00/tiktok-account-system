#!/bin/bash
# 部署修复脚本 - 用于在服务器上部署账号管理按钮和Nginx端口修复

# 显示彩色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}开始部署修复...${NC}"

# 1. 备份当前文件
echo -e "${GREEN}1. 备份当前文件...${NC}"
BACKUP_DIR="/opt/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR
cp -r /opt/tiktok-account-system/static/css/accounts.css $BACKUP_DIR/
cp -r /opt/tiktok-account-system/templates/accounts.html $BACKUP_DIR/
cp -r /opt/tiktok-account-system/static/js/accounts.js $BACKUP_DIR/
cp /etc/nginx/sites-available/tiktok_account_system $BACKUP_DIR/
echo -e "${GREEN}✓ 备份完成: $BACKUP_DIR${NC}"

# 2. 更新代码库
echo -e "${GREEN}2. 更新代码库...${NC}"
cd /opt/tiktok-account-system
git fetch origin
git checkout -b temp-fix
git reset --hard origin/fix-account-buttons
echo -e "${GREEN}✓ 代码更新完成${NC}"

# 3. 修复Nginx配置
echo -e "${GREEN}3. 修复Nginx配置...${NC}"
chmod +x fix_nginx_port.sh
sudo ./fix_nginx_port.sh
echo -e "${GREEN}✓ Nginx配置修复完成${NC}"

# 4. 重启应用
echo -e "${GREEN}4. 重启应用...${NC}"
sudo supervisorctl restart tiktok_account_system
echo -e "${GREEN}✓ 应用重启完成${NC}"

# 5. 检查服务状态
echo -e "${GREEN}5. 检查服务状态...${NC}"
echo "Nginx状态:"
sudo systemctl status nginx | grep Active
echo "应用状态:"
sudo supervisorctl status tiktok_account_system

# 6. 清理
echo -e "${GREEN}6. 清理临时分支...${NC}"
git checkout main
git branch -D temp-fix

echo -e "${YELLOW}部署完成!${NC}"
echo -e "${YELLOW}如果页面显示仍有问题，请尝试清除浏览器缓存或强制刷新页面 (Ctrl+F5)${NC}"
echo -e "${YELLOW}备份文件位于: $BACKUP_DIR${NC}"
