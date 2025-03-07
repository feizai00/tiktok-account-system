#!/bin/bash
# TikTok账号管理系统 - 服务器修复脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    TikTok账号管理系统 - 服务器修复脚本    ${NC}"
echo -e "${BLUE}================================================${NC}"

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}错误: 此脚本必须以root用户身份运行${NC}" 
   echo -e "${YELLOW}请使用 sudo ./fix_server.sh 运行此脚本${NC}"
   exit 1
fi

# 设置应用目录
APP_DIR="/opt/tiktok-account-system"
LOG_DIR="/var/log/tiktok_account_system"

echo -e "${YELLOW}步骤1: 更新代码${NC}"
cd $APP_DIR
if [ -d ".git" ]; then
    git pull origin main
    if [ $? -ne 0 ]; then
        echo -e "${RED}无法更新代码，尝试手动修复依赖${NC}"
    fi
else
    echo -e "${YELLOW}目录不是Git仓库，跳过代码更新${NC}"
fi

echo -e "${YELLOW}步骤2: 修复Python环境${NC}"
cd $APP_DIR
source venv/bin/activate || { echo -e "${RED}无法激活虚拟环境${NC}"; exit 1; }

echo -e "${YELLOW}安装/更新关键依赖...${NC}"
pip install --upgrade pip

# 先卸载可能冲突的包
pip uninstall -y werkzeug sqlalchemy flask-sqlalchemy

# 安装指定版本的依赖
pip install Werkzeug==2.0.3
pip install Jinja2==3.0.3 itsdangerous==2.0.1 click==8.0.4
pip install SQLAlchemy==1.4.46 Flask-SQLAlchemy==2.5.1
pip install requests==2.28.2
pip install numpy==1.22.4

echo -e "${YELLOW}步骤3: 测试应用${NC}"
cd $APP_DIR
python -c "from app import app; print('应用导入测试成功')" || {
    echo -e "${RED}应用导入测试失败，尝试安装所有依赖${NC}"
    pip install -r requirements.txt
}

echo -e "${YELLOW}步骤4: 修复日志目录权限${NC}"
mkdir -p $LOG_DIR
chmod -R 755 $LOG_DIR

echo -e "${YELLOW}步骤5: 检查Supervisor配置${NC}"
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

echo -e "${YELLOW}步骤6: 重启服务${NC}"
supervisorctl reread
supervisorctl update
supervisorctl restart tiktok_account_system

echo -e "${YELLOW}等待服务启动...${NC}"
sleep 5

echo -e "${YELLOW}步骤7: 检查服务状态${NC}"
supervisorctl status tiktok_account_system

echo -e "${YELLOW}步骤8: 重启Nginx${NC}"
systemctl restart nginx

echo -e "${GREEN}修复完成!${NC}"
echo -e "${YELLOW}如果服务仍然无法启动，请检查日志:${NC}"
echo -e "${YELLOW}- 应用日志: $LOG_DIR/error.log${NC}"
echo -e "${YELLOW}- Nginx日志: /var/log/nginx/tiktok_error.log${NC}"
echo -e "${BLUE}================================================${NC}"
