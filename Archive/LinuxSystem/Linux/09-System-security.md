
# 所有的安全都是相对的，原则上，最小的权限，最少的服务，能提供最大的安全


1. 访问控制机制(ACM)

    ACM：即Access Control Mechanism

    ACM为系统管理员提供了一种控制哪些用户、进程可以访问不同的文件、设备和接口等的一种方式。当需要确保计算机系统或网络安全时，ACM是一个主要的考虑因素。

    ACM主要有以下6种方式：

    1) 自主访问控制：Discretionary Access Control (DAC)

    2) 访问控制列表：Access Control Lists (ACLs)

    3) 强制访问控制：Mandatory Access Control (MAC)

    4) 基于角色的访问控制：Role-based Access Control (RBAC)

    5) 多级安全：Multi-Level Security (MLS)

    6) 多类安全：Multi-Category Security (MCS)


1.1 自主访问控制(DAC)

      DAC为文件系统中的对象(文件、目录、设备等)定义基本的访问控制，即典型的文件权限和共享等。此访问机制通常由对象的所有者来决定。


1.2 访问控制列表(ACL)

      ACL为一个subject(进程、用户等)可访问哪些object提供了进一步的控制。     


 1.3 强制访问控制(MAC)

       MAC是一种安全机制，此安全机制是限制了用户(subject)对它自己所创建的对象所拥有的“控制级别”。与DAC不一样，在DAC中，用户对他们自己的object(文件、目录、设备等)拥有完全的控制权；而在MAC中，对所有的文件系统objects增加了额外的labels或categories。在subjects(用户或进程)与objects交互之前，它们必须对这些categories或labels进行合适的访问(即先要进行权限判断)。

       对访问的控制彻底化，对所有的文件、目录、端口的访问，都是基于策略设定的。这些策略是由管理员设定的、一般用户是无权更改的。


1.4 基于角色的访问控制 (RBAC)
      RBAC是控制用户访问文件系统objects的一种可先方法。它不是基于用户权限进控制， 系统管理员基于商业功能需求建立对应的角色(Roles)，这些角色对object有不同的类型和访问级别。
      与DAC和MAC系统相比，在DAC和MAC系统中，用户基于它们自己和object的权限来访问objects；而在RBAC系统中，在用户与objects(文件、目录、设备等)交互之前，用户必须是一个适当组的成员或角色。

      从系统管理员的角度看，RBAC更易于通过控制组成员，从而控制哪些用户可以访问文件系统的哪些部分。  

      对于用户只赋予最小权限。对于用户来说，被划分成一些role，即使是root用户，你要是不在sysadm_r里，也还是不能实行sysadm_t管理操作的。因为，哪些role可以执行哪些domain也是在策略里设定的。role也是可以迁移的，但是只能按策略规定的迁移。 

1.5. 多级安全 (MLS)
       Multi-Level Security (MLS)是一个具体的强制访问控制安全方案。在此方案中，进程被叫做“Subjects”，文件、目录、套接字和其它操作系统被动实体被叫做“Objects”。


1.6. 多类安全 (MCS)

     Multi-Category Security (MCS) 是一个增强的SELinux，允许用户标记文件类别。在SELinux中，MCS是MLSand重用MLS框架的适配器。

 

* 自主访问控制 一种方式是由客体的属主对自己的客体进行管理，由属主自己决定是否将自己客体的访问权或部分访问权授予其他主体，这种控制方式是自主的，我们把它称为自主访问控制（Discretionary Access Control——DAC）。在自主访问控制下，一个用户可以自主选择哪些用户可以共享他的文件。Linux系统中有两种自主访问控制策略，一种是9位权限码（User-Group-Other），另一种是访问控制列表ACL（Access Control List）。
强制访问控制

* 强制访问控制（Mandatory Access Control——MAC），用于将系统中的信息分密级和类进行管理，以保证每个用户只能访问到那些被标明可以由他访问的信息的一种访问约束机制。通俗的来说，在强制访问控制下，用户（或其他主体）与文件（或其他客体）都被标记了固定的安全属性（如安全级、访问权限等），在每次访问发生时，系统检测安全属性以便确定一个用户是否有权访问该文件。其中多级安全（MultiLevel Secure, MLS）就是一种强制访问控制策略。

  * ACL (Access Control List)
  * PAM (Pluggable Authentication Modules)
  * LSM (Selinux / Apparm) 
  * FireWall (netfilter/iptables)  
  * 应用防火墙 TCP_Wrappers

# PAM模块

## 概述

PAM（Pluggable Authentication Modules ）是由Sun提出的一种认证机制。它通过提供一些动态链接库和一套统一的API，将系统提供的服务 和该服务的认证方式分开，使得系统管理员可以灵活地根据需要给不同的服务配置不同的认证方式而无需更改服务程序，同时也便于向系统中添加新的认证手段.
 
### PAM的核心文件和配置文件位置：

