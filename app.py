from flask import Flask, render_template, request, jsonify, redirect, url_for, Response
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta
import json
import os
import uuid
import csv
import io
import random
from sqlalchemy import extract, func
from sqlalchemy.sql import text
from services.tiktok_api import TikTokAPI

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# 导入模型并初始化
from models.account import Account
from models.transaction import Transaction

# 初始化模型
AccountModel = Account.init_model(db)
TransactionModel = Transaction.init_model(db, Account)

@app.route('/')
def index():
    # 获取统计数据
    total_accounts = AccountModel.query.count()
    sold_accounts = AccountModel.query.filter_by(status='已售').count()
    
    # 计算本月收入
    current_month = datetime.now().month
    current_year = datetime.now().year
    monthly_income = sum([t.amount for t in TransactionModel.query.filter(
        extract('month', TransactionModel.transaction_date) == current_month,
        extract('year', TransactionModel.transaction_date) == current_year
    ).all()])
    
    # 计算转化率
    conversion_rate = (sold_accounts / total_accounts * 100) if total_accounts > 0 else 0
    
    # 获取月度销售趋势数据
    sales_trend = get_sales_trend()
    
    # 获取月度收入统计
    monthly_income_stats = get_monthly_income_stats()
    
    # 获取最近交易记录
    recent_transactions = TransactionModel.query.order_by(TransactionModel.transaction_date.desc()).limit(10).all()
    
    # 获取账号地区分布数据
    region_distribution = get_region_distribution()
    
    return render_template('index.html', 
                          total_accounts=total_accounts,
                          sold_accounts=sold_accounts,
                          monthly_income=monthly_income,
                          conversion_rate=conversion_rate,
                          sales_trend=sales_trend,
                          monthly_income_stats=monthly_income_stats,
                          recent_transactions=recent_transactions,
                          region_distribution=region_distribution)

def get_sales_trend():
    # 模拟获取6个月的销售趋势数据
    return {
        '1月': 150,
        '2月': 230,
        '3月': 220,
        '4月': 210,
        '5月': 140,
        '6月': 150
    }

def get_monthly_income_stats():
    # 模拟获取6个月的收入统计数据
    return {
        '1月': 15000,
        '2月': 23000,
        '3月': 22000,
        '4月': 21000,
        '5月': 14000,
        '6月': 15000
    }

def get_region_distribution():
    # 模拟获取账号地区分布数据
    return {
        '美国': 35,
        '英国': 15,
        '日本': 20,
        '韩国': 12,
        '德国': 8,
        '法国': 5,
        '加拿大': 10,
        '其他': 15
    }

@app.route('/accounts')
def accounts_page():
    page = request.args.get('page', 1, type=int)
    per_page = 10
    
    # 获取分页数据
    pagination = AccountModel.query.order_by(AccountModel.id.desc()).paginate(page=page, per_page=per_page, error_out=False)
    accounts = pagination.items
    total_pages = pagination.pages
    
    return render_template('accounts.html', accounts=accounts, page=page, total_pages=total_pages, per_page=per_page)

