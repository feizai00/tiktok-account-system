from datetime import datetime

db = None

class Transaction(object):
    __tablename__ = 'transaction'
    
    id = None
    order_number = None
    account_id = None
    amount = None
    transaction_date = None
    status = None
    
    @classmethod
    def init_model(cls, db_instance, Account):
        global db
        db = db_instance
        
        class TransactionModel(db.Model):
            __tablename__ = 'transaction'
            
            id = db.Column(db.Integer, primary_key=True)
            order_number = db.Column(db.String(50), unique=True, nullable=False)
            account_id = db.Column(db.Integer, db.ForeignKey('account.id'), nullable=False)
            amount = db.Column(db.Float, nullable=False)
            transaction_date = db.Column(db.DateTime, default=datetime.now)
            status = db.Column(db.String(20), default='完成')  # 完成/取消/处理中
            
            account = db.relationship(Account.model, backref=db.backref('transactions', lazy=True))
            
            def to_dict(self):
                return {
                    'id': self.id,
                    'order_number': self.order_number,
                    'account_id': self.account_id,
                    'account_type': self.account.username if self.account else '',
                    'amount': self.amount,
                    'transaction_date': self.transaction_date.strftime('%Y-%m-%d %H:%M:%S'),
                    'status': self.status
                }
        
        cls.model = TransactionModel
        # 将模型类的属性映射到外部类
        cls.id = TransactionModel.id
        cls.order_number = TransactionModel.order_number
        cls.account_id = TransactionModel.account_id
        cls.amount = TransactionModel.amount
        cls.transaction_date = TransactionModel.transaction_date
        cls.status = TransactionModel.status
        
        return TransactionModel
    
    @classmethod
    def query(cls):
        return cls.model.query
