# Django:Note

#### 接入MySQL数据库

```yaml
DATABASES = {
	'default': {
		'ENGINE': 'django.db.backends.mysql',
		'NAME': 'django',
		'USER': 'root',
		'PASSWORD': 'rosemaryq1w2E#R$',
		'HOST': '127.0.0.1',
		'PORT': 3306,
		'OPTIONS': {
			'init_command': 'SET default_storage_engine=INNODB;'
		}
	}
}
```

#### 创建用户

```shell
# 登陆django-shell
python3 manage.py shell

from django.contrib.auth.models import User
user = User.objects.create_user("rose", "15151889248@139.com", "rosemary")
u = User.objects.get(username = 'rock')
u.set_password('123456') # 用于修改密码
u.save()
```

#### 分页

```shell
Paginator对象以及Page对象

```

#### 数据库模型

```shell
makemigrations,负责基于你的模型修改创建一个新的迁移。
migrate,负责执行迁移,以及撤销和列出迁移的状态。
sqlmigrate,展示迁移的sql语句。
```

#### ORM框架增删改查

```shell
# 创建
In [1]: from django.contrib.auth.models import User                                                          

In [2]: User.objects.create_user(username="rock", email="15151889248", password="hello")                     
Out[2]: <User: rock>

In [3]: User.objects.all()                                                                                   
Out[3]: <QuerySet [<User: rock>]>

# 查询
In [10]: Idc.objects.all()                                                                                   
Out[10]: <QuerySet [<Idc: 应天西路机房>]>

In [12]: Idc.objects.filter(name="应天西路机房")                                                             
Out[12]: <QuerySet [<Idc: 应天西路机房>]>

In [14]: Idc.objects.filter(name__startswith="应天")                                                         
Out[14]: <QuerySet [<Idc: 应天西路机房>]>

# Entry.objects.filter(pub_date__year=2006)
# Entry.objects.filter(pub_date__gte=datetime.date.today())
# body_text__icontains="food"
# exact 精确匹配
# iexact大小写不敏感匹配
# contains大小写敏感
# icontains大小写不敏感
# startwith,endwith
# istartwith,iendswith
# in在给定列表内
# gt/gte/lt/lte/range/year/month/day/week_day

# User.objects.values("id","username","email")返回的queryset中是字典
# value_list("id","username") 返回的是元祖

# F() 专门去对象中某列值的操作
from django.db.models import F
order = Order.objects.get(orderid='1000')
order.amount = F('amount') - 1
order.save()
# Q()对对象的复杂查询
Q对象可以对关键字参数进行封装从而更好地应用多个查询，可以组合使用&(and),|(or),~(not)操作符,当一个操作符应用于两个Q对象，它可以产生一个新的Q对象
Order.objects.get(
	Q(desc__startswith='who'),
	Q(create_time=date(2016,10,2))|Q(create_time=date(2016,10,6))
	)
```

#### 序列化

```shell
In [28]: from django.core import serializers 
In [33]: data = serializers.serialize('json', User.objects.all())
# data就是一个标准的json
```

#### 多对一

```shell
django使用django.db.models.ForeignKey定义多对一关系
ForeignKey需要一个位置参数来指定本Model关联的Model,ForeignKey关联的model是一，ForeignKey所在的Model是多
class Manufacurer(models.Model):
	name = models.CharField(max_length=30)
class Car(model.Model):
	manufacturer = models.ForeignKey(Manufacturer)
	name = models.Charfield(max_length=30)

多对一查询
car = Car.objects.get(pk=2)
car.manufacturer.all()
反向查询
如果模型有一个ForeignKey,那么该ForeignKey所指的模型实例可以通过一个管理器返回前一个有ForeignKey的模型的所有实例。默认情况下这个管理器名字为foo_set，其中foo为模型的小写名称。
返回的查询集可以过滤和操作。
manufacturer = Manufacturer.objects.get(pk=1)
manufacturer.car_set.all() # 返回多个car对象
```

#### 多对多

```shell
django.db.models.ManyToManyField和ForeignKey一样有一个位置参数，用来指定和它关联的Model
如果不仅需要知道两个Model之间是多对多的关系，还需要知道关系的更多信息。比如Person和Group是多对多关系，每个Person可以在多个group里。那么group里有多个person
class Group(model.Models):
	#...
class Person(model.Models):
	groups = models.ManyToMany(Group)
# 建议以被关联模型名称的复数形式作为ManyToManyField的名字
# 在那个模型中设置ManyToManyField并不重要，在两个模型中任选一个即可--不要在两个模型中都设置
```

