## 系统安全 

linux系统重要的会留下你的痕迹日志有：lastlog、utmp、wtmp、messages、syslog、sulog，所以不能完全依赖工具。


默认的日志存放地点是：
 
*  /var/log/wtmp    系统成功登陆的记录,此文件默认打开时乱码，可以使用`last`命令进行查询操作
*  /var/log/btmp    系统登陆失败的记录,此文件默认打开时乱码，可以使用`lastb`命令进行查询操作
*  /var/log/lastlog 可以使用`lastlog`命令进行查询操作
*  ~/.bash_history  用户目录下的shell命令历史记录
    * history -c                   #清除记录 
    * history -r /root/history.txt #导入记录 
    * history                      #查询结果
