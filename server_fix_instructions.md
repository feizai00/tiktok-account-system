# 服务器修复指南

## 问题描述

1. 账号管理页面的操作按钮不显示
2. Nginx配置中的端口设置错误（配置为5000端口，但应用实际运行在5001端口）

## 修复步骤

### 方法一：使用修复脚本（推荐）

1. 登录服务器
   ```bash
   ssh root@141.11.87.103
   ```

2. 下载修复脚本
   ```bash
   cd /tmp
   wget https://raw.githubusercontent.com/feizai00/tiktok-account-system/fix-account-buttons/fix_buttons_part2.sh
   chmod +x fix_buttons_part2.sh
   ```

3. 执行修复脚本
   ```bash
   sudo ./fix_buttons_part2.sh
   ```

4. 验证修复结果
   - 打开浏览器访问 http://141.11.87.103/accounts
   - 按 Ctrl+F5 强制刷新页面，清除浏览器缓存
   - 检查操作按钮是否正常显示

### 方法二：手动修复

如果脚本执行失败，可以按照以下步骤手动修复：

1. 修复CSS文件
   ```bash
   # 备份当前文件
   mkdir -p /opt/backups/$(date +%Y%m%d_%H%M%S)
   cp -f /opt/tiktok-account-system/static/css/accounts.css /opt/backups/$(date +%Y%m%d_%H%M%S)/
   
   # 编辑CSS文件
   nano /opt/tiktok-account-system/static/css/accounts.css
   ```

   在CSS文件中添加或修改以下内容：
   ```css
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
   
   /* 修复列宽设置 */
   .data-table th:nth-child(15) { width: 30%; } /* 操作 */
   ```

2. 修复Nginx配置
   ```bash
   # 备份Nginx配置
   cp /etc/nginx/sites-available/tiktok_account_system /etc/nginx/sites-available/tiktok_account_system.bak
   
   # 编辑Nginx配置
   nano /etc/nginx/sites-available/tiktok_account_system
   ```

   将以下行：
   ```
   proxy_pass http://127.0.0.1:5000;
   ```
   
   修改为：
   ```
   proxy_pass http://127.0.0.1:5001;
   ```

3. 测试并重启Nginx
   ```bash
   # 测试配置
   nginx -t
   
   # 如果测试成功，重启Nginx
   systemctl restart nginx
   ```

4. 重启应用
   ```bash
   supervisorctl restart tiktok_account_system
   ```

## 验证修复

1. 检查Nginx配置
   ```bash
   grep -n "proxy_pass" /etc/nginx/sites-available/tiktok_account_system
   ```
   应该显示 `proxy_pass http://127.0.0.1:5001;`

2. 检查应用状态
   ```bash
   supervisorctl status tiktok_account_system
   ```
   应该显示 `RUNNING`

3. 检查网站访问
   - 打开浏览器访问 http://141.11.87.103/accounts
   - 按 Ctrl+F5 强制刷新页面
   - 验证操作按钮是否正常显示

## 故障排除

如果修复后仍然有问题：

1. 检查应用日志
   ```bash
   tail -f /var/log/tiktok_account_system/error.log
   ```

2. 检查Nginx日志
   ```bash
   tail -f /var/log/nginx/tiktok_error.log
   ```

3. 检查浏览器控制台
   - 在浏览器中按F12打开开发者工具
   - 切换到Console标签页
   - 检查是否有JavaScript错误
   - 切换到Network标签页，检查CSS文件是否正确加载

4. 清除浏览器缓存
   - Chrome: Ctrl+Shift+Delete，选择"缓存的图片和文件"，点击"清除数据"
   - Firefox: Ctrl+Shift+Delete，选择"缓存"，点击"立即清除"
   - Safari: Command+Option+E

如果以上方法都不能解决问题，请联系系统管理员获取进一步帮助。
