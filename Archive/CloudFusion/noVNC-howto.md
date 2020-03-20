# NoVNC的配置与使用

## 简介

noVNC提供一种在网页上通过html5的Canvas，访问机器上vncserver提供的vnc服务，需要做tcp到websocket的转化，才能在html5中显示出来。网页就是一个客户端，类似win下面的vncviewer，只是此时填的不是裸露的vnc服务的ip+port，而是由noVNC提供的websockets的代理，在noVNC代理服务器上要配置每个vnc服务，noVNC提供一个标识，去反向代理所配置的vnc服务。

noVNC 被普遍用在各大云计算、虚拟机控制面板中，比如 OpenStack Dashboard 和 OpenNebula Sunstone 都用的是 noVNC。


## windows系统
 
1、远程目标主机：Windows Server 2008 r2（用vmare中虚拟机测试）
2、UltraVNC：http://www.uvnc.com/（Windows环境下的VNC Server，还有TightVNC、TigerVNC、RealVNC等，其中RealVNC不能通过noVNC）
3、Node.js：https://nodejs.org/en/download/（用于执行Websockify.js）
4、noVNC：http://github.com/kanaka/noVNC/zipball/master
5、Websockify：https://github.com/novnc/websockify/archive/master.zip



