# Tomcat


Tomcat是一个免费的开放源代码的Web应用服务器，目前属于Apache软件基金会的Jakarta项目中的一个核心项目。


## 实例，安装部署最新tomcat-9

```
yum install java-1.8.0-openjdk.x86_64 -y
wget http://www.apache.org/dist/tomcat/tomcat-9/v9.0.0.M22/bin/apache-tomcat-9.0.0.M22.tar.gz
tar -xvpf apache-tomcat-9.0.0.M22.tar.gz -C /opt/
echo "export CATALINA_HOME="/opt/apache-tomcat-9.0.0.M22" >> ~/.bashrc
echo "export JRE_HOME=/usr/lib/jvm/jre-1.8.0-openjdk.x86_64/" >> ~/.bashrc
source ~/.bashrc
/opt/apache-tomcat-9.0.0.M22/bin/startup.sh
```

## 验证服务运行状态

* 打开浏览器访问：`http://ip:8080` 能出现apache tomcat配置页面，说明配置成功
* 相关配置在`/opt/apache-tomcat-9.0.0.M22/conf目录下` 

