# 学习使用 Beautiful Soup 

* https://lxml.de/
* Xpath简介: https://developer.mozilla.org/en-US/docs/Web/XPath/Comparison_with_CSS_selectors
* Xpath语法: https://www.w3school.com.cn/xpath/xpath_syntax.asp


cat > request-demo.py <<EOF
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import random
import urllib3
import time

import requests
import ssl
from lxml import etree





def get_header():
  rand_range_list=[
  'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.96 Safari/537.36', 
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36'
  ]

  header={
  'User-Agent': ""   
  }

  header['User-Agent']=rand_range_list[random.randrange(3)]
  return header

def get_books(url, header, page_num):
  urllib3.disable_warnings()
  url=url+'?start='+str(page_num)
  r = requests.get(url, headers=header, verify=False)
  result=re.findall( r"title\=\"(.*?)\"",r.text)
  for item in result:
    print(item)

def get_etree(url, header, page_num):
  ssl._create_default_https_context = ssl._create_unverified_context
  session = requests.Session()
  URL = 'https://movie.douban.com/top250/?start=0'
  req = session.get(URL)
  req.encoding = 'utf8'
  req = session.get(URL,headers=header)
  root = etree.HTML(req.content)
  print(root)
  result = etree.tostring(root)
  print(result.decode('utf-8'))

if __name__ == "__main__":
  url='https://book.douban.com/top250'
  header=get_header()
  get_etree(url, header, 0)


EOF



```
result = root.xpath('//body/div[@id="wrapper"]/div[@id="content"]/div/div[@class="article"]/div//table/tr/')
```


```
```


## 参考

* Beautiful Soup：https://www.crummy.com/software/BeautifulSoup/bs4/doc/index.zh.html
* XPath：https://developer.mozilla.org/zh-CN/docs/Web/XPath



