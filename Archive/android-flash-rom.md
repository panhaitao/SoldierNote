# android 刷机

## fastboot 线刷

```
fastboot --wipe-and-use-fbe 
fastboot flash boot boot.img
fastboot flash system system.img
```

## wifi 问题

```
adb shell settings put global captive_portal_https_url https://www.google.cn/generate_204 
```

参考: http://www.pixcn.cn/article-2990-1.html


## MIUI国际版mi pay解决方案

1. 准备：

首先手机系统必须是MIUI国际版，国内版就没有必要看这篇文章了
手机已经root，已经解锁system锁，可以更改系统文件，这也是必须的
安装root explorer或者类似的可以修改系统文件的app
最好安装第三方recovery，可以在修改system文件夹之前先备份system区，避免变砖丢失数据


2. 开始：

把所有重要的数据备份一遍，先备份，先备份，先备份
进入recovery把system区备份，先备份，先备份，先备份，防止学习（折腾）过程中导致卡米，如果卡米直接进去recovery把system区恢复就直接没事了，但是防止意外产生，所以先进行第一步
下载MIUI国内版，然后解压出来system.img文件
用simg2img工具把system.img文件转换成可以挂载的img文件，linux（ubuntu）下直接“simg2img system.img system1.img”，windows下的话，simg2img有windows版本的，下载之后相应转化即可
linux版本下直接挂载就直接可以提取里面的软件了，windows版本下需要这个软件才可以查看镜像里面的软件
在/system/app路径中提取出Mipay,NextPay,SmartcardService,TSMClient,UPTsmService五个软件包，直接整个文件夹提取出来，然后把TSMClient里面的lib文件夹删除，再在/system/lib64中提取一个libuptsmaddonmi.so文件，到这里提取文件已经结束，接下来就是把提取的文件转移到我们的MIUI国际版上面了，如果你觉得提取麻烦，或者不会提取，可以直接用我提取出来的文件，链接：百度云盘，提取码：rapp，如果链接失效可以联系我
最后我们就要把提取的文件转移到我们的MIUI国际版上去了，把我们上面提取的五个软件的文件夹，用root explorer这个软件，复制到/system/app路径中，同时注意！！要修改权限，选定文件夹修改权限，文件夹权限设定为0755（十进制数表示权限），文件夹下所有的子文件夹也设置为0755,文件夹内文件都设置为0644,权限很重要，如果设置不正确是不能正常运行的
用root explorer这个软件用文本形式查看/system/build.prop文件，其中ro.se.type=eSE,HCE,UICC这一行中，如果有eSE选项的话，就不用修改，跳过这一步，如果是ro.se.type=HCE,UICC没有eSE这个选项的话，则自己用文本编辑形式打开，然后添加即可，注意选项之间添加逗号，如果不会修改，可以用我修改好的文件（arv8）（如果用我的文件的话，我不能保证成功，所以最好自己修改，如果用我的文件的话，记得该权限，设定为0600）
完成上面步骤的话，现在就可以重启了，重启之后就可以用了，如果开机直接卡米，不用急，直接进入recovery直接恢复system区就可以拯救了
本人实验环境：手机：小米6MIUI国际版8.4.19，电脑系统：linux（ubuntu），提取包系统：MIUI国内版8.58


