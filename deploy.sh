#!/bin/bash
# TikTok账号管理系统 - 一键部署脚本
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

# 配置项（可根据需要修改）
APP_NAME="tiktok_account_system"
APP_PORT=5000
DEPLOY_DIR="/opt/$APP_NAME"
VENV_DIR="$DEPLOY_DIR/venv"
LOG_DIR="/var/log/$APP_NAME"
SERVICE_NAME="$APP_NAME"
GIT_REPO=""  # 如果使用Git部署，请填写Git仓库地址

# 显示欢迎信息
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    TikTok账号管理系统 - 一键部署脚本    ${NC}"
echo -e "${BLUE}    版本: v0.0.2                         ${NC}"
echo -e "${BLUE}    日期: 2025-03-08                     ${NC}"
echo -e "${BLUE}================================================${NC}"

# 检查是否以root用户运行
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}错误: 请以root用户运行此脚本${NC}"
  exit 1
fi

# 检查操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
else
    echo -e "${RED}无法确定操作系统类型${NC}"
    exit 1
fi

echo -e "${GREEN}检测到操作系统: $OS${NC}"

# 安装基础依赖
echo -e "${YELLOW}正在安装基础依赖...${NC}"
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    apt-get update
    apt-get install -y python3 python3-pip python3-venv nginx supervisor git
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Fedora"* ]]; then
    yum -y update
    yum -y install python3 python3-pip nginx supervisor git
else
    echo -e "${RED}不支持的操作系统: $OS${NC}"
    exit 1
fi

# 创建应用目录
echo -e "${YELLOW}正在创建应用目录...${NC}"
mkdir -p $DEPLOY_DIR
mkdir -p $LOG_DIR

# 部署应用
echo -e "${YELLOW}正在部署应用...${NC}"
if [ -z "$GIT_REPO" ]; then
    # 从本地目录复制
    echo -e "${YELLOW}从本地目录复制应用...${NC}"
    cp -r . $DEPLOY_DIR
else
    # 从Git仓库克隆
    echo -e "${YELLOW}从Git仓库克隆应用...${NC}"
    git clone $GIT_REPO $DEPLOY_DIR
fi

# 创建虚拟环境并安装依赖
echo -e "${YELLOW}正在创建Python虚拟环境并安装依赖...${NC}"
python3 -m venv $VENV_DIR
$VENV_DIR/bin/pip install --upgrade pip
$VENV_DIR/bin/pip install -r $DEPLOY_DIR/requirements.txt
$VENV_DIR/bin/pip install gunicorn

# 创建gunicorn配置文件
echo -e "${YELLOW}正在创建Gunicorn配置...${NC}"
cat > $DEPLOY_DIR/gunicorn_config.py << EOF
bind = "127.0.0.1:$APP_PORT"
workers = 4
timeout = 120
accesslog = "$LOG_DIR/access.log"
errorlog = "$LOG_DIR/error.log"
loglevel = "info"
EOF

# 创建supervisor配置
echo -e "${YELLOW}正在创建Supervisor配置...${NC}"
cat > /etc/supervisor/conf.d/$SERVICE_NAME.conf << EOF
[program:$SERVICE_NAME]
directory=$DEPLOY_DIR
command=$VENV_DIR/bin/gunicorn -c gunicorn_config.py app:app
autostart=true
autorestart=true
stderr_logfile=$LOG_DIR/supervisor_err.log
stdout_logfile=$LOG_DIR/supervisor_out.log
user=root
environment=PATH="$VENV_DIR/bin"
EOF

# 创建nginx配置
echo -e "${YELLOW}正在创建Nginx配置...${NC}"
cat > /etc/nginx/sites-available/$SERVICE_NAME << EOF
server {
    listen 80;
    server_name _;  # 替换为你的域名

    location / {
        proxy_pass http://127.0.0.1:$APP_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /static {
        alias $DEPLOY_DIR/static;
        expires 30d;
    }
}
EOF

# 启用nginx配置
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    ln -sf /etc/nginx/sites-available/$SERVICE_NAME /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Fedora"* ]]; then
    ln -sf /etc/nginx/sites-available/$SERVICE_NAME /etc/nginx/conf.d/$SERVICE_NAME.conf
fi

# 设置文件权限
echo -e "${YELLOW}正在设置文件权限...${NC}"
chown -R root:root $DEPLOY_DIR
chmod -R 755 $DEPLOY_DIR
chown -R root:root $LOG_DIR
chmod -R 755 $LOG_DIR

# 初始化数据库
echo -e "${YELLOW}正在初始化数据库...${NC}"
cd $DEPLOY_DIR
$VENV_DIR/bin/python -c "from app import db; db.create_all()"

# 重启服务
echo -e "${YELLOW}正在重启服务...${NC}"
systemctl restart supervisor
supervisorctl reread
supervisorctl update
supervisorctl restart $SERVICE_NAME
systemctl restart nginx

# 检查服务状态
echo -e "${YELLOW}正在检查服务状态...${NC}"
supervisorctl status $SERVICE_NAME
systemctl status nginx --no-pager

# 显示部署成功信息
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}    TikTok账号管理系统部署完成!    ${NC}"
echo -e "${GREEN}------------------------------------------------${NC}"
echo -e "${GREEN}应用目录: $DEPLOY_DIR${NC}"
echo -e "${GREEN}日志目录: $LOG_DIR${NC}"
echo -e "${GREEN}应用URL: http://服务器IP${NC}"
echo -e "${GREEN}================================================${NC}"
echo -e "${YELLOW}注意: 请确保防火墙已开放80端口${NC}"
echo -e "${YELLOW}如需配置HTTPS，请手动设置SSL证书${NC}"
