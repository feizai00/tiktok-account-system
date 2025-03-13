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
