#!/bin/bash
# TikTok账号管理系统 - 综合管理脚本
# 版本：v1.0.0
# 日期：2025-03-11
# 功能：整合多个脚本功能，包括数据备份、项目更新、服务器修复等

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # 恢复默认颜色

# 配置变量
APP_NAME="tiktok_account_system"
DEPLOY_DIR="/opt/$APP_NAME"
LOCAL_DIR="$(pwd)"
LOG_DIR="/var/log/$APP_NAME"
BACKUP_DIR="$LOCAL_DIR/backups/$(date +%Y%m%d_%H%M%S)"
GITHUB_REPO="https://github.com/feizai00/tiktok-account-system.git"
APP_PORT=5001

# 日志函数
log() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${timestamp} - $1"
}

# 显示标题
show_header() {
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}    TikTok账号管理系统 - 综合管理脚本    ${NC}"
    echo -e "${BLUE}    版本: v1.0.0                         ${NC}"
    echo -e "${BLUE}    日期: 2025-03-11                     ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

# 检查是否为root用户
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}警告: 此操作需要root权限${NC}"
        echo -e "${YELLOW}某些功能可能无法正常工作${NC}"
        read -p "是否继续? (y/n): " choice
        if [ "$choice" != "y" ]; then
            exit 1
        fi
    fi
}

# 检查操作系统
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
    else
        OS=$(uname -s)
    fi
    
    echo -e "${YELLOW}检测到操作系统: $OS${NC}"
}

# 主菜单
show_main_menu() {
    show_header
    echo -e "${CYAN}请选择操作:${NC}"
    echo -e "${YELLOW}1.${NC} 部署工具"
    echo -e "${YELLOW}2.${NC} 备份工具"
    echo -e "${YELLOW}3.${NC} 系统维护"
    echo -e "${YELLOW}4.${NC} 开发工具"
    echo -e "${YELLOW}0.${NC} 退出"
    echo ""
    read -p "请输入选项 [0-4]: " choice
    
    case $choice in
        1) deployment_menu ;;
        2) backup_menu ;;
        3) maintenance_menu ;;
        4) development_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            show_main_menu
            ;;
    esac
}

# 部署菜单
deployment_menu() {
    show_header
    echo -e "${CYAN}部署工具:${NC}"
    echo -e "${YELLOW}1.${NC} 安装新系统"
    echo -e "${YELLOW}2.${NC} 更新现有系统"
    echo -e "${YELLOW}3.${NC} 配置Nginx"
    echo -e "${YELLOW}4.${NC} 配置Supervisor"
    echo -e "${YELLOW}5.${NC} 一键部署(全部步骤)"
    echo -e "${YELLOW}9.${NC} 返回主菜单"
    echo -e "${YELLOW}0.${NC} 退出"
    echo ""
    read -p "请输入选项 [0-9]: " choice
    
    case $choice in
        1) install_system ;;
        2) update_system ;;
        3) configure_nginx ;;
        4) configure_supervisor ;;
        5) full_deployment ;;
        9) show_main_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            deployment_menu
            ;;
    esac
}

# 备份菜单
backup_menu() {
    show_header
    echo -e "${CYAN}备份工具:${NC}"
    echo -e "${YELLOW}1.${NC} 完整系统备份"
    echo -e "${YELLOW}2.${NC} 仅备份数据库"
    echo -e "${YELLOW}3.${NC} 仅备份配置文件"
    echo -e "${YELLOW}4.${NC} 列出现有备份"
    echo -e "${YELLOW}5.${NC} 恢复备份"
    echo -e "${YELLOW}9.${NC} 返回主菜单"
    echo -e "${YELLOW}0.${NC} 退出"
    echo ""
    read -p "请输入选项 [0-9]: " choice
    
    case $choice in
        1) backup_full_system ;;
        2) backup_database ;;
        3) backup_config ;;
        4) list_backups ;;
        5) restore_backup ;;
        9) show_main_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            backup_menu
            ;;
    esac
}

