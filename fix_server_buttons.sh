#!/bin/bash
# 服务器上修复账号管理页面按钮显示问题的脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    服务器修复账号管理页面按钮显示问题    ${NC}"
echo -e "${BLUE}================================================${NC}"

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}错误: 此脚本必须以root用户身份运行${NC}" 
   echo -e "${YELLOW}请使用 sudo ./fix_server_buttons.sh 运行此脚本${NC}"
   exit 1
fi

# 设置应用目录
APP_DIR="/opt/tiktok-account-system"
BACKUP_DIR="/opt/backups/$(date +%Y%m%d_%H%M%S)"

# 创建备份目录
mkdir -p $BACKUP_DIR
echo -e "${YELLOW}创建备份目录: $BACKUP_DIR${NC}"

# 备份当前文件
echo -e "${YELLOW}步骤1: 备份当前文件${NC}"
cp -f $APP_DIR/templates/accounts.html $BACKUP_DIR/ 2>/dev/null || echo "accounts.html 不存在，跳过备份"
cp -f $APP_DIR/static/css/accounts.css $BACKUP_DIR/ 2>/dev/null || echo "accounts.css 不存在，跳过备份"

# 修复CSS文件
echo -e "${YELLOW}步骤2: 创建修复后的accounts.css文件${NC}"
mkdir -p $APP_DIR/static/css

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

/* 工具栏样式 */
.toolbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 25px;
    flex-wrap: wrap;
    gap: 15px;
}

/* 按钮样式 */
.btn {
    padding: 10px 18px;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    border: none;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
}

.btn-primary {
    background-color: #1a73e8;
    color: #fff;
}

.btn-primary:hover {
    background-color: #1765cc;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(26, 115, 232, 0.2);
}

.btn-secondary {
    background-color: #f1f3f4;
    color: #333;
}

.btn-secondary:hover {
    background-color: #e8eaed;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
}

.btn-danger {
    background-color: #ea4335;
    color: #fff;
}

.btn-danger:hover {
    background-color: #d93025;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(234, 67, 53, 0.2);
}

/* 搜索和筛选样式 */
.search-box {
    flex: 1;
    max-width: 300px;
}

.search-box input {
    width: 100%;
    padding: 12px 15px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 14px;
    background-color: #f9f9f9;
    transition: all 0.3s ease;
}

.search-box input:focus {
    outline: none;
    border-color: #1a73e8;
    box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.1);
    background-color: #fff;
}

.filter-box select {
    padding: 12px 15px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 14px;
    background-color: #f9f9f9;
    min-width: 150px;
    transition: all 0.3s ease;
}

.filter-box select:focus {
    outline: none;
    border-color: #1a73e8;
    box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.1);
    background-color: #fff;
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
    overflow: visible !important;
    text-overflow: clip !important;
    padding: 5px !important;
    min-width: 280px !important;
}

.data-table th {
    font-weight: 600;
    color: #444;
    background-color: #f8f9fa;
    border-bottom: 2px solid #e0e0e0;
    position: sticky;
    top: 0;
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

.data-table td {
    border-bottom: 1px solid #eee;
    color: #555;
}

.data-table tbody tr:hover {
    background-color: #f5f9ff;
    transition: background-color 0.2s;
}

/* 状态标签样式 */
.status-badge {
    display: inline-block;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    text-align: center;
    min-width: 80px;
}

.未售 {
    background-color: #e6f4ea;
    color: #137333;
}

.已售 {
    background-color: #fce8e6;
    color: #c5221f;
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

/* 分页样式 */
.pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 20px;
    margin-top: 30px;
}

.page-btn {
    padding: 10px 18px;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    border: none;
    background-color: #f1f3f4;
    color: #333;
    transition: all 0.3s ease;
}

.page-btn:hover:not(:disabled) {
    background-color: #e8eaed;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
}

.page-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

.page-info {
    font-size: 14px;
    color: #555;
}
EOF

# 确保HTML文件中的操作按钮结构正确
echo -e "${YELLOW}步骤3: 检查HTML文件中的操作按钮结构${NC}"
mkdir -p $APP_DIR/templates

# 检查HTML文件是否存在
if [ -f "$APP_DIR/templates/accounts.html" ]; then
    # 检查是否包含action-buttons类
    if ! grep -q "class=\"action-buttons\"" "$APP_DIR/templates/accounts.html"; then
        echo -e "${YELLOW}修复HTML中的操作按钮结构...${NC}"
        # 创建临时文件
        TMP_FILE=$(mktemp)
        
        # 使用sed修复HTML结构
        sed 's/<td class="actions">/<td class="actions">\n                                <div class="action-buttons">/' "$APP_DIR/templates/accounts.html" > $TMP_FILE
        sed -i 's/<\/button>\n                                    {% if account.status/\n                                    {% if account.status/' $TMP_FILE
        sed -i 's/{% endif %}\n                            <\/td>/{% endif %}\n                                <\/div>\n                            <\/td>/' $TMP_FILE
        
        # 将修复后的内容移回原文件
        mv $TMP_FILE "$APP_DIR/templates/accounts.html"
    else
        echo -e "${GREEN}HTML文件中的操作按钮结构已正确${NC}"
    fi
else
    echo -e "${RED}HTML文件不存在: $APP_DIR/templates/accounts.html${NC}"
fi

# 修复Nginx配置
echo -e "${YELLOW}步骤4: 修复Nginx配置${NC}"
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
echo -e "${YELLOW}步骤5: 重启应用${NC}"
supervisorctl restart tiktok_account_system

# 清除浏览器缓存提示
echo -e "${YELLOW}步骤6: 完成${NC}"
echo -e "${GREEN}修复已完成!${NC}"
echo -e "${YELLOW}请在浏览器中按Ctrl+F5强制刷新页面，清除缓存后查看效果${NC}"
echo -e "${BLUE}================================================${NC}"
