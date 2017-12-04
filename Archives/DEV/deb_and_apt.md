
---
title: DEB包与APT仓库
tags: 包管理
categories: 基础技能
---

DEB包与APT仓库基础（基础入门）
准备开发环境

apt-get install build-essential dpkg-dev debhelper

    build-essential 基础开发环境工具集
    dpkg-dev deb包开发基础套件
    debhelper 包含dh开头的命令集合,主要用于简化rules文件的编写，把一些通用，重复的操作用perl命令来代替。

修改来自上游仓库的软件包简要示例

确保 /etc/apt/sources.list 中开启 deb-src 源码仓库配置，例如：

deb-src [trusted=yes] http://10.1.10.21/server-dev/dsce-15-amd64 kui contrib main non-free

获取dsc格式的源码，重新编译打包

apt-get source zip
cd zip-3.0
apt-get build-dep zip -y
…
dpkg-buildpackage -a

debian目录的重要文件

    debian/rules deb格式软件包的编译规则文件
    debian/control 定义二进制deb包的名称，编译依赖，安装依赖等信息
    debian/changelog 记录软件包修订版记录，以及定义版本号码
    debian/compat 定义对 debhelper 最低版本要求
    debian/source/format 定义 deb 源代码包格式
    debian/copyright 定义版权信息

debian/rules 解析

rules文件本质上是一个Makefile文件，这个Makefile文件定义了创建deb格式软件包的规则。打包工具按照rules文件指定的规则，完成编译，将软件安装到临时安装目录 debiani/tmpdir，清理编译目录等操作，并依据安装到临时目录的文件来生成deb格式的软件包。
deb包的执行脚本

许多软件安装前或安装后都需要进行一些设置工作，deb格式的软件安装过程执行的操作是由如下脚本来控制的

debian/preinst    安装前执行脚本
debian/postinst   安装后执行脚本
debian/prerm      卸载前执行脚本
debian/postrm     卸载后执行脚本

创建APT仓库

工具 reprepro 一个快速搭建deb软件仓库的工具。

    安装软件包

    执行命令 apt-get install reprepro -y

    创建配置文件
    比如仓库目录在/var/www/repo 为例

mkdir conf/
cat > conf/distributions << "EOF"
Origin: deepin
Label:  kui
Codename: kui
Architectures: i386 amd64 source
Components: main
UDebComponents: main
Contents: .gz
Version: 2017.5.12
Description: local repo 2017.5.12
EOF

    向仓库导入软件包