@app.route('/finance')
def finance_page():
    # 获取查询参数
    page = request.args.get('page', 1, type=int)
    per_page = 10
    
    # 获取日期范围
    today = datetime.now().date()
    start_date_str = request.args.get('start_date', (today - timedelta(days=30)).isoformat())
    end_date_str = request.args.get('end_date', today.isoformat())
    
    start_date = datetime.fromisoformat(start_date_str)
    end_date = datetime.fromisoformat(end_date_str)
    end_date = datetime.combine(end_date, datetime.max.time())  # 设置为当天的最后时间
    
    # 计算时间范围描述
    days_diff = (end_date.date() - start_date.date()).days
    if days_diff <= 1:
        period_text = "今天"
    elif days_diff <= 7:
        period_text = "本周"
    elif days_diff <= 30:
        period_text = "本月"
    else:
        period_text = f"{start_date.strftime('%Y-%m-%d')} 至 {end_date.strftime('%Y-%m-%d')}"
    
    # 查询交易数据
    transactions_query = TransactionModel.query.filter(
        TransactionModel.transaction_date >= start_date,
        TransactionModel.transaction_date <= end_date
    ).order_by(TransactionModel.transaction_date.desc())
    
    # 分页
    pagination = transactions_query.paginate(page=page, per_page=per_page, error_out=False)
    transactions = pagination.items
    total_pages = pagination.pages
    
    # 计算汇总指标
    total_income = db.session.query(func.sum(TransactionModel.amount)).filter(
        TransactionModel.transaction_date >= start_date,
        TransactionModel.transaction_date <= end_date,
        TransactionModel.status == '完成'
    ).scalar() or 0
    
    transaction_count = db.session.query(func.count(TransactionModel.id)).filter(
        TransactionModel.transaction_date >= start_date,
        TransactionModel.transaction_date <= end_date,
        TransactionModel.status == '完成'
    ).scalar() or 0
    
    average_amount = total_income / transaction_count if transaction_count > 0 else 0
    
    # 模拟利润率数据（实际项目中应该从数据库中获取）
    profit_margin = random.uniform(30, 50)  # 模拟30%-50%的利润率
    
    # 为每个交易添加利润和ROI数据（模拟数据）
    for transaction in transactions:
        # 模拟利润（实际项目中应该从数据库中获取）
        transaction.profit = transaction.amount * (random.uniform(0.3, 0.5))
        # 模拟 ROI（实际项目中应该从数据库中获取）
        transaction.roi = random.uniform(80, 150)
    
    # 生成收入趋势数据（按月分组）
    income_trend_data = []
    
    # 生成过去12个月的数据
    for i in range(12):
        month_date = today.replace(day=1) - timedelta(days=30*i)
        month_start = datetime(month_date.year, month_date.month, 1)
        if month_date.month == 12:
            month_end = datetime(month_date.year + 1, 1, 1) - timedelta(days=1)
        else:
            month_end = datetime(month_date.year, month_date.month + 1, 1) - timedelta(days=1)
        month_end = datetime.combine(month_end, datetime.max.time())
        
        # 查询该月的收入总额
        month_income = db.session.query(func.sum(TransactionModel.amount)).filter(
            TransactionModel.transaction_date >= month_start,
            TransactionModel.transaction_date <= month_end,
            TransactionModel.status == '完成'
        ).scalar() or 0
        
        income_trend_data.append({
            'x': month_start.isoformat(),
            'y': float(month_income)
        })
    
    # 收入来源分布数据（模拟数据）
    income_source_labels = ['小账号', '中账号', '大账号', 'VIP账号', '其他']
    income_source_data = [random.randint(5000, 15000) for _ in range(5)]
    
    # 利润率趋势数据（模拟数据）
    profit_margin_data = []
    for i in range(12):
        month_date = today.replace(day=1) - timedelta(days=30*i)
        profit_margin_data.append({
            'x': month_date.isoformat(),
            'y': random.uniform(25, 55)
        })
    
    # ROI分析数据（模拟数据）
    roi_analysis_labels = ['小账号', '中账号', '大账号', 'VIP账号', '其他']
    roi_analysis_data = [random.uniform(80, 150) for _ in range(5)]
    
    return render_template('finance.html', 
                           transactions=transactions,
                           page=page,
                           total_pages=total_pages,
                           start_date=start_date_str,
                           end_date=end_date_str,
                           total_income=total_income,
                           transaction_count=transaction_count,
                           average_amount=average_amount,
                           profit_margin=profit_margin,
                           period_text=period_text,
                           income_trend_data=income_trend_data,
                           income_source_labels=income_source_labels,
                           income_source_data=income_source_data,
                           profit_margin_data=profit_margin_data,
                           roi_analysis_labels=roi_analysis_labels,
                           roi_analysis_data=roi_analysis_data)

@app.route('/api/accounts', methods=['GET'])
def get_accounts():
    accounts = AccountModel.query.all()
    return jsonify([account.to_dict() for account in accounts])

@app.route('/api/accounts/<int:account_id>', methods=['GET'])
def get_account(account_id):
    account = AccountModel.query.get_or_404(account_id)
    return jsonify(account.to_dict())

