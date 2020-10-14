# 命令行下使用socks5代理

1、privoxy安装
安装很简单用brew安装：

brew install privoxy
2、privoxy配置
打开配置文件 /usr/local/etc/privoxy/config

vim /usr/local/etc/privoxy/config
加入下面这两项配置项

listen-address 0.0.0.0:8118
forward-socks5 / localhost:1080 .
第一行设置privoxy监听任意IP地址的8118端口。第二行设置本地socks5代理客户端端口，注意不要忘了最后有一个空格和点号。

3、启动privoxy
因为没有安装在系统目录内，所以启动的时候需要打全路径。

sudo /usr/local/sbin/privoxy /usr/local/etc/privoxy/config
4、查看是否启动成功
netstat -na | grep 8118
看到有类似如下信息就表示启动成功了

tcp4       0      0  *.8118                 *.*                    LISTEN
如果没有，可以查看日志信息，判断哪里出了问题。打开配置文件找到 logdir 配置项，查看log文件。

5、privoxy使用
在命令行终端中输入如下命令后，该终端即可翻墙了。

export http_proxy='http://localhost:8118'
export https_proxy='http://localhost:8118'
他的原理是讲socks5代理转化成http代理给命令行终端使用。

如果不想用了取消即可

unset http_proxy
unset https_proxy
如果关闭终端窗口，功能就会失效，如果需要代理一直生效，则可以把上述两行代码添加到 ~/.bash_profile 文件最后。

vim ~/.bash_profile
-----------------------------------------------------
export http_proxy='http://localhost:8118'
export https_proxy='http://localhost:8118'
-----------------------------------------------------
使配置立即生效

source  ~/.bash_profile
还可以在 ~/.bash_profile 里加入开关函数，使用起来更方便

function proxy_off(){
    unset http_proxy
    unset https_proxy
    echo -e "已关闭代理"
}

function proxy_on() {
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
    export http_proxy="http://127.0.0.1:8118"
    export https_proxy=$http_proxy
    echo -e "已开启代理"
}