* /lib64/libpam.so.* PAM核心库
* /lib64/security/pam_*.so 可动态加载的PAM service module
* /etc/pam.conf 或 /etc/pam.d/  PAM配置文件位置

## PAM的配置 

 
如果`/etc/pam.conf`配置文件，PAM配置文件的语法如下：
```
service-name module-type control-flag module-path arguments
```
使用配置目录/etc/pam.d/ 目录下的配置件名则默认对应的service-name，PAM配置文件的语法如下：

```
module-type control-flag module-path arguments
```

参考上节实例二的配置，各个配置解释如下：
* service-name 服务的名字对的是`sshd`
* module-type（实例二为`auth`）：模块类型有四种：`auth、account、session、password`即对应PAM所支持的四种管理方式。同一个服务可以调用多个PAM模块进行认证，这些模块构成一个stack。
   * auth 是指认证管理（authentication management）主要是接受用户名和密码，进而对该用户的密码进行认证，并负责设置用户的一些秘密
信息。
   * account 是指帐户管理（account management）主要是检查帐户是否被允许登录系统，帐号是否已经过期，帐号的登录是否有时间段的
限制等等。
   * 密码管理（password management） 主要是用来修改用户的密码。
   * 会话管理（session management） 主要是提供对会话的管理和记账（accounting）。
* control-flag 实例二为`required`，用来告诉PAM库该如何处理与该服务相关的PAM模块的成功或失败情况。它有四种可能的 值：required，requisite，sufficient，optional。
   * required 表示本模块必须返回成功才能通过认证，但是如果该模块返回失败的话，失败结果也不会立即通知用户，而是要等到同一stack 中的所有模块全部执行完毕再将失败结果返回给应用程序。可以认为是一个必要条件。
   * requisite 与required类似，该模块必须返回成功才能通过认证，但是一旦该模块返回失败，将不再执行同一stack内的任何模块，而是直 接将控制权返回给应用程序。是一个必要条件。注：这种只有RedHat支持，Solaris不支持。
   * sufficient 表明本模块返回成功已经足以通过身份认证的要求，不必再执行同一stack内的其它模块，但是如果本模块返回失败的话可以 忽略。可以认为是一个充分条件。
   * optional表明本模块是可选的，它的成功与否一般不会对身份认证起关键作用，其返回值一般被忽略。
* module-path （实例二为`pam_tally2.so`）是指用来指明本模块对应的程序文件的路径名，一般采用绝对路径，如果没有给出绝对路径，默认该文件在目录`/lib64/security`下面。
* arguments （实例二为`deny=3    unlock_time=180    even_deny_root root_unlock_time=30`）：是指用来传递给该模块的参数。一般来说每个模块的参数都不相同，可以由该模块的开发者自己定义，但是也有以下几个共同 的参数：
  * debug 该模块应当用syslog( )将调试信息写入到系统日志文件中。
  * no_warn 表明该模块不应把警告信息发送给应用程序。
  * use_first_pass 表明该模块不能提示用户输入密码，而应使用前一个模块从用户那里得到的密码。
  * try_first_pass 表明该模块首先应当使用前一个模块从用户那里得到的密码，如果该密码验证不通过，再提示用户输入新的密码。
  * use_mapped_pass 该模块不能提示用户输入密码，而是使用映射过的密码。
  * expose_account 允许该模块显示用户的帐号名等信息，一般只能在安全的环境下使用，因为泄漏用户名会对安全造成一定程度的威 胁。

# SElinux

SELinux（全称 Security Enhanced Linux）是基于LSM(Linux Security Modules)的一种实现方式，提供了一种灵活的强制访问控制(MAC)系统，且内嵌于Linux Kernel中。SELinux定义了系统中每个用户、进程、应用和文件的访问和转变的权限，然后它使用一个安全策略来控制这些实体(用户、进程、应用和文件)之间的交互，安全策略指定如何严格或宽松地进行检查。

强制访问控制系统的用途在于增强系统抵御 0-Day 攻击(利用尚未公开的漏洞实现的攻击行为)的能力。所以它不是网络防火墙或 ACL 的替代品，在用途上也不重复。举例来说，系统上的 Apache 被发现存在一个漏洞，使得某远程用户可以访问系统上的敏感文件(比如 /etc/passwd 来获得系统已存在用户)，而修复该安全漏洞的 Apache 更新补丁尚未释出。此时 SELinux 可以起到弥补该漏洞的缓和方案。因为 /etc/passwd 不具有 Apache 的访问标签，所以 Apache 对于 /etc/passwd 的访问会被 SELinux 阻止。

相比其他强制性访问控制系统，SELinux 有如下优势：

* 控制策略是可查询而非程序不可见的。
* 可以热更改策略而无需重启或者停止服务。
* 可以从进程初始化、继承和程序执行三个方面通过策略进行控制。
* 控制范围覆盖文件系统、目录、文件、文件启动描述符、端口、消息接口和网络接口。

另外，开启SELinux的会给系统带来一定的性能损失，

