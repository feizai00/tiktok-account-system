# TikTok账号管理系统 - 部署指南

本文档提供了TikTok账号管理系统的部署说明，包括传统部署和Docker部署两种方式。

## 系统要求

### 传统部署
- 操作系统：Ubuntu/Debian/CentOS/RHEL/Fedora
- Python 3.6+
- Nginx
- Supervisor

### Docker部署
- 操作系统：支持Docker的任何Linux系统
- Docker
- Docker Compose

## 一、传统部署方式

### 1. 准备工作
- 确保服务器可以访问互联网
- 确保有root权限

### 2. 部署步骤

1. 将项目文件上传到服务器

```bash
# 例如使用scp命令
scp -r 账号管理系统V0.0.1 user@your-server-ip:/tmp/
```

2. 登录到服务器，进入项目目录

```bash
ssh user@your-server-ip
cd /tmp/账号管理系统V0.0.1
```

3. 运行部署脚本

```bash
sudo ./deploy.sh
```

4. 部署完成后，可以通过服务器IP地址访问系统：

```
http://服务器IP
```

### 3. 常见问题排查

- 如果无法访问网站，检查防火墙是否开放了80端口
```bash
sudo ufw status  # Ubuntu/Debian
sudo firewall-cmd --list-all  # CentOS/RHEL
```

- 检查服务状态
```bash
sudo supervisorctl status tiktok_account_system
sudo systemctl status nginx
```

- 查看日志
```bash
sudo tail -f /var/log/tiktok_account_system/error.log
sudo tail -f /var/log/nginx/error.log
```

## 二、Docker部署方式

### 1. 准备工作
- 确保服务器可以访问互联网
- 确保有root权限

### 2. 部署步骤

1. 将项目文件上传到服务器

```bash
# 例如使用scp命令
scp -r 账号管理系统V0.0.1 user@your-server-ip:/tmp/
```

2. 登录到服务器，进入项目目录

```bash
ssh user@your-server-ip
cd /tmp/账号管理系统V0.0.1
```

3. 运行Docker部署脚本

```bash
sudo ./deploy_docker.sh
```

4. 部署完成后，可以通过服务器IP地址访问系统：

```
http://服务器IP
```

### 3. Docker常用命令

```bash
# 查看容器状态
docker-compose ps

# 查看应用日志
docker-compose logs -f

# 重启应用
docker-compose restart

# 停止应用
docker-compose down

# 启动应用
docker-compose up -d
```

### 4. 常见问题排查

- 如果无法访问网站，检查防火墙是否开放了80端口
```bash
sudo ufw status  # Ubuntu/Debian
sudo firewall-cmd --list-all  # CentOS/RHEL
```

- 检查Docker容器状态
```bash
docker ps
docker-compose ps
```

- 查看容器日志
```bash
docker-compose logs -f
```

## 三、HTTPS配置

如需配置HTTPS，请按照以下步骤操作：

### 传统部署方式

1. 安装certbot

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# CentOS/RHEL
sudo yum install certbot python3-certbot-nginx
```

2. 获取SSL证书

```bash
sudo certbot --nginx -d your-domain.com
```

3. 按照提示完成配置

### Docker部署方式

1. 修改nginx.conf文件，添加SSL配置

2. 重新构建并启动容器

```bash
docker-compose down
docker-compose up -d
```

## 四、数据备份

### 备份数据库

```bash
# 传统部署
cp /opt/tiktok_account_system/instance/database.db /backup/database_$(date +%Y%m%d).db

# Docker部署
docker cp tiktok-account-system:/app/instance/database.db /backup/database_$(date +%Y%m%d).db
```

### 定期备份（推荐）

创建定时任务：

```bash
crontab -e
```

添加以下内容（每天凌晨2点备份）：

```
0 2 * * * cp /opt/tiktok_account_system/instance/database.db /backup/database_$(date +%Y%m%d).db
```

## 五、系统更新

### 传统部署方式

1. 备份数据库
2. 上传新版本代码
3. 重新运行部署脚本

### Docker部署方式

1. 备份数据库
2. 上传新版本代码
3. 重新运行Docker部署脚本

## 六、联系支持

如果在部署过程中遇到任何问题，请联系系统管理员或开发团队。
