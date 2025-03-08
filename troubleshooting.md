# TikTok账号管理系统部署故障排除指南

如果您在部署过程中遇到问题，请参考以下常见问题及解决方案。

## 最新更新

### 2025-03-08 修复账号管理页面操作按钮不显示问题

**问题描述**：
在账号管理页面中，操作列的按钮（查看、编辑、删除、刷新等）不显示或显示不完整。

**解决方案**：
1. 修复了CSS样式问题，确保操作列有足够的宽度
2. 调整了表格列宽，为操作列分配了更多空间
3. 修改了HTML结构，使用div包装按钮，使其更加灵活
4. 优化了按钮样式，使其更加紧凑
5. 确保了所有按钮（查看、编辑、删除、刷新、出售）都有正确的样式

**应用更新**：
```bash
# 重启开发服务器
cd /path/to/tiktok-account-system
./restart_dev.sh

# 或在生产环境中
sudo supervisorctl restart tiktok_account_system
sudo systemctl restart nginx
```

## 常见问题

### 1. 502 Bad Gateway 错误

**可能原因**：
- Flask应用未正确启动
- Supervisor配置错误
- 权限问题
- 依赖包安装失败

**解决方案**：

1. **检查应用日志**：
   ```bash
   sudo cat /var/log/tiktok_account_system/error.log
   ```

2. **检查Supervisor状态**：
   ```bash
   sudo supervisorctl status tiktok_account_system
   ```

3. **手动启动应用测试**：
   ```bash
   cd /opt/tiktok-account-system
   source venv/bin/activate
   python app.py
   ```

4. **重启服务**：
   ```bash
   sudo supervisorctl restart tiktok_account_system
   sudo systemctl restart nginx
   ```

5. **检查权限**：
   ```bash
   sudo chown -R www-data:www-data /opt/tiktok-account-system
   sudo chmod -R 755 /opt/tiktok-account-system
   ```

### 2. 依赖包安装错误

**可能原因**：
- requirements.txt中包含不存在的包
- 网络连接问题
- Python版本不兼容
- 依赖包版本冲突

**解决方案**：

1. **完全重置环境**：
   ```bash
   cd /opt/tiktok-account-system
   source venv/bin/activate
   
   # 卸载所有包
   pip freeze | xargs pip uninstall -y
   
   # 重新安装所有依赖
   pip install -r requirements.txt
   ```

2. **手动安装关键依赖**：
   ```bash
   cd /opt/tiktok-account-system
   source venv/bin/activate
   
   # 先卸载可能冲突的包
   pip uninstall -y werkzeug sqlalchemy flask-sqlalchemy
   
   # 安装指定版本
   pip install Flask==2.0.1 Werkzeug==2.0.3 Jinja2==3.0.3 itsdangerous==2.0.1 click==8.0.4
   pip install SQLAlchemy==1.4.46 Flask-SQLAlchemy==2.5.1
   pip install requests==2.28.2
   ```

3. **解决常见错误**：

   - **Werkzeug url_quote 错误**：
     ```bash
     # 如果遇到 "ImportError: cannot import name 'url_quote' from 'werkzeug.urls'" 错误
     pip uninstall -y werkzeug
     pip install werkzeug==2.0.3
     ```
   
   - **SQLAlchemy __all__ 属性错误**：
     ```bash
     # 如果遇到 "AttributeError: module 'sqlalchemy' has no attribute '__all__'" 错误
     pip uninstall -y sqlalchemy flask-sqlalchemy
     pip install SQLAlchemy==1.4.46
     pip install Flask-SQLAlchemy==2.5.1
     ```

4. **检查Python版本**：
   ```bash
   python --version
   # 确保版本为3.6或更高
   ```

5. **更新pip**：
   ```bash
   pip install --upgrade pip
   ```

### 3. 静态文件404错误

**可能原因**：
- Nginx配置中静态文件路径错误
- 静态文件权限问题

**解决方案**：

1. **检查静态文件路径**：
   ```bash
   ls -la /opt/tiktok-account-system/static
   ```

2. **修复Nginx配置**：
   ```bash
   sudo nano /etc/nginx/sites-available/tiktok_account_system
   # 确保静态文件路径正确
   ```

3. **设置正确权限**：
   ```bash
   sudo chmod -R 755 /opt/tiktok-account-system/static
   ```

## 高级故障排除

### 检查端口占用

```bash
sudo netstat -tulpn | grep 5000
```

### 检查防火墙设置

```bash
# Ubuntu/Debian
sudo ufw status

# CentOS/RHEL
sudo firewall-cmd --list-all
```

### 检查SELinux状态（CentOS/RHEL）

```bash
sudo sestatus
# 如果启用，可能需要设置正确的上下文
sudo setenforce 0  # 临时禁用
```

### 检查系统日志

```bash
sudo journalctl -u nginx
sudo journalctl -u supervisor
```

## 联系支持

如果您尝试了上述解决方案后问题仍然存在，请联系系统管理员或在GitHub仓库提交Issue：

[https://github.com/feizai00/tiktok-account-system/issues](https://github.com/feizai00/tiktok-account-system/issues)
