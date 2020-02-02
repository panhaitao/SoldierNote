# k8s集群管理 MacOS dev
a simple multi k8s cluster web console

# 第一节: 准备环境

## 安装依赖包

```
mkdir ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple
EOF

pip3 install django
pip3 install djangorestframework 
```

## 初始化项目

django-admin startproject k8s_web_console
cd k8s_web_console
manager.py startapp cluster # 执行前，修改manager.py 首行为如下` #!/usr/bin/env python3`

## 在项目配置中加入rest框架

编辑 k8s_web_console/setting.py 修改 INSTALLED_APPS 加入

```
'rest_framework',
  'cluster',
```
## 创建数据库以及数据表

```
python3 manage.py makemigrations
python3 manage.py migrate
```

# 第二节: 开始正真的编码

1. cluster/models.py           cluster应用添加一个k8s集群信息的model
2. cluster/serializers.py      cluster应用添加一个serializers.py文件
3. cluster/views.py            cluster的view文件添加cluster的viewset 
4. k8s_web_console/settings.py 设置rest框架的parser:jsonparser
5. cluster/admin.py            将cluster注册到Django Admin后台
6. k8s_web_console/urls.py                                         设置路由
7. python3 manage.py createsuperuser                               设置用户
8. python3 manage.py makemigrations && python3 manage.py migrate   建数据库以及数据表
9. python3 manage.py runserver 0.0.0.0:8000                        运行服务器
10. 测试
  * http://127.0.0.1:8000/admin/cluster/cluster/ 
  * http://127.0.0.1:8000/api/cluster/

# 第三节: 使用 kubernetes.client 连接kubernetes集群

需要安装`pip install kubernetes`

1. cluster/views.py            cluster应用添加对kubernetes集群的代码
2. table.html                  使用django的template模式做数据返回 

# 第四节: 创建一个新的dashboard 便于页面刷新和管理

cd k8s_web_console
python3 manager.py startapp dashboard

1. dashboard/views.py              dashboard 应用添加对集群信息的引用
2. dashboard/urls.py               dashboard 应用设置urls
3. main.html                       dashboard 应用的模版

## 参考
* https://github.com/jackfrued/Python-100-Days/blob/master/Day41-55/48.%E5%89%8D%E5%90%8E%E7%AB%AF%E5%88%86%E7%A6%BB%E5%BC%80%E5%8F%91%E5%85%A5%E9%97%A8.md
* https://www.cnblogs.com/zhixi/p/9996832.html