# 维护菜单
maintenance_menu() {
    show_header
    echo -e "${CYAN}系统维护:${NC}"
    echo -e "${YELLOW}1.${NC} 检查系统状态"
    echo -e "${YELLOW}2.${NC} 重启应用"
    echo -e "${YELLOW}3.${NC} 修复服务器"
    echo -e "${YELLOW}4.${NC} 紧急修复"
    echo -e "${YELLOW}5.${NC} 完全重置"
    echo -e "${YELLOW}6.${NC} 清理日志"
    echo -e "${YELLOW}7.${NC} 修复Nginx配置"
    echo -e "${YELLOW}9.${NC} 返回主菜单"
    echo -e "${YELLOW}0.${NC} 退出"
    echo ""
    read -p "请输入选项 [0-9]: " choice
    
    case $choice in
        1) check_system_status ;;
        2) restart_application ;;
        3) fix_server ;;
        4) emergency_fix ;;
        5) complete_reset ;;
        6) clean_logs ;;
        7) fix_nginx ;;
        9) show_main_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            maintenance_menu
            ;;
    esac
}

# 修复Nginx配置
fix_nginx() {
    show_header
    echo -e "${CYAN}TikTok账号管理系统 - Nginx修复脚本${NC}"
    
    # 检查是否为root用户
    if [ "$(id -u)" != "0" ]; then
       echo -e "${RED}错误: 此脚本必须以root用户身份运行${NC}" 
       echo -e "${YELLOW}请使用 sudo $0 运行此脚本${NC}"
       read -p "按Enter键继续..." key
       maintenance_menu
       return
    fi
    
    # 设置应用目录
    local APP_DIR="/opt/tiktok-account-system"
    local NGINX_CONF="/etc/nginx/sites-available/tiktok_account_system"
    local NGINX_ENABLED="/etc/nginx/sites-enabled/tiktok_account_system"
    local DEFAULT_SITE="/etc/nginx/sites-enabled/default"
    
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
        read -p "按Enter键继续..." key
        maintenance_menu
        return
    fi
    
    echo -e "${YELLOW}步骤5: 重启Nginx${NC}"
    systemctl restart nginx
    if [ $? -ne 0 ]; then
        echo -e "${RED}Nginx重启失败，请检查错误日志${NC}"
        echo -e "${YELLOW}查看Nginx错误日志: sudo journalctl -u nginx${NC}"
        read -p "按Enter键继续..." key
        maintenance_menu
        return
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
        read -p "按Enter键继续..." key
        maintenance_menu
        return
    fi
    
    echo -e "${GREEN}Nginx配置修复完成!${NC}"
    echo -e "${YELLOW}如果仍然无法访问，请检查以下内容:${NC}"
    echo -e "${YELLOW}1. 防火墙是否允许80端口访问${NC}"
    echo -e "${YELLOW}2. 应用是否正确运行在5001端口${NC}"
    echo -e "${YELLOW}3. Nginx错误日志: /var/log/nginx/tiktok_error.log${NC}"
    echo -e "${YELLOW}4. 应用错误日志: /var/log/tiktok_account_system/error.log${NC}"
    
    read -p "按Enter键继续..." key
    maintenance_menu
}

# 开发菜单
development_menu() {
    show_header
    echo -e "${CYAN}开发工具:${NC}"
    echo -e "${YELLOW}1.${NC} 启动开发服务器"
    echo -e "${YELLOW}2.${NC} 运行测试"
    echo -e "${YELLOW}3.${NC} 生成测试数据"
    echo -e "${YELLOW}4.${NC} 重启开发环境"
    echo -e "${YELLOW}5.${NC} 直接修复UI按钮"
    echo -e "${YELLOW}9.${NC} 返回主菜单"
    echo -e "${YELLOW}0.${NC} 退出"
    echo ""
    read -p "请输入选项 [0-9]: " choice
    
    case $choice in
        1) start_dev_server ;;
        2) run_tests ;;
        3) generate_test_data ;;
        4) restart_dev_environment ;;
        5) fix_ui_buttons ;;
        9) show_main_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            development_menu
            ;;
    esac
}

