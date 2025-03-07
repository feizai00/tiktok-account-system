#!/bin/bash
# TikTok账号管理系统 - 完全重置脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    TikTok账号管理系统 - 完全重置脚本    ${NC}"
echo -e "${BLUE}================================================${NC}"

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}错误: 此脚本必须以root用户身份运行${NC}" 
   echo -e "${YELLOW}请使用 sudo ./complete_reset.sh 运行此脚本${NC}"
   exit 1
fi

# 设置应用目录
APP_DIR="/opt/tiktok-account-system"
LOG_DIR="/var/log/tiktok_account_system"
BACKUP_DIR="/opt/tiktok-account-system-backup-$(date +%Y%m%d%H%M%S)"

echo -e "${YELLOW}步骤1: 备份当前系统${NC}"
mkdir -p $BACKUP_DIR
cp -r $APP_DIR/* $BACKUP_DIR/
echo -e "${GREEN}已备份到 $BACKUP_DIR${NC}"

echo -e "${YELLOW}步骤2: 停止所有服务${NC}"
supervisorctl stop tiktok_account_system
systemctl stop nginx

echo -e "${YELLOW}步骤3: 重置Python环境${NC}"
cd $APP_DIR

if [ -d "venv" ]; then
    echo -e "${YELLOW}删除旧虚拟环境...${NC}"
    rm -rf venv
fi

echo -e "${YELLOW}创建新虚拟环境...${NC}"
python3 -m venv venv
source venv/bin/activate

echo -e "${YELLOW}步骤4: 更新代码${NC}"
if [ -d ".git" ]; then
    git fetch --all
    git reset --hard origin/main
    if [ $? -ne 0 ]; then
        echo -e "${RED}无法更新代码${NC}"
        echo -e "${YELLOW}尝试手动安装依赖...${NC}"
    fi
else
    echo -e "${YELLOW}目录不是Git仓库，尝试重新克隆${NC}"
    cd /opt
    mv tiktok-account-system tiktok-account-system-old-$(date +%Y%m%d%H%M%S)
    git clone https://github.com/feizai00/tiktok-account-system.git
    cd tiktok-account-system
    python3 -m venv venv
    source venv/bin/activate
fi

echo -e "${YELLOW}步骤5: 安装所有依赖${NC}"
pip install --upgrade pip
pip install -r requirements.txt

echo -e "${YELLOW}步骤6: 测试应用${NC}"
python -c "from app import app; print('应用导入测试成功')" || {
    echo -e "${RED}应用导入测试失败，尝试手动修复依赖${NC}"
    pip uninstall -y werkzeug sqlalchemy flask-sqlalchemy
    pip install Werkzeug==2.0.3
    pip install SQLAlchemy==1.4.46 Flask-SQLAlchemy==2.5.1
    pip install requests==2.28.2
}

echo -e "${YELLOW}步骤7: 修复日志目录权限${NC}"
mkdir -p $LOG_DIR
chmod -R 755 $LOG_DIR

echo -e "${YELLOW}步骤8: 更新Supervisor配置${NC}"
cat > /etc/supervisor/conf.d/tiktok_account_system.conf << EOF
[program:tiktok_account_system]
directory=$APP_DIR
command=$APP_DIR/venv/bin/python app.py
autostart=true
autorestart=true
environment=FLASK_APP=app.py,FLASK_ENV=production
user=root
stderr_logfile=$LOG_DIR/error.log
stdout_logfile=$LOG_DIR/access.log
EOF

echo -e "${YELLOW}步骤9: 重启服务${NC}"
supervisorctl reread
supervisorctl update
supervisorctl restart tiktok_account_system

echo -e "${YELLOW}等待服务启动...${NC}"
sleep 5

echo -e "${YELLOW}步骤10: 检查服务状态${NC}"
supervisorctl status tiktok_account_system

echo -e "${YELLOW}步骤11: 重启Nginx${NC}"
systemctl restart nginx

echo -e "${GREEN}重置完成!${NC}"
echo -e "${YELLOW}如果服务仍然无法启动，请检查日志:${NC}"
echo -e "${YELLOW}- 应用日志: $LOG_DIR/error.log${NC}"
echo -e "${YELLOW}- Nginx日志: /var/log/nginx/tiktok_error.log${NC}"
echo -e "${BLUE}================================================${NC}"
