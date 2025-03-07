#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
清除所有虚拟数据
"""

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import os

# 创建临时应用程序实例
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# 导入模型
from models.account import Account
from models.transaction import Transaction

# 初始化模型
AccountModel = Account.init_model(db)
TransactionModel = Transaction.init_model(db, Account)

def clear_all_data():
    """清除所有数据"""
    with app.app_context():
        try:
            # 删除所有交易记录
            TransactionModel.query.delete()
            print("已删除所有交易记录")
            
            # 删除所有账号
            AccountModel.query.delete()
            print("已删除所有账号")
            
            # 提交更改
            db.session.commit()
            print("数据库已清空")
            
        except Exception as e:
            db.session.rollback()
            print(f"清除数据时出错: {str(e)}")

if __name__ == "__main__":
    # 确认操作
    confirm = input("警告: 此操作将删除所有数据! 输入 'YES' 确认: ")
    if confirm.upper() == "YES":
        clear_all_data()
    else:
        print("操作已取消")