#### 一对一

```shell
django.db.models.OneToOneField来实现
被关联的模型对象字段会被设置为unique
```





#### Rest_framework

```shell
# 模型
from django.db import models

# Create your models here.
class Idc(models.Model):
    name = models.CharField("机房名称", max_length=30)
    address = models.CharField("机房地址", max_length=30)
    phone = models.CharField("联系人", max_length=30)
    email = models.CharField("邮件地址", max_length=30)
    letter = models.CharField("简称", max_length=30)

    def __str__(self):
        return self.name
    
    
    class Meta:
        db_table = "resource_idc"
    
    def __str__(self):
        return self.name
        
# 创建数据
In [3]: idc = Idc()                                                                                          

In [4]: idc.name = "应天西路机房"                                                                            

In [5]: idc.address = "应天西路"                                                                             

In [6]: idc.phone = "15151889248"                                                                            

In [7]: idc.email = "15151889248@139.com"                                                                    

In [8]: idc.letter = "应天机房"                                                                              

In [9]: idc.save()
# 准备序列化
In [11]: from idcs.serializers import Idc_serializer 
In [12]: idc = Idc.objects.first()                                                                           

In [13]: idc                                                                                                 
Out[13]: <Idc: 应天西路机房>

In [14]: serilizer = Idc_serializer(idc, many=True)  #如果多条记录需要添加
In [15]: serilizer                                                                                           
Out[15]: 
Idc_serializer(<Idc: 应天西路机房>):
    id = IntegerField()
    name = CharField()
    address = CharField()
    phone = CharField()
    email = EmailField()
    letter = CharField()

In [16]: serilizer.data                                                                                      
Out[16]: {'id': 1, 'name': '应天西路机房', 'address': '应天西路', 'phone': '15151889248', 'email': '151518892
48@139.com', 'letter': '应天机房'}
# 返回的数据类型为dict类型 模拟表单向后台提交数据
In [17]: from rest_framework.renderers import JSONRenderer   
In [19]: JSONRenderer.render(data) 
In [20]: JSONRenderer().render(data)                                                                         
Out[20]: b'{"id":1,"name":"\xe5\xba\x94\xe5\xa4\xa9\xe8\xa5\xbf\xe8\xb7\xaf\xe6\x9c\xba\xe6\x88\xbf","address":"\xe5\xba\x94\xe5\xa4\xa9\xe8\xa5\xbf\xe8\xb7\xaf","phone":"15151889248","email":"15151889248@139.com","letter":"\xe5\xba\x94\xe5\xa4\xa9\xe6\x9c\xba\xe6\x88\xbf"}'
# 反序列化
from rest_framework.parsers import JSONParser
JSONParser().parse(BytesIO(content))
serializer = IdcSerializer(data=data)
serializer.is_valid()
serializer.save()
```

#### REST_FRAMEWORK DEMO1

```python
# Model层
from django.db import models

# Create your models here.
class Idc(models.Model):
    name = models.CharField("机房名称", max_length=30)
    address = models.CharField("机房地址", max_length=30)
    phone = models.CharField("联系人", max_length=30)
    email = models.CharField("邮件地址", max_length=30)
    letter = models.CharField("简称", max_length=30)

    def __str__(self):
        return self.name
    
    
    class Meta:
        db_table = "resource_idc"
    
    def __str__(self):
        return self.name

 # view层
from django.shortcuts import render
from idcs.models import Idc
from idcs.serializers import Idc_serializer
from rest_framework.parsers import JSONParser
from rest_framework.renderers import JSONRenderer
from django.http import HttpResponse
# Create your views here.

class JsonResponse(HttpResponse):
    def __init__(self, data, **kwargs):
        kwargs.setdefault("content_type", "application/json")
        content = JSONRenderer().render(data)
        super().__init__(content, **kwargs)


def idc_list(request, *args, **kwargs):
    if request.method == "GET":
        query_set = Idc.objects.all()
        serializer = Idc_serializer(query_set, many=True)
        # content = JSONRenderer().render(serializer.data)
        # return HttpResponse(content, content_type="application/json")
        return JsonResponse(serializer.data)
    elif request.method == "POST":
        data = JSONParser().parse(request)
        serializer = Idc_serializer(data=data)
        if serializer.is_valid():
            serializer.save()
            # 转换成二进制字符串
            content = JSONRenderer().render(serializer.data)
            return HttpResponse(content, content_type="application/json")

 # 序列号层
from rest_framework import serializers
from idcs.models import Idc
class Idc_serializer(serializers.Serializer):
    # 这里的数据类型代表返回给前端的数据类型
    id = serializers.IntegerField(read_only=True)
    name = serializers.CharField(required=True, max_length=30)
    address = serializers.CharField(required=True,max_length=30)
    phone = serializers.CharField(required=True, max_length=30)
    email = serializers.EmailField(required=True)
    letter = serializers.CharField(required=True, max_length=30)

    def create(self, validated_data):
        return Idc.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance.name = validated_data.get("name", instance.name)
        instance.address = validated_data.get("address", instance.address)
        instance.phone = validated_data.get("phone", instance.phone)
        instance.email = validated_data.get("email", instance.email)
        instance.save()
        return instance
```

