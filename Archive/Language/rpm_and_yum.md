# RPM包与YUM仓库基础（基础入门）

## 什么是RPM
RPM包源自于Red Hat Linux 分发版，是Linux下常见的软件包格式之一，RPM包有两种包格式：

    扩展名为 .rpm     封装完成的RPM二进制安装包
    扩展名为 .src.rpm 包含编译控制文件的SRPM源码包


## 同步yum仓库

/etc/yum.repos.d/centos-6.8.repo 
```
[centos6.8-64]
name=centos 6.8 x86-64
baseurl=http://vault.centos.org/6.8/os/x86_64/
enabled=1
priority=1
```

`yum repolist`,列出当前的配置中的仓库，输出如下： 
```
repo id         repo name               status
centos6.8       centos 6.8 x86-64        6,696
repolist: 6,696
```

使用reposync工具同步仓库，参考操作如下`reposync -m <repo id>`

## 构建 RPM 软件包

* 准备工作环境
  * 系统中安装好 rpmbuild 打包工具
  * 编写一个扩展名为 .spec 文件，该文件指导 rpmbuild 命令如何构建和打包软件。这个文件可以任意地给它命名并把它放到任何地方，RPM对此没有限制。

修改上游源码包，获取上游SRPM包，将其解压到工作目录`rpm -ivh http://mirrors.ustc.edu.cn/fedora/releases/22/Server/source/SRPMS/b/bc-1.06.95-13.fc22.src.rpm` 解压后,会把srpm包解压到 ~/rpmbuild/ 目录，其中：

* spec文件解压到 ~/rpmbuild/SPECS/ 目录中
* 补丁和源码解压到 ~/rpmbuild/SOURCES/ 目录中

重新编译源码包`rpmbuild -ba ~/rpmbuild/SPECS/bc.spec` 编译完成后，结果会存放在 ~/rpmbuild/SRPM/ ~/rpmbuild/RPM/ 目录中，在这里需要了解一下rpm的环境变量，查看rpm的环境变量 rpm --showrc ，其中 _topdir 定义了工作目录位置，默认是 $HOME/rpmbuild/，该目录下有五个目录：

    SPECS       放置 .spec 文件
    SOURCES     放置套件的源码及补丁等
    BUILD       用于存放解后压合并布补丁的源码目录
    BUILDROOT   用于存放封装生成的 RPM 安装包的文件
    RPMS        放置二进制 RPM 安装包 (.rpm)
    SRPMS       放置源码格式的 RPM包 (.src.rpm)

下面总结了在您运行 rpm -ba filename.spec 时，RPM 都做些什么：

    读取并解析 filename.spec 文件
    运行 %prep 部分来将源代码解包一个临时目录 (~/rpmbuild/BUILD/XXXX)，并应用所有的补丁程序
    运行 %build 部分来编译代码
    运行 %install 部分将代码安装到一个临时目录（~/rpmbuild/BUILDROOT/XXXX）
    读取 %files 部分的文件列表，收集文件并创建二进制和源 RPM 文件。
    运行 %clean 部分清楚临时构建目录

## 创建仓库

yum主要用于自动安装、升级rpm软件包，它能自动查找并解决rpm包之间的依赖关系。使用yum就需要有添加一个包含各种rpm软件包的repository（软件仓库），这个软件仓库我们习惯称为yum源，下面我们就讲述如何创建自定义的软件仓库。
创建仓库执行命令 `yum install createrepo -y`，安装一个名为createrepo的软件包，然后使用createrepo就可以完成yum仓库的创建，示例如下：

createrepo -g dvd-comps.xml -u Packages/ /repo

    -g dvd-comps.xml        指定分组配置文件
    -u Packages/            使用Packages/ 这个rpm包存放目录
    /repo                   仓库根目录， 默认生成的索引文件存放在这个目录下

各个版本软件分组参考可以从这里获取 ：`git clone git://git.fedorahosted.org/git/comps.git`

## 更新仓库

在一个已创建好的yum仓库目录下，添加或删除rpm包后，使用 –update 参数就可以完成仓库的更新 `createrepo -g dvd-comps.xml -u Packages/ --update /repo` 

