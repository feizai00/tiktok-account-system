#!/bin/bash
# 直接修复账号管理页面按钮显示问题的脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    直接修复账号管理页面按钮显示问题    ${NC}"
echo -e "${BLUE}================================================${NC}"

# 设置应用目录
APP_DIR="/Users/feizai/Desktop/项目文件/肥仔/tiktok项目/开发区/账号管理系统V0.0.1"
BACKUP_DIR="$APP_DIR/backups/$(date +%Y%m%d_%H%M%S)"

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
    sed -i '' '/th:nth-child(13)/a\\
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

# 修复HTML文件中的操作按钮
echo -e "${YELLOW}步骤3: 检查accounts.html文件中的操作按钮...${NC}"
if ! grep -q "class=\"action-buttons\"" "$APP_DIR/templates/accounts.html"; then
    echo -e "${YELLOW}修复HTML中的操作按钮结构...${NC}"
    sed -i '' 's/<td class="actions">/<td class="actions">\n                                <div class="action-buttons">/' "$APP_DIR/templates/accounts.html"
    sed -i '' 's/<\/button>\n                                    {% if account.status/\n                                    {% if account.status/' "$APP_DIR/templates/accounts.html"
    sed -i '' 's/{% endif %}\n                            <\/td>/{% endif %}\n                                <\/div>\n                            <\/td>/' "$APP_DIR/templates/accounts.html"
fi

# 检查是否有重复的CSS规则
echo -e "${YELLOW}步骤4: 检查并删除重复的CSS规则...${NC}"
sed -i '' '/\.sell-btn {/,/}/{ /\.sell-btn {/{x;/./p;x;}; /}/h; }' "$APP_DIR/static/css/accounts.css"

echo -e "${GREEN}修复完成!${NC}"
echo -e "${YELLOW}请刷新浏览器缓存查看效果 (按Ctrl+F5)${NC}"
echo -e "${BLUE}================================================${NC}"
