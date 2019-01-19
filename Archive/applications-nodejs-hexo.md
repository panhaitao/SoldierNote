# 使用hexo搭建个人博客

##  安装nodejs8版本


* CentOS7 

```
curl -sL https://rpm.nodesource.com/setup_8.x | bash -
yum  makecache -y
yum install -y nodejs && 
```

* Debian9

```
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt update -y
yum install -y nodejs && 
```

## 安装hexo和完成基本配置 

```
mkdir /opt/blog
cd /opt/blog &&                                            \
npm config set registry https://registry.npm.taobao.org && \
npm install hexo-cli -g  &&                                \
hexo init /opt/blog &&                                     \
npm install

hexo server  -i 0.0.0.0 -p 80
```

## 安装主题

```
git clone https://github.com/chaooo/hexo-theme-BlueLake.git themes/BlueLake
npm install hexo-renderer-jade@0.3.0 --save
npm install hexo-renderer-stylus --save
```

在Hexo配置文件（hexo/_config.yml）中把主题设置修改为BlueLake。

```
theme: BlueLake
```

## 托管文档

可以将 source/_posts 目录的MD文件托管到github便于发布网站的自动更新,关于git的操作忽略,具体可参考github的帮助，

## 自动同步

1. 首先将同步一份仓库到hexo 工作目录
```
git clone https://github.com/panhaitao/hexo-blog.git /opt/blog/source/_posts/
```
2. 然后借助crond实现自动同步,创建/etc/cron.d/sync-git-repo
```
*/1 * * * * root cd /opt/blog/source/_posts/ && git pull &> /dev/null
```
3. 重启crond服务生效


## 使用ansbile 来维护以上全部操作



## 参考

* https://hexo.io/docs/server
* https://github.com/chaooo/hexo-theme-BlueLake
* https://www.hugeserver.com/kb/install-nodejs8-centos7-debian8-ubuntu16/
* https://hub.docker.com/r/ipple1986/hexo/~/dockerfile/