在创建好的yum仓库目录下会创建repodata目录，里面存放XML格式或sqlite数据库的仓库索引文件，执行命令yum update，就是在同步yum源的索引，下面是repodata索引部分的概述：

    repomd.xml                   描述的其他元数据文件的文件
    primary.[xml/sqlite].[gz]    主要元数据信息文件，记录软件包报名,版本，预配置文件，依赖关系等
    filelists.[xml/sqlite].[gz]  软件包文件，目录列表描述信息
    other.[xml/sqlite].[gz]      目前只记录存储数据的变更记录
    comps.xml.[gz]               用于记录软件包组分类等信息(需要创建仓库的时候指定分组文件)

更多细节可参考文档 http://createrepo.baseurl.org/

## 添加软件源

以上文提到的创建好的yum的软件仓库为例，添加一个软件源. yum仓库配置文件扩展名是 .repo, 创建配置文件：/etc/yum.repos.d/local.repo
```
[local]
name=local
baseurl=file:///repo/
gpgcheck=0
```

重新执行命令yum update之后就可以使用这个软件仓库了。

## repo文件格式

所有 repository 服务器设置都遵循如下格式：

    [serverid]
    name=Some name for this server
    baseurl=url://path/to/repository/
    其他可选配置


* serverid 是用于区分不同的 repository ，必须有一个独一无二的名称；
* name 是对 repository 的描述部分
* baseurl 是服务器设置中最重要的部分，只有设置正确，才能从上面获取软件。它的格式是：
```
baseurl=url://server1/path/to/repository/
　　　   url://server2/path/to/repository/
　　　   url://server3/path/to/repository/
```

其中url 支持的协议有http:// ftp:// file://三种。baseurl 后可以跟多个url，

* 一个 repo 文件可以添加多个repository配置
* 一个 repository 配置中只能有一个baseurl
* 其中 url 指向的目录必须是这个repository 索引目录所在的根目录

## 打包辅助工具

实际开发过程中必须模拟用户的环境或是构建一个“干净”的环境（一个仅仅满足编译构建的最小系统环境）使用mock命令就达到在一个“干净”的环境重新编译构建。

安装软件包： `yum install mock -y`

使用 mock 工具编译软件包，需要在yum仓库中建立了一个sysbuild分组，该分组包含了一个最小化系统所需的基础软件包。以下是 comps.xml 参考：

```
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE comps PUBLIC "-//CentOS//DTD Comps info//EN" "comps.dtd">
<comps>
  <group>
    <id>sysbuild</id>
    <name>mock build base group</name>
    <name xml:lang="zh_CN">自动编译基础系统</name>
    <name xml:lang="zh_TW">自动编译基础系统</name>
    <description>mock build base group</description>
    <description xml:lang="zh_CN">自动编译基础系统</description>
    <description xml:lang="zh_TW">自动编译基础系统</description>
    <default>false</default>
    <uservisible>true</uservisible>
    <packagelist>
        <packagereq type="default">bash</packagereq>
        <packagereq type="default">gawk</packagereq>
        <packagereq type="default">rpm</packagereq>
        <packagereq type="default">rpm-build</packagereq>
        <packagereq type="default">bzip2</packagereq>
        <packagereq type="default">gcc</packagereq>
        <packagereq type="default">sed</packagereq>
        <packagereq type="default">coreutils</packagereq>
        <packagereq type="default">git</packagereq>
        <packagereq type="default">deepin-release</packagereq>
        <packagereq type="default">tar</packagereq>
        <packagereq type="default">cpio</packagereq>
        <packagereq type="default">gnupg2</packagereq>
        <packagereq type="default">texinfo</packagereq>
        <packagereq type="default">curl</packagereq>
        <packagereq type="default">grep</packagereq>
        <packagereq type="default">unzip</packagereq>
        <packagereq type="default">diffutils</packagereq>
        <packagereq type="default">gzip</packagereq>
        <packagereq type="default">redhat-rpm-config</packagereq>
        <packagereq type="default">util-linux-ng</packagereq>
        <packagereq type="default">findutils</packagereq>
        <packagereq type="default">make</packagereq>
        <packagereq type="default">patch</packagereq>
        <packagereq type="default">which</packagereq>
    </packagelist>
  </group>
  <category>
    <id>sysbuild</id>
    <name>sysbuild</name>
    <description>mock mini require</description>
    <display_order>60</display_order>
    <grouplist>
      <groupid>sysbuild</groupid>
    </grouplist>
  </category>
</comps>
```