@app.route('/api/accounts', methods=['POST'])
def create_account():
    data = request.json
    
    try:
        # 处理注册日期字段
        register_date = None
        if data.get('register_date'):
            try:
                register_date = datetime.strptime(data['register_date'], '%Y-%m-%d').date()
            except ValueError:
                register_date = None
                
        account = AccountModel(
            username=data['username'],
            password=data['password'],
            contact=data['contact'],
            api_password=data.get('api_password', ''),
            register_date=register_date,
            register_region=data.get('register_region', ''),
            has_showcase=data.get('has_showcase', '无'),
            followers=data.get('followers', 0),
            likes=data.get('likes', 0),
            status=data['status'],
            price=data['price'],
            created_date=datetime.now(),
            total_views=data.get('total_views', 0),
            total_comments=data.get('total_comments', 0),
            total_shares=data.get('total_shares', 0),
            total_favorites=data.get('total_favorites', 0),
            region=data.get('region', '未知'),
            account_type=data.get('account_type', '普通账号')
        )
        
        # 如果没有提供详细数据，尝试从API获取
        if not all([account.followers, account.likes, account.total_views]):
            account = TikTokAPI.refresh_account_stats(account)
            
        db.session.add(account)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'account': account.to_dict()
        })
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400

@app.route('/api/accounts/<int:account_id>', methods=['PUT'])
def update_account(account_id):
    account = AccountModel.query.get_or_404(account_id)
    data = request.json
    
    try:
        # 更新基本字段
        account.username = data['username']
        account.status = data['status']
        account.price = data['price']
        
        # 更新新增字段
        if 'password' in data:
            account.password = data['password']
        if 'contact' in data:
            account.contact = data['contact']
        if 'api_password' in data:
            account.api_password = data['api_password']
        if 'register_date' in data and data['register_date']:
            try:
                account.register_date = datetime.strptime(data['register_date'], '%Y-%m-%d').date()
            except ValueError:
                pass
        if 'register_region' in data:
            account.register_region = data['register_region']
        if 'has_showcase' in data:
            account.has_showcase = data['has_showcase']
        
        # 如果请求中包含 auto_refresh 参数并且为 true，则从 API 获取最新数据
        if data.get('auto_refresh', False):
            # 使用 TikTokAPI 获取数据
            account = TikTokAPI.refresh_account_stats(account)
        else:
            # 只有当手动提供了这些字段时才更新，否则保留现有值
            if 'followers' in data:
                account.followers = data['followers']
            if 'likes' in data:
                account.likes = data['likes']
            if 'total_views' in data:
                account.total_views = data['total_views']
            if 'total_comments' in data:
                account.total_comments = data['total_comments']
            if 'total_shares' in data:
                account.total_shares = data['total_shares']
            if 'total_favorites' in data:
                account.total_favorites = data['total_favorites']
            if 'region' in data:
                account.region = data['region']
            if 'account_type' in data:
                account.account_type = data['account_type']
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'account': account.to_dict()
        })
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400

@app.route('/api/accounts/<int:account_id>', methods=['DELETE'])
def delete_account(account_id):
    account = AccountModel.query.get_or_404(account_id)
    
    try:
        db.session.delete(account)
        db.session.commit()
        
        return jsonify({
            'success': True
        })
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400
        
@app.route('/api/accounts/<int:account_id>/refresh', methods=['POST'])
def refresh_account(account_id):
    account = AccountModel.query.get_or_404(account_id)
    
    try:
        # 调用第三方API获取最新数据
        account = TikTokAPI.refresh_account_stats(account)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'account': account.to_dict()
        })
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400

@app.route('/api/transactions', methods=['GET'])
def get_transactions():
    transactions = TransactionModel.query.all()
    return jsonify([transaction.to_dict() for transaction in transactions])

@app.route('/api/transactions', methods=['POST'])
def create_transaction():
    data = request.json
    
    try:
        # 获取账号
        account = AccountModel.query.get_or_404(data['account_id'])
        
        # 创建交易记录
        transaction = TransactionModel(
            order_number=f'ORD-{datetime.now().strftime("%Y%m%d")}-{str(uuid.uuid4())[:8]}',
            account_id=account.id,
            amount=data['amount'],
            transaction_date=datetime.now(),
            status='完成'
        )
        
        # 更新账号状态
        account.status = '已售'
        
        db.session.add(transaction)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'transaction': transaction.to_dict()
        })
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': str(e)
        }), 400

