# GitHub上传指南

本文档提供了将代码上传到GitHub的详细步骤。

## 最新更新（2025-03-08）

我们创建了一个新分支 `fix-account-buttons` 来修复账号管理页面操作按钮不显示的问题。该分支包含以下更改：

- 修复了CSS样式问题，确保操作列有足够的宽度
- 调整了表格列宽，为操作列分配了更多空间
- 修改了HTML结构，使用div包装按钮，使其更加灵活
- 优化了按钮样式，使其更加紧凑
- 更新了文档（README.md, CHANGELOG.md, troubleshooting.md）

要将这些更改推送到GitHub，请按照以下步骤操作：

## 方法1：使用GitHub Desktop（推荐）

1. 下载并安装 [GitHub Desktop](https://desktop.github.com/)
2. 打开GitHub Desktop并登录您的GitHub账户
3. 点击 "Add an Existing Repository from your Hard Drive"
4. 浏览并选择项目文件夹：`/Users/feizai/Desktop/项目文件/肥仔/tiktok项目/开发区/账号管理系统V0.0.1`
5. 确认仓库设置并点击 "Add Repository"
6. 点击 "Publish repository" 按钮
7. 确认仓库名称为 `tiktok-account-system`，然后点击 "Publish Repository"

## 方法2：使用个人访问令牌（Personal Access Token）

1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token"（可能需要确认您的密码）
3. 给令牌一个描述性名称，如 "TikTok Account System"
4. 选择权限范围：至少需要选择 "repo" 权限
5. 点击 "Generate token"
6. 复制生成的令牌（这是唯一一次可以看到完整令牌的机会）
7. 打开终端，执行以下命令：

```bash
cd "/Users/feizai/Desktop/项目文件/肥仔/tiktok项目/开发区/账号管理系统V0.0.1"

# 推送新分支到远程仓库
git push -u origin fix-account-buttons

# 如果您想将更改合并到main分支，请执行以下命令：
git checkout main
git merge fix-account-buttons
git push origin main
```

8. 当提示输入用户名和密码时，输入您的GitHub用户名和刚才生成的个人访问令牌（而不是您的GitHub密码）

## 合并分支到main分支

如果您已经测试并确认了分支中的更改是正确的，可以将其合并到main分支：

1. 在GitHub上创建一个Pull Request：
   - 访问您的GitHub仓库
   - 点击 "Pull requests" 标签
   - 点击 "New pull request" 按钮
   - 选择基础分支（main）和比较分支（fix-account-buttons）
   - 点击 "Create pull request" 按钮
   - 添加标题和描述，然后再次点击 "Create pull request" 按钮

2. 合并Pull Request：
   - 在Pull Request页面上，如果没有冲突，您将看到一个绿色的 "Merge pull request" 按钮
   - 点击该按钮，然后点击 "Confirm merge" 按钮

3. 或者在本地合并：

```bash
git checkout main
git merge fix-account-buttons
git push origin main
```

## 方法3：设置SSH密钥

1. 检查是否已有SSH密钥：

```bash
ls -la ~/.ssh
```

2. 如果没有，生成新的SSH密钥：

```bash
ssh-keygen -t ed25519 -C "您的GitHub邮箱地址"
```

3. 将SSH密钥添加到ssh-agent：

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

4. 复制公钥：

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

5. 访问 https://github.com/settings/keys
6. 点击 "New SSH key"
7. 给密钥一个标题，如 "My Mac"
8. 粘贴公钥到 "Key" 字段
9. 点击 "Add SSH key"
10. 设置仓库使用SSH URL：

```bash
cd "/Users/feizai/Desktop/项目文件/肥仔/tiktok项目/开发区/账号管理系统V0.0.1"
git remote set-url origin git@github.com:feizaiNW/tiktok-account-system.git
git push -u origin main
```

## 注意事项

- 确保您的GitHub账户已验证电子邮件地址
- 确保您有正确的仓库访问权限
- 如果使用的是公司或学校网络，可能需要配置代理设置
