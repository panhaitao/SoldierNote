# 学习使用 Beautiful Soup 

* Beautiful Soup  https://www.crummy.com/software/BeautifulSoup/bs4/doc/index.zh.html
* https://cn.python-requests.org/zh_CN/latest/user/advanced.html#advanced


#!/usr/bin/env python3
import requests
import random
import re
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

soup = BeautifulSoup(r.text, "lxml")
for item in soup.select('a[title]'):
  print("{name:<20}{url:<40}".format( name=item.get("title"), url=item.get("href")) )