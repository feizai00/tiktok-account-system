#!/bin/bash
# TikTok账号管理系统 - Nginx修复脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    TikTok账号管理系统 - Nginx修复脚本    ${NC}"
echo -e "${BLUE}================================================${NC}"

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}错误: 此脚本必须以root用户身份运行${NC}" 
   echo -e "${YELLOW}请使用 sudo ./fix_nginx.sh 运行此脚本${NC}"
   exit 1
fi

# 设置应用目录
APP_DIR="/opt/tiktok-account-system"
NGINX_CONF="/etc/nginx/sites-available/tiktok_account_system"
NGINX_ENABLED="/etc/nginx/sites-enabled/tiktok_account_system"
DEFAULT_SITE="/etc/nginx/sites-enabled/default"

echo -e "${YELLOW}步骤1: 备份当前Nginx配置${NC}"
if [ -f "$NGINX_CONF" ]; then
    cp "$NGINX_CONF" "${NGINX_CONF}.bak.$(date +%Y%m%d%H%M%S)"
    echo -e "${GREEN}已备份当前配置到 ${NGINX_CONF}.bak.$(date +%Y%m%d%H%M%S)${NC}"
fi

echo -e "${YELLOW}步骤2: 创建新的Nginx配置${NC}"
cat > "$NGINX_CONF" << EOF
server {
    listen 80;
    server_name _;

    access_log /var/log/nginx/tiktok_access.log;
    error_log /var/log/nginx/tiktok_error.log;

    location / {
        proxy_pass http://127.0.0.1:5001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 300s;
        proxy_read_timeout 300s;
    }

    location /static {
        alias $APP_DIR/static;
        expires 30d;
        add_header Cache-Control "public, max-age=2592000";
    }
}
EOF

echo -e "${YELLOW}步骤3: 启用配置并禁用默认站点${NC}"
# 确保链接存在
ln -sf "$NGINX_CONF" "$NGINX_ENABLED"

# 移除默认站点（如果存在）
if [ -f "$DEFAULT_SITE" ]; then
    rm -f "$DEFAULT_SITE"
    echo -e "${GREEN}已禁用默认站点${NC}"
fi

echo -e "${YELLOW}步骤4: 检查Nginx配置语法${NC}"
nginx -t
if [ $? -ne 0 ]; then
    echo -e "${RED}Nginx配置有语法错误，请修复后再重启Nginx${NC}"
    exit 1
fi

echo -e "${YELLOW}步骤5: 重启Nginx${NC}"
systemctl restart nginx
if [ $? -ne 0 ]; then
    echo -e "${RED}Nginx重启失败，请检查错误日志${NC}"
    echo -e "${YELLOW}查看Nginx错误日志: sudo journalctl -u nginx${NC}"
    exit 1
fi

echo -e "${YELLOW}步骤6: 检查应用状态${NC}"
# 检查应用是否在运行
if pgrep -f "python.*app.py" > /dev/null; then
    echo -e "${GREEN}应用正在运行${NC}"
else
    echo -e "${RED}应用未运行，正在启动...${NC}"
    cd "$APP_DIR"
    supervisorctl restart tiktok_account_system
fi

echo -e "${YELLOW}步骤7: 检查端口监听状态${NC}"
netstat -tulpn | grep -E ':(5000|5001)'
if [ $? -ne 0 ]; then
    echo -e "${RED}应用未在端口5001上监听，请检查应用日志${NC}"
    echo -e "${YELLOW}查看应用日志: sudo tail -f /var/log/tiktok_account_system/error.log${NC}"
    exit 1
fi

echo -e "${GREEN}Nginx配置修复完成!${NC}"
echo -e "${YELLOW}如果仍然无法访问，请检查以下内容:${NC}"
echo -e "${YELLOW}1. 防火墙是否允许80端口访问${NC}"
echo -e "${YELLOW}2. 应用是否正确运行在5001端口${NC}"
echo -e "${YELLOW}3. Nginx错误日志: /var/log/nginx/tiktok_error.log${NC}"
echo -e "${YELLOW}4. 应用错误日志: /var/log/tiktok_account_system/error.log${NC}"
echo -e "${BLUE}================================================${NC}"
