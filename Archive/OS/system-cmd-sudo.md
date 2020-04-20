# sudo 

sudo条目语法
```
who host=(runas)  TAG:command

who ：运行者用户名
host:主机
runad:以那个身份运行
TAG:标签
command：命令
```

样例： 

oracle ALL=(root) NOPASSWD：/usr/sbin/useradd, PASSWD:/usr/sbin/userdel

注：上面的意思就是：oracle用户可以在任何地方以root身份无密码执行useradd有密码执行usermod。
