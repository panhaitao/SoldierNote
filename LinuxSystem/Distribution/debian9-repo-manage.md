
### 如何同步上游仓库

创建参考配置，如下所示：

* 执行命令 `gpg --gen-key`创建签名密钥对，导入当前管理仓库所在的机器，具体执行步骤略：
* 在repo目录 创建`reprepro`需要的配置:
   * conf/distributions
```
Origin: orion
Label: Orion Linux Server Main Repo
Codename: orion
Suite: stable
Architectures: i386 amd64 source
Components: main non-free contrib
UDebComponents: main
Contents: udebs percomponent allcomponents
Description: Orion Linux Server 
SignWith: Orion Server kui Automatic Signing Key <packages@orion.pub> 
Log: orion.log
Update: upstream-main
```
   * conf/updates
```
Name: upstream-main
Method: http://mirrors.ustc.edu.cn/debian/ 
Suite: stretch
Components: main contrib non-free
Architectures: i386 amd64 source
GetInRelease: yes
FilterSrcList: install filterlist/debian-stretch-src
VerifyRelease: blindtrust
```
   * conf/incoming
```
Name: default
IncomingDir: incoming/
TempDir: temp/
MorgueDir: morgue/
LogDir: incoming-logs/
Allow: orion stretch>orion
Permit: unused_files older_version
Cleanup: unused_files on_deny on_error
```
   * 最后执行命令
```
reprepro -V update
```
这列出最基本的实例，更多配置和更多高级特性请参考`man reprepro`.

### 源码与打包 

* 修改来自上游仓库的软件包

```
apt-get source zip
apt-get build-dep zip -y
cd zip-3.0
...
dpkg-buildpackage -a
```
    
* 获取上游源码包制作新的deb包

```
wget http://ftp.gnu.org/pub/gnu/ed/ed-1.9.tar.gz
tar -xvpf ed-1.9.tar.gz
cd ed-1.9
dh_make -s -y -e panhaitao@orion.pub -f ../ed-1.9.tar.gz
apt install autotools-dev -y
dpkg-buildpackage -a
```

* 如何源码目录 debian/source/format 是3.0 (native)格式，那么这个工作就比较简单，连同代码和debian目录文件，全部提交到远端git仓库，每次克隆下来就是一套完整的deb源码包，直接构建就好.

* 如何源码目录 debian/source/format 是3.0 (quilt))格式，可以考虑使用git仅仅托管debian目录
```
apt-get source pkg_name                           # 从仓库获取源码
cd pkg_name/ && rm -rvf pkg_name/debian           # 删除陈旧的debian目录
cd pkg_name/ && git clone git_repo_url debian     # 从仓库获取最新最新的debian 
编译构建 ...
```

最后打包好的软件包可以使用`dput`工具上传到仓库管理主机的`/data/UploadQueue`目录，下文会谈到这个目录的用途,具体使用参考`man dput`。

## 管理仓库

`reprepro` 可以用来方便的管理的deb包导入仓库，推荐的方式是使用reprepro工具操作.changes文件，完整的导入二进制和源码示例如下：
`reprepro inlude <codename> glibc_2.23_amd64.changes`

下面是一个结合inotifywait实现自动管理仓库的脚本，结合dput把构建好的软件包提交到仓库对应主机 /data/UploadQueue目录就能实现自动管理仓库

```
#!/bin/bash

inotifywait -me close_write --format '%w%f' /data//UploadQueue 2> /dev/null | while read line
do
    if [ "${line##*.}" = "changes" ];then
        DIST=`cat $line | grep Distribution | awk '{print $2}'` 
        cd repo_tools_dir && reprepro.sh include $DIST $line
    fi
done
```

仓库推送流程: 开发版本仓库 -> 内网正式仓库 -> 外网正式仓库，TIPS：建议每个提交阶段仓库都能创建快照，在遇到问题的时候也好做回滚操作，比如利用LVM，btrfs。

