软件包和存储库简介
我们都在那里 - 需要一个程序，我们做什么？ 我们大多数人只是apt-get的安装postfix，和急！ 我们神奇地有Postfix安装。

这不是真的魔术，但。 软件包管理器apt-get会为您搜索，下载和安装软件包。 这是非常方便的，但如果apt-get找不到你需要的程序在其标准的存储库列表呢？ 幸运的是，apt-get允许用户指定自定义下载位置（称为仓库）。

在本教程中，我们将介绍如何设置您自己的安全存储库，并将其公开供其他人使用。 我们将在Ubuntu 14.04 LTS Droplet上创建存储库，并测试来自具有相同分配的另一个Droplet的下载。

要充分利用本指南，一定要看看我们的教程管理与apt-get的包 。

先决条件
两个Ubuntu的LTS 14.04Droplet

在指南的结尾，您将有：

准备并发布存储库签名密钥
使用存储库管理器Reprepro设置存储库
使网络服务器Nginx公开的存储库
在另一个服务器上添加了存储库
准备和发布签名密钥
首先，我们需要一个有效的包签名密钥。 此步骤对于安全存储库至关重要，因为我们将对所有数据包进行数字签名。 包签名给予下载者对源可信的信心。

在本节中，您将通过以下步骤生成加密的主公钥和签名子密钥：

生成主密钥
生成包签名的子项
从子项分离主键
生成主密钥
让我们做主键。 这个密钥应该保持安全，因为这是人们会信任的。

在我们开始之前，让我们安装RNG工具虽然易于得到 ：

apt-get install rng-tools
GPG需要随机数据（称为熵）来生成密钥。 熵通常由Linux内核随时间生成并存储在池中。 然而，在云服务器（如Droplet）上，内核可能会产生GPG所需的熵量。 为了帮助内核，我们安装了rngd程序（在rng-tools包中）。 这个程序会询问主机服务器（Droplets所在的位置）的熵。 一旦检索rngd将数据添加到熵池用相同的GPG其它应用中使用。

如果你收到这样的消息：

Trying to create /dev/hwrng device inode...
Starting Hardware RNG entropy gatherer daemon: (failed).
invoke-rc.d: initscript rng-tools, action "start" failed.
与手动启动rngd守护程序：

rngd -r /dev/urandom
默认情况下rngd寻找一个特殊的装置来检索从/ dev / hwrng熵。 一些Droplet没有这个设备。 为了弥补我们用伪随机设备/ dev / urandom的通过指定-r指令。 欲了解更多信息，您可以查看我们的教程： 如何安装附加的熵 。

现在我们有一个熵池，我们可以生成主密钥。 通过调用命令GPG做到这一点。 您将看到类似于以下内容的提示：

gpg --gen-key
gpg (GnuPG) 1.4.16; Copyright (C) 2013 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection? 1
指定第一个选项，“RSA和RSA（默认）” 1 ，在提示。 选择，这将有GPG生成第一签名密钥，则加密的子项（既使用RSA算法）。 我们不需要本教程的加密密钥，但作为一个伟大的人曾经说过，“为什么不？”没有缺点，有两个，你可以使用密钥在未来的加密。

按下回车键 ，你会被提示输入密钥长度：

RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
密钥大小直接关系到您希望主密钥的安全性。 位大小越高，键就越安全。 Debian项目推荐使用4096位任何签名密钥，所以我会在这里指定4096。 在接下来的2 - 5年，如果你宁愿使用默认位大小2048就足够了。 1024的大小不舒服地接近不安全，不应该使用。

出版社为到期提示符下输入 。

Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0
主密钥通常不具有到期日期，但只要您希望使用此密钥，请设置此值。 如果你只打算使用这个仓库只有在未来6个月，你可以指定6米 。0将使其永远有效。

敲回车 ，则y。 系统将提示您生成“用户ID”。 这些信息将被其他人和您自己用于识别此密钥 - 因此请使用真实信息！

You need a user ID to identify your key; the software constructs the user ID
from the Real Name, Comment and Email Address in this form:
    "Heinrich Heine (Der Dichter) <heinrichh@duesseldorf.de>"

Real name: Mark Lopez
Email address: mark.lopez@example.com
Comment: 
You selected this USER-ID:
    "Mark Lopez <mark.lopez@example.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
如果信息是正确的，打O和Enter键 。 我们需要添加密码，以确保只有您可以访问此密钥。 确保，因为没有办法恢复GPG密钥密码（一件好事） 记住这个密码 。

You need a Passphrase to protect your secret key.

Enter passphrase: (hidden)
Repeat passphrase: (hidden)
现在为一些魔法（数学）发生。 这可能需要一段时间，所以坐下来或喝一杯你最喜欢的饮料。

We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

