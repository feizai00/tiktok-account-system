#!/bin/bash
# TikTok账号管理系统 - Nginx端口修复脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    TikTok账号管理系统 - Nginx端口修复脚本    ${NC}"
echo -e "${BLUE}================================================${NC}"

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}错误: 此脚本必须以root用户身份运行${NC}" 
   echo -e "${YELLOW}请使用 sudo ./fix_nginx_port.sh 运行此脚本${NC}"
   exit 1
fi

echo -e "${YELLOW}问题诊断：${NC}"
echo -e "Nginx错误日志显示连接到127.0.0.1:5000被拒绝，但应用实际运行在端口5001上。"
echo -e "这是一个端口不匹配问题，我们将修复Nginx配置。"

echo -e "${YELLOW}步骤1: 备份当前Nginx配置${NC}"
if [ -f /etc/nginx/sites-available/tiktok_account_system ]; then
    cp /etc/nginx/sites-available/tiktok_account_system /etc/nginx/sites-available/tiktok_account_system.bak
    echo -e "${GREEN}Nginx配置已备份${NC}"
else
    echo -e "${RED}Nginx配置文件不存在，将创建新配置${NC}"
fi

echo -e "${YELLOW}步骤2: 更新Nginx配置${NC}"
cat > /etc/nginx/sites-available/tiktok_account_system << EOF
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
        alias /opt/tiktok-account-system/static;
        expires 30d;
        add_header Cache-Control "public, max-age=2592000";
    }
}
EOF

echo -e "${YELLOW}步骤3: 确保链接存在${NC}"
ln -sf /etc/nginx/sites-available/tiktok_account_system /etc/nginx/sites-enabled/

# 移除默认站点（如果存在）
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm -f /etc/nginx/sites-enabled/default
    echo -e "${GREEN}已移除默认站点${NC}"
fi

echo -e "${YELLOW}步骤4: 检查Supervisor配置${NC}"
if [ -f /etc/supervisor/conf.d/tiktok_account_system.conf ]; then
    # 检查端口设置
    if grep -q "PORT=5000" /etc/supervisor/conf.d/tiktok_account_system.conf; then
        echo -e "${YELLOW}更新Supervisor配置中的端口设置${NC}"
        sed -i 's/PORT=5000/PORT=5001/g' /etc/supervisor/conf.d/tiktok_account_system.conf
        echo -e "${GREEN}Supervisor配置已更新${NC}"
    else
        echo -e "${GREEN}Supervisor配置端口正确${NC}"
    fi
else
    echo -e "${RED}Supervisor配置文件不存在，将创建新配置${NC}"
    cat > /etc/supervisor/conf.d/tiktok_account_system.conf << EOF
[program:tiktok_account_system]
directory=/opt/tiktok-account-system
command=/opt/tiktok-account-system/venv/bin/python app.py
autostart=true
autorestart=true
environment=FLASK_APP=app.py,FLASK_ENV=production,PORT=5001
user=root
stderr_logfile=/var/log/tiktok_account_system/error.log
stdout_logfile=/var/log/tiktok_account_system/access.log
EOF
fi

echo -e "${YELLOW}步骤5: 测试Nginx配置${NC}"
nginx -t
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Nginx配置测试通过${NC}"
else
    echo -e "${RED}Nginx配置测试失败，请检查配置文件${NC}"
    exit 1
fi

echo -e "${YELLOW}步骤6: 重启服务${NC}"
echo -e "${YELLOW}重启Supervisor...${NC}"
supervisorctl reread
supervisorctl update
supervisorctl restart tiktok_account_system

echo -e "${YELLOW}重启Nginx...${NC}"
systemctl restart nginx

echo -e "${YELLOW}等待服务启动...${NC}"
sleep 5

echo -e "${YELLOW}步骤7: 检查服务状态${NC}"
echo -e "${YELLOW}Supervisor状态:${NC}"
supervisorctl status tiktok_account_system

echo -e "${YELLOW}Nginx状态:${NC}"
systemctl status nginx | grep Active

echo -e "${YELLOW}步骤8: 验证端口${NC}"
echo -e "${YELLOW}检查5001端口是否在监听:${NC}"
netstat -tulpn | grep 5001

echo -e "${GREEN}修复完成!${NC}"
echo -e "${YELLOW}如果服务仍然无法访问，请检查以下内容:${NC}"
echo -e "${YELLOW}1. 防火墙设置是否允许80端口访问${NC}"
echo -e "${YELLOW}2. 应用日志: /var/log/tiktok_account_system/error.log${NC}"
echo -e "${YELLOW}3. Nginx日志: /var/log/nginx/tiktok_error.log${NC}"
echo -e "${BLUE}================================================${NC}"