根据需要修改默认配置 /etc/mock/default.cfg，配置文件中config_opts['chroot_setup_cmd'] = 'install @sysbuild' 分组名称sysbuild需要和仓库配置保持一致，参考配置如下：

```
config_opts['root'] = 'Rebuild-15-x86_64'
config_opts['target_arch'] = 'x86_64'
config_opts['legal_host_arches'] = ('x86_64',)
config_opts['chroot_setup_cmd'] = 'install @sysbuild'
config_opts['dist'] = 'deepin15'  # only useful for --resultdir variable subst
config_opts['yum.conf'] = """
[main]
keepcache=1
debuglevel=2
reposdir=/dev/null
logfile=/var/log/yum.log
retries=20
obsoletes=1
gpgcheck=0
assumeyes=1
syslog_ident=mock
syslog_device=
mdpolicy=group:primary
best=1

# repos
[deepin]
name= amd64 repo 
baseurl=http://vault.centos.org/6.8/os/x86_64/ 
enabled=1 
gpgcheck=0 
"""
```

一切准备就绪，开始使用mock 重新编译一个软件包。

    mock –init
    mock –rebuild pkg.src.rpm

小技巧：使用mock编译辅助脚本，并行编译软件包

```
#！/bin/bash
pkg=$1

cat > /etc/mock/$1.cfg <<EOF
config_opts['dist'] = 'deepin15'
config_opts['root'] = '$pkg'
config_opts['target_arch'] = 'x86_64'
config_opts['legal_host_arches'] = ('x86_64',)
config_opts['chroot_setup_cmd'] = 'install @buildsys-build'
config_opts['yum.conf'] = """
[main]
keepcache=1
debuglevel=2
reposdir=/dev/null
logfile=/var/log/yum.log
retries=20
obsoletes=1
gpgcheck=0
assumeyes=1
syslog_ident=mock
syslog_device=
mdpolicy=group:primary
best=1

[main]
name=centos main repo
baseurl=http://10.1.10.21/server-dev/dsee-15-amd64/main/
enabled=1
priority=1
gpgcheck=0
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-release

"""
EOF

mock -r $pkg --nocheck --cleanup-after --rebuild $pkg --resultdir=/data &>/tmp/$1.log &
```

## 深入理解RPM打包与仓库索引

### spec文件的内容

spec 文件有几个部分。第一部分是未标记的；其它部分以 %prep 和 %build 这样的行开始。

* spec 文件摘要部分定义了多种信息，其格式类似电子邮件消息头。
* Summary 是一行关于该软件包的描述。
* Name 是该软件包的基名， Version 是该软件的版本号。 Release 是 RPM 本身的版本号 ― 如果修复了 spec 文件中的一个错误并发布了该软件同一版本的新 RPM，就应该增加发行版号。
* License 应该给出一些许可术语（如：“GPL”、“Commercial”、“Shareware”）。
* Group 标识软件类型；那些试图帮助人们管理 RPM 的程序通常按照组列出 RPM。您可以在 /usr/share/doc/rpm-4.8.0/GROUPS 文件看到一个 Red Hat 使用的组列表
* Source0 、 Source1 等等给这些源文件命名（通常为 tar.gz 文件）。 %{name} 和 %{version} 是 RPM 宏，它们扩展成为头中定义的 rpm 名称和版本。不要在 Source 语句中包含任何路径。缺省情况下，RPM 会在 rpmbuild/SOURCES/ 中寻找文件。请将您的源文件复制到那里。
* 接下来的部分从 %description 行开始。您应该在这里提供该软件更多的描述，这样任何人使用 rpm -qi 查询您的软件包时都可以看到它。您可以解释这个软件包做什么，描述任何警告或附加的配置指令，等等。

下面几部分是嵌入 spec 文件中的 shell 脚本。

