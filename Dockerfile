FROM python:3.9-slim

WORKDIR /app

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn

# 复制应用代码
COPY . .

# 暴露端口
EXPOSE 5000

# 创建数据库目录
RUN mkdir -p /app/instance

# 设置启动命令
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
