#!/bin/bash
# TikTok账号管理系统 - 紧急修复脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    TikTok账号管理系统 - 紧急修复脚本    ${NC}"
echo -e "${BLUE}================================================${NC}"

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}错误: 此脚本必须以root用户身份运行${NC}" 
   echo -e "${YELLOW}请使用 sudo ./emergency_fix.sh 运行此脚本${NC}"
   exit 1
fi

# 设置应用目录
APP_DIR="/opt/tiktok-account-system"
LOG_DIR="/var/log/tiktok_account_system"

echo -e "${YELLOW}步骤1: 停止所有服务${NC}"
supervisorctl stop tiktok_account_system
systemctl stop nginx

echo -e "${YELLOW}步骤2: 修复Python环境${NC}"
cd $APP_DIR

# 激活虚拟环境
source venv/bin/activate || {
    echo -e "${RED}无法激活虚拟环境，尝试重新创建${NC}"
    rm -rf venv
    python3 -m venv venv
    source venv/bin/activate
}

echo -e "${YELLOW}步骤3: 强制安装正确版本的依赖${NC}"
# 先卸载所有可能冲突的包
pip uninstall -y flask flask-sqlalchemy sqlalchemy werkzeug

# 按照正确的顺序安装依赖
pip install Werkzeug==2.0.3
pip install SQLAlchemy==1.4.46
sleep 2
pip install Flask==2.0.1
sleep 2
pip install Flask-SQLAlchemy==2.5.1
pip install requests==2.28.2
pip install matplotlib==3.4.3 pandas==1.3.3 Pillow==8.3.2 openpyxl==3.0.9 XlsxWriter==3.0.2

echo -e "${YELLOW}步骤4: 修复Nginx配置${NC}"
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
        alias $APP_DIR/static;
        expires 30d;
        add_header Cache-Control "public, max-age=2592000";
    }
}
EOF

# 确保链接存在
ln -sf /etc/nginx/sites-available/tiktok_account_system /etc/nginx/sites-enabled/

# 移除默认站点（如果存在）
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm -f /etc/nginx/sites-enabled/default
fi

echo -e "${YELLOW}步骤5: 修复Supervisor配置${NC}"
cat > /etc/supervisor/conf.d/tiktok_account_system.conf << EOF
[program:tiktok_account_system]
directory=$APP_DIR
command=$APP_DIR/venv/bin/python app.py
autostart=true
autorestart=true
environment=FLASK_APP=app.py,FLASK_ENV=production,PORT=5001
user=root
stderr_logfile=$LOG_DIR/error.log
stdout_logfile=$LOG_DIR/access.log
EOF

echo -e "${YELLOW}步骤6: 测试应用${NC}"
cd $APP_DIR
python -c "
import sys
print('Python版本:', sys.version)
print('导入依赖...')
import flask
print('Flask版本:', flask.__version__)
import werkzeug
print('Werkzeug版本:', werkzeug.__version__)
import sqlalchemy
print('SQLAlchemy版本:', sqlalchemy.__version__)
import flask_sqlalchemy
print('Flask-SQLAlchemy版本:', flask_sqlalchemy.__version__)
print('测试成功!')
" || {
    echo -e "${RED}测试失败，请检查日志${NC}"
}

echo -e "${YELLOW}步骤7: 创建静态目录${NC}"
mkdir -p $APP_DIR/static
chmod -R 755 $APP_DIR/static

echo -e "${YELLOW}步骤8: 修复日志目录权限${NC}"
mkdir -p $LOG_DIR
chmod -R 755 $LOG_DIR

echo -e "${YELLOW}步骤9: 重启服务${NC}"
supervisorctl reread
supervisorctl update
supervisorctl restart tiktok_account_system

echo -e "${YELLOW}等待服务启动...${NC}"
sleep 5

echo -e "${YELLOW}步骤10: 检查服务状态${NC}"
supervisorctl status tiktok_account_system

echo -e "${YELLOW}步骤11: 重启Nginx${NC}"
nginx -t && systemctl restart nginx

echo -e "${GREEN}紧急修复完成!${NC}"
echo -e "${YELLOW}如果服务仍然无法启动，请检查日志:${NC}"
echo -e "${YELLOW}- 应用日志: $LOG_DIR/error.log${NC}"
echo -e "${YELLOW}- Nginx日志: /var/log/nginx/tiktok_error.log${NC}"
echo -e "${BLUE}================================================${NC}"