* %prep 负责对软件包解包。在最常见情况下，您只要用 %setup 宏即可，它会做适当的事情，在构建目录下解包源 tar 文件。加上 -q 项只是为了减少输出。
* %build 应该编译软件包。该 shell 脚本从软件包的子目录下运行，在我们这个例子里是 indent-2.2.6 目录，因而这常常与运行 make 一样简单。
* %install 在构建系统上安装软件包。这似乎和 make install 一样简单，唯一的关键点是要把所有二进制文件安装到rpmbuild/BUILDROOT/目录。
* %files 列出应该捆绑到 RPM 中的文件，并能够可选地设置许可权和其它信息。
* 在 %files 中，
   * 可以使用 一次%defattr 来定义缺省的许可权、所有者和组；在这个示例中， %defattr(-,root,root) 会安装 root 用户拥有的所有文件，使用当 RPM 从构建系统捆绑它们时它们所具有的任何许可权。
   * 可以用 %attr(permissions,user,group) 覆盖个别文件的所有者和许可权。
   * 可以在 %files 中用一行包括多个文件。
   * 可以通过在行中添加 %doc 或 %config 来标记文件。 %doc 告诉 RPM 这是一个文档文件，因此如果用户安装软件包时使用 –excludedocs ，将不安装该文件。您也可以在 %doc 下不带路径列出文件名，RPM 会在构建目录下查找这些文件并在 RPM 文件中包括它们，并把它们安装到 /usr/share/doc/%{name}-%{version} 。以 %doc 的形式包括 README 和 ChangeLog 这样的文件是个好主意。
   * %config 告诉 RPM 这是一个配置文件。在升级时，RPM 将会试图避免用 RPM 打包的缺省配置文件覆盖用户仔细修改过的配置。
   * 警告：如果在 %files 下列出一个目录名，RPM 会包括该目录下的所有文件。通常这不是您想要的，特别对于 /bin 这样的目录
   * %changelog 记录变更日志

## RPM签名 

创建过程可参考文档http://www.cryptnet.net/fdp/crypto/keysigning_party/en/keysigning_party.html

    列出系统中已有的密钥信息 gpg --list-keys
    导出公钥,用于验证已签名的软件包或备份
    gpg --armor --output RPM-GPG-KEY-CentOS-KS --export [用户ID]
    导出私钥，留作做备份
    gpg --armor --output private-key.csr --export-secret-keys

RPM签名的准备工作

定义如下配置:

%_signature gpg
%_gpg_path /root/.gnupg                         #GPG密钥位置 
%_gpg_name HaiTao Pan <panht@knownsec.com>    #证书UID
%_gpgbin /usr/bin/gpg

    可以保存在全局配置文件/usr/lib/rpm/macros
    可以保存用户自定义配置文件 $HOME/.rpmmacros ,
    或执行rpm,rpmbuild命令通过 -D, –define=’MACRO EXPR’ 选项定义配置

使用 rpmbuild 签名

引用配置文件中定义的配置签名

rpmbuild -ba --sign ~/rpmbuild/SPECS/package.spec 
或通过 -D 选项定义配置
rpmbuild -D '%_gpg_name HaiTao Pan <panht@knownsec.com>' -D '%_gpg_path /root/.gnupg' -D '%_gpgbin /usr/bin/gpg' -D '%_signature gpg' -ba --sign ~/rpmbuild/SPECS/package.spec

签名过程中会提示输入私钥密码
使用 rpm 签名

rpm --addsign package.rpm
rpm --resign package.rpm

签名过程中会提示输入私钥密码
签名验证

rpm -K package.rpm
rpm -qpi package.rpm 

其他

结合 yum-utils软件包 repomanager 等工具可以辅助管理仓库内的rpm文件。

## 参考文档

* http://docs.fedoraproject.org/en-US/Fedora_Draft_Documentation/0.1/html/RPM_Guide/ch11s04s02.html
* http://yum.baseurl.org/wiki/RepoCreate
* http://fedoraproject.org/wiki/Docs/Drafts/BuildingPackagesGuide
* http://fedoraproject.org/wiki/Packaging/Guidelines
* http://fedoraproject.org/wiki/ParagNemade/PackagingNotes
* http://www.rpm.org/max-rpm/

