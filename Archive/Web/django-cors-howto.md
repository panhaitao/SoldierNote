# django cors跨域设置

## 使用jsonp方法

需要让服务器端放回jsonp格式的response，如Django可以加jsonp相关的decorator，如：https://coderwall.com/p/k8vb_a/returning-json-jsonp-from-a-django-view-with-a-little-decorator-help由于我不太喜欢这种方式，所以这里略过了，可看后面的参考资料。

## 

2.直接修改Django中的views.py文件
修改views.py中对应API的实现函数，允许其他域通过Ajax请求数据：

```
def myview(_request):
  response = HttpResponse(json.dumps({"key": "value", "key2": "value"}))
  response["Access-Control-Allow-Origin"] = "*"
  response["Access-Control-Allow-Methods"] = "POST, GET, OPTIONS"
  response["Access-Control-Max-Age"] = "1000"
  response["Access-Control-Allow-Headers"] = "*"
  return response
```

3. 使用django-cors-headers插件

在Django中，有人开发了CORS-header的middleware，只在settings.py中做一些简单的配置即可，见：
* https://github.com/ottoyiu/django-cors-headers/

安装django-cors-headers： pip install django-cors-headers

在settings.py中增加：

```
INSTALLED_APPS = (
  ...
  'corsheaders',
  ...
)
...


MIDDLEWARE_CLASSES = (
  ...
  'corsheaders.middleware.CorsMiddleware',
  'django.middleware.common.CommonMiddleware',
  ...
)
```

#跨域增加忽略

```
CORS_ALLOW_CREDENTIALS = True
CORS_ORIGIN_ALLOW_ALL = True
CORS_ORIGIN_WHITELIST = ( '*' )
CORS_ALLOW_METHODS = (
        'DELETE',
        'GET',
        'OPTIONS',
        'PATCH',
        'POST',
        'PUT',
        'VIEW',
)

CORS_ALLOW_HEADERS = (
        'XMLHttpRequest',
        'X_FILENAME',
        'accept-encoding',
        'authorization',
        'content-type',
        'dnt',
        'origin',
        'user-agent',
        'x-csrftoken',
        'x-requested-with',
        'Pragma',
)
```