# 防火墙

## 防火墙的工作原理

通常意义的防火墙实际是由两个组件组成(iptables和netfilter). iptables组件是用户空间（userspace）的工具，可以方便管理插入、修改和删除防火墙规则（也就是信息包过滤表），netfilter则是内核（kernelspace）的一部分，tcp/ip协议栈必须经过的地方这些模块,netfilter模块负责读取，并处理用户空间设置的规则集，在内核空间中有5个位置定义的数据包的流向，分别是：

* 从一个网络接口进来，到另一个网络接口去的
* 数据包从内核流入用户空间的
* 数据包从用户空间流出的
* 进入/离开本机的外网接口
* 进入/离开本机的内网接口

以上提及的这五个位置也被称为五个钩子函数（hook functions）,在防火墙规则中也称为五个规则链，任何一个数据包，只要经过本机，必将经过这五个链中的其中一个链，NetFilter规定的五个规则链的描述如下：
		
* PREROUTING (路由前)
* INPUT (数据包流入口)
* FORWARD (转发管卡)
* OUTPUT(数据包出口)
* POSTROUTING（路由后） 

为了方便维护管理，引入“表”的定义来区分各种不同的工作功能和处理方式。这4个表分别描述如下：

* filter：一般的过滤功能
* nat:用于nat功能（端口映射，地址映射等）
* mangle:用于对特定数据包的修改
* raw: 设置raw时一般是为了不再让iptables做数据包的链接跟踪处理，提高性能

以上也就是通常所说iptables包含4个表，5个链。再执行iptables命令工作管理访问规则的时候，没有指定表的时候默认操作filter表。表的处理优先级：`raw>mangle>nat>filter`，其中表是按照对数据包的操作区分的，链是按照不同的Hook点来区分的，表和链实际上是netfilter的两个维度。使用比较频繁有3个表：filter，nat，mangle

* 对于filter来讲一般只能做在3个链上：INPUT ，FORWARD ，OUTPUT
* 对于nat来讲一般也只能做在3个链上：PREROUTING ，OUTPUT ，POSTROUTING
* 而mangle则是5个链都可以做：PREROUTING，INPUT，FORWARD，OUTPUT，POSTROUTING

## 防火墙的操作和管理

防火墙策略一般分为两种，一种叫“通”策略，一种叫“堵”策略，下面是两条添加规则的操作实例：

* 允许本机80端口被访问
```
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
```

* 禁止本机90端口被访问
```
iptables -t filter -A INPUT -p tcp --dport 90 -j DROP
```

## iptables的基本语法格式

`iptables [-t 表名] 命令选项 ［链名］ ［条件匹配］ ［-j 目标动作或跳转］`

|           | table      | command   | chain     |     parameter     |  target   |
|-----------|------------|:---------:|-----------|:-----------------:|-----------|
| iptables  | -t filter  |   -A      | INPUT     | -p tcp --dport 80 | -j ACCEPT |
| iptables  | -t filter  |   -A      | INPUT     | -p tcp --dport 90 | -j DROP   |

说明：表名、链名用于指定 iptables命令所操作的表和链，命令选项用于指定管理iptables规则的方式（比如：插入、增加、删除、查看等；条件匹配用于指定对符合什么样 条件的数据包进行处理；目标动作或跳转用于指定数据包的处理方式（比如允许通过、拒绝、丢弃、跳转（Jump）给其它链处理。更多细节请参考`man iptables`


# TCP_Wrappers简介

TCP_Wrappers是一个工作在应用层的安全工具，它只能针对某些具体的应用或者服务起到一定的防护作用。比如说ssh、telnet、FTP等服务的请求，都会先受到TCP_Wrappers的拦截。（关于什么是应用层，可以参考百度百科词条网络协议）
TCP_Wrappers工作原理

TCP_Wrappers有一个TCP的守护进程叫作tcpd。以telnet为例，每当有telnet的连接请求时，tcpd即会截获请求，先读取系统管理员所设置的访问控制文件，合乎要求，则会把这次连接原封不动的转给真正的telnet进程，由telnet完成后续工作；如果这次连接发起的ip不符合访问控制文件中的设置，则会中断连接请求，拒绝提供telnet服务。
TCP_Wrappers配置

这里主要涉及到两个配置文件/etc/hosts.allow和/etc/hosts.deny。/usr/sbin/tcpd进程会根据这两个文件判断是否对访问请求提供服务。
/usr/sbin/tcpd进程先检查文件/etc/hosts.allow，如果请求访问的主机名或IP包含在此文件中，则允许访问。
如果请求访问的主机名或IP不包含在/etc/hosts.allow中，那么tcpd进程就检查/etc/hosts.deny。看请求访问的主机名或IP有没有包含在hosts.deny文件中。如果包含，那么访问就被拒绝；如果既不包含在/etc/hosts.allow中，又不包含在/etc/hosts.deny中，那么此访问也被允许。 
