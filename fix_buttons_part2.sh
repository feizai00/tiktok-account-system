#!/bin/bash
# 修复账号管理页面按钮显示问题 - 部署脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    部署修复后的文件    ${NC}"
echo -e "${BLUE}================================================${NC}"

# 设置应用目录
APP_DIR="/opt/tiktok-account-system"

# 确保目录存在
mkdir -p $APP_DIR/static/css
mkdir -p $APP_DIR/templates

# 修复CSS文件
echo -e "${YELLOW}步骤1: 修复accounts.css文件${NC}"
cat > $APP_DIR/static/css/accounts.css << 'EOF'
/* 账号管理页面特有样式 */
/* 主内容区域样式 */
main {
    padding: 30px;
    max-width: 1400px;
    margin: 0 auto;
}

.container {
    background-color: #fff;
    border-radius: 10px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    padding: 25px;
}

/* 表格样式 */
.table-container {
    overflow-x: auto;
    margin-bottom: 25px;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    width: 100%;
    max-width: 100%;
    display: block;
}

.data-table {
    width: 100%;
    border-collapse: collapse;
    border-radius: 8px;
    overflow: hidden;
    table-layout: fixed;
}

.data-table th,
.data-table td {
    padding: 10px 8px;
    text-align: left;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.data-table td.actions {
    white-space: nowrap;
    overflow: visible;
    text-overflow: clip;
    padding: 5px;
}

/* 设置列宽 */
.data-table th:nth-child(1) { width: 3%; }  /* # */
.data-table th:nth-child(2) { width: 7%; }  /* 用户名 */
.data-table th:nth-child(3) { width: 7%; }  /* 密码 */
.data-table th:nth-child(4) { width: 7%; }  /* 号码/邮箱 */
.data-table th:nth-child(5) { width: 6%; }  /* 注册时间 */
.data-table th:nth-child(6) { width: 6%; }  /* 注册地区 */
.data-table th:nth-child(7) { width: 5%; }  /* 橱窗功能 */
.data-table th:nth-child(8) { width: 6%; }  /* 粉丝数 */
.data-table th:nth-child(9) { width: 6%; }  /* 点赞数 */
.data-table th:nth-child(10) { width: 6%; } /* 账号类型 */
.data-table th:nth-child(11) { width: 5%; } /* 辈分 */
.data-table th:nth-child(12) { width: 5%; } /* 地区 */
.data-table th:nth-child(13) { width: 5%; } /* 价格 */
.data-table th:nth-child(14) { width: 5%; } /* 状态 */
.data-table th:nth-child(15) { width: 30%; } /* 操作 */

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

# 修复Nginx配置
echo -e "${YELLOW}步骤2: 修复Nginx配置${NC}"
NGINX_CONFIG="/etc/nginx/sites-available/tiktok_account_system"

# 检查Nginx配置文件是否存在
if [ -f "$NGINX_CONFIG" ]; then
    # 备份Nginx配置
    cp $NGINX_CONFIG ${NGINX_CONFIG}.bak
    
    # 修改Nginx配置中的端口
    sed -i 's/proxy_pass http:\/\/127.0.0.1:5000;/proxy_pass http:\/\/127.0.0.1:5001;/g' $NGINX_CONFIG
    
    # 测试Nginx配置
    nginx -t
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Nginx配置测试成功${NC}"
        # 重启Nginx
        systemctl restart nginx
    else
        echo -e "${RED}Nginx配置测试失败，恢复备份${NC}"
        cp ${NGINX_CONFIG}.bak $NGINX_CONFIG
    fi
else
    echo -e "${RED}Nginx配置文件不存在: $NGINX_CONFIG${NC}"
fi

# 重启应用
echo -e "${YELLOW}步骤3: 重启应用${NC}"
supervisorctl restart tiktok_account_system

# 清除浏览器缓存提示
echo -e "${YELLOW}步骤4: 完成${NC}"
echo -e "${GREEN}修复已完成!${NC}"
echo -e "${YELLOW}请在浏览器中按Ctrl+F5强制刷新页面，清除缓存后查看效果${NC}"
echo -e "${BLUE}================================================${NC}"
