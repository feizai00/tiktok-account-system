#!/bin/bash
# 服务器修复命令

# 这些命令需要在服务器上执行

# 1. 下载修复脚本（从fix-account-buttons分支）
wget https://raw.githubusercontent.com/feizai00/tiktok-account-system/fix-account-buttons/deploy_fixes.sh

# 2. 添加执行权限
chmod +x deploy_fixes.sh

# 3. 执行部署修复脚本
sudo ./deploy_fixes.sh

# 如果上面的脚本不工作，请手动执行以下步骤：

# 4. 备份当前文件
BACKUP_DIR="/opt/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR
cp -r /opt/tiktok-account-system/static/css/accounts.css $BACKUP_DIR/
cp -r /opt/tiktok-account-system/templates/accounts.html $BACKUP_DIR/
cp -r /opt/tiktok-account-system/static/js/accounts.js $BACKUP_DIR/
cp /etc/nginx/sites-available/tiktok_account_system $BACKUP_DIR/

# 5. 下载修复后的文件
cd /tmp
wget https://raw.githubusercontent.com/feizai00/tiktok-account-system/fix-account-buttons/static/css/accounts.css
wget https://raw.githubusercontent.com/feizai00/tiktok-account-system/fix-account-buttons/templates/accounts.html
wget https://raw.githubusercontent.com/feizai00/tiktok-account-system/fix-account-buttons/static/js/accounts.js

# 6. 复制文件到正确位置
sudo cp accounts.css /opt/tiktok-account-system/static/css/
sudo cp accounts.html /opt/tiktok-account-system/templates/
sudo cp accounts.js /opt/tiktok-account-system/static/js/

# 7. 修复Nginx配置
sudo sed -i 's/proxy_pass http:\/\/127.0.0.1:5000;/proxy_pass http:\/\/127.0.0.1:5001;/g' /etc/nginx/sites-available/tiktok_account_system

# 8. 测试Nginx配置
sudo nginx -t

# 9. 重启服务
sudo systemctl restart nginx
sudo supervisorctl restart tiktok_account_system

# 10. 清除浏览器缓存
echo "请在浏览器中按Ctrl+F5强制刷新页面"