Not enough random bytes available.  Please do some other work to give
the OS a chance to collect more entropy! (Need 300 more bytes)
+++++
................+++++
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
..+++++
+++++
gpg: /root/.gnupg/trustdb.gpg: trustdb created
gpg: key 10E6133F marked as ultimately trusted
public and secret key created and signed.

gpg: checking the trustdb
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
pub   4096R/10E6133F 2014-08-16
      Key fingerprint = 1CD3 22ED 54B8 694A 0975  7164 6C1D 28A0 10E6 133F
uid                  Mark Lopez <mark.lopez@example.com>
sub   4096R/7B34E07C 2014-08-16
现在我们有一个主密钥。 输出显示，我们创建了一个主密钥签署（`在酒馆线之上0E6133F）。 您的密钥将具有不同的ID。 记下你的签名密钥的ID的（例子中使用10E6133F）。 在创建用于签名的另一个子项时，我们将在后续步骤中使用此信息。

生成包签名的子项
现在，我们将创建第二个签名密钥，以便我们不需要此服务器上的主密钥。 认为主密钥是授予子密钥权限的根权限。 如果用户信任主密钥，则暗示对子密钥的信任。

在终端执行：

gpg --edit-key 10E6133F

将示例ID替换为您的密钥的ID。 此命令进入我们进入GPG环境。 这里我们可以编辑我们的新键并添加一个子键。 您将看到以下输出：

gpg (GnuPG) 1.4.16; Copyright (C) 2013 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

pub  4096R/10E6133F  created: 2014-08-16  expires: never       usage: SC
                     trust: ultimate      validity: ultimate
sub  4096R/7B34E07C  created: 2014-08-16  expires: never       usage: E
[ultimate] (1). Mark Lopez <mark.lopez@example.com>

gpg>
在提示符下，键入addkey ：

addkey
按Enter键 。 GPG将提示您输入密码。 输入用于加密此密钥的密码。

Key is protected.

You need a passphrase to unlock the secret key for
user: "Mark Lopez <mark.lopez@example.com>"
4096-bit RSA key, ID 10E6133F, created 2014-08-16

gpg: gpg-agent is not available in this session
Enter passphrase: <hidden>
您将看到以下关于键类型的提示。

Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
Your selection? 4
我们希望创建一个<I>签署</ i>的子项，所以选择“RSA（仅签名）” 4 。RSA是为客户更快，而DSA是服务器更快。我们在这种情况下，因为采摘RSA ，对于我们在一个包上的每个签名，可能有数百个客户端将需要验证它，这两种类型是同样安全的。

我们再次提示输入密钥大小。

RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
本教程使用4096以提高安全性。

Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 1y
我们已经有一个主键，所以子键的过期时间不太重要。 一年是一个好的时间框架。

按下回车键，然后键入y（是）两次在接下来的两个提示。 一些数学将生成另一个密钥。

We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
............+++++
.+++++

pub  4096R/10E6133F  created: 2014-08-16  expires: never       usage: SC
                     trust: ultimate      validity: ultimate
sub  4096R/7B34E07C  created: 2014-08-16  expires: never       usage: E
sub  4096R/A72DB3EF  created: 2014-08-16  expires: 2015-08-16  usage: S
[ultimate] (1). Mark Lopez <mark.lopez@example.com>

gpg>
类型保存在提示符下。

save
在上面的输出，从我们的主密钥的SC告诉我们，关键是只为签名和认证。 电子装置的键仅可用于加密。 我们的签名密钥可以正确地看到，只有在S。

注意你的新签名密钥的ID（这个例子显示A72DB3EF在第二次线以上）。 您的密钥的ID将不同。

输入保存返回到终端，并保存新的密钥。

save
从子项分离主密钥
创建子项的要点是，我们不需要在我们的服务器上的主密钥，这使它更安全。 现在我们将从我们的子项中分离我们的主键。 我们需要导出主密钥和子密钥，然后从GPG的存储中删除密钥，然后只重新导入子密钥。

首先让我们使用--export秘密密钥和--export命令导出整个键。 记住使用你的主密钥的ID！

gpg --export-secret-key 10E6133F > private.key
gpg --export 10E6133F >> private.key
默认情况下--export秘密密钥和--export将打印的关键，我们的控制台上，所以我们反而管道输出到一个新文件（private.key）。 请务必指定您自己的主密钥ID，如上所述。

重要提示：请在private.key文件的副本，安全的地方 （在服务器上没有）。 可能的位置在软盘或USB驱动器上。 此文件包含您的私钥，您的公钥，您的加密子密钥和您的签名子密钥。

你已经备份这个文件到一个安全的位置后，删除文件：

#back up the private.key file before running this# rm private.key
现在导出您的公钥和您的子项。 确保更改ID以匹配主密钥和生成的第二个子项（不使用第一个子项）。

gpg --export 10E6133F > public.key
gpg --export-secret-subkeys A72DB3EF > signing.key
现在我们已经备份了我们的密钥，我们可以从我们的服务器中删除我们的主密钥。

gpg --delete-secret-key 10E6133F
只重新导入我们的签名子项。

gpg --import public.key signing.key
检查我们的服务器上是否不再有主密钥：

gpg --list-secret-keys
sec#  4096R/10E6133F 2014-08-16
uid                  Mark Lopez <mark.lopez@example.com>
ssb   4096R/7B34E07C 2014-08-16
ssb   4096R/A72DB3EF 2014-08-16
注意秒后＃。 这意味着我们的主密钥未安装。 服务器仅包含我们的签名子项。

清理您的钥匙：

rm public.key signing.key
您最后需要做的是发布您的签名密钥。

gpg --keyserver keyserver.ubuntu.com --send-key 10E6133F
此命令将您的密钥发布到公钥存储库 - 在这种情况下是Ubuntu自己的密钥服务器。 这允许其他人下载您的密钥，并轻松验证您的包。

使用Reprepro设置存储库
现在让我们来看看本教程：创建apt-get存储库。 Apt-get存储库不是最容易管理的东西。 值得庆幸的是R. 伯恩哈德创建Reprepro，谁使用“生产，管理和同步Debian软件包的本地存储库”（又称Mirrorer）。 Reprepro是根据GNU许可证和完全开源。

安装和配置Reprepro
Reprepro可以从默认的Ubuntu存储库安装。

apt-get update
apt-get install reprepro
Reprepro的配置是特定于存储库的，这意味着如果您创建多个存储库，您可以有不同的配置。 让我们首先为我们的存储库。

为此存储库创建一个专用文件夹并移动到该文件夹​​。

mkdir -p /var/repositories/
cd /var/repositories/
创建配置目录。

mkdir conf
cd conf/
创建两个空的配置文件（ 选择和分布 ）。

touch options distributions
打开你喜欢的文本编辑器选项文件（ 纳米是默认安装的）。

nano options
此文件包含Reprepro的选项，并将在每次Reprepro运行时读取。 您可以在此处指定几个选项。 有关其他选项，请参阅手册。

在您的文本编辑器中添加以下内容。

ask-passphrase
在问-密码指令告诉Reprepro签署时请求GPG密码。 如果我们不把这添加到选项Reprepro将死，如果我们的密钥是加密的（它是）。

Ctrl + x然后按y和Enter将保存我们的更改并返回到控制台。

打开分布文件。

nano distributions
此文件有四个必需的指令。 将这些添加到文件。

Codename: trusty
Components: main
Architectures: i386 amd64
SignWith: A72DB3EF
代号为指令直接关系到发布的Debian发行版的代码名，并要求。 这是将下载软件包的分发的代码名称，并且不一定与此服务器的分发相匹配。 例如，在Ubuntu 14.04 LTS版被称为可信赖的，Ubuntu 12.04 LTS称为精确 ，和Debian 7.6被称为喘鸣 。 该库是为Ubuntu LTS 14.04 可信赖所以应该在这里设置。

组件字段是必需的。 这只是一个简单的仓库，所以设置main在这里。 还有其他命名空间，如“非自由”或“contrib” - 指适当命名方案的apt-get。

架构是另一个必填字段。 此字段列出此存储库中由空格分隔的二进制体系结构。 该库将举办包32位和64位服务器，所以i386的AMD64是这里设置。 根据需要添加或删除体系结构。

要指定其他计算机如何验证我们的包，我们使用SignWith指令。 这是一个可选指令，但是需要签名。 前面在本实施例的签名密钥具有该ID A72DB3EF，以便在此设置。 更改此字段以匹配您生成的子项的ID。

使用Ctrl +`x，然后按y和Enter键保存并退出文件。

