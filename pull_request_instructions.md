# 创建Pull Request指南

## 通过GitHub Web界面创建Pull Request

1. 访问GitHub仓库页面：https://github.com/feizai00/tiktok-account-system

2. 点击"Pull requests"标签

3. 点击绿色的"New pull request"按钮

4. 在"Compare changes"页面：
   - 确保"base"分支是"main"
   - 确保"compare"分支是"fix-account-buttons"

5. 点击"Create pull request"按钮

6. 填写Pull Request信息：
   - 标题：`修复账号管理页面操作按钮显示和Nginx端口配置问题`
   - 描述：
   ```
   ## 修复内容

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

   ## 测试情况
   - 本地测试通过，按钮显示正常
   - 服务器部署测试通过，Nginx配置正确
   ```

7. 点击"Create pull request"按钮完成创建

## 通过命令行创建Pull Request（需要安装GitHub CLI）

如果您已安装GitHub CLI，可以使用以下命令：

```bash
# 安装GitHub CLI（如果尚未安装）
brew install gh

# 登录GitHub
gh auth login

# 创建Pull Request
cd /Users/feizai/Desktop/项目文件/肥仔/tiktok项目/开发区/账号管理系统V0.0.1
gh pr create --title "修复账号管理页面操作按钮显示和Nginx端口配置问题" --body "详细描述见PR模板" --base main --head fix-account-buttons
```

## 合并Pull Request

1. 在Pull Request页面上，如果没有冲突，您将看到一个绿色的"Merge pull request"按钮
2. 点击该按钮，然后点击"Confirm merge"按钮
3. 合并完成后，可以删除分支（可选）
