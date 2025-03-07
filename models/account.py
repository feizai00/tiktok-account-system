from datetime import datetime

db = None

class Account(object):
    __tablename__ = 'account'
    
    id = None
    username = None
    password = None
    contact = None
    api_password = None
    register_date = None
    register_region = None
    has_showcase = None
    followers = None
    likes = None
    status = None
    price = None
    created_date = None
    total_views = None
    total_comments = None
    total_shares = None
    total_favorites = None
    region = None
    account_type = None
    
    @classmethod
    def init_model(cls, db_instance):
        global db
        db = db_instance
        
        class AccountModel(db.Model):
            __tablename__ = 'account'
            
            id = db.Column(db.Integer, primary_key=True)
            username = db.Column(db.String(100), nullable=False)
            password = db.Column(db.String(100), nullable=False)
            contact = db.Column(db.String(100), nullable=False)
            api_password = db.Column(db.String(100), nullable=True)
            register_date = db.Column(db.Date, nullable=True)
            register_region = db.Column(db.String(50), nullable=True)
            has_showcase = db.Column(db.String(10), default='无')  # 有/无
            followers = db.Column(db.Integer, default=0)
            likes = db.Column(db.Integer, default=0)
            status = db.Column(db.String(20), default='未售')  # 未售/已售
            price = db.Column(db.Float, default=0.0)
            created_date = db.Column(db.DateTime, default=datetime.now)
            total_views = db.Column(db.Integer, default=0)
            total_comments = db.Column(db.Integer, default=0)
            total_shares = db.Column(db.Integer, default=0)
            total_favorites = db.Column(db.Integer, default=0)
            region = db.Column(db.String(50), default='未知')
            account_type = db.Column(db.String(20), default='普通账号')  # 小账号/中账号/大账号/VIP账号
            
            def to_dict(self):
                return {
                    'id': self.id,
                    'username': self.username,
                    'password': self.password,
                    'contact': self.contact,
                    'api_password': self.api_password,
                    'register_date': self.register_date.strftime('%Y-%m-%d') if self.register_date else '',
                    'register_region': self.register_region,
                    'has_showcase': self.has_showcase,
                    'followers': self.followers,
                    'likes': self.likes,
                    'status': self.status,
                    'price': self.price,
                    'created_date': self.created_date.strftime('%Y-%m-%d %H:%M:%S'),
                    'total_views': self.total_views,
                    'total_comments': self.total_comments,
                    'total_shares': self.total_shares,
                    'total_favorites': self.total_favorites,
                    'region': self.region,
                    'account_type': self.account_type
                }
        
        cls.model = AccountModel
        # 将模型类的属性映射到外部类
        cls.id = AccountModel.id
        cls.username = AccountModel.username
        cls.password = AccountModel.password
        cls.contact = AccountModel.contact
        cls.api_password = AccountModel.api_password
        cls.register_date = AccountModel.register_date
        cls.register_region = AccountModel.register_region
        cls.has_showcase = AccountModel.has_showcase
        cls.followers = AccountModel.followers
        cls.likes = AccountModel.likes
        cls.status = AccountModel.status
        cls.price = AccountModel.price
        cls.created_date = AccountModel.created_date
        cls.total_views = AccountModel.total_views
        cls.total_comments = AccountModel.total_comments
        cls.total_shares = AccountModel.total_shares
        cls.total_favorites = AccountModel.total_favorites
        cls.region = AccountModel.region
        cls.account_type = AccountModel.account_type
        
        return AccountModel
    
    @classmethod
    def query(cls):
        return cls.model.query