您现在已设置Reprepro的必需结构。

添加包含Reprepro的软件包
首先，我们将目录更改为临时位置。

mkdir -p /tmp/debs
cd /tmp/debs
我们需要一些例子包一起工作-用wget它们：

wget https://github.com/Silvenga/examples/raw/master/example-helloworld_1.0.0.0_amd64.deb
wget https://github.com/Silvenga/examples/raw/master/example-helloworld_1.0.0.0_i386.deb 
这些包是纯粹为本指南，并包含一个简单的bash脚本来证明我们的存储库的功能。 如果你愿意，你可以使用不同的包。

运行程序ls应该给我们这个布局：

ls
example-helloworld_1.0.0.0_amd64.deb  example-helloworld_1.0.0.0_i386.deb
我们现在有两个示例包。 一个用于32位（i386）计算机，另一个用于64位（amd64）计算机。 您可以将它们添加到我们的存储库：

reprepro -b /var/repositories includedeb trusty example-helloworld_1.0.0.0_*
该-b参数指定库中的“（二）ASE”目录。 该includedeb命令需要两个参数- < distribution code name > and < file path(s) > 。 Reprepro将提示我们的子密钥密码两次。

Exporting indices...
C3D099E3A72DB3EF Mark Lopez <mark.lopez@example.com> needs a passphrase
Please enter passphrase: < hidden >
C3D099E3A72DB3EF Mark Lopez <mark.lopez@example.com> needs a passphrase
Please enter passphrase: < hidden >
成功！

