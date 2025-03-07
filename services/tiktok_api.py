import random
import time
import requests
from flask import current_app

class TikTokAPI:
    """
    模拟TikTok第三方API服务
    实际项目中应替换为真实的API调用
    """
    
    @staticmethod
    def get_account_stats(username):
        """
        获取TikTok账号的统计数据
        
        Args:
            username: TikTok用户名
            
        Returns:
            dict: 包含账号统计数据的字典
        """
        # 在实际项目中，这里应该调用真实的TikTok API
        # 这里使用随机数据模拟API响应
        
        # 模拟API调用延迟
        time.sleep(0.5)
        
        # 基于用户名生成一个稳定的随机种子，使得同一用户名总是返回相似的数据
        seed = sum(ord(c) for c in username)
        random.seed(seed)
        
        # 生成随机统计数据
        followers = random.randint(1000, 1000000)
        likes = random.randint(5000, 5000000)
        total_views = random.randint(10000, 10000000)
        total_comments = random.randint(1000, 500000)
        total_shares = random.randint(500, 200000)
        total_favorites = random.randint(2000, 1000000)
        
        # 随机选择一个地区
        regions = ['美国', '英国', '日本', '韩国', '德国', '法国', '加拿大', '澳大利亚', '巴西', '印度']
        region = regions[random.randint(0, len(regions) - 1)]
        
        # 根据粉丝数确定账号类型
        if followers < 10000:
            account_type = '小账号'
        elif followers < 100000:
            account_type = '中账号'
        elif followers < 500000:
            account_type = '大账号'
        else:
            account_type = 'VIP账号'
        
        # 返回模拟的API响应
        return {
            'username': username,
            'followers': followers,
            'likes': likes,
            'total_views': total_views,
            'total_comments': total_comments,
            'total_shares': total_shares,
            'total_favorites': total_favorites,
            'region': region,
            'account_type': account_type
        }
    
    @staticmethod
    def refresh_account_stats(account_model):
        """
        刷新账号统计数据并更新数据库
        
        Args:
            account_model: 账号模型实例
            
        Returns:
            account_model: 更新后的账号模型实例
        """
        try:
            # 获取最新的账号统计数据
            stats = TikTokAPI.get_account_stats(account_model.username)
            
            # 更新账号模型
            account_model.followers = stats['followers']
            account_model.likes = stats['likes']
            account_model.total_views = stats['total_views']
            account_model.total_comments = stats['total_comments']
            account_model.total_shares = stats['total_shares']
            account_model.total_favorites = stats['total_favorites']
            account_model.region = stats['region']
            account_model.account_type = stats['account_type']
            
            return account_model
        except Exception as e:
            current_app.logger.error(f"Error refreshing account stats: {str(e)}")
            return account_model
