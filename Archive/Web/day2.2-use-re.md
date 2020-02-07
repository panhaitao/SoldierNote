# 学习使用 Beautiful Soup 

* python正则表达式  https://docs.python.org/zh-cn/3/library/re.html

## 解决上次遗留的问题

访问https://网站无请求数据的问题

cat > request-demo.py <<EOF
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import random
import urllib3
from bs4 import BeautifulSoup

rand_range_list=[
'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.96 Safari/537.36', 
'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36',
'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36'
]

header={
'User-Agent': "" 
}

header['User-Agent']=rand_range_list[random.randrange(3)]

urllib3.disable_warnings()
r = requests.get('https://book.douban.com/top250', headers=header, verify=False)
result=re.findall( r"title\=\"(.*?)\"",r.text)
for item in result:
  print(item)

EOF

python3 request-demo.py



## 参考

* Beautiful Soup：https://www.crummy.com/software/BeautifulSoup/bs4/doc/index.zh.html
* XPath：https://developer.mozilla.org/zh-CN/docs/Web/XPath



