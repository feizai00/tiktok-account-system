#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
TikTok账号管理系统启动脚本
"""

import os
import sys
import webbrowser
from threading import Timer

def open_browser():
    """启动浏览器打开应用"""
    webbrowser.open('http://127.0.0.1:5000')

if __name__ == '__main__':
    # 设置工作目录
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    # 检查依赖是否已安装
    try:
        from flask import Flask
    except ImportError:
        print("正在安装依赖包...")
        os.system('pip install -r requirements.txt')
    
    # 导入应用
    from app import app
    
    # 设置延时启动浏览器
    Timer(1.5, open_browser).start()
    
    # 启动应用
    print("正在启动TikTok账号管理系统...")
    print("应用将在浏览器中自动打开，或者您可以手动访问: http://127.0.0.1:5000")
    app.run(debug=True)
