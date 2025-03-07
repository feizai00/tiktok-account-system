# TikTok账号管理系统部署故障排除指南

如果您在部署过程中遇到问题，请参考以下常见问题及解决方案。

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

**解决方案**：

1. **手动安装依赖**：
   ```bash
   cd /opt/tiktok-account-system
   source venv/bin/activate
   pip install Flask==2.0.1 Flask-SQLAlchemy==2.5.1 matplotlib==3.4.3 pandas==1.3.3 Pillow==8.3.2 openpyxl==3.0.9 XlsxWriter==3.0.2
   ```

2. **检查Python版本**：
   ```bash
   python --version
   # 确保版本为3.6或更高
   ```

3. **更新pip**：
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
