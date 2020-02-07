# day1 

## prep python3-dev  

```
docker pull openwhisk/python3action
docker run -d --net=host --name=python3-dev openwhisk/python3action:latest
```
## 进入开发环境

```
docker exec -t -i python3-dev /bin/sh
pip3 install generic-request-signer
```

## 运行第一个 request-demo.py

```
cat > request-demo.py <<EOF
#!/usr/bin/env python3
import requests
r = requests.get('https://book.douban.com/top250')
print(r.text)
EOF

python3 request-demo.py
```

## 运行第二个 request-demo-with-auth.py 

```
cat > request-demo-with-auth.py <<EOF
#!/usr/bin/env python3
import requests
r = requests.get('http://127.0.0.1:30880/login', auth=('admin', 'P@88w0rd'))
print(r.text)
EOF

python3 request-demo-with-auth.py
```

## 参考

* https://developer.mozilla.org/zh-CN/docs/Learn/HTML
* https://developer.mozilla.org/zh-CN/docs/Web/HTTP
* https://docs.python.org/zh-cn/3/library/urllib.html#module-urllib
* https://requests.readthedocs.io/en/master/

