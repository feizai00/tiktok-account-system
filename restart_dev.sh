#!/bin/bash
# TikTok账号管理系统 - 开发环境重启脚本

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    TikTok账号管理系统 - 开发环境重启    ${NC}"
echo -e "${BLUE}================================================${NC}"

# 获取当前目录
CURRENT_DIR=$(pwd)

echo -e "${YELLOW}步骤1: 停止当前运行的Flask服务${NC}"
# 查找并终止Flask进程
PID=$(ps aux | grep "python app.py" | grep -v grep | awk '{print $2}')
if [ ! -z "$PID" ]; then
    echo -e "${YELLOW}终止进程 $PID${NC}"
    kill -9 $PID
else
    echo -e "${YELLOW}没有找到运行中的Flask进程${NC}"
fi

echo -e "${YELLOW}步骤2: 删除现有数据库${NC}"
if [ -f "$CURRENT_DIR/database.db" ]; then
    rm -f "$CURRENT_DIR/database.db"
    echo -e "${GREEN}数据库已删除${NC}"
else
    echo -e "${YELLOW}数据库文件不存在${NC}"
fi

echo -e "${YELLOW}步骤3: 启动Flask服务${NC}"
python app.py &

echo -e "${YELLOW}等待服务启动...${NC}"
sleep 3

echo -e "${GREEN}开发服务已重启!${NC}"
echo -e "${YELLOW}访问地址: http://127.0.0.1:5001${NC}"
echo -e "${BLUE}================================================${NC}"
