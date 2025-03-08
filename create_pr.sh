#!/bin/bash
# 创建Pull Request脚本

# 设置变量
REPO_URL="https://github.com/feizai00/tiktok-account-system"
BRANCH="fix-account-buttons"
BASE_BRANCH="main"
PR_TITLE="修复账号管理页面操作按钮显示和Nginx端口配置问题"
PR_BODY="## 修复内容

### 1. 账号管理页面操作按钮不显示问题
- 修复了CSS样式问题，确保操作列有足够的宽度
- 调整了表格列宽，为操作列分配了更多空间
- 修改了HTML结构，使用div包装按钮，使其更加灵活
- 优化了按钮样式，使其更加紧凑

### 2. Nginx端口配置不匹配问题
- 修复Nginx配置中的端口设置，将代理端口从5000改为5001
- 添加了自动检测和修复端口不匹配问题的脚本
- 优化了服务器部署流程，确保配置一致性

### 3. 文档更新
- 更新了README.md，添加了最新版本信息和变更日志
- 更新了CHANGELOG.md，记录了v0.0.3版本的所有更改
- 更新了troubleshooting.md，添加了问题解决方案
- 添加了restart_dev.sh脚本，用于在开发环境中快速重启应用
- 添加了deploy_fixes.sh脚本，用于在服务器上部署修复

## 测试情况
- 本地测试通过，按钮显示正常
- 服务器部署测试通过，Nginx配置正确"

# 打开浏览器创建PR
PR_URL="${REPO_URL}/compare/${BASE_BRANCH}...${BRANCH}?expand=1&title=${PR_TITLE}"

echo "正在打开浏览器创建Pull Request..."
open "$PR_URL"

echo "请在浏览器中完成以下步骤:"
echo "1. 检查标题: \"${PR_TITLE}\""
echo "2. 粘贴以下内容到描述框中:"
echo "$PR_BODY"
echo "3. 点击 \"Create pull request\" 按钮"
echo "4. 等待CI检查完成后，如果没有冲突，点击 \"Merge pull request\" 按钮"
echo "5. 确认合并"
