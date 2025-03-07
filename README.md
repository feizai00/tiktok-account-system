# TikTok账号管理系统 (v0.0.2)

这是一个基于Flask的TikTok账号管理系统，用于管理和销售TikTok账号。系统提供了完整的账号管理、数据统计和财务报表功能，支持传统部署和Docker容器化部署。

当前版本: v0.0.2-deploy (2025年3月8日更新)

**GitHub仓库**: [https://github.com/feizai00/tiktok-account-system](https://github.com/feizai00/tiktok-account-system)

## 功能特点

### 控制台
- 账号总数、已售账号、本月收入、账号转化率等关键指标展示
- 账号销售趋势图表
- 月度收入统计图表
- 最近交易记录表格

### 账号管理
- 账号列表展示，支持分页
- 添加、编辑、删除账号功能
- 账号出售功能，自动创建交易记录
- 全字段搜索功能，支持所有账号属性搜索
- 按状态筛选账号
- 完整展示账号信息：用户名、密码、号码/邮箱、注册时间、注册地区、橱窗功能、粉丝数、点赞数、账号类型、地区、价格和状态

### 其他
- 响应式设计，适配不同设备
- RESTful API接口
- 模块化设计，易于扩展

## 技术栈

- 前端：HTML, CSS, JavaScript, Chart.js
- 后端：Python, Flask, SQLAlchemy
- 数据库：SQLite

## 快速安装

### 方法1：Linux服务器一键安装

```bash
# 下载并运行安装脚本
curl -sSL https://raw.githubusercontent.com/feizai00/tiktok-account-system/main/install.sh | sudo bash
```

### 方法2：手动安装

```bash
# 克隆仓库
git clone https://github.com/feizai00/tiktok-account-system.git
cd tiktok-account-system

# 安装依赖
pip install -r requirements.txt

# 运行应用
python app.py
```

### 方法3：Docker部署

```bash
# 克隆仓库
git clone https://github.com/feizai00/tiktok-account-system.git
cd tiktok-account-system

# 使用Docker Compose构建和运行
docker-compose up -d
```

应用将在 `http://服务器IP地址` 或本地开发环境的 `http://127.0.0.1:5000` 访问

## 文档

- [部署指南](DEPLOY.md)：详细的部署说明，包括传统部署和Docker部署
- [故障排除](troubleshooting.md)：常见问题和解决方案
- [更新日志](CHANGELOG.md)：版本历史和功能变更记录
- [进度报告](PROGRESS.md)：项目开发进度和计划

## 项目结构

```
账号管理系统V0.0.1/
├── app.py                  # 主应用文件
├── run.py                  # 运行脚本
├── requirements.txt        # 依赖包列表
├── PROGRESS.md             # 项目进度文档
├── CHANGELOG.md            # 更新日志
├── models/                 # 数据模型
│   ├── __init__.py
│   ├── account.py          # 账号模型
│   └── transaction.py      # 交易模型
├── static/                 # 静态资源
│   ├── css/
│   │   ├── style.css       # 全局样式文件
│   │   └── accounts.css    # 账号管理页面样式
│   ├── js/                 # JavaScript文件
│   │   └── accounts.js     # 账号管理页面脚本
│   └── img/                # 图标和图片
│       ├── logo.svg
│       ├── dashboard.svg
│       ├── accounts.svg
│       ├── finance.svg
│       └── user.svg
└── templates/              # HTML模板
    ├── index.html          # 控制台页面模板
    └── accounts.html       # 账号管理页面模板
```

## 数据库结构

### Account表
- id: 主键
- username: 账号用户名
- password: 账号密码
- contact: 号码/邮箱
- api_password: 邮箱密码/API密码
- register_date: 注册时间
- register_region: 注册地区
- has_showcase: 橱窗功能（有/无）
- followers: 粉丝数
- likes: 点赞数
- total_views: 总播放量
- total_comments: 总评论数
- total_shares: 总转发数
- total_favorites: 总收藏数
- region: 地区
- account_type: 账号类型（小账号/中账号/大账号/VIP账号/普通账号）
- status: 账号状态（已售/未售）
- price: 账号价格
- created_date: 创建日期
- auto_refresh: 自动刷新标志

### Transaction表
- id: 主键
- order_number: 订单号
- account_id: 关联的账号ID
- amount: 交易金额
- transaction_date: 交易日期
- status: 交易状态（完成/取消/处理中）
