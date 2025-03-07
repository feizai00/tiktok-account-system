#!/bin/bash
# TikTok账号管理系统 - 一键安装脚本
# 从GitHub克隆项目并部署

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

# 配置变量
GITHUB_REPO="https://github.com/feizai00/tiktok-account-system.git"
DEPLOY_DIR="/opt/tiktok-account-system"
APP_PORT=5000

# 显示欢迎信息
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    TikTok账号管理系统 - 一键安装脚本    ${NC}"
echo -e "${BLUE}================================================${NC}"
echo -e "${YELLOW}此脚本将从GitHub克隆项目并部署到您的服务器${NC}"
echo -e "${YELLOW}GitHub仓库: ${GITHUB_REPO}${NC}"
echo -e "${YELLOW}部署目录: ${DEPLOY_DIR}${NC}"
echo -e "${YELLOW}应用端口: ${APP_PORT}${NC}"
echo ""

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}错误: 此脚本必须以root用户身份运行${NC}" 
   echo -e "${YELLOW}请使用 sudo ./install.sh 运行此脚本${NC}"
   exit 1
fi

# 检查系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo -e "${RED}无法确定操作系统类型${NC}"
    exit 1
fi

echo -e "${YELLOW}检测到操作系统: ${OS} ${VER}${NC}"

# 安装依赖
echo -e "${YELLOW}正在安装依赖...${NC}"

# 根据不同的Linux发行版安装依赖
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    apt-get update
    apt-get install -y python3 python3-pip python3-venv git nginx supervisor
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Fedora"* ]]; then
    yum -y update
    yum -y install python3 python3-pip git nginx supervisor
    # 如果是CentOS 7，可能需要启用EPEL仓库
    if [[ "$VER" == "7" ]]; then
        yum -y install epel-release
        yum -y install supervisor
    fi
else
    echo -e "${RED}不支持的操作系统: ${OS}${NC}"
    echo -e "${YELLOW}此脚本支持Ubuntu、Debian、CentOS、Red Hat和Fedora${NC}"
    exit 1
fi

# 克隆GitHub仓库
echo -e "${YELLOW}正在从GitHub克隆项目...${NC}"
if [ -d "$DEPLOY_DIR" ]; then
    echo -e "${YELLOW}部署目录已存在，正在备份...${NC}"
    mv $DEPLOY_DIR ${DEPLOY_DIR}_backup_$(date +%Y%m%d%H%M%S)
fi

git clone $GITHUB_REPO $DEPLOY_DIR

if [ $? -ne 0 ]; then
    echo -e "${RED}克隆仓库失败${NC}"
    exit 1
fi

# 创建Python虚拟环境并安装依赖
echo -e "${YELLOW}正在设置Python环境...${NC}"
cd $DEPLOY_DIR
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 配置Supervisor
echo -e "${YELLOW}正在配置Supervisor...${NC}"
cat > /etc/supervisor/conf.d/tiktok_account_system.conf << EOF
[program:tiktok_account_system]
directory=$DEPLOY_DIR
command=$DEPLOY_DIR/venv/bin/python app.py
autostart=true
autorestart=true
stderr_logfile=/var/log/tiktok_account_system/error.log
stdout_logfile=/var/log/tiktok_account_system/access.log
EOF

# 创建日志目录
mkdir -p /var/log/tiktok_account_system

# 配置Nginx
echo -e "${YELLOW}正在配置Nginx...${NC}"
cat > /etc/nginx/sites-available/tiktok_account_system << EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:$APP_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /static {
        alias $DEPLOY_DIR/static;
    }
}
EOF

# 启用Nginx配置
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    ln -sf /etc/nginx/sites-available/tiktok_account_system /etc/nginx/sites-enabled/
    # 删除默认配置
    rm -f /etc/nginx/sites-enabled/default
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Fedora"* ]]; then
    ln -sf /etc/nginx/sites-available/tiktok_account_system /etc/nginx/conf.d/
    # 确保sites-available目录存在
    mkdir -p /etc/nginx/sites-available
fi

# 重启服务
echo -e "${YELLOW}正在重启服务...${NC}"
systemctl restart supervisor
systemctl restart nginx

# 配置防火墙
echo -e "${YELLOW}正在配置防火墙...${NC}"
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    # 检查ufw是否安装
    if command -v ufw &> /dev/null; then
        ufw allow 80/tcp
        ufw allow 443/tcp
        echo -e "${YELLOW}已配置ufw防火墙规则${NC}"
    fi
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Fedora"* ]]; then
    # 检查firewalld是否安装
    if command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --reload
        echo -e "${YELLOW}已配置firewalld防火墙规则${NC}"
    fi
fi

# 显示安装成功信息
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}    TikTok账号管理系统安装成功!    ${NC}"
echo -e "${GREEN}================================================${NC}"
echo -e "${YELLOW}您可以通过以下URL访问系统:${NC}"
echo -e "${YELLOW}http://服务器IP地址${NC}"
echo ""
echo -e "${YELLOW}如需配置HTTPS，请参考以下步骤:${NC}"
echo -e "${YELLOW}1. 安装certbot${NC}"
echo -e "${YELLOW}2. 运行: certbot --nginx -d 您的域名${NC}"
echo -e "${YELLOW}3. 按照提示完成配置${NC}"
echo ""
echo -e "${YELLOW}如有任何问题，请参考项目文档或联系系统管理员${NC}"