#### 基于类视图的APIVIEW

```python
from rest_framework import status # 定义了一系列的状态码
# view部分
from django.shortcuts import render
from idcs.models import Idc
from idcs.serializers import Idc_serializer
from rest_framework.parsers import JSONParser
from rest_framework.renderers import JSONRenderer
from django.http import HttpResponse
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import Http404
class IdcList(APIView):
    def get(self, request, format=None):
        queryset = Idc.objects.all()
        serializer = Idc_serializer(queryset, many=True)
        return Response(serializer.data)

    def post(self,  request, format=None):
        serializer = Idc_serializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.data, status=status.HTTP_400_BAD_REQUEST)

class IdcDetail(APIView):
    def get_obj(self, pk):
        try:
            return Idc.objects.get(pk=pk)
        except query.DoesNotExist:
            return Http404
    def get(self, request, pk, format=None):
        idc = self.get_obj(pk=pk)
        serializer = Idc_serializer(idc)
        return Response(serializer.data)
    def put(self, request, pk, format=None):
        idc = self.get_obj(pk)
        serializer = Idc_serializer(idc, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_404_NOT_FOUND)
    
    def delete(self, request, pk, format=None):
        idc = self.get_obj(pk)
        idc.delete()
        
# 序列化部分未改变

# URL部分
from django.urls import path, re_path
from .views import IdcList, IdcDetail
urlpatterns = [
    re_path("^home/$", IdcList.as_view(), name="Idc-list"),
    re_path("^home/(?P<pk>[0-9]+)/$", IdcDetail.as_view(), name="Idc-detail")
]

```

#### MIXINS

```shell
from rest_framework import mixins, generics

class IdcList(generics.GenericAPIView,
                mixins.ListModelMixin,
                mixins.CreateModelMixin):
    queryset = Idc.objects.all()
    serializer_class = Idc_serializer

    def get(self, request, *args, **kwargs):
        return self.list(request, *args, **kwargs)
    
    def post(self, request, *args, **kwargs):
        return self.create(request, *args, **kwargs)
```

#### MIXINS高级

```python
class IdcList(generics.ListCreateAPIView):
    queryset = Idc.objects.all()
    serializer_class = Idc_serializer


class IdcDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Idc.objects.all()
    serializer_class = Idc_serializer
```

#### VIEWSET

```python
# VIEW部分
from idcs.models import Idc
from idcs.serializers import Idc_serializer
from rest_framework import viewsets
class IdcViewSet(viewsets.ModelViewSet):
    queryset = Idc.objects.all()
    serializer_class = Idc_serializer
# URL部分
from rest_framework import routers

route = routers.DefaultRouter()
route.register('home', IdcViewSet)

urlpatterns = [
    re_path('^', include(route.urls))
]
```

#### REST_FRAMEWORK分页

```python
from rest_framework import viewsets
# 导入分页的类
from rest_framework.pagination import PageNumberPagination
class IdcViewSet(viewsets.ModelViewSet):
    """
        retrive:
            返回指定IDC信息
        list:
            返回IDC列表
        update:
            更新IDC信息
        destroy:
            删除IDC记录
        create:
             创建IDC记录
        partial_update:
            更新部分字段
    """
    queryset = Idc.objects.all()
    serializer_class = Idc_serializer
    pagination_class = PageNumberPagination
   
  
 settings中需要在
REST_FRAMEWORK = {
	"PAGE_SIZE": 2
}

# 假如有通用的分页
```

