# 测试get请求

启动一个 nginx apahce


test.json
```
[{"ai":"0a1b4118dd954ec3bcc69da5138bdb96","av":"2.1.36","b":"Web","u":"ce8d5fb6-0b0a-43db-a6f7-ab8b7a68c6ff","s":"f3feee14-4412-4257-9ba5-9a2e4a4e4728","t":"vst","tm":1598013140093,"pt":"https","sh":900,"sw":1440,"d":"docs.growingio.com","p":"/","rf":"","l":"en"},{"ai":"0a1b4118dd954ec3bcc69da5138bdb96","av":"2.1.36","b":"Web","u":"ce8d5fb6-0b0a-43db-a6f7-ab8b7a68c6ff","s":"f3feee14-4412-4257-9ba5-9a2e4a4e4728","t":"vst","tm":1598013140093,"pt":"https","sh":900,"sw":1440,"d":"docs.growingio.com","p":"/","rf":"","l":"en"}]
```

```
ab -p /home/test.json  -T application/json -n 1000000 -c 3000 "https://api-test-xjh.growingio.com:4433/v3/0a1b4118dd954ec3bcc69da5138bdb96/web/pv?stm=1597991043684" 
```

## 新加work节点 安装java环境

* 1、拷贝106.75.37.217 /home下的apache-jmeter-5.2.1.tar.gz到新服务器下
* 2、cd /home/apache-jmeter-5.2.1/bin
* 3、编辑jmeter-server文件，修改RMI_HOST_DEF=-Djava.rmi.server.hostname=10.10.16.180中的ip
* 4、后台启动./jmeter-server &

## jmx模版


##  

/home/apache-jmeter-5.2.1/bin/jmeter -n -t post.jmx -l result/result.jtl -e -o result -R ab-1,ab-2,ab-3,ab-3,ab-4,ab-5,ab-6,ab-7,ab-8,ab-9,ab-10

## 

## wrk 的使用

```
nohup wrk -t2000 -c8000 -d300s -R40000 -L -s /home/post.lua  "https://lb_ip_or_domain:999/v3/0a1b4118dd954ec3bcc69da5138bdb96/web/pv?stm=1597991043684" &> /dev/null &
#wrk -t1 -c1 -d 60s -R1 -L -s /home/post.lua  "https://lb_ip_or_domain:999/v3/0a1b4118dd954ec3bcc69da5138bdb96/web/pv?stm=1597991043684"
```