# 修复UI按钮功能
fix_ui_buttons() {
    show_header
    echo -e "${CYAN}修复账号管理页面按钮显示问题${NC}"
    
    # 设置应用目录
    local APP_DIR="$LOCAL_DIR"
    local BACKUP_DIR="$LOCAL_DIR/backups/ui_fix_$(date +%Y%m%d_%H%M%S)"
    
    # 创建备份目录
    mkdir -p $BACKUP_DIR
    echo -e "${YELLOW}创建备份目录: $BACKUP_DIR${NC}"
    
    # 备份当前文件
    echo -e "${YELLOW}步骤1: 备份当前文件${NC}"
    cp -f $APP_DIR/templates/accounts.html $BACKUP_DIR/ 2>/dev/null || echo "accounts.html 不存在，跳过备份"
    cp -f $APP_DIR/static/css/accounts.css $BACKUP_DIR/ 2>/dev/null || echo "accounts.css 不存在，跳过备份"
    cp -f $APP_DIR/static/js/accounts.js $BACKUP_DIR/ 2>/dev/null || echo "accounts.js 不存在，跳过备份"
    
    # 修复CSS文件
    echo -e "${YELLOW}步骤2: 修复accounts.css文件${NC}"
    
    # 检查目录是否存在，如果不存在则创建
    if [ ! -d "$APP_DIR/static/css" ]; then
        mkdir -p "$APP_DIR/static/css"
        echo -e "${YELLOW}创建CSS目录: $APP_DIR/static/css${NC}"
    fi
    
    # 如果CSS文件不存在，创建一个新的
    if [ ! -f "$APP_DIR/static/css/accounts.css" ]; then
        echo -e "${YELLOW}创建新的accounts.css文件${NC}"
        cat > "$APP_DIR/static/css/accounts.css" << 'EOF'
/* 账号管理系统样式表 */
.data-table {
    width: 100%;
    border-collapse: collapse;
    margin: 20px 0;
}

.data-table th, .data-table td {
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
}

.data-table th {
    background-color: #f2f2f2;
    position: sticky;
    top: 0;
    z-index: 10;
}

/* 列宽设置 */
.data-table th:nth-child(1) { width: 3%; } /* ID */
.data-table th:nth-child(2) { width: 8%; } /* 账号名 */
.data-table th:nth-child(3) { width: 8%; } /* 密码 */
.data-table th:nth-child(4) { width: 8%; } /* 邮箱 */
.data-table th:nth-child(5) { width: 5%; } /* 手机 */
.data-table th:nth-child(6) { width: 5%; } /* 粉丝数 */
.data-table th:nth-child(7) { width: 5%; } /* 关注数 */
.data-table th:nth-child(8) { width: 5%; } /* 获赞数 */
.data-table th:nth-child(9) { width: 5%; } /* 作品数 */
.data-table th:nth-child(10) { width: 5%; } /* 类型 */
.data-table th:nth-child(11) { width: 5%; } /* 辈分 */
.data-table th:nth-child(12) { width: 5%; } /* 地区 */
.data-table th:nth-child(13) { width: 5%; } /* 价格 */
.data-table th:nth-child(14) { width: 5%; } /* 状态 */
.data-table th:nth-child(15) { width: 15%; } /* 操作 */

/* 确保操作列有足够的空间 */
.actions {
    min-width: 280px;
    white-space: nowrap;
    padding: 5px !important;
    overflow: visible !important;
    text-overflow: clip !important;
}

.action-buttons {
    display: flex;
    flex-wrap: wrap;
    gap: 5px;
}

/* 操作按钮样式 */
.action-btn {
    padding: 3px 5px;
    border-radius: 3px;
    font-size: 11px;
    cursor: pointer;
    border: none;
    transition: all 0.2s ease;
    font-weight: 500;
    white-space: nowrap;
    display: inline-block;
    min-width: 35px;
    text-align: center;
    margin: 2px;
}

.view-btn {
    background-color: #e6f4ea;
    color: #137333;
}

.view-btn:hover {
    background-color: #ceead6;
    transform: translateY(-2px);
    box-shadow: 0 2px 5px rgba(19, 115, 51, 0.15);
}

.refresh-btn {
    background-color: #f1f3f4;
    color: #333;
}

.refresh-btn:hover {
    background-color: #e8eaed;
    transform: translateY(-2px);
}

.edit-btn {
    background-color: #e8f0fe;
    color: #1a73e8;
}

.edit-btn:hover {
    background-color: #d2e3fc;
    transform: translateY(-2px);
    box-shadow: 0 2px 5px rgba(26, 115, 232, 0.15);
}

.delete-btn {
    background-color: #fce8e6;
    color: #ea4335;
}

.delete-btn:hover {
    background-color: #fad2cf;
    transform: translateY(-2px);
    box-shadow: 0 2px 5px rgba(234, 67, 53, 0.15);
}

.sell-btn {
    background-color: #fff8e1;
    color: #f9a825;
}

.sell-btn:hover {
    background-color: #ffecb3;
    transform: translateY(-2px);
    box-shadow: 0 2px 5px rgba(249, 168, 37, 0.15);
}
EOF
    else
        # 检查列宽设置是否正确
        echo -e "${YELLOW}检查列宽设置...${NC}"
        if grep -q "th:nth-child(11) { width: 5%; } /\* 地区 \*/" "$APP_DIR/static/css/accounts.css"; then
            echo -e "${YELLOW}发现列宽设置错误，修复中...${NC}"
            sed -i '' 's/th:nth-child(11) { width: 5%; } \/\* 地区 \*\//th:nth-child(11) { width: 5%; } \/\* 辈分 \*\//' "$APP_DIR/static/css/accounts.css"
        fi

        if grep -q "th:nth-child(12) { width: 5%; } /\* 价格 \*/" "$APP_DIR/static/css/accounts.css"; then
            echo -e "${YELLOW}发现列宽设置错误，修复中...${NC}"
            sed -i '' 's/th:nth-child(12) { width: 5%; } \/\* 价格 \*\//th:nth-child(12) { width: 5%; } \/\* 地区 \*\//' "$APP_DIR/static/css/accounts.css"
        fi

        if grep -q "th:nth-child(13) { width: 5%; } /\* 状态 \*/" "$APP_DIR/static/css/accounts.css"; then
            echo -e "${YELLOW}发现列宽设置错误，修复中...${NC}"
            sed -i '' 's/th:nth-child(13) { width: 5%; } \/\* 状态 \*\//th:nth-child(13) { width: 5%; } \/\* 价格 \*\//' "$APP_DIR/static/css/accounts.css"
        fi

        # 添加第14列的宽度设置
        if ! grep -q "th:nth-child(14) { width: 5%; } /\* 状态 \*/" "$APP_DIR/static/css/accounts.css"; then
            echo -e "${YELLOW}添加第14列(状态)的宽度设置...${NC}"
            sed -i '' '/th:nth-child(13)/a\
.data-table th:nth-child(14) { width: 5%; } /* 状态 */' "$APP_DIR/static/css/accounts.css"
        fi

        # 确保操作列样式存在
        if ! grep -q ".actions {" "$APP_DIR/static/css/accounts.css"; then
            echo -e "${YELLOW}添加操作列样式...${NC}"
            cat >> "$APP_DIR/static/css/accounts.css" << 'EOF'

/* 确保操作列有足够的空间 */
.actions {
    min-width: 280px;
    white-space: nowrap;
    padding: 5px !important;
    overflow: visible !important;
    text-overflow: clip !important;
}

.action-buttons {
    display: flex;
    flex-wrap: wrap;
    gap: 5px;
}
EOF
        fi

        # 确保操作按钮样式存在
        if ! grep -q ".action-btn {" "$APP_DIR/static/css/accounts.css"; then
            echo -e "${YELLOW}添加操作按钮样式...${NC}"
            cat >> "$APP_DIR/static/css/accounts.css" << 'EOF'

/* 操作按钮样式 */
.action-btn {
    padding: 3px 5px;
    border-radius: 3px;
    font-size: 11px;
    cursor: pointer;
    border: none;
    transition: all 0.2s ease;
    font-weight: 500;
    white-space: nowrap;
    display: inline-block;
    min-width: 35px;
    text-align: center;
    margin: 2px;
}

.view-btn {
    background-color: #e6f4ea;
    color: #137333;
}

.view-btn:hover {
    background-color: #ceead6;
    transform: translateY(-2px);
    box-shadow: 0 2px 5px rgba(19, 115, 51, 0.15);
}

.refresh-btn {
    background-color: #f1f3f4;
    color: #333;
}

.refresh-btn:hover {
    background-color: #e8eaed;
    transform: translateY(-2px);
}

.edit-btn {
    background-color: #e8f0fe;
    color: #1a73e8;
}

.edit-btn:hover {
    background-color: #d2e3fc;
    transform: translateY(-2px);
    box-shadow: 0 2px 5px rgba(26, 115, 232, 0.15);
}

.delete-btn {
    background-color: #fce8e6;
    color: #ea4335;
}

.delete-btn:hover {
    background-color: #fad2cf;
    transform: translateY(-2px);
    box-shadow: 0 2px 5px rgba(234, 67, 53, 0.15);
}

.sell-btn {
    background-color: #fff8e1;
    color: #f9a825;
}

.sell-btn:hover {
    background-color: #ffecb3;
    transform: translateY(-2px);
    box-shadow: 0 2px 5px rgba(249, 168, 37, 0.15);
}
EOF
        fi
    fi
    
    # 检查是否有HTML文件，如果有则修复操作按钮
    if [ -f "$APP_DIR/templates/accounts.html" ]; then
        echo -e "${YELLOW}步骤3: 检查accounts.html文件中的操作按钮...${NC}"
        if ! grep -q "class=\"action-buttons\"" "$APP_DIR/templates/accounts.html"; then
            echo -e "${YELLOW}修复HTML中的操作按钮结构...${NC}"
            sed -i '' 's/<td class="actions">/<td class="actions">\n                                <div class="action-buttons">/' "$APP_DIR/templates/accounts.html"
            sed -i '' 's/<\/button>\n                                    {% if account.status/<\/button>\n                                    {% if account.status/' "$APP_DIR/templates/accounts.html"
            sed -i '' 's/{% endif %}\n                            <\/td>/{% endif %}\n                                <\/div>\n                            <\/td>/' "$APP_DIR/templates/accounts.html"
        fi
    else
        echo -e "${YELLOW}未找到accounts.html文件，跳过HTML修复${NC}"
    fi
    
    # 检查是否有重复的CSS规则
    echo -e "${YELLOW}步骤4: 检查并删除重复的CSS规则...${NC}"
    if [ -f "$APP_DIR/static/css/accounts.css" ]; then
        sed -i '' '/\.sell-btn {/,/}/{ /\.sell-btn {/{x;/./p;x;}; /}/h; }' "$APP_DIR/static/css/accounts.css"
    fi
    
    echo -e "${GREEN}修复完成!${NC}"
    echo -e "${YELLOW}请刷新浏览器缓存查看效果 (按Ctrl+F5)${NC}"
    echo ""
    read -p "按Enter键继续..." key
    development_menu
}

