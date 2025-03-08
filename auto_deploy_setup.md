# 自动部署设置指南

本文档提供了在服务器上设置自动部署TikTok账号管理系统的详细步骤。

## 方法一：使用Cron定时任务

1. **上传自动部署脚本**：
   ```bash
   # 登录到服务器
   ssh root@141.11.87.103
   
   # 创建脚本目录
   mkdir -p /opt/scripts
   
   # 下载自动部署脚本
   wget -O /opt/scripts/auto_deploy.sh https://raw.githubusercontent.com/feizai00/tiktok-account-system/main/auto_deploy.sh
   
   # 添加执行权限
   chmod +x /opt/scripts/auto_deploy.sh
   ```

2. **设置Cron定时任务**：
   ```bash
   # 编辑crontab
   crontab -e
   
   # 添加以下行（每天凌晨2点执行）
   0 2 * * * /opt/scripts/auto_deploy.sh >> /var/log/tiktok_auto_deploy.log 2>&1
   
   # 或者每小时执行一次
   # 0 * * * * /opt/scripts/auto_deploy.sh >> /var/log/tiktok_auto_deploy.log 2>&1
   ```

3. **测试自动部署脚本**：
   ```bash
   # 手动执行脚本测试
   /opt/scripts/auto_deploy.sh
   
   # 查看日志
   tail -f /var/log/tiktok_auto_deploy.log
   ```

## 方法二：使用GitHub Webhooks（推荐）

使用GitHub Webhooks可以在代码推送到仓库后自动触发部署，实现真正的持续集成/持续部署(CI/CD)。

1. **安装必要的软件**：
   ```bash
   # 安装webhook处理程序
   apt-get update
   apt-get install -y webhook
   ```

2. **创建webhook配置文件**：
   ```bash
   # 创建配置目录
   mkdir -p /etc/webhook
   
   # 创建配置文件
   cat > /etc/webhook/hooks.json << 'EOF'
   [
     {
       "id": "tiktok-deploy",
       "execute-command": "/opt/scripts/auto_deploy.sh",
       "command-working-directory": "/opt/tiktok-account-system",
       "response-message": "Deploying TikTok Account System...",
       "trigger-rule": {
         "match": {
           "type": "payload-hash-sha1",
           "secret": "YOUR_SECRET_HERE",
           "parameter": {
             "source": "header",
             "name": "X-Hub-Signature"
           }
         }
       }
     }
   ]
   EOF
   
   # 替换YOUR_SECRET_HERE为您的密钥
   # 生成随机密钥：
   # openssl rand -hex 20
   ```

3. **创建Systemd服务**：
   ```bash
   # 创建服务文件
   cat > /etc/systemd/system/webhook.service << 'EOF'
   [Unit]
   Description=GitHub webhook
   After=network.target
   
   [Service]
   ExecStart=/usr/bin/webhook -hooks /etc/webhook/hooks.json -verbose
   Restart=always
   
   [Install]
   WantedBy=multi-user.target
   EOF
   
   # 启动服务
   systemctl daemon-reload
   systemctl enable webhook
   systemctl start webhook
   ```

4. **配置GitHub Webhook**：
   - 访问您的GitHub仓库
   - 点击 "Settings" > "Webhooks" > "Add webhook"
   - 设置 Payload URL: `http://141.11.87.103:9000/hooks/tiktok-deploy`
   - 设置 Content type: `application/json`
   - 设置 Secret: 与hooks.json中相同的密钥
   - 选择 "Just the push event"
   - 勾选 "Active"
   - 点击 "Add webhook"

5. **配置Nginx反向代理（可选但推荐）**：
   ```bash
   # 创建Nginx配置
   cat > /etc/nginx/sites-available/webhook << 'EOF'
   server {
       listen 80;
       server_name webhook.yourdomain.com;
   
       location / {
           proxy_pass http://localhost:9000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   EOF
   
   # 启用配置
   ln -s /etc/nginx/sites-available/webhook /etc/nginx/sites-enabled/
   nginx -t
   systemctl restart nginx
   ```

6. **测试Webhook**：
   - 在本地对仓库进行更改并推送
   - 查看webhook日志：`journalctl -u webhook -f`
   - 查看部署日志：`tail -f /var/log/tiktok_auto_deploy.log`

## 安全建议

1. **使用HTTPS**：如果直接暴露webhook，强烈建议使用HTTPS
2. **限制IP**：在Nginx或防火墙层面限制只允许GitHub的IP访问webhook
3. **定期备份**：确保系统定期备份，以便在部署失败时能够恢复
4. **监控**：设置监控和告警，在部署失败时及时通知管理员

## 故障排除

如果自动部署失败，请检查以下几点：

1. 查看部署日志：`tail -f /var/log/tiktok_auto_deploy.log`
2. 检查应用状态：`supervisorctl status tiktok_account_system`
3. 检查Nginx状态：`systemctl status nginx`
4. 检查webhook状态：`systemctl status webhook`
5. 检查GitHub webhook设置和传递历史
