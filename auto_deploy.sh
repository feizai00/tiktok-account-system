#!/bin/bash
# 自动部署脚本 - 用于在服务器上自动部署最新代码

# 显示彩色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 设置日志文件
LOG_FILE="/var/log/tiktok_auto_deploy.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 记录日志函数
log() {
    echo -e "${TIMESTAMP} - $1" | tee -a $LOG_FILE
}

log "${YELLOW}开始自动部署流程...${NC}"

# 1. 备份当前文件
log "${GREEN}1. 备份当前文件...${NC}"
BACKUP_DIR="/opt/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR
cp -r /opt/tiktok-account-system/static $BACKUP_DIR/
cp -r /opt/tiktok-account-system/templates $BACKUP_DIR/
cp -r /opt/tiktok-account-system/app.py $BACKUP_DIR/
cp /etc/nginx/sites-available/tiktok_account_system $BACKUP_DIR/
log "${GREEN}✓ 备份完成: $BACKUP_DIR${NC}"

# 2. 更新代码库
log "${GREEN}2. 更新代码库...${NC}"
cd /opt/tiktok-account-system

# 保存当前分支
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
log "当前分支: $CURRENT_BRANCH"

# 获取最新代码
git fetch origin
git checkout main
git pull origin main

# 检查更新是否成功
if [ $? -ne 0 ]; then
    log "${RED}✗ 代码更新失败，回滚到之前的分支${NC}"
    git checkout $CURRENT_BRANCH
    exit 1
fi

log "${GREEN}✓ 代码更新完成${NC}"

# 3. 检查Nginx配置
log "${GREEN}3. 检查Nginx配置...${NC}"
NGINX_CONFIG="/etc/nginx/sites-available/tiktok_account_system"
if grep -q "proxy_pass http://127.0.0.1:5000;" $NGINX_CONFIG; then
    log "${YELLOW}! 发现Nginx端口配置错误，正在修复...${NC}"
    
    # 检查是否有修复脚本
    if [ -f "fix_nginx_port.sh" ]; then
        chmod +x fix_nginx_port.sh
        sudo ./fix_nginx_port.sh
        log "${GREEN}✓ Nginx配置已修复${NC}"
    else
        # 手动修复
        log "${YELLOW}! 未找到修复脚本，尝试手动修复...${NC}"
        sudo sed -i 's/proxy_pass http:\/\/127.0.0.1:5000;/proxy_pass http:\/\/127.0.0.1:5001;/g' $NGINX_CONFIG
        sudo nginx -t
        
        if [ $? -eq 0 ]; then
            sudo systemctl restart nginx
            log "${GREEN}✓ Nginx配置已手动修复${NC}"
        else
            log "${RED}✗ Nginx配置手动修复失败${NC}"
            exit 1
        fi
    fi
else
    log "${GREEN}✓ Nginx配置正确${NC}"
fi

# 4. 安装/更新依赖
log "${GREEN}4. 检查依赖更新...${NC}"
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    log "${GREEN}✓ 依赖已更新${NC}"
fi

# 5. 重启应用
log "${GREEN}5. 重启应用...${NC}"
sudo supervisorctl restart tiktok_account_system
log "${GREEN}✓ 应用重启完成${NC}"

# 6. 检查服务状态
log "${GREEN}6. 检查服务状态...${NC}"
NGINX_STATUS=$(systemctl is-active nginx)
APP_STATUS=$(supervisorctl status tiktok_account_system | grep RUNNING | wc -l)

log "Nginx状态: $NGINX_STATUS"
log "应用状态: $(supervisorctl status tiktok_account_system)"

if [ "$NGINX_STATUS" = "active" ] && [ $APP_STATUS -eq 1 ]; then
    log "${GREEN}✓ 所有服务运行正常${NC}"
else
    log "${RED}✗ 服务状态异常，请检查${NC}"
    exit 1
fi

log "${YELLOW}自动部署完成!${NC}"

# 添加部署成功通知（可选，如有需要可以添加邮件或其他通知方式）
# mail -s "TikTok账号管理系统自动部署成功" admin@example.com < $LOG_FILE