# 备份相关功能
# 完整系统备份
backup_full_system() {
    show_header
    echo -e "${YELLOW}执行完整系统备份...${NC}"
    
    # 创建备份目录
    mkdir -p $BACKUP_DIR
    echo -e "${YELLOW}创建备份目录: $BACKUP_DIR${NC}"
    
    # 确定要备份的目录
    if [ -d "$DEPLOY_DIR" ]; then
        TARGET_DIR=$DEPLOY_DIR
    else
        TARGET_DIR=$LOCAL_DIR
    fi
    
    # 执行备份
    echo -e "${YELLOW}正在备份系统文件...${NC}"
    cp -r $TARGET_DIR/* $BACKUP_DIR/ 2>/dev/null
    
    # 备份配置文件
    if [ -f "/etc/nginx/sites-available/$APP_NAME" ]; then
        mkdir -p $BACKUP_DIR/config/nginx
        cp /etc/nginx/sites-available/$APP_NAME $BACKUP_DIR/config/nginx/
    fi
    
    if [ -f "/etc/supervisor/conf.d/$APP_NAME.conf" ]; then
        mkdir -p $BACKUP_DIR/config/supervisor
        cp /etc/supervisor/conf.d/$APP_NAME.conf $BACKUP_DIR/config/supervisor/
    fi
    
    # 创建备份信息文件
    echo "备份时间: $(date)" > $BACKUP_DIR/backup_info.txt
    echo "备份类型: 完整系统备份" >> $BACKUP_DIR/backup_info.txt
    echo "备份目录: $TARGET_DIR" >> $BACKUP_DIR/backup_info.txt
    
    echo -e "${GREEN}完整系统备份完成!${NC}"
    echo -e "${YELLOW}备份保存在: $BACKUP_DIR${NC}"
    echo ""
    read -p "按Enter键继续..." key
    backup_menu
}

# 仅备份数据库
backup_database() {
    show_header
    echo -e "${YELLOW}执行数据库备份...${NC}"
    
    # 创建备份目录
    mkdir -p $BACKUP_DIR/database
    echo -e "${YELLOW}创建备份目录: $BACKUP_DIR/database${NC}"
    
    # 确定数据库位置
    if [ -f "$DEPLOY_DIR/database.db" ]; then
        DB_FILE="$DEPLOY_DIR/database.db"
    elif [ -f "$LOCAL_DIR/database.db" ]; then
        DB_FILE="$LOCAL_DIR/database.db"
    elif [ -f "$DEPLOY_DIR/instance/database.db" ]; then
        DB_FILE="$DEPLOY_DIR/instance/database.db"
    elif [ -f "$LOCAL_DIR/instance/database.db" ]; then
        DB_FILE="$LOCAL_DIR/instance/database.db"
    else
        echo -e "${RED}无法找到数据库文件${NC}"
        read -p "按Enter键继续..." key
        backup_menu
        return
    fi
    
    # 执行备份
    echo -e "${YELLOW}正在备份数据库: $DB_FILE${NC}"
    cp $DB_FILE $BACKUP_DIR/database/
    
    # 创建备份信息文件
    echo "备份时间: $(date)" > $BACKUP_DIR/backup_info.txt
    echo "备份类型: 数据库备份" >> $BACKUP_DIR/backup_info.txt
    echo "备份文件: $DB_FILE" >> $BACKUP_DIR/backup_info.txt
    
    echo -e "${GREEN}数据库备份完成!${NC}"
    echo -e "${YELLOW}备份保存在: $BACKUP_DIR/database/${NC}"
    echo ""
    read -p "按Enter键继续..." key
    backup_menu
}

# 仅备份配置文件
backup_config() {
    show_header
    echo -e "${YELLOW}执行配置文件备份...${NC}"
    
    # 创建备份目录
    mkdir -p $BACKUP_DIR/config/{nginx,supervisor}
    echo -e "${YELLOW}创建备份目录: $BACKUP_DIR/config${NC}"
    
    # 备份Nginx配置
    if [ -f "/etc/nginx/sites-available/$APP_NAME" ]; then
        echo -e "${YELLOW}备份Nginx配置...${NC}"
        cp /etc/nginx/sites-available/$APP_NAME $BACKUP_DIR/config/nginx/
    else
        echo -e "${YELLOW}未找到Nginx配置文件${NC}"
    fi
    
    # 备份Supervisor配置
    if [ -f "/etc/supervisor/conf.d/$APP_NAME.conf" ]; then
        echo -e "${YELLOW}备份Supervisor配置...${NC}"
        cp /etc/supervisor/conf.d/$APP_NAME.conf $BACKUP_DIR/config/supervisor/
    else
        echo -e "${YELLOW}未找到Supervisor配置文件${NC}"
    fi
    
    # 备份本地配置文件
    if [ -f "$LOCAL_DIR/nginx_config.conf" ]; then
        cp $LOCAL_DIR/nginx_config.conf $BACKUP_DIR/config/
    fi
    
    if [ -f "$LOCAL_DIR/docker-compose.yml" ]; then
        cp $LOCAL_DIR/docker-compose.yml $BACKUP_DIR/config/
    fi
    
    # 创建备份信息文件
    echo "备份时间: $(date)" > $BACKUP_DIR/backup_info.txt
    echo "备份类型: 配置文件备份" >> $BACKUP_DIR/backup_info.txt
    
    echo -e "${GREEN}配置文件备份完成!${NC}"
    echo -e "${YELLOW}备份保存在: $BACKUP_DIR/config/${NC}"
    echo ""
    read -p "按Enter键继续..." key
    backup_menu
}

# 列出现有备份
list_backups() {
    show_header
    echo -e "${YELLOW}现有备份列表:${NC}"
    
    # 检查备份目录
    if [ -d "$LOCAL_DIR/backups" ]; then
        BACKUP_COUNT=$(ls -1 $LOCAL_DIR/backups | wc -l)
        
        if [ $BACKUP_COUNT -eq 0 ]; then
            echo -e "${YELLOW}没有找到备份${NC}"
        else
            echo -e "${GREEN}找到 $BACKUP_COUNT 个备份:${NC}"
            echo ""
            
            # 列出备份及其信息
            for backup in $LOCAL_DIR/backups/*; do
                if [ -d "$backup" ]; then
                    BACKUP_NAME=$(basename $backup)
                    echo -e "${CYAN}备份: $BACKUP_NAME${NC}"
                    
                    if [ -f "$backup/backup_info.txt" ]; then
                        echo -e "${YELLOW}信息:${NC}"
                        cat $backup/backup_info.txt | while read line; do
                            echo -e "  $line"
                        done
                    else
                        echo -e "${YELLOW}  创建时间: $(date -r $backup)${NC}"
                    fi
                    echo ""
                fi
            done
        fi
    else
        echo -e "${YELLOW}备份目录不存在${NC}"
    fi
    
    echo ""
    read -p "按Enter键继续..." key
    backup_menu
}

# 恢复备份
restore_backup() {
    show_header
    echo -e "${YELLOW}恢复备份:${NC}"
    
    # 检查备份目录
    if [ ! -d "$LOCAL_DIR/backups" ] || [ $(ls -1 $LOCAL_DIR/backups | wc -l) -eq 0 ]; then
        echo -e "${RED}没有找到可用的备份${NC}"
        read -p "按Enter键继续..." key
        backup_menu
        return
    fi
    
    # 列出可用备份
    echo -e "${YELLOW}可用备份:${NC}"
    local i=1
    declare -a backup_paths
    
    for backup in $LOCAL_DIR/backups/*; do
        if [ -d "$backup" ]; then
            backup_paths[$i]=$backup
            BACKUP_NAME=$(basename $backup)
            echo -e "${YELLOW}$i.${NC} $BACKUP_NAME"
            
            if [ -f "$backup/backup_info.txt" ]; then
                head -n 2 "$backup/backup_info.txt" | while read line; do
                    echo -e "   $line"
                done
            else
                echo -e "   创建时间: $(date -r $backup)"
            fi
            
            i=$((i+1))
        fi
    done
    
    echo -e "${YELLOW}0.${NC} 返回上级菜单"
    echo ""
    read -p "请选择要恢复的备份 [0-$((i-1))]: " choice
    
    if [ "$choice" = "0" ]; then
        backup_menu
        return
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -gt 0 ] && [ "$choice" -lt "$i" ]; then
        selected_backup=${backup_paths[$choice]}
        
        # 确认恢复
        echo -e "${RED}警告: 恢复备份将覆盖当前系统!${NC}"
        read -p "是否确定要恢复此备份? (y/n): " confirm
        
        if [ "$confirm" = "y" ]; then
            echo -e "${YELLOW}正在恢复备份...${NC}"
            
            # 确定恢复类型
            if [ -f "$selected_backup/backup_info.txt" ]; then
                BACKUP_TYPE=$(grep "备份类型" "$selected_backup/backup_info.txt" | cut -d':' -f2 | tr -d ' ')
            else
                # 根据目录结构猜测备份类型
                if [ -d "$selected_backup/database" ]; then
                    BACKUP_TYPE="数据库备份"
                elif [ -d "$selected_backup/config" ]; then
                    BACKUP_TYPE="配置文件备份"
                else
                    BACKUP_TYPE="完整系统备份"
                fi
            fi
            
            # 根据备份类型执行恢复
            case "$BACKUP_TYPE" in
                "完整系统备份")
                    # 停止服务
                    if command -v supervisorctl &> /dev/null; then
                        echo -e "${YELLOW}停止服务...${NC}"
                        supervisorctl stop $APP_NAME &> /dev/null
                    fi
                    
                    # 恢复文件
                    if [ -d "$DEPLOY_DIR" ]; then
                        TARGET_DIR=$DEPLOY_DIR
                    else
                        TARGET_DIR=$LOCAL_DIR
                    fi
                    
                    echo -e "${YELLOW}恢复系统文件到 $TARGET_DIR...${NC}"
                    cp -r $selected_backup/* $TARGET_DIR/ 2>/dev/null
                    
                    # 恢复配置文件
                    if [ -d "$selected_backup/config/nginx" ] && [ -f "$selected_backup/config/nginx/$APP_NAME" ]; then
                        echo -e "${YELLOW}恢复Nginx配置...${NC}"
                        cp "$selected_backup/config/nginx/$APP_NAME" "/etc/nginx/sites-available/" 2>/dev/null
                    fi
                    
                    if [ -d "$selected_backup/config/supervisor" ] && [ -f "$selected_backup/config/supervisor/$APP_NAME.conf" ]; then
                        echo -e "${YELLOW}恢复Supervisor配置...${NC}"
                        cp "$selected_backup/config/supervisor/$APP_NAME.conf" "/etc/supervisor/conf.d/" 2>/dev/null
                    fi
                    
                    # 重启服务
                    if command -v supervisorctl &> /dev/null; then
                        echo -e "${YELLOW}重启服务...${NC}"
                        supervisorctl reread &> /dev/null
                        supervisorctl update &> /dev/null
                        supervisorctl start $APP_NAME &> /dev/null
                    fi
                    ;;
                    
                "数据库备份")
                    # 确定数据库位置
                    if [ -f "$DEPLOY_DIR/database.db" ]; then
                        DB_TARGET="$DEPLOY_DIR/database.db"
                    elif [ -f "$LOCAL_DIR/database.db" ]; then
                        DB_TARGET="$LOCAL_DIR/database.db"
                    elif [ -f "$DEPLOY_DIR/instance/database.db" ]; then
                        DB_TARGET="$DEPLOY_DIR/instance/database.db"
                    elif [ -f "$LOCAL_DIR/instance/database.db" ]; then
                        DB_TARGET="$LOCAL_DIR/instance/database.db"
                    else
                        DB_TARGET="$LOCAL_DIR/database.db"
                    fi
                    
                    # 找到备份的数据库文件
                    DB_SOURCE=$(find "$selected_backup" -name "*.db" | head -n 1)
                    
                    if [ -z "$DB_SOURCE" ]; then
                        echo -e "${RED}无法找到备份的数据库文件${NC}"
                    else
                        echo -e "${YELLOW}恢复数据库到 $DB_TARGET...${NC}"
                        cp "$DB_SOURCE" "$DB_TARGET"
                    fi
                    ;;
                    
                "配置文件备份")
                    # 恢复配置文件
                    if [ -d "$selected_backup/config/nginx" ] && [ -f "$selected_backup/config/nginx/$APP_NAME" ]; then
                        echo -e "${YELLOW}恢复Nginx配置...${NC}"
                        cp "$selected_backup/config/nginx/$APP_NAME" "/etc/nginx/sites-available/" 2>/dev/null
                    fi
                    
                    if [ -d "$selected_backup/config/supervisor" ] && [ -f "$selected_backup/config/supervisor/$APP_NAME.conf" ]; then
                        echo -e "${YELLOW}恢复Supervisor配置...${NC}"
                        cp "$selected_backup/config/supervisor/$APP_NAME.conf" "/etc/supervisor/conf.d/" 2>/dev/null
                    fi
                    
                    if [ -f "$selected_backup/config/nginx_config.conf" ]; then
                        echo -e "${YELLOW}恢复本地Nginx配置...${NC}"
                        cp "$selected_backup/config/nginx_config.conf" "$LOCAL_DIR/"
                    fi
                    
                    if [ -f "$selected_backup/config/docker-compose.yml" ]; then
                        echo -e "${YELLOW}恢复Docker配置...${NC}"
                        cp "$selected_backup/config/docker-compose.yml" "$LOCAL_DIR/"
                    fi
                    ;;
                    
                *)
                    echo -e "${RED}未知的备份类型${NC}"
                    ;;
            esac
            
            echo -e "${GREEN}备份恢复完成!${NC}"
        else
            echo -e "${YELLOW}已取消恢复操作${NC}"
        fi
    else
        echo -e "${RED}无效选项${NC}"
    fi
    
    read -p "按Enter键继续..." key
    backup_menu
}

# 程序入口
main() {
    # 检查操作系统
    check_os
    
    # 显示主菜单
    show_main_menu
}

# 执行主函数
main
