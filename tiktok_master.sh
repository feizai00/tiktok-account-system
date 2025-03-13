#!/bin/bash
# TikTok账号管理系统 - 主控脚本
# 版本：v2.0.0
# 日期：2025-03-13
# 功能：整合所有脚本功能，提供统一的管理界面

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
NGINX_CONFIG="/etc/nginx/sites-available/tiktok_account_system"
VERSION="2.0.0"
LAST_UPDATE="2025-03-13"

# 日志函数
log() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${timestamp} - $1"
    
    # 如果日志目录存在，则写入日志文件
    if [ -d "$LOG_DIR" ]; then
        echo "${timestamp} - $1" >> "$LOG_DIR/master.log"
    fi
}

# 显示标题
show_header() {
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}    TikTok账号管理系统 - 主控脚本    ${NC}"
    echo -e "${BLUE}    版本: v${VERSION}                ${NC}"
    echo -e "${BLUE}    日期: ${LAST_UPDATE}             ${NC}"
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
            return 1
        fi
    fi
    return 0
}

# 检查操作系统
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    echo -e "${YELLOW}检测到操作系统: $OS $VER${NC}"
    sleep 1
}

# 主菜单
show_main_menu() {
    show_header
    echo -e "${CYAN}请选择操作类别:${NC}"
    echo -e "${YELLOW}1.${NC} 部署管理"
    echo -e "${YELLOW}2.${NC} 备份与恢复"
    echo -e "${YELLOW}3.${NC} 系统维护"
    echo -e "${YELLOW}4.${NC} 开发工具"
    echo -e "${YELLOW}5.${NC} 问题修复"
    echo -e "${YELLOW}6.${NC} GitHub操作"
    echo -e "${YELLOW}7.${NC} 系统信息"
    echo -e "${YELLOW}8.${NC} 脚本管理"
    echo -e "${YELLOW}0.${NC} 退出"
    echo ""
    read -p "请输入选项 [0-8]: " choice
    
    case $choice in
        1) deployment_menu ;;
        2) backup_menu ;;
        3) maintenance_menu ;;
        4) development_menu ;;
        5) fix_menu ;;
        6) github_menu ;;
        7) system_info ;;
        8) script_management ;;
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
    echo -e "${CYAN}部署管理:${NC}"
    echo -e "${YELLOW}1.${NC} 标准部署"
    echo -e "${YELLOW}2.${NC} 自动部署"
    echo -e "${YELLOW}3.${NC} Docker部署"
    echo -e "${YELLOW}4.${NC} 部署修复"
    echo -e "${YELLOW}5.${NC} 更新已部署系统"
    echo -e "${YELLOW}9.${NC} 返回主菜单"
    echo -e "${YELLOW}0.${NC} 退出"
    echo ""
    read -p "请输入选项 [0-9]: " choice
    
    case $choice in
        1) standard_deploy ;;
        2) auto_deploy ;;
        3) docker_deploy ;;
        4) deploy_fixes ;;
        5) update_deployed_system ;;
        9) show_main_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            deployment_menu
            ;;
    esac
}