@app.route('/api/export/transactions/csv')
def export_transactions_csv():
    # 获取日期范围
    today = datetime.now().date()
    start_date_str = request.args.get('start_date', (today - timedelta(days=30)).isoformat())
    end_date_str = request.args.get('end_date', today.isoformat())
    
    start_date = datetime.fromisoformat(start_date_str)
    end_date = datetime.fromisoformat(end_date_str)
    end_date = datetime.combine(end_date, datetime.max.time())
    
    # 查询交易数据
    transactions = TransactionModel.query.filter(
        TransactionModel.transaction_date >= start_date,
        TransactionModel.transaction_date <= end_date
    ).order_by(TransactionModel.transaction_date.desc()).all()
    
    # 创建CSV文件
    output = io.StringIO()
    writer = csv.writer(output)
    
    # 写入表头
    writer.writerow(['订单号', '账号ID', '账号用户名', '金额', '交易日期', '状态'])
    
    # 写入数据
    for transaction in transactions:
        account = AccountModel.query.get(transaction.account_id) if transaction.account_id else None
        username = account.username if account else '未知账号'
        writer.writerow([
            transaction.order_number,
            transaction.account_id,
            username,
            transaction.amount,
            transaction.transaction_date.strftime('%Y-%m-%d %H:%M:%S'),
            transaction.status
        ])
    
    # 设置响应头
    output.seek(0)
    return Response(
        output.getvalue(),
        mimetype="text/csv",
        headers={
            "Content-Disposition": f"attachment;filename=transactions_{start_date_str}_to_{end_date_str}.csv"
        }
    )

@app.route('/api/export/transactions/excel')
def export_transactions_excel():
    # 模拟Excel导出，实际项目中可以使用xlsxwriter或pandas生成Excel文件
    # 这里为了简化，返回CSV格式
    return export_transactions_csv()

def init_sample_data():
    # 添加示例账号数据
    for i in range(1, 1235):
        status = '已售' if i <= 856 else '未售'
        register_date = datetime.now() - timedelta(days=random.randint(30, 365))
        regions = ['中国', '美国', '英国', '日本', '韩国', '加拿大', '澳大利亚']
        showcase = ['有', '无']
        account_types = ['小账号', '中账号', '大账号', 'VIP账号', '普通账号']
        
        account = AccountModel(
            username=f'tiktok_user_{i}',
            password=f'password{i}',
            contact=f'user{i}@example.com' if i % 2 == 0 else f'1{i:010d}',
            api_password=f'api_key_{i}' if i % 3 == 0 else '',
            register_date=register_date.date(),
            register_region=random.choice(regions),
            has_showcase=random.choice(showcase),
            followers=10000 + i * 100,
            likes=50000 + i * 500,
            status=status,
            price=100 + i % 100,
            created_date=datetime.now(),
            total_views=random.randint(10000, 1000000),
            total_comments=random.randint(1000, 50000),
            total_shares=random.randint(500, 20000),
            total_favorites=random.randint(2000, 100000),
            region=random.choice(regions),
            account_type=random.choice(account_types)
        )
        db.session.add(account)
    
    # 添加示例交易数据
    for i in range(1, 857):
        transaction = TransactionModel(
            order_number=f'ORD-{2023}{i:04d}',
            account_id=i,
            amount=100 + i % 100,
            transaction_date=datetime.now(),
            status='完成'
        )
        db.session.add(transaction)
    
    db.session.commit()

# 初始化数据库
with app.app_context():
    # 确保创建所有表和字段
    db.create_all()
    
    # 如果没有数据，添加一些示例数据
    if AccountModel.query.count() == 0:
        init_sample_data()
    else:
        # 检查并更新现有账号的新字段
        accounts = AccountModel.query.all()
        for account in accounts:
            if not hasattr(account, 'total_views') or account.total_views is None:
                account.total_views = random.randint(10000, 1000000)
            if not hasattr(account, 'total_comments') or account.total_comments is None:
                account.total_comments = random.randint(1000, 100000)
            if not hasattr(account, 'total_shares') or account.total_shares is None:
                account.total_shares = random.randint(500, 50000)
            if not hasattr(account, 'total_favorites') or account.total_favorites is None:
                account.total_favorites = random.randint(5000, 500000)
            if not hasattr(account, 'region') or account.region is None:
                account.region = random.choice(['中国', '美国', '日本', '韩国', '英国', '其他'])
            if not hasattr(account, 'account_type') or account.account_type is None:
                account.account_type = random.choice(['普通账号', '商业账号', '创作者账号', 'VIP账号'])
        db.session.commit()



if __name__ == '__main__':
    app.run(debug=True, port=5001)