列出和删除
我们可以用list命令后面的代号列出管理包。 例如：

reprepro -b /var/repositories/ list trusty

trusty|main|i386: example-helloworld 1.0.0.0
trusty|main|amd64: example-helloworld 1.0.0.0
要删除包，请使用remove命令。 remove命令需要软件包的codename和软件包名称。 例如：

reprepro -b /var/repositories/ remove trusty example-helloworld
使存储库公用

 
我们现在有一个本地包存储库与几个包。 接下来，我们将安装Nginx作为Web服务器，以使此存储库公开。

安装Nginx

apt-get update
apt-get install nginx
Nginx安装了默认的示例配置。 制作文件的副本，以防您在其他时间查看该文件。

mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
touch /etc/nginx/sites-available/default
现在我们有一个空配置文件，我们可以开始配置我们的Nginx服务器托管我们的新仓库。

使用您喜欢的文本编辑器打开配置文件。

nano /etc/nginx/sites-available/default
并添加以下配置指令：

server {

    ## Let your repository be the root directory
    root        /var/repositories;

    ## Always good to log
    access_log  /var/log/nginx/repo.access.log;
    error_log   /var/log/nginx/repo.error.log;

    ## Prevent access to Reprepro's files
    location ~ /(db|conf) {
        deny        all;
        return      404;
    }
}
Nginx有一些相当健全的默认值。 我们需要配置的是根目录，而拒绝访问Reprepro的文件。 有关详细信息，请参阅内嵌注释。

重新启动Nginx服务以加载这些新配置。

service nginx restart
您的公共Ubuntu存储库可以使用了！

您将需要您的Droplet的IP地址，让用户知道存储库的位置。 如果你不知道你的Droplet的公共地址，您可以用ifconfig找到它。

ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 04:01:23:f9:0e:01
          inet addr:198.199.114.168  Bcast:198.199.114.255  Mask:255.255.255.0
          inet6 addr: fe80::601:23ff:fef9:e01/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:16555 errors:0 dropped:0 overruns:0 frame:0
          TX packets:16815 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:7788170 (7.7 MB)  TX bytes:3058446 (3.0 MB)
在上面的例子中，服务器的地址是198.199.114.168。 你的会不同。

使用Reprepro服务器的IP地址，您现在可以将此存储库添加到任何其他适当的服务器。

从我们的新存储库安装包
如果你还没有，启动另一个Droplet与Ubuntu 14.04 LTS，以便您可以从新的存储库进行测试安装。

在新服务器上，下载您的公钥以验证存储库中的包。 回想一下，你发表你的钥匙keyserver.ubuntu.com。

这是用apt-key命令完成。

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 10E6133F
此命令下载指定的键，并将键添加到apt-get数据库。 副词命令告诉易键使用GPG下载的关键。 其他两个参数直接传递给GPG。 既然你上传你的钥匙“keyserver.ubuntu.com”使用--keyserver keyserver.ubuntu.com指令retrived从同一位置的关键。 该--recv-键<键ID>指令指定的确切键添加。

现在添加存储库的地址，apt-get中找到。 您将需要上一步中的存储库服务器的IP地址。 这是很容易与附加的apt-库程序来完成。

add-apt-repository "deb http://198.199.114.168/ trusty main"
请注意，我们给予附加的apt-库中的字符串。 大多数Debian存储库可以添加以下通用格式：

deb (repository location) (current distribution code name)  (the components name)
存储库位置应设置为服务器的位置。 我们有一个HTTP服务器，这样的协议是http：//。 这个例子的地点是198.199.114.168。 我们的服务器的代号为可信赖的 。 这是一个简单的存储库，所以我们调用组件“main”。

我们添加存储库后，一定要运行apt-get的更新 。 此命令将检查所有已知的存储库更新和更改（包括您刚刚创建的）。

apt-get update
更新apt-get之后，现在可以从存储库安装示例包。 正常使用apt-get命令。

apt-get install example-helloworld
如果一切顺利，你现在可以执行例如-的HelloWorld看看：

Hello, World!
This package was successfully installed!
恭喜！ 您刚刚从您创建的存储库安装了一个包！

要删除示例程序包，请运行以下命令：

apt-get remove example-helloworld
这将删除刚刚安装的示例软件包。