# 标准部署
standard_deploy() {
    show_header
    echo -e "${CYAN}执行标准部署...${NC}"
    
    # 检查root权限
    check_root || return
    
    # 创建备份目录
    mkdir -p "$BACKUP_DIR"
    
    echo -e "${YELLOW}开始部署应用到 $DEPLOY_DIR${NC}"
    
    # 备份当前部署
    if [ -d "$DEPLOY_DIR" ]; then
        echo -e "${YELLOW}备份当前部署...${NC}"
        cp -r "$DEPLOY_DIR" "$BACKUP_DIR/deploy_backup"
    fi
    
    # 创建部署目录
    mkdir -p "$DEPLOY_DIR"
    
    # 复制应用文件
    echo -e "${YELLOW}复制应用文件...${NC}"
    cp -r "$LOCAL_DIR"/* "$DEPLOY_DIR/"
    
    # 设置权限
    echo -e "${YELLOW}设置权限...${NC}"
    chown -R www-data:www-data "$DEPLOY_DIR" 2>/dev/null || echo -e "${YELLOW}权限设置跳过，需要root权限${NC}"
    chmod -R 755 "$DEPLOY_DIR" 2>/dev/null || echo -e "${YELLOW}权限设置跳过，需要root权限${NC}"
    
    echo -e "${GREEN}标准部署完成!${NC}"
    echo -e "${YELLOW}应用已部署到: $DEPLOY_DIR${NC}"
    
    read -p "按Enter键返回..." key
    deployment_menu
}

# 自动部署
auto_deploy() {
    show_header
    echo -e "${CYAN}执行自动部署...${NC}"
    
    # 检查root权限
    check_root || return
    
    # 创建备份目录
    mkdir -p "$BACKUP_DIR"
    
    echo -e "${YELLOW}开始自动部署流程...${NC}"
    
    # 备份当前部署
    if [ -d "$DEPLOY_DIR" ]; then
        echo -e "${YELLOW}备份当前部署...${NC}"
        cp -r "$DEPLOY_DIR" "$BACKUP_DIR/deploy_backup"
    fi
    
    # 从GitHub克隆最新代码
    echo -e "${YELLOW}从GitHub克隆最新代码...${NC}"
    if [ -d "$LOCAL_DIR/temp_git" ]; then
        rm -rf "$LOCAL_DIR/temp_git"
    fi
    
    mkdir -p "$LOCAL_DIR/temp_git"
    git clone "$GITHUB_REPO" "$LOCAL_DIR/temp_git" || {
        echo -e "${RED}克隆仓库失败${NC}"
        read -p "按Enter键返回..." key
        deployment_menu
        return
    }
    
    # 复制到部署目录
    echo -e "${YELLOW}复制到部署目录...${NC}"
    mkdir -p "$DEPLOY_DIR"
    cp -r "$LOCAL_DIR/temp_git"/* "$DEPLOY_DIR/"
    
    # 设置权限
    echo -e "${YELLOW}设置权限...${NC}"
    chown -R www-data:www-data "$DEPLOY_DIR" 2>/dev/null || echo -e "${YELLOW}权限设置跳过，需要root权限${NC}"
    chmod -R 755 "$DEPLOY_DIR" 2>/dev/null || echo -e "${YELLOW}权限设置跳过，需要root权限${NC}"
    
    # 清理临时目录
    rm -rf "$LOCAL_DIR/temp_git"
    
    echo -e "${GREEN}自动部署完成!${NC}"
    echo -e "${YELLOW}应用已部署到: $DEPLOY_DIR${NC}"
    
    read -p "按Enter键返回..." key
    deployment_menu
}

# Docker部署
docker_deploy() {
    show_header
    echo -e "${CYAN}执行Docker部署...${NC}"
    
    # 检查Docker是否安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装${NC}"
        echo -e "${YELLOW}请先安装Docker${NC}"
        read -p "按Enter键返回..." key
        deployment_menu
        return
    fi
    
    # 创建备份目录
    mkdir -p "$BACKUP_DIR"
    
    echo -e "${YELLOW}开始Docker部署流程...${NC}"
    
    # 创建Dockerfile
    echo -e "${YELLOW}创建Dockerfile...${NC}"
    cat > "$LOCAL_DIR/Dockerfile" << EOF
FROM python:3.9-slim

WORKDIR /app

COPY . /app/

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE $APP_PORT

CMD ["python", "app.py"]
EOF
    
    # 构建Docker镜像
    echo -e "${YELLOW}构建Docker镜像...${NC}"
    docker build -t $APP_NAME:latest "$LOCAL_DIR" || {
        echo -e "${RED}构建Docker镜像失败${NC}"
        read -p "按Enter键返回..." key
        deployment_menu
        return
    }
    
    # 停止并删除旧容器
    if docker ps -a | grep -q $APP_NAME; then
        echo -e "${YELLOW}停止并删除旧容器...${NC}"
        docker stop $APP_NAME
        docker rm $APP_NAME
    fi
    
    # 运行新容器
    echo -e "${YELLOW}运行新容器...${NC}"
    docker run -d --name $APP_NAME -p $APP_PORT:$APP_PORT $APP_NAME:latest || {
        echo -e "${RED}运行Docker容器失败${NC}"
        read -p "按Enter键返回..." key
        deployment_menu
        return
    }
    
    echo -e "${GREEN}Docker部署完成!${NC}"
    echo -e "${YELLOW}容器名称: $APP_NAME${NC}"
    echo -e "${YELLOW}端口映射: $APP_PORT:$APP_PORT${NC}"
    echo -e "${YELLOW}查看容器日志: docker logs $APP_NAME${NC}"
    
    read -p "按Enter键返回..." key
    deployment_menu
}

# 部署修复
deploy_fixes() {
    show_header
    echo -e "${CYAN}执行部署修复...${NC}"
    
    # 检查root权限
    check_root || return
    
    echo -e "${YELLOW}开始修复部署问题...${NC}"
    
    # 修复权限
    echo -e "${YELLOW}修复文件权限...${NC}"
    chown -R www-data:www-data "$DEPLOY_DIR" 2>/dev/null || echo -e "${YELLOW}权限设置跳过，需要root权限${NC}"
    chmod -R 755 "$DEPLOY_DIR" 2>/dev/null || echo -e "${YELLOW}权限设置跳过，需要root权限${NC}"
    
    # 修复UI按钮问题
    echo -e "${YELLOW}修复UI按钮问题...${NC}"
    if [ -f "$DEPLOY_DIR/templates/accounts.html" ]; then
        # 备份原文件
        cp "$DEPLOY_DIR/templates/accounts.html" "$BACKUP_DIR/accounts.html.bak"
        
        # 修改JavaScript引用路径
        sed -i "s|<script src=\"/static/js/accounts.js\"></script>|<script src=\"{{ url_for('static', filename='js/accounts.js') }}\"></script>|g" "$DEPLOY_DIR/templates/accounts.html" || echo -e "${YELLOW}修改JavaScript引用路径失败${NC}"
        
        # 添加内联JavaScript确保按钮正常显示
        if ! grep -q "确保按钮显示" "$DEPLOY_DIR/templates/accounts.html"; then
            cat > "$DEPLOY_DIR/temp_script.js" << 'EOL'
<!-- 确保按钮显示和功能正常 -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // 确保所有按钮可见
        var actionButtons = document.querySelectorAll(".action-btn");
        actionButtons.forEach(function(btn) {
            btn.style.display = "inline-block";
        });
        
        // 重新绑定按钮事件
        var viewButtons = document.querySelectorAll(".view-btn");
        viewButtons.forEach(function(btn) {
            btn.addEventListener("click", function() {
                var accountId = this.getAttribute("data-id");
                window.location.href = "/view_account/" + accountId;
            });
        });
        
        var refreshButtons = document.querySelectorAll(".refresh-btn");
        refreshButtons.forEach(function(btn) {
            btn.addEventListener("click", function() {
                var accountId = this.getAttribute("data-id");
                window.location.href = "/refresh_account/" + accountId;
            });
        });
        
        var editButtons = document.querySelectorAll(".edit-btn");
        editButtons.forEach(function(btn) {
            btn.addEventListener("click", function() {
                var accountId = this.getAttribute("data-id");
                window.location.href = "/edit_account/" + accountId;
            });
        });
        
        var deleteButtons = document.querySelectorAll(".delete-btn");
        deleteButtons.forEach(function(btn) {
            btn.addEventListener("click", function() {
                var accountId = this.getAttribute("data-id");
                if(confirm("确定要删除这个账号吗?")) {
                    window.location.href = "/delete_account/" + accountId;
                }
            });
        });
    });
</script>
EOL
            # 使用更可靠的方式插入脚本
            sed -i "/<\/body>/i $(cat "$DEPLOY_DIR/temp_script.js" | sed 's/\//\\\//g')" "$DEPLOY_DIR/templates/accounts.html" || echo -e "${YELLOW}添加内联JavaScript失败${NC}"
            rm "$DEPLOY_DIR/temp_script.js"

        fi
    fi
    
    echo -e "${GREEN}部署修复完成!${NC}"
    
    read -p "按Enter键返回..." key
    deployment_menu
}

# 更新已部署系统
update_deployed_system() {
    show_header
    echo -e "${CYAN}更新已部署系统...${NC}"
    
    # 检查root权限
    check_root || return
    
    # 创建备份目录
    mkdir -p "$BACKUP_DIR"
    
    echo -e "${YELLOW}开始更新已部署系统...${NC}"
    
    # 备份当前部署
    if [ -d "$DEPLOY_DIR" ]; then
        echo -e "${YELLOW}备份当前部署...${NC}"
        cp -r "$DEPLOY_DIR" "$BACKUP_DIR/deploy_backup"
    else
        echo -e "${RED}错误: 部署目录不存在${NC}"
        read -p "按Enter键返回..." key
        deployment_menu
        return
    fi
    
    # 从GitHub获取最新代码
    echo -e "${YELLOW}从GitHub获取最新代码...${NC}"
    if [ -d "$LOCAL_DIR/temp_update" ]; then
        rm -rf "$LOCAL_DIR/temp_update"
    fi
    
    mkdir -p "$LOCAL_DIR/temp_update"
    git clone "$GITHUB_REPO" "$LOCAL_DIR/temp_update" || {
        echo -e "${RED}克隆仓库失败${NC}"
        read -p "按Enter键返回..." key
        deployment_menu
        return
    }
    
    # 更新部署目录
    echo -e "${YELLOW}更新部署目录...${NC}"
    cp -r "$LOCAL_DIR/temp_update"/* "$DEPLOY_DIR/"
    
    # 设置权限
    echo -e "${YELLOW}设置权限...${NC}"
    chown -R www-data:www-data "$DEPLOY_DIR" 2>/dev/null || echo -e "${YELLOW}权限设置跳过，需要root权限${NC}"
    chmod -R 755 "$DEPLOY_DIR" 2>/dev/null || echo -e "${YELLOW}权限设置跳过，需要root权限${NC}"
    
    # 清理临时目录
    rm -rf "$LOCAL_DIR/temp_update"
    
    echo -e "${GREEN}系统更新完成!${NC}"
    
    read -p "按Enter键返回..." key
    deployment_menu
}

# 备份菜单
backup_menu() {
    show_header
    echo -e "${CYAN}备份与恢复:${NC}"
    echo -e "${YELLOW}1.${NC} 完整系统备份"
    echo -e "${YELLOW}2.${NC} 仅备份数据库"
    echo -e "${YELLOW}3.${NC} 仅备份配置文件"
    echo -e "${YELLOW}4.${NC} 列出现有备份"
    echo -e "${YELLOW}5.${NC} 恢复备份"
    echo -e "${YELLOW}6.${NC} 清理旧备份"
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
        6) clean_old_backups ;;
        9) show_main_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            backup_menu
            ;;
    esac
}

# 完整系统备份
backup_full_system() {
    show_header
    echo -e "${CYAN}执行完整系统备份...${NC}"
    
    # 创建备份目录
    FULL_BACKUP_DIR="$BACKUP_DIR/full_backup"
    mkdir -p "$FULL_BACKUP_DIR"
    
    echo -e "${YELLOW}开始备份整个系统...${NC}"
    
    # 备份应用文件
    echo -e "${YELLOW}备份应用文件...${NC}"
    cp -r "$LOCAL_DIR"/* "$FULL_BACKUP_DIR/" || {
        echo -e "${RED}备份应用文件失败${NC}"
        read -p "按Enter键返回..." key
        backup_menu
        return
    }
    
    # 备份数据库
    echo -e "${YELLOW}备份数据库...${NC}"
    if [ -f "$LOCAL_DIR/instance/tiktok.db" ]; then
        mkdir -p "$FULL_BACKUP_DIR/instance"
        cp "$LOCAL_DIR/instance/tiktok.db" "$FULL_BACKUP_DIR/instance/" || {
            echo -e "${RED}备份数据库失败${NC}"
        }
    fi
    
    # 备份配置文件
    echo -e "${YELLOW}备份配置文件...${NC}"
    if [ -d "$LOCAL_DIR/config" ]; then
        mkdir -p "$FULL_BACKUP_DIR/config"
        cp -r "$LOCAL_DIR/config"/* "$FULL_BACKUP_DIR/config/" || {
            echo -e "${RED}备份配置文件失败${NC}"
        }
    fi
    
    # 创建备份信息文件
    echo -e "${YELLOW}创建备份信息文件...${NC}"
    cat > "$FULL_BACKUP_DIR/backup_info.txt" << EOF
备份类型: 完整系统备份
备份时间: $(date +"%Y-%m-%d %H:%M:%S")
备份版本: $VERSION
备份目录: $FULL_BACKUP_DIR
EOF
    
    echo -e "${GREEN}完整系统备份完成!${NC}"
    echo -e "${YELLOW}备份保存在: $FULL_BACKUP_DIR${NC}"
    
    read -p "按Enter键返回..." key
    backup_menu
}

# 仅备份数据库
backup_database() {
    show_header
    echo -e "${CYAN}备份数据库...${NC}"
    
    # 创建备份目录
    DB_BACKUP_DIR="$BACKUP_DIR/db_backup"
    mkdir -p "$DB_BACKUP_DIR"
    
    echo -e "${YELLOW}开始备份数据库...${NC}"
    
    # 备份 SQLite 数据库
    if [ -f "$LOCAL_DIR/instance/tiktok.db" ]; then
        mkdir -p "$DB_BACKUP_DIR/instance"
        cp "$LOCAL_DIR/instance/tiktok.db" "$DB_BACKUP_DIR/instance/tiktok.db" || {
            echo -e "${RED}备份数据库失败${NC}"
            read -p "按Enter键返回..." key
            backup_menu
            return
        }
        
        echo -e "${GREEN}数据库备份完成!${NC}"
        echo -e "${YELLOW}备份保存在: $DB_BACKUP_DIR/instance/tiktok.db${NC}"
    else
        echo -e "${RED}错误: 数据库文件不存在${NC}"
    fi
    
    # 创建备份信息文件
    cat > "$DB_BACKUP_DIR/backup_info.txt" << EOF
备份类型: 数据库备份
备份时间: $(date +"%Y-%m-%d %H:%M:%S")
备份版本: $VERSION
备份目录: $DB_BACKUP_DIR
EOF
    
    read -p "按Enter键返回..." key
    backup_menu
}

# 仅备份配置文件
backup_config() {
    show_header
    echo -e "${CYAN}备份配置文件...${NC}"
    
    # 创建备份目录
    CONFIG_BACKUP_DIR="$BACKUP_DIR/config_backup"
    mkdir -p "$CONFIG_BACKUP_DIR"
    
    echo -e "${YELLOW}开始备份配置文件...${NC}"
    
    # 备份配置文件
    if [ -d "$LOCAL_DIR/config" ]; then
        mkdir -p "$CONFIG_BACKUP_DIR/config"
        cp -r "$LOCAL_DIR/config"/* "$CONFIG_BACKUP_DIR/config/" || {
            echo -e "${RED}备份配置文件失败${NC}"
            read -p "按Enter键返回..." key
            backup_menu
            return
        }
        
        echo -e "${GREEN}配置文件备份完成!${NC}"
        echo -e "${YELLOW}备份保存在: $CONFIG_BACKUP_DIR/config${NC}"
    else
        echo -e "${YELLOW}未找到配置目录，尝试备份其他配置文件...${NC}"
    fi
    
    # 备份 app.py 和 requirements.txt
    if [ -f "$LOCAL_DIR/app.py" ]; then
        cp "$LOCAL_DIR/app.py" "$CONFIG_BACKUP_DIR/" || echo -e "${RED}备份 app.py 失败${NC}"
    fi
    
    if [ -f "$LOCAL_DIR/requirements.txt" ]; then
        cp "$LOCAL_DIR/requirements.txt" "$CONFIG_BACKUP_DIR/" || echo -e "${RED}备份 requirements.txt 失败${NC}"
    fi
    
    # 创建备份信息文件
    cat > "$CONFIG_BACKUP_DIR/backup_info.txt" << EOF
备份类型: 配置文件备份
备份时间: $(date +"%Y-%m-%d %H:%M:%S")
备份版本: $VERSION
备份目录: $CONFIG_BACKUP_DIR
EOF
    
    echo -e "${GREEN}配置文件备份完成!${NC}"
    
    read -p "按Enter键返回..." key
    backup_menu
}

# 列出现有备份
list_backups() {
    show_header
    echo -e "${CYAN}列出现有备份:${NC}"
    
    # 检查备份目录
    if [ ! -d "$LOCAL_DIR/backups" ]; then
        echo -e "${RED}未找到备份目录${NC}"
        read -p "按Enter键返回..." key
        backup_menu
        return
    fi
    
    # 列出备份目录
    echo -e "${YELLOW}找到以下备份:${NC}"
    
    # 计数器
    count=0
    
    # 遍历备份目录
    for backup in "$LOCAL_DIR"/backups/*/; do
        if [ -d "$backup" ]; then
            backup_name=$(basename "$backup")
            backup_date=$(echo "$backup_name" | grep -oE "[0-9]{8}_[0-9]{6}" || echo "Unknown")
            
            # 检查备份类型
            backup_type="未知"
            if [ -d "$backup/full_backup" ]; then
                backup_type="完整系统备份"
            elif [ -d "$backup/db_backup" ]; then
                backup_type="数据库备份"
            elif [ -d "$backup/config_backup" ]; then
                backup_type="配置文件备份"
            elif [ -d "$backup/deploy_backup" ]; then
                backup_type="部署备份"
            fi
            
            # 格式化日期
            if [ "$backup_date" != "Unknown" ]; then
                year=${backup_date:0:4}
                month=${backup_date:4:2}
                day=${backup_date:6:2}
                hour=${backup_date:9:2}
                minute=${backup_date:11:2}
                second=${backup_date:13:2}
                formatted_date="$year-$month-$day $hour:$minute:$second"
            else
                formatted_date="未知日期"
            fi
            
            echo -e "${GREEN}$((++count)).${NC} [$backup_type] $formatted_date - $backup"
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo -e "${RED}没有找到备份${NC}"
    fi
    
    read -p "按Enter键返回..." key
    backup_menu
}

