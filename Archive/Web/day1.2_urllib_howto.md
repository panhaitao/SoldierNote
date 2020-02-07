# 浏览器的模拟

## 使用python3 urllib 库

```
#!/usr/bin/env python3

import urllib.request
import urllib.parse
import random

rand_range_list=[
'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.96 Safari/537.36', 
'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36',
'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36'
]

header={
'User-Agent': "" 
}

url="http://127.0.0.1:30080"

header['User-Agent']=rand_range_list[random.randrange(3)]

request = urllib.request.Request(url, headers=header)
reponse = urllib.request.urlopen(request).read()

print(reponse)

```

## 参考

* https://docs.python.org/zh-cn/3/library/random.html#