reprepro includedeb kui pkgdir/*.deb
reprepro includeudeb kui pkgdir/*.udeb
reprepro includedsc kui pkgdir/*.dsc

    添加apt 仓库配置文件

cat >> /etc/apt/sources.list  << "EOF"
deb file:///var/www/repo kui main
deb-src file:///var/www/repo kui main
EOF
# DEB包与APT仓库基础
## 准备开发环境

    `apt-get install build-essential dpkg-dev dh-make debhelper dpkg-sign` 

    * gcc        GNU C语言编译器
    * g++        GNU C++语言编译器
    * make       GNU自动化构建工具 
    * autotools  autoconf automake 工具集  
    * dpkg-dev   这个软件包包括了在解开、制作、上传Debian源文件包时需要用到的工具
    * diff/patch 源码补丁制作与补丁管理工具
    * fakeroot   模拟变成root用户，这在创建软件包的过程的一些部分是必要的
    * dh-make    提供了我们需要用到的 dh_make 命令,用于根据上游tarball生成我们deb包模板
    * debhelper  包含dh开头的命令集合,主要用于简化rules文件的编写，把一些通用，重复的操作用perl命令来代替。  
    * gnupg      加密签名相关
    * dpkg-sign  deb包签名工具 

    ## 基础部分

    ### 修改来自上游仓库的软件包简要示例

    ```
    apt-get source zip
    cd zip-3.0
    apt-get build-dep zip -y
    …
    dpkg-buildpackage -a
    ```

    ### debian目录的重要文件

    * debian/control             定义二进制deb包的名称，编译依赖，安装依赖等信息
    * debian/changelog        记录软件包修订版记录，以及定义版本号码
    * debian/compat             定义对 debhelper 最低版本要求 
    * debian/source/format   定义 deb 源代码包格式    
    * debian/copyright          定义版权信息
    * debian/rules                 

    ### debian/rules  解析

    rules文件本质上是一个Makefile文件，这个Makefile文件定义了创建deb格式软件包的规则。打包工具按照rules文件指定的规则，完成编译，将软件安装到临时安装目录 debiani/tmpdir，清理编译目录等操作，并依据安装到临时目录的文件来生成deb格式的软件包。

    rules文件一般会包含，”binary-arch”, ”binary-indep”, ”binary”，”build”, ”clean”, ”install”, 等targets。

    ### dh命令简要解析

    dh是debhelper包中的命令序列，dh开头的命令主要用于简化rules文件的编写，把一些通用的重复的操作用perl命令来代替。

    下面是一些dh命令和实际对应执行的操作的简要介绍

    ```
    dh_auto_clean           make distclean
    dh_auto_configure       ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var ...
    dh_auto_build           make
    dh_auto_test            make test
    dh_auto_install         make install DESTDIR=/path/to/package_version-revision/debian/package 

    以上的targets 如果需要 fakeroot 操作，则需要加上dh_testroot
    ```

    ### deb包的执行脚本

    许多软件安装前或安装后都需要进行一些设置工作，deb格式的软件安装过程执行的操作是由如下脚本来控制的

        debian/preinst    安装前执行脚本
        debian/postinst   安装后执行脚本
        debian/prerm      卸载前执行脚本
        debian/postrm     卸载后执行脚本

    ## 深入理解打包

    ### 从源码安装开始 

    基于 autotools 制作的源码包编译安装,通常为如下步骤

    ```
    ./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var 
    make 
    make install
    make clean
    ```

    ### 从软件源码包开始制作deb包

    ```
     wget http://ftp.gnu.org/gnu/tar/tar-1.26.tar.bz2
     tar -xvpf tar-1.26.tar.bz2
     cd tar-1.26
     dh_make -e regulus_cn@163.com -f ../tar-1.26.tar.bz2
     … 
     debian/rules
     debian/changlog
     dpkg-buildpackage -a
     ...
    ```

    更多细节参考  

    ＊ [ https://www.debian.org/doc/manuals/maint-guide/index.en.html ]
    ＊ [ https://www.debian.org/doc/debian-policy/ ］


    ### 创建一个简单的 debian/rules
    ```
    #!/usr/bin/make -f

    binary:build install 
        dh_gencontrol
        dh_md5sums 
        dh_builddeb 
    binary-indep: binary
    binary-arch: binary
    build:
        ./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var
        make -j16
    install:
            make install DSEDIR=./debian/tmpdir/    
    clean:
        make clean
        rm -rf debian/tmpdir/

    ```

    ### 全部操作 使用 debhelper 命令集来简化 debian/rules 的编写  

    ```
    #!/usr/bin/make -f

    binary:build install 
        dh_gencontrol
        dh_md5sums 
        dh_builddeb 
    binary-indep: binary
    binary-arch: binary
    build:
        dh_auto_configure
        dh_auto_build
    install:
            dh_auto_install
    clean:
            dh_auto_clean
    ```

    ### 使用默认的rules

    在新版本中，dh_make 会使用默认的dh $@ 指令 来进一步简化 rules 文件的编写

    ```
    %:
        dh $@    
    ```

    使用 dh $@时，dh_make会执行一系列的默认的dh_命令，具体请参考 [ http://www.debian.org/doc/manuals/maint-guide/dreq.zh-cn.html#defaultrules ] 

    这一系列的默认的dh命令，不能满足所有软件包的编译安装，我们可以通过 override_来重新定义 dh命令，示例如下:

    ```
    %:
            dh $@ --with python2

    override_dh_install:
            python setup.py install --root=$(CURDIR)/debian/timelib --prefix=/usr --install-layout=deb

    override_dh_auto_clean:
            dh_auto_clean
            rm -rf $(CURDIR)/debian/timelib

    ```


    ##  仓库同步

    ### 使用 reprepro工具同步  

    ###  使用 apt-mirror工具来同步

    #### 基本配置：

    /etc/apt/mirror.list

        ############# config ##################
        #
        # set base_path    /var/spool/apt-mirror
        #
        # set mirror_path  $base_path/mirror
        # set skel_path    $base_path/skel
        # set var_path     $base_path/var
        # set cleanscript $var_path/clean.sh
        # set defaultarch  <running host architecture>
        # set postmirror_script $var_path/postmirror.sh
        # set run_postmirror 0
        set base_path    /data/upstream/
        set mirror_path  $base_path/mirror
        set skel_path    $base_path/skel
        set var_path     $base_path/var
        set nthreads     20
        set run_postmirror 0

        ############# end config ##############

        deb http://security.ubuntu.com/ubuntu precise-security main restricted universe multiverse
        deb-src http://security.ubuntu.com/ubuntu precise-security main restricted universe multiverse


    #### 结合crond 每天自动同步

    ```
    /etc/cron.d/apt-mirror
    0 1 * * * root /usr/bin/apt-mirror &> /data/log/cron.log &
    ```


    ## deb 签名

    ### 生成签名所需的密钥
    ```
    gpg --gen-key
    gpg --list-keys
    gpg --export -a 6A9E1B52 > key.pub
    apt-key add key.pub
    ```

    用户需要将这个公钥key.pub下载添加到系统的keyring中，就可以使用对应签过名的软件包

    ### 给deb软件包签名

    给软件包签名指令如下,需要输入之前生成公钥时的密码，：
    ```
     dpkg-sig -k keyid --sign builder /your_packages_<version>_<architecture>.deb -f passwdfile
     Keyid          为之前生成的公钥ID， 
     --sign builder 后面为deb全路径和deb包
    ```

    参考文档 [ http://blog.csdn.net/michaelwubo/article/details/keyid ]


    #### 其他进阶工具

    * debootstrap    构建临时环境
    * devscripts      辅助脚本集合
    * pbuilder         用于创建和维护chroot环境的程序。在此chroot环境中构建Debian可以检查构建软件包的依赖关系的正确性
    * ccache            用于缓存编译临时文件，加快编译

    #### 介绍下pbuilder 的基本用法

        pbuilder create
        pbuilder build  *.dsc

    * https://wiki.ubuntu.com/PbuilderHowto



    ## 参考文档：


    http://live-systems.org/build/
    http://www.buildd.net/
    https://wiki.debian.org/buildd



    * https://wiki.debian.org/Debootstrap/
    * https://wiki.debian.org/Simple-CDD/Howto
    * https://wiki.debian.org/DebianCustomCD
    * http://debian-handbook.info/browse/stable/sect.automated-installation.html#sect.simple-cdd
    * <https://wiki.debian.org/tasksel> 安装定制相关
    * <http://www.infrastructureanywhere.com/documentation/additional/mirrors.html#reprepro> reprepro udeb deb dsc
    * <https://www.debian.org/releases/wheezy/example-preseed.txt> preseed 参考文档



    也十分简单，命令格式为：

    sudo debootstrap --arch [平台] [发行版本代号] [目录]
    比如下面的命令
    sudo debootstrap --arch i386 trusty /mnt



debian 打包原理分析

还是从deb源码包说起，使用dh_make初始化之后的源码目录下会生成debian目录，里面包换所有打包相关的文件，一个典型的deb-src格式源码包,下面会有如下文件:

changelog              记录软件包修订版记录,以及定义生成的二进制包的版本号
compat                 定义对 debhelper 最低版本要求
rules                  一个别名的Makefile文件,用于控制整个打包流程 
postinst               安装执行脚本
source/format          定义 deb 源代码包格式      
control                定义二进制deb包的名称，编译依赖，安装依赖等控制信息
copyright              定义版权信息
docs                   定义默认文档
README                 说明文档
README.Debian          说明文档
README.source          版本变更记录
*.ex                   这些是用于参考的模板文件

在源码目录下执行dpkg-buildpackage命令开始打包，会完成如下流程:

    首先会调用dpkg-source 生成deb-src格式的源码包
    然后执行 debian/rules完成打包操作。debian/rules是整个打包流程的核心控制文件，这个文件本质上是一个别名的Makefile文件，其中定义了创建deb格式软件包的规则。打包工具按照rules文件指定的规则，完成编译，将软件安装到临时安装目录(debian/tmp 或者 debian/PKG_NAME)，生成对应二进制包的控制文件，并调用dpkg-deb依据安装到临时目录的文件和控制文件来生成deb格式的安装包。

更多具体细节可以参考debian新人维护手册


[TOC]
# DEB包与APT仓库基础

## 准备开发环境

`apt-get install build-essential dpkg-dev dh-make debhelper dpkg-sign` 

* gcc        GNU C语言编译器
* g++        GNU C++语言编译器
* make       GNU自动化构建工具 
* autotools  autoconf automake 工具集  
* dpkg-dev   这个软件包包括了在解开、制作、上传Debian源文件包时需要用到的工具
* diff/patch 源码补丁制作与补丁管理工具
* fakeroot   模拟变成root用户，这在创建软件包的过程的一些部分是必要的
* dh-make    提供了我们需要用到的 dh_make 命令,用于根据上游tarball生成我们deb包模板
* debhelper  包含dh开头的命令集合,主要用于简化rules文件的编写，把一些通用，重复的操作用perl命令来代替。  
* gnupg      加密签名相关
* dpkg-sign  deb包签名工具 

## 基础部分

### 修改来自上游仓库的软件包简要示例

```
apt-get source zip
cd zip-3.0
apt-get build-dep zip -y
…
dpkg-buildpackage -a
```

### debian目录的重要文件

* debian/control             定义二进制deb包的名称，编译依赖，安装依赖等信息
* debian/changelog        记录软件包修订版记录，以及定义版本号码
* debian/compat             定义对 debhelper 最低版本要求 
* debian/source/format   定义 deb 源代码包格式	
* debian/copyright          定义版权信息
* debian/rules                 

### debian/rules  解析

rules文件本质上是一个Makefile文件，这个Makefile文件定义了创建deb格式软件包的规则。打包工具按照rules文件指定的规则，完成编译，将软件安装到临时安装目录 debiani/tmpdir，清理编译目录等操作，并依据安装到临时目录的文件来生成deb格式的软件包。

rules文件一般会包含，”binary-arch”, ”binary-indep”, ”binary”，”build”, ”clean”, ”install”, 等targets。

### dh命令简要解析

dh是debhelper包中的命令序列，dh开头的命令主要用于简化rules文件的编写，把一些通用的重复的操作用perl命令来代替。

下面是一些dh命令和实际对应执行的操作的简要介绍

```
dh_auto_clean           make distclean
dh_auto_configure       ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var ...
dh_auto_build           make
dh_auto_test            make test
dh_auto_install         make install DESTDIR=/path/to/package_version-revision/debian/package 

以上的targets 如果需要 fakeroot 操作，则需要加上dh_testroot
```

### deb包的执行脚本

许多软件安装前或安装后都需要进行一些设置工作，deb格式的软件安装过程执行的操作是由如下脚本来控制的

    debian/preinst    安装前执行脚本
    debian/postinst   安装后执行脚本
    debian/prerm      卸载前执行脚本
    debian/postrm     卸载后执行脚本

## 深入理解打包

### 从源码安装开始 

基于 autotools 制作的源码包编译安装,通常为如下步骤

```
./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var 
make 
make install
make clean
```

### 从软件源码包开始制作deb包

```
 wget http://ftp.gnu.org/gnu/tar/tar-1.26.tar.bz2
 tar -xvpf tar-1.26.tar.bz2
 cd tar-1.26
 dh_make -e regulus_cn@163.com -f ../tar-1.26.tar.bz2
 … 
 debian/rules
 debian/changlog
 dpkg-buildpackage -a
 ...
```

更多细节参考  

＊ [ https://www.debian.org/doc/manuals/maint-guide/index.en.html ]
＊ [ https://www.debian.org/doc/debian-policy/ ］

        
### 创建一个简单的 debian/rules
```
#!/usr/bin/make -f

binary:build install 
	dh_gencontrol
	dh_md5sums 
	dh_builddeb 
binary-indep: binary
binary-arch: binary
build:
	./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var
	make -j16
install:
        make install DSEDIR=./debian/tmpdir/	
clean:
	make clean
	rm -rf debian/tmpdir/

```

### 全部操作 使用 debhelper 命令集来简化 debian/rules 的编写  

```
#!/usr/bin/make -f

binary:build install 
	dh_gencontrol
	dh_md5sums 
	dh_builddeb 
binary-indep: binary
binary-arch: binary
build:
	dh_auto_configure
	dh_auto_build
install:
        dh_auto_install
clean:
        dh_auto_clean
```

### 使用默认的rules

在新版本中，dh_make 会使用默认的dh $@ 指令 来进一步简化 rules 文件的编写

```
%:
	dh $@    
```

使用 dh $@时，dh_make会执行一系列的默认的dh_命令，具体请参考 [ http://www.debian.org/doc/manuals/maint-guide/dreq.zh-cn.html#defaultrules ] 

这一系列的默认的dh命令，不能满足所有软件包的编译安装，我们可以通过 override_来重新定义 dh命令，示例如下:

```
%:
        dh $@ --with python2

override_dh_install:
        python setup.py install --root=$(CURDIR)/debian/timelib --prefix=/usr --install-layout=deb

override_dh_auto_clean:
        dh_auto_clean
        rm -rf $(CURDIR)/debian/timelib

```


##  仓库同步

### 使用 reprepro工具同步  

###  使用 apt-mirror工具来同步

#### 基本配置：

/etc/apt/mirror.list

    ############# config ##################
    #
    # set base_path    /var/spool/apt-mirror
    #
    # set mirror_path  $base_path/mirror
    # set skel_path    $base_path/skel
    # set var_path     $base_path/var
    # set cleanscript $var_path/clean.sh
    # set defaultarch  <running host architecture>
    # set postmirror_script $var_path/postmirror.sh
    # set run_postmirror 0
    set base_path    /data/upstream/
    set mirror_path  $base_path/mirror
    set skel_path    $base_path/skel
    set var_path     $base_path/var
    set nthreads     20
    set run_postmirror 0
    
    ############# end config ##############
    
    deb http://security.ubuntu.com/ubuntu precise-security main restricted universe multiverse
    deb-src http://security.ubuntu.com/ubuntu precise-security main restricted universe multiverse


#### 结合crond 每天自动同步

```
/etc/cron.d/apt-mirror
0 1 * * * root /usr/bin/apt-mirror &> /data/log/cron.log &
```


## deb 签名

### 生成签名所需的密钥
```
gpg --gen-key
gpg --list-keys
gpg --export -a 6A9E1B52 > key.pub
apt-key add key.pub
```

用户需要将这个公钥key.pub下载添加到系统的keyring中，就可以使用对应签过名的软件包

### 给deb软件包签名

给软件包签名指令如下,需要输入之前生成公钥时的密码，：
```
 dpkg-sig -k keyid --sign builder /your_packages_<version>_<architecture>.deb -f passwdfile
 Keyid          为之前生成的公钥ID， 
 --sign builder 后面为deb全路径和deb包
```

参考文档 [ http://blog.csdn.net/michaelwubo/article/details/keyid ]


#### 其他进阶工具

* debootstrap    构建临时环境
* devscripts      辅助脚本集合
* pbuilder         用于创建和维护chroot环境的程序。在此chroot环境中构建Debian可以检查构建软件包的依赖关系的正确性
* ccache            用于缓存编译临时文件，加快编译

#### 介绍下pbuilder 的基本用法

    pbuilder create
    pbuilder build  *.dsc

* https://wiki.ubuntu.com/PbuilderHowto



## 参考文档：


http://live-systems.org/build/
http://www.buildd.net/
https://wiki.debian.org/buildd
 
##  仓库管理

工具 reprepro 一个快速搭建deb软件仓库的工具。

### 安装 apt-get install reprepro -y

### 使用

创建配置文件，比如仓库目录在/var/www/repo  为例

<pre>
cd /var/www/repo/
cat > conf/distributions << "EOF"
Origin: deepin
Label:  jessie
Codename: jessie
Architectures: i386 amd64 source
Components: main
UDebComponents: main
Contents: .gz
Version: 2015.4.17
Description: local repo 2015.4.17
SignWith: 48FE4F60

Origin: deepin
Label:  jessie-updates
Codename: jessie-updates
Architectures: i386 amd64 source
Components: main
UDebComponents: main
Contents: .gz
Version: 2015.4.17
Description: local repo update 2015.4.17
SignWith: 48FE4F60

Origin: deepin
Label:  jessie-security
Codename: jessie-security
Architectures: i386 amd64 source
Components: main
UDebComponents: main
Contents: .gz
Version: 2015.4.17
Description: local repo update 2015.4.17
SignWith: 48FE4F60
EOF
</pre>

### 更新仓库

<pre>
reprepro includedeb wheezy pkgdir/*.deb
reprepro includeudeb wheezy pkgdir/*.udeb
reprepro includedsc wheezy pkgdir/*.dsc
</pre>

<pre>
SignWith: key_id  仓库签名
UDebComponents: main   Udeb包相关
</pre>

    /var/www/repo/
    conf/  
    db/..  
    dists/..  
    pool/..


## 创建ISO

    build-simple-cdd --conf ./custom.conf

* https://wiki.debian.org/Debootstrap/
* https://wiki.debian.org/Simple-CDD/Howto
* https://wiki.debian.org/DebianCustomCD
* http://debian-handbook.info/browse/stable/sect.automated-installation.html#sect.simple-cdd
* <https://wiki.debian.org/tasksel> 安装定制相关
* <http://www.infrastructureanywhere.com/documentation/additional/mirrors.html#reprepro> reprepro udeb deb dsc
* <https://www.debian.org/releases/wheezy/example-preseed.txt> preseed 参考文档



也十分简单，命令格式为：

sudo debootstrap --arch [平台] [发行版本代号] [目录]
比如下面的命令
sudo debootstrap --arch i386 trusty /mnt



### 详解 debian/rules 

一个通用的源码包可能使用如下方式编译安装:

```
./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var 
make 
make install
```
  
将编译安装转化为一个简单的rules文件来完成打包, rules文件一般会包含，”binary-arch”, ”binary-indep”, ”binary”，”build”, ”clean”, ”install”, 等targets，参考如下例子:

```
#!/usr/bin/make -f

binary:build install 
	dh_gencontrol
	dh_md5sums 
	dh_builddeb 
binary-indep: binary
binary-arch: binary
build:
	./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var
	make 
install:
        make install DSEDIR=./debian/pkg_name/	
clean:
	make clean
	rm -rf debian/pkg_name/
```

很多操作是通用重复的，因此debian社区开发了一个 包含常用操作dh命令的 debhelper 软件包来简化 debian/rules 的编写  

```
#!/usr/bin/make -f

binary:build install 
	dh_gencontrol
	dh_md5sums 
	dh_builddeb 
binary-indep: binary
binary-arch: binary
build:
	dh_auto_configure
	dh_auto_build
install:
        dh_auto_install
clean:
        dh_auto_clean
</pre>


即使使用各种dh命令来简化`debian/rules`的编写，对于维护众多软件包的发行版来说，编写`debian/rules`依然是重复机械的体力劳动，最新版本的 dh_make 会使用默认的`dh $@` 来进一步简化rules文件的编写

```
%:
	dh $@    
```

使用 dh $@时，dh_make会执行一系列的默认的dh_命令，具体请参考[debian官方手册] (http://www.debian.org/doc/manuals/maint-guide/dreq.zh-cn.html#defaultrules)
当默认执行的dh命令，不能满足所有软件包的编译安装，我们可以通过 override_来重新定义 dh命令，示例如下:

```
%:
	dh $@
override_dh_auto_install:
	mv release/bin/liblfs.so release/bin/liblfs.so.1.02.160708
	dh_auto_install
```

#### dh命令简要解析

dh是debhelper包中的命令序列，dh开头的命令主要用于简化rules文件的编写，把一些通用的重复的操作用perl命令来代替。下面是部分dh命令和实际对应执行的操作的简要介绍

```
dh_auto_clean           make distclean
dh_auto_configure       ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var ...
dh_auto_build           make
dh_auto_test            make test
dh_auto_install         make install DESTDIR=/path/to/package_version-revision/debian/package 
```
以上的targets 如果需要 fakeroot 操作，则需要加上dh_testroot

#### deb包的执行脚本

许多软件安装前或安装后都需要进行一些设置工作，deb格式的软件安装过程执行的操作是由如下脚本来控制的

    debian/preinst    安装前执行脚本
    debian/postinst   安装后执行脚本
    debian/prerm      卸载前执行脚本
    debian/postrm     卸载后执行脚本

#### deb源代码包新格式

* Format：1.0		一个 .dsc 文件，一个 .orig.tar.gz 文件，一个 .diff.gz 文件 　　
* Format：2.0		这个格式不建议广泛使用，是个过渡格式
* Format：3.0 (native)	包含了 debian 化的所有更改全部在一个压缩包中　　
* Format：3.0 (quilt)	一个 .dsc 文件,  一个 .debian.tar.{gz,bz2,lzma} 包含了 debian 化的所有更改, 零个或者多个 .orig-.tar.{gz,bz2,lzma}， 　　
* Format：3.0 (git)	实验性质的，源代码包和版本控制系统 (git) 的结合
* Format：3.0 (bzr)	实验性质的，源代码包和版本控制系统 (bzr) 的结合


## deb 签名


### 生成签名所需的密钥

    # gpg --gen-key
    # gpg --list-keys
    # gpg --export -a 6A9E1B52 > key.pub
    # apt-key add key.pub

用户需要将这个公钥key.pub下载添加到系统的keyring中，就可以使用对应签过名的软件包

### 给deb软件包签名

给软件包签名指令如下,需要输入之前生成公钥时的密码，：

    dpkg-sig -k keyid --sign builder /your_packages_<version>_<architecture>.deb

    Keyid          为之前生成的公钥ID， 
    --sign builder 后面为deb全路径和deb包


参考文档 [ http://blog.csdn.net/michaelwubo/article/details/keyid ]


#### 其他进阶工具

* debootstrap    构建临时环境
* devscripts      辅助脚本集合
* pbuilder         用于创建和维护chroot环境的程序。在此chroot环境中构建Debian可以检查构建软件包的依赖关系的正确性
* ccache            用于缓存编译临时文件，加快编译

#### 介绍下pbuilder 的基本用法

    pbuilder create
    pbuilder build  *.dsc

* https://wiki.ubuntu.com/PbuilderHowto



## 参考文档：


http://live-systems.org/build/
http://www.buildd.net/
https://wiki.debian.org/buildd
 
##  仓库管理

工具 reprepro 一个快速搭建deb软件仓库的工具。

### 安装 apt-get install reprepro -y

### 使用

创建配置文件，比如仓库目录在/var/www/repo  为例

<pre>
cd /var/www/repo/
cat > conf/distributions << "EOF"
Origin: regulus
Label:  wheezy
Codename: wheezy
Architectures: i386 amd64 source 
Components: main
Version: 2015.4.17
Description: regulus.intra.repo 2015.4.17
EOF
</pre>

### 更新仓库

<pre>
reprepro includedeb wheezy pkgdir/*.deb
reprepro includedsc wheezy pkgdir/*.dsc
</pre>

    /var/www/repo/
    conf/  
    db/..  
    dists/..  
    pool/..

## DEB_BUILD_OPTIONS 

`DEB_BUILD_OPTIONS=nocheck`

This is a quick post to show how you can rebuild a debian package and skip some steps, like “make test” for example in the upstream package, by passing some build options. More and more debian packages are now supporting the nodocs, nocheck/notest build options. You might want this if you are repeatedly building the package and want to skip some parts and make it faster, or maybe some step is failing while running the tests and that is something acceptable and known. In this case you can build the package as usual and export DEB_BUILD_OPTIONS=nocheck.

For example rebuilding the mysql package takes quite a long time, and to skip the package run tests we will do something like:

dpkg-source -x mysql-dfsg-5.0_5.0.67-1.dsc
cd mysql-dfsg-5.0-5.0.67/
**DEB_BUILD_OPTIONS=nocheck debuild -us -uc**
Note: not all packages implement this option and you might want to look in the rules file and see if this is defined or not.

