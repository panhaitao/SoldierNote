# Django:创建开发环境 

## Django 简介和安装

Django 是用 Python 开发的一个免费开源的 Web 框架，可以用来快速搭建优雅的高性能网站。它采用的是“MVC”的框架模式，即模型 M、视图 V 和控制器 C。

## 安装

构建一个docker镜像作为应用开发环境

cat > Dockerfile <<EOF
FROM python:3.7-alpine

COPY requirements.txt /requirements.txt

RUN apk --no-cache add --virtual .build-deps build-base \
    && pip install -r /requirements.txt \
    && rm -rf .cache/pip \
    && apk del .build-deps
EXPOSE 8000

CMD ["sh"]
EOF

cat > requirements.txt <<EOF
Django
EOF

docker build -t python:django .

## 运行

docker run -t -i -d --net=host --name=django python:django


## 构建一个项目

django-admin --version
django-admin startproject newproject
cd newproject
python3 manage.py migrate

python3 manage.py createsuperuser             # 初始化用户
python manage.py runserver 0.0.0.0:8000       # 启动 Django 的 debugging 模式 0.0.0.0:8000

## 解释说明

