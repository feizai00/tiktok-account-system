import sqlite3
import os

# 数据库文件路径
DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'database.db')

def migrate_database():
    """
    迁移数据库，添加新的字段
    """
    print(f"正在连接数据库: {DB_PATH}")
    
    # 检查数据库文件是否存在
    if not os.path.exists(DB_PATH):
        print("数据库文件不存在，请先运行应用程序创建数据库")
        return False
    
    # 连接数据库
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    try:
        # 检查表中是否已有新字段
        cursor.execute("PRAGMA table_info(account)")
        columns = [column[1] for column in cursor.fetchall()]
        
        # 需要添加的新字段
        new_columns = {
            "total_views": "INTEGER DEFAULT 0",
            "total_comments": "INTEGER DEFAULT 0",
            "total_shares": "INTEGER DEFAULT 0",
            "total_favorites": "INTEGER DEFAULT 0",
            "region": "TEXT DEFAULT '未知'",
            "account_type": "TEXT DEFAULT '普通账号'"
        }
        
        # 添加缺少的字段
        for column, definition in new_columns.items():
            if column not in columns:
                print(f"添加字段: {column}")
                cursor.execute(f"ALTER TABLE account ADD COLUMN {column} {definition}")
        
        # 提交更改
        conn.commit()
        print("数据库迁移成功！")
        return True
    
    except Exception as e:
        print(f"迁移数据库时出错: {e}")
        conn.rollback()
        return False
    
    finally:
        conn.close()

if __name__ == "__main__":
    migrate_database()
