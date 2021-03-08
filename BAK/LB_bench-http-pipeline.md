# 使用wrk进行 http pipeline 场景压测

本片文档主要分享了如何使用nginx 和 python 搭建服务器，使用wrk工具对 http pipeline 进行场景压测

1. 安装软件包
2. 编写一个简单的python接口程序: /usr/share/nginx/api/restfulapi.py
3. 编写uwsgi配置 /usr/share/nginx/api/uwsgiconfig.ini
4. 启动 uwsgi 进程
5. 修改 nginx 配置添加uwsgi 相关配置，重启生效
6. 编写lua脚本，使用wrk工具压测
7. 观察nginx日志和抓包数据确认

## 安装软件包

yum install nginx python2-pip -y
pip install flask uwsgi

## 编写一个简单的python接口程序

/usr/share/nginx/api/restfulapi.py
```
# -*- coding:utf-8 -*-

import flask, json
from flask import Flask, abort, request, jsonify

app = Flask(__name__)

@app.route('/login', methods=['get', 'post'])
def login():
    username = request.values.get('name')
    pwd = request.values.get('pw')
    # 判断用户名、密码都不为空，如果不传用户名、密码则username和pwd为None
    if username and pw:
        if username=='xiaoming' and pw=='xxx':
            resu = {'code': 200, 'message': '登录成功'}
            return json.dumps(resu, ensure_ascii=False)
        else:
            resu = {'code': -1, 'message': '账号密码错误'}
            return json.dumps(resu, ensure_ascii=False)
    else:
        resu = {'code': 10001, 'message': '参数不能为空！'}
        return json.dumps(resu, ensure_ascii=False)

@app.route('/name', methods=['get', 'post'])
def name():
    username = request.values.get('name')
    resu = {'code': 200, 'message': username }
    return json.dumps(resu, ensure_ascii=False)

@app.route('/pw', methods=['get', 'post'])
def pw():
    password = request.values.get('pw')
    resu = {'code': 200, 'message': password }
    return json.dumps(resu, ensure_ascii=False)

if __name__ == '__main__':
    app.run(debug=True, port=999, host='127.0.0.1')
```

/usr/share/nginx/api/uwsgiconfig.ini

```
[uwsgi]
socket = 127.0.0.1:8080
chdir = /usr/share/nginx/api/
wsgi-file = restfulapi.py  
callable = app
processes = 8
threads = 20
stats = 127.0.0.1:9191
pidfile = restfulapi.pid
daemonize = /var/log/restfulapi.log
```
## 启动uwsgi进程

uwsgi --ini /usr/share/nginx/api/uwsgiconfig.ini

## 修改配置

编辑/etc/nginx/nginx.conf 
```
location / {
            include uwsgi_params;
            uwsgi_pass 127.0.0.1:8080;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
```

执行命令systemctl restart nginx 重启nginx服务生效， 

* uwsgi_pass一定要跟uwsgi_conf.ini中socket定义的完全一致
* nginx的 keepalive_requests 和 keepalive_timeout 这两个配置项要开启
* http pipeline 需要服务端和客户端都支持，python run起来的simple server不支持pipeline，所需也要nginx做前端，将请求转发给python接口程序 


## 使用wrk 对 http pipeline 场景进行压测

```
git clone https://github.com/giltene/wrk2.git
yum groupinstall 'Development Tools' -y  
yum install openssl-devel -y
cd wrk2 && make 
```

1. 编写 post.lua 构造单链接3请求的模拟
```
wrk.method = "POST"
wrk.headers["Content-Type"] = "application/json"
wrk.body = '{"name": "xiaoming","pw": "xxx"}'

init = function(args)
   local r = {}
   r[1] = wrk.format(nil, "/login")
   r[2] = wrk.format(nil, "/name")
   r[3] = wrk.format(nil, "/pw")

   req = table.concat(r)
end

request = function()
   return req
end
```

2. wrk -t1 -c1 -d1s -R1 -L -s post.lua http://nginx_server_ip

## 检查确认

1. wrk 每次压测,nginx日志可见服务端依次处理了 /login /name /pw 三个请求

```
10.10.74.50 - - [09/Sep/2020:16:41:22 +0800] "POST /login HTTP/1.1" 200 51 "-" "-" "-"
10.10.74.50 - - [09/Sep/2020:16:41:22 +0800] "POST /name HTTP/1.1" 200 30 "-" "-" "-"
10.10.74.50 - - [09/Sep/2020:16:41:22 +0800] "POST /pw HTTP/1.1" 200 30 "-" "-" "-"
```
2. 使用tcpdump port 80 and host wrk_host_ip 抓包可见如下类似结果

```
tcpdump 抓包片段
...
16:41:12.000352 IP 10.10.74.50.32894 > 10-10-37-126.http: 
HTTP: POST /login HTTP/1.1
16:41:12.000359 IP 10-10-37-126.http > 10.10.74.50.32894: 
16:41:12.001516 IP 10-10-37-126.http > 10.10.74.50.32894: length 213: HTTP: HTTP/1.1 200 OK
16:41:12.001640 IP 10.10.74.50.32894 > 10-10-37-126.http: length 192: HTTP: HTTP/1.1 200 OK
16:41:12.002432 IP 10.10.74.50.32894 > 10-10-37-126.http: length 255: HTTP: HTTP/1.1 200 OK
16:41:12.003136 IP 10.10.74.50.32894 > 10-10-37-126.http: Flags [.], ack 598, win 128, options [nop,nop,TS val 
...
```

## 确认达到压测效果后，可以调大参数做性能压测了

```
wrk -t100 -c1000 -d60s -R10000000 -L -s post.lua http://nginx_server_ip
```