# 恢复备份
restore_backup() {
    show_header
    echo -e "${CYAN}恢复备份:${NC}"
    
    # 检查备份目录
    if [ ! -d "$LOCAL_DIR/backups" ]; then
        echo -e "${RED}未找到备份目录${NC}"
        read -p "按Enter键返回..." key
        backup_menu
        return
    fi
    
    # 列出备份目录
    echo -e "${YELLOW}可用备份:${NC}"
    
    # 存储备份路径的数组
    declare -a backup_paths
    
    # 计数器
    count=0
    
    # 遍历备份目录
    for backup in "$LOCAL_DIR"/backups/*/; do
        if [ -d "$backup" ]; then
            backup_name=$(basename "$backup")
            backup_date=$(echo "$backup_name" | grep -oE "[0-9]{8}_[0-9]{6}" || echo "Unknown")
            
            # 检查备份类型
            backup_type="未知"
            if [ -d "$backup/full_backup" ]; then
                backup_type="完整系统备份"
            elif [ -d "$backup/db_backup" ]; then
                backup_type="数据库备份"
            elif [ -d "$backup/config_backup" ]; then
                backup_type="配置文件备份"
            elif [ -d "$backup/deploy_backup" ]; then
                backup_type="部署备份"
            fi
            
            # 格式化日期
            if [ "$backup_date" != "Unknown" ]; then
                year=${backup_date:0:4}
                month=${backup_date:4:2}
                day=${backup_date:6:2}
                hour=${backup_date:9:2}
                minute=${backup_date:11:2}
                second=${backup_date:13:2}
                formatted_date="$year-$month-$day $hour:$minute:$second"
            else
                formatted_date="未知日期"
            fi
            
            # 保存备份路径
            backup_paths[$count]="$backup"
            
            echo -e "${GREEN}$((++count)).${NC} [$backup_type] $formatted_date - $backup_name"
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo -e "${RED}没有找到备份${NC}"
        read -p "按Enter键返回..." key
        backup_menu
        return
    fi
    
    echo -e "${YELLOW}0.${NC} 返回备份菜单"
    echo ""
    read -p "请选择要恢复的备份 [0-$count]: " choice
    
    # 验证输入
    if [[ ! $choice =~ ^[0-9]+$ ]] || [ $choice -lt 0 ] || [ $choice -gt $count ]; then
        echo -e "${RED}无效选项${NC}"
        sleep 1
        restore_backup
        return
    fi
    
    # 返回备份菜单
    if [ $choice -eq 0 ]; then
        backup_menu
        return
    fi
    
    # 获取选择的备份路径
    selected_backup=${backup_paths[$((choice-1))]}
    
    # 确认恢复
    echo -e "${YELLOW}警告: 恢复备份将覆盖当前系统。继续操作?${NC}"
    read -p "确认恢复? (y/n): " confirm
    
    if [ "$confirm" != "y" ]; then
        echo -e "${YELLOW}操作已取消${NC}"
        sleep 1
        restore_backup
        return
    fi
    
    # 确定备份类型并恢复
    echo -e "${YELLOW}开始恢复备份...${NC}"
    
    # 创建当前系统的备份
    echo -e "${YELLOW}创建当前系统的备份...${NC}"
    current_backup_dir="$BACKUP_DIR/pre_restore_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$current_backup_dir"
    
    # 备份当前系统
    if [ -d "$LOCAL_DIR" ]; then
        cp -r "$LOCAL_DIR"/* "$current_backup_dir/" 2>/dev/null || echo -e "${YELLOW}部分文件无法备份${NC}"
    fi
    
    # 检查备份类型并恢复
    if [ -d "$selected_backup/full_backup" ]; then
        echo -e "${YELLOW}恢复完整系统备份...${NC}"
        
        # 恢复应用文件
        echo -e "${YELLOW}恢复应用文件...${NC}"
        cp -r "$selected_backup/full_backup"/* "$LOCAL_DIR/" || {
            echo -e "${RED}恢复应用文件失败${NC}"
            read -p "按Enter键返回..." key
            backup_menu
            return
        }
        
        echo -e "${GREEN}完整系统备份恢复成功!${NC}"
    elif [ -d "$selected_backup/db_backup" ]; then
        echo -e "${YELLOW}恢复数据库备份...${NC}"
        
        # 确保目标目录存在
        mkdir -p "$LOCAL_DIR/instance"
        
        # 恢复数据库文件
        if [ -f "$selected_backup/db_backup/instance/tiktok.db" ]; then
            cp "$selected_backup/db_backup/instance/tiktok.db" "$LOCAL_DIR/instance/" || {
                echo -e "${RED}恢复数据库失败${NC}"
                read -p "按Enter键返回..." key
                backup_menu
                return
            }
            
            echo -e "${GREEN}数据库备份恢复成功!${NC}"
        else
            echo -e "${RED}数据库备份文件不存在${NC}"
            read -p "按Enter键返回..." key
            backup_menu
            return
        fi
    elif [ -d "$selected_backup/config_backup" ]; then
        echo -e "${YELLOW}恢复配置文件备份...${NC}"
        
        # 恢复配置文件
        if [ -d "$selected_backup/config_backup/config" ]; then
            mkdir -p "$LOCAL_DIR/config"
            cp -r "$selected_backup/config_backup/config"/* "$LOCAL_DIR/config/" || {
                echo -e "${RED}恢复配置文件失败${NC}"
                read -p "按Enter键返回..." key
                backup_menu
                return
            }
        fi
        
        # 恢复其他配置文件
        if [ -f "$selected_backup/config_backup/app.py" ]; then
            cp "$selected_backup/config_backup/app.py" "$LOCAL_DIR/" || echo -e "${RED}恢复 app.py 失败${NC}"
        fi
        
        if [ -f "$selected_backup/config_backup/requirements.txt" ]; then
            cp "$selected_backup/config_backup/requirements.txt" "$LOCAL_DIR/" || echo -e "${RED}恢复 requirements.txt 失败${NC}"
        fi
        
        echo -e "${GREEN}配置文件备份恢复成功!${NC}"
    elif [ -d "$selected_backup/deploy_backup" ]; then
        echo -e "${YELLOW}恢复部署备份...${NC}"
        
        # 恢复部署文件
        cp -r "$selected_backup/deploy_backup"/* "$DEPLOY_DIR/" || {
            echo -e "${RED}恢复部署备份失败${NC}"
            read -p "按Enter键返回..." key
            backup_menu
            return
        }
        
        echo -e "${GREEN}部署备份恢复成功!${NC}"
    else
        echo -e "${RED}无法确定备份类型，恢复失败${NC}"
        read -p "按Enter键返回..." key
        backup_menu
        return
    fi
    
    # 设置权限
    echo -e "${YELLOW}设置权限...${NC}"
    chown -R www-data:www-data "$LOCAL_DIR" 2>/dev/null || echo -e "${YELLOW}权限设置跳过，需要root权限${NC}"
    chmod -R 755 "$LOCAL_DIR" 2>/dev/null || echo -e "${YELLOW}权限设置跳过，需要root权限${NC}"
    
    echo -e "${GREEN}备份恢复完成!${NC}"
    echo -e "${YELLOW}当前系统的备份已保存在: $current_backup_dir${NC}"
    
    read -p "按Enter键返回..." key
    backup_menu
}

# 清理旧备份
clean_old_backups() {
    show_header
    echo -e "${CYAN}清理旧备份:${NC}"
    
    # 检查备份目录
    if [ ! -d "$LOCAL_DIR/backups" ]; then
        echo -e "${RED}未找到备份目录${NC}"
        read -p "按Enter键返回..." key
        backup_menu
        return
    fi
    
    # 列出备份目录
    echo -e "${YELLOW}当前备份:${NC}"
    
    # 存储备份路径的数组
    declare -a backup_paths
    declare -a backup_dates
    
    # 计数器
    count=0
    
    # 遍历备份目录
    for backup in "$LOCAL_DIR"/backups/*/; do
        if [ -d "$backup" ]; then
            backup_name=$(basename "$backup")
            backup_date=$(echo "$backup_name" | grep -oE "[0-9]{8}_[0-9]{6}" || echo "Unknown")
            
            # 检查备份类型
            backup_type="未知"
            if [ -d "$backup/full_backup" ]; then
                backup_type="完整系统备份"
            elif [ -d "$backup/db_backup" ]; then
                backup_type="数据库备份"
            elif [ -d "$backup/config_backup" ]; then
                backup_type="配置文件备份"
            elif [ -d "$backup/deploy_backup" ]; then
                backup_type="部署备份"
            fi
            
            # 格式化日期
            if [ "$backup_date" != "Unknown" ]; then
                year=${backup_date:0:4}
                month=${backup_date:4:2}
                day=${backup_date:6:2}
                hour=${backup_date:9:2}
                minute=${backup_date:11:2}
                second=${backup_date:13:2}
                formatted_date="$year-$month-$day $hour:$minute:$second"
            else
                formatted_date="未知日期"
            fi
            
            # 保存备份路径和日期
            backup_paths[$count]="$backup"
            backup_dates[$count]="$backup_date"
            
            echo -e "${GREEN}$((++count)).${NC} [$backup_type] $formatted_date - $backup_name"
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo -e "${RED}没有找到备份${NC}"
        read -p "按Enter键返回..." key
        backup_menu
        return
    fi
    
    echo -e "\n${YELLOW}清理选项:${NC}"
    echo -e "1. 按时间清理（保留最近N个备份）"
    echo -e "2. 手动选择要删除的备份"
    echo -e "3. 删除所有备份"
    echo -e "0. 返回备份菜单"
    echo ""
    read -p "请选择清理方式 [0-3]: " clean_choice
    
    case $clean_choice in
        0)
            backup_menu
            return
            ;;
        1)
            echo -e "\n${YELLOW}保留最近的备份数量:${NC}"
            read -p "请输入要保留的最近备份数量: " keep_count
            
            # 验证输入
            if [[ ! $keep_count =~ ^[0-9]+$ ]] || [ $keep_count -lt 1 ]; then
                echo -e "${RED}无效输入，请输入大于0的数字${NC}"
                sleep 1
                clean_old_backups
                return
            fi
            
            # 如果要保留的数量大于等于现有备份数量，则不需要删除
            if [ $keep_count -ge $count ]; then
                echo -e "${YELLOW}当前备份数量($count)小于或等于要保留的数量($keep_count)，无需清理${NC}"
                read -p "按Enter键返回..." key
                clean_old_backups
                return
            fi
            
            # 按日期排序备份（从旧到新）
            for ((i=0; i<$count; i++)); do
                for ((j=i+1; j<$count; j++)); do
                    if [ "${backup_dates[$i]}" \> "${backup_dates[$j]}" ]; then
                        # 交换日期
                        temp_date=${backup_dates[$i]}
                        backup_dates[$i]=${backup_dates[$j]}
                        backup_dates[$j]=$temp_date
                        
                        # 交换路径
                        temp_path=${backup_paths[$i]}
                        backup_paths[$i]=${backup_paths[$j]}
                        backup_paths[$j]=$temp_path
                    fi
                done
            done
            
            # 计算要删除的备份数量
            delete_count=$((count - keep_count))
            
            echo -e "\n${YELLOW}将删除以下$delete_count个最旧的备份:${NC}"
            for ((i=0; i<$delete_count; i++)); do
                backup_name=$(basename "${backup_paths[$i]}")
                echo -e "${RED}$(($i+1)).${NC} $backup_name"
            done
            
            echo -e "\n${RED}警告: 此操作无法撤销!${NC}"
            read -p "确认删除? (y/n): " confirm
            
            if [ "$confirm" != "y" ]; then
                echo -e "${YELLOW}操作已取消${NC}"
                sleep 1
                clean_old_backups
                return
            fi
            
            # 删除旧备份
            for ((i=0; i<$delete_count; i++)); do
                echo -e "删除: ${RED}$(basename "${backup_paths[$i]}")${NC}"
                rm -rf "${backup_paths[$i]}"
            done
            
            echo -e "\n${GREEN}成功删除$delete_count个旧备份，保留了最近的$keep_count个备份${NC}"
            ;;
        2)
            echo -e "\n${YELLOW}请输入要删除的备份编号（用空格分隔）:${NC}"
            read -p "> " delete_numbers
            
            # 验证输入
            valid_input=true
            for num in $delete_numbers; do
                if [[ ! $num =~ ^[0-9]+$ ]] || [ $num -lt 1 ] || [ $num -gt $count ]; then
                    valid_input=false
                    break
                fi
            done
            
            if [ "$valid_input" = false ]; then
                echo -e "${RED}无效输入，请输入1到$count之间的数字${NC}"
                sleep 1
                clean_old_backups
                return
            fi
            
            echo -e "\n${YELLOW}将删除以下备份:${NC}"
            for num in $delete_numbers; do
                backup_name=$(basename "${backup_paths[$((num-1))]}") 
                echo -e "${RED}$num.${NC} $backup_name"
            done
            
            echo -e "\n${RED}警告: 此操作无法撤销!${NC}"
            read -p "确认删除? (y/n): " confirm
            
            if [ "$confirm" != "y" ]; then
                echo -e "${YELLOW}操作已取消${NC}"
                sleep 1
                clean_old_backups
                return
            fi
            
            # 删除选定的备份
            for num in $delete_numbers; do
                echo -e "删除: ${RED}$(basename "${backup_paths[$((num-1))]}")${NC}"
                rm -rf "${backup_paths[$((num-1))]}"
            done
            
            echo -e "\n${GREEN}成功删除选定的备份${NC}"
            ;;
        3)
            echo -e "\n${RED}警告: 将删除所有备份!此操作无法撤销!${NC}"
            read -p "确认删除所有备份? (y/n): " confirm
            
            if [ "$confirm" != "y" ]; then
                echo -e "${YELLOW}操作已取消${NC}"
                sleep 1
                clean_old_backups
                return
            fi
            
            # 删除所有备份
            echo -e "${YELLOW}删除所有备份...${NC}"
            rm -rf "$LOCAL_DIR"/backups/*
            
            echo -e "\n${GREEN}成功删除所有备份${NC}"
            ;;
        *)
            echo -e "${RED}无效选项${NC}"
            sleep 1
            clean_old_backups
            ;;
    esac
    
    read -p "按Enter键返回..." key
    backup_menu
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
    echo -e "${YELLOW}8.${NC} 更新系统依赖"
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
        8) update_dependencies ;;
        9) show_main_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            maintenance_menu
            ;;
    esac
}

# 开发菜单
development_menu() {
    show_header
    echo -e "${CYAN}开发工具:${NC}"
    echo -e "${YELLOW}1.${NC} 启动开发服务器"
    echo -e "${YELLOW}2.${NC} 重启开发服务器"
    echo -e "${YELLOW}3.${NC} 运行测试"
    echo -e "${YELLOW}4.${NC} 代码检查"
    echo -e "${YELLOW}5.${NC} 生成文档"
    echo -e "${YELLOW}6.${NC} 创建测试数据"
    echo -e "${YELLOW}9.${NC} 返回主菜单"
    echo -e "${YELLOW}0.${NC} 退出"
    echo ""
    read -p "请输入选项 [0-9]: " choice
    
    case $choice in
        1) start_dev_server ;;
        2) restart_dev_server ;;
        3) run_tests ;;
        4) code_check ;;
        5) generate_docs ;;
        6) create_test_data ;;
        9) show_main_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            development_menu
            ;;
    esac
}

# 修复菜单
fix_menu() {
    show_header
    echo -e "${CYAN}问题修复:${NC}"
    echo -e "${YELLOW}1.${NC} 修复UI按钮"
    echo -e "${YELLOW}2.${NC} 修复Nginx配置"
    echo -e "${YELLOW}3.${NC} 修复服务器问题"
    echo -e "${YELLOW}4.${NC} 修复数据库连接"
    echo -e "${YELLOW}5.${NC} 修复权限问题"
    echo -e "${YELLOW}6.${NC} 修复静态文件"
    echo -e "${YELLOW}7.${NC} 直接修复"
    echo -e "${YELLOW}8.${NC} 紧急修复"
    echo -e "${YELLOW}9.${NC} 返回主菜单"
    echo -e "${YELLOW}0.${NC} 退出"
    echo ""
    read -p "请输入选项 [0-9]: " choice
    
    case $choice in
        1) fix_ui_buttons ;;
        2) fix_nginx ;;
        3) fix_server ;;
        4) fix_database ;;
        5) fix_permissions ;;
        6) fix_static_files ;;
        7) direct_fix ;;
        8) emergency_fix ;;
        9) show_main_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            fix_menu
            ;;
    esac
}

# GitHub菜单
github_menu() {
    show_header
    echo -e "${CYAN}GitHub操作:${NC}"
    echo -e "${YELLOW}1.${NC} 上传到GitHub"
    echo -e "${YELLOW}2.${NC} 创建PR"
    echo -e "${YELLOW}3.${NC} 拉取最新代码"
    echo -e "${YELLOW}4.${NC} 查看提交历史"
    echo -e "${YELLOW}5.${NC} 创建新分支"
    echo -e "${YELLOW}9.${NC} 返回主菜单"
    echo -e "${YELLOW}0.${NC} 退出"
    echo ""
    read -p "请输入选项 [0-9]: " choice
    
    case $choice in
        1) github_upload ;;
        2) create_pr ;;
        3) pull_latest ;;
        4) view_commit_history ;;
        5) create_branch ;;
        9) show_main_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            github_menu
            ;;
    esac
}

# 系统信息
system_info() {
    show_header
    echo -e "${CYAN}系统信息:${NC}"
    
    echo -e "${YELLOW}操作系统:${NC}"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "  名称: $NAME"
        echo -e "  版本: $VERSION_ID"
    else
        echo -e "  $(uname -s) $(uname -r)"
    fi
    
    echo -e "\n${YELLOW}应用信息:${NC}"
    echo -e "  名称: $APP_NAME"
    echo -e "  版本: $VERSION"
    echo -e "  最后更新: $LAST_UPDATE"
    echo -e "  部署目录: $DEPLOY_DIR"
    echo -e "  端口: $APP_PORT"
    
    echo -e "\n${YELLOW}服务状态:${NC}"
    if command -v supervisorctl &> /dev/null; then
        echo -e "  Supervisor状态:"
        supervisorctl status $APP_NAME
    else
        echo -e "  ${RED}Supervisor未安装${NC}"
    fi
    
    if command -v systemctl &> /dev/null; then
        echo -e "\n  Nginx状态:"
        systemctl status nginx | grep Active
    else
        echo -e "\n  ${RED}Systemd未安装${NC}"
    fi
    
    echo -e "\n${YELLOW}磁盘使用情况:${NC}"
    df -h | grep -E "Filesystem|/$"
    
    echo -e "\n${YELLOW}内存使用情况:${NC}"
    free -h
    
    echo -e "\n${YELLOW}数据库状态:${NC}"
    if [ -f "$DEPLOY_DIR/instance/tiktok.db" ]; then
        echo -e "  SQLite数据库大小: $(du -h $DEPLOY_DIR/instance/tiktok.db | cut -f1)"
    else
        echo -e "  ${RED}数据库文件不存在${NC}"
    fi
    
    echo ""
    read -p "按Enter键返回主菜单..." key
    show_main_menu
}

# 脚本管理
script_management() {
    show_header
    echo -e "${CYAN}脚本管理:${NC}"
    echo -e "${YELLOW}1.${NC} 列出所有脚本"
    echo -e "${YELLOW}2.${NC} 整合所有脚本到主控脚本"
    echo -e "${YELLOW}3.${NC} 清理冗余脚本"
    echo -e "${YELLOW}4.${NC} 备份所有脚本"
    echo -e "${YELLOW}9.${NC} 返回主菜单"
    echo -e "${YELLOW}0.${NC} 退出"
    echo ""
    read -p "请输入选项 [0-9]: " choice
    
    case $choice in
        1) list_all_scripts ;;
        2) integrate_scripts ;;
        3) clean_redundant_scripts ;;
        4) backup_scripts ;;
        9) show_main_menu ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选项${NC}"
            sleep 1
            script_management
            ;;
    esac
}

# 列出所有脚本
list_all_scripts() {
    show_header
    echo -e "${CYAN}项目中的所有脚本:${NC}\n"
    
    echo -e "${YELLOW}找到以下脚本文件:${NC}"
    find "$LOCAL_DIR" -name "*.sh" | sort | while read script; do
        # 获取脚本的第一行注释作为描述
        description=$(head -n 3 "$script" | grep -E "^#" | head -n 1 | sed 's/^# //')
        script_name=$(basename "$script")
        
        if [ -z "$description" ]; then
            description="无描述"
        fi
        
        echo -e "${GREEN}$script_name${NC} - $description"
    done
    
    echo ""
    read -p "按Enter键返回..." key
    script_management
}

# 整合所有脚本
integrate_scripts() {
    show_header
    echo -e "${CYAN}整合所有脚本到主控脚本${NC}\n"
    
    echo -e "${YELLOW}此功能将分析项目中的所有脚本，并将它们的功能整合到主控脚本中。${NC}"
    echo -e "${RED}警告: 这可能需要一些时间，并且可能需要手动调整。${NC}"
    read -p "是否继续? (y/n): " choice
    
    if [ "$choice" != "y" ]; then
        script_management
        return
    fi
    
    echo -e "\n${YELLOW}分析脚本...${NC}"
    
    # 创建临时目录存放分析结果
    mkdir -p "$LOCAL_DIR/temp_script_analysis"
    
    # 分析每个脚本
    find "$LOCAL_DIR" -name "*.sh" | grep -v "tiktok_master.sh" | sort | while read script; do
        script_name=$(basename "$script")
        echo -e "分析: ${GREEN}$script_name${NC}"
        
        # 提取脚本中的函数
        grep -E "^[a-zA-Z0-9_]+\(\)" "$script" > "$LOCAL_DIR/temp_script_analysis/${script_name}_functions.txt"
        
        # 提取脚本的主要功能描述
        head -n 10 "$script" | grep -E "^#" > "$LOCAL_DIR/temp_script_analysis/${script_name}_description.txt"
    done
    
    echo -e "\n${GREEN}分析完成!${NC}"
    echo -e "${YELLOW}分析结果保存在: $LOCAL_DIR/temp_script_analysis${NC}"
    echo -e "${YELLOW}请手动检查分析结果，并根据需要修改主控脚本。${NC}"
    
    read -p "按Enter键返回..." key
    script_management
}

# 清理冗余脚本
clean_redundant_scripts() {
    show_header
    echo -e "${CYAN}清理冗余脚本${NC}\n"
    
    echo -e "${YELLOW}此功能将帮助您识别和清理冗余的脚本文件。${NC}"
    echo -e "${RED}警告: 请确保您已经将所有必要的功能整合到主控脚本中。${NC}"
    read -p "是否继续? (y/n): " choice
    
    if [ "$choice" != "y" ]; then
        script_management
        return
    fi
    
    # 创建备份目录
    SCRIPT_BACKUP_DIR="$LOCAL_DIR/script_backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$SCRIPT_BACKUP_DIR"
    
    echo -e "\n${YELLOW}以下脚本可能是冗余的:${NC}"
    find "$LOCAL_DIR" -name "*.sh" | grep -v "tiktok_master.sh" | sort | while read script; do
        script_name=$(basename "$script")
        echo -e "${GREEN}$script_name${NC}"
    done
    
    echo -e "\n${YELLOW}选项:${NC}"
    echo -e "1. 备份并移除所有脚本（除了tiktok_master.sh）"
    echo -e "2. 手动选择要移除的脚本"
    echo -e "3. 返回"
    
    read -p "请选择 [1-3]: " clean_choice
    
    case $clean_choice in
        1)
            echo -e "\n${YELLOW}备份并移除所有脚本...${NC}"
            find "$LOCAL_DIR" -name "*.sh" | grep -v "tiktok_master.sh" | while read script; do
                script_name=$(basename "$script")
                echo -e "备份并移除: ${GREEN}$script_name${NC}"
                cp "$script" "$SCRIPT_BACKUP_DIR/"
                rm "$script"
            done
            echo -e "\n${GREEN}所有脚本已备份到: $SCRIPT_BACKUP_DIR${NC}"
            echo -e "${GREEN}所有脚本（除了tiktok_master.sh）已被移除${NC}"
            ;;
        2)
            echo -e "\n${YELLOW}请输入要移除的脚本名称（用空格分隔）:${NC}"
            read -p "> " scripts_to_remove
            
            for script_name in $scripts_to_remove; do
                if [ -f "$LOCAL_DIR/$script_name" ]; then
                    echo -e "备份并移除: ${GREEN}$script_name${NC}"
                    cp "$LOCAL_DIR/$script_name" "$SCRIPT_BACKUP_DIR/"
                    rm "$LOCAL_DIR/$script_name"
                else
                    echo -e "${RED}脚本不存在: $script_name${NC}"
                fi
            done
            echo -e "\n${GREEN}选定的脚本已备份到: $SCRIPT_BACKUP_DIR${NC}"
            echo -e "${GREEN}选定的脚本已被移除${NC}"
            ;;
        3)
            script_management
            return
            ;;
        *)
            echo -e "${RED}无效选项${NC}"
            sleep 1
            clean_redundant_scripts
            ;;
    esac
    
    read -p "按Enter键返回..." key
    script_management
}

# 备份所有脚本
backup_scripts() {
    show_header
    echo -e "${CYAN}备份所有脚本${NC}\n"
    
    # 创建备份目录
    SCRIPT_BACKUP_DIR="$LOCAL_DIR/script_backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$SCRIPT_BACKUP_DIR"
    
    echo -e "${YELLOW}备份所有脚本...${NC}"
    find "$LOCAL_DIR" -name "*.sh" | while read script; do
        script_name=$(basename "$script")
        echo -e "备份: ${GREEN}$script_name${NC}"
        cp "$script" "$SCRIPT_BACKUP_DIR/"
    done
    
    echo -e "\n${GREEN}所有脚本已备份到: $SCRIPT_BACKUP_DIR${NC}"
    
    read -p "按Enter键返回..." key
    script_management
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
