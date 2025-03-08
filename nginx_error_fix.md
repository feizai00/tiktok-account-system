# Nginx错误修复指南

## 问题描述

在服务器部署后，Nginx错误日志中出现以下错误：

```
2025/03/08 02:19:47 [error] 299471#299471: *1 connect() failed (111: Connection refused) while connecting to upstream, client: 2.59.182.171, server: _, request: "GET / HTTP/1.1", upstream: "http://127.0.0.1:5000/", host: "141.11.87.103"
2025/03/08 02:19:48 [error] 299471#299471: *1 connect() failed (111: Connection refused) while connecting to upstream, client: 2.59.182.171, server: _, request: "GET / HTTP/1.1", upstream: "http://127.0.0.1:5000/", host: "141.11.87.103"
```

## 问题分析

1. **端口不匹配**：
   - Nginx配置中设置为代理到 `http://127.0.0.1:5000/`
   - 但Flask应用实际运行在端口 `5001` 上（在app.py中配置）

2. **连接被拒绝**：
   - 错误代码 `111: Connection refused` 表明没有服务在端口5000上监听

## 解决方案

我们创建了一个修复脚本 `fix_nginx_port.sh`，它会执行以下操作：

1. 备份当前Nginx配置
2. 更新Nginx配置，将代理端口从5000改为5001
3. 确保Nginx配置链接正确设置
4. 检查并更新Supervisor配置中的端口设置
5. 测试Nginx配置
6. 重启Supervisor和Nginx服务
7. 检查服务状态和端口监听情况

## 使用方法

在服务器上执行以下命令：

```bash
# 下载修复脚本
wget https://raw.githubusercontent.com/feizai00/tiktok-account-system/fix-account-buttons/fix_nginx_port.sh

# 添加执行权限
chmod +x fix_nginx_port.sh

# 执行脚本
sudo ./fix_nginx_port.sh
```

## 预防措施

为避免将来出现类似问题，请确保：

1. Nginx配置中的代理端口与Flask应用运行的端口一致
2. 在更新应用时，同步更新所有相关配置
3. 部署后立即测试应用的可访问性
4. 定期检查错误日志，及时发现问题

## 相关文件

- **app.py**: 设置Flask应用运行在端口5001
- **nginx_config.conf**: Nginx配置文件
- **emergency_fix.sh**: 紧急修复脚本，包含Supervisor配置
- **fix_nginx_port.sh**: 专门用于修复Nginx端口问题的脚本
