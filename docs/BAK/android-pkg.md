# Android odex文件反编译

odex 是经过优化的dex文件，且独立存在于apk文件。odex 多用于系统预制应用或服务。通过将apk中的dex文件进行 odex，可以加载 apk 的启动速度，同时减小空间的占用。请参考ODEX关于 odex 的说明。

在反编译 odex 文件的过程中，我们需要使用到以下工具

* smali/baksmali
* dex2jar
* JD Compiler, jar反编译工具

smali/baksmali是odex与dex文件格式互相转换的两个工具，dex2jar则是将dex文件转为java的jar文件，JD Compiler用于反编译jar文件。也就是说，经过以上一系列的操作，我们最终可以从一个odex文件得到一个可读的java文件。（事实上，也不是完全可读，与源码上还是有差别，有时候部分代码还无法反编译过来，只能以jdk虚拟机指令的方式存在了）。

首先，一个 odex 文件的生成过程是：java -> class -> dex -> odex
那么反编译的就是上面过程的逆操作了：odex -> dex -> class -> java。

我的测试环境：

Android 4.1.2
Samsung Galaxy II
以Android系统中的 uiautomator.odex 文件为例，目标是反编译其源码（其实它的源码grepcode).

工具准备
创建一个临时目录test，将 smali/baksmali 相关的工具都放入其中。

反编译 (odex -> dex)
首先，将目标 odex 文件拿出来。

cd test
adb pull /system/framework/uiautomator.odex
在合成 odex 文件过程中，还需要用到很多依赖文件，它们同样也是 odex 格式的。因此在合成时，我们需要根据情况反复从手机中抽取相关的依赖包。

关于命令的使用，直接执行 java -jar baksmali-2.0.2.jar 可以得到相关的使用说明。这里要用到的参数主要是:

[-a | --api-level]: Android API等级，Android 4.1.2是16
[-x | --deodex]: 操作，反编译
[-d|--bootclasspath-dir]: 依赖包的目录，我们用当前目录.
开始反编译，执行以下命令：

D:\test>java -jar baksmali-2.0.2.jar -a 16 -x uiautomator.odex -d .
 
Error occured while loading boot class path files. Aborting.
org.jf.util.ExceptionWithContext: Cannot locate boot class path file /system/framework/core-junit.odex
        at org.jf.dexlib2.analysis.ClassPath.loadClassPathEntry(ClassPath.java:217)
        at org.jf.dexlib2.analysis.ClassPath.fromClassPath(ClassPath.java:161)
        at org.jf.baksmali.baksmali.disassembleDexFile(baksmali.java:59)
        at org.jf.baksmali.main.main(main.java:274)
以上的异常表明，反编译的过程缺少依赖包/system/framework/core-junit.odex,那就从系统中提取。

D:\test>adb pull /system/framework/core-junit.odex
 
# 重复
D:\test>java -jar baksmali-2.0.2.jar -a 16 -x uiautomator.odex -d .
 
# 如果还有缺失的依赖包，则反复从手机上提取
反编译 uiautomator.odex 总共需要使用到以下依赖包：

D:\test>ls *.odex
android.policy.odex  bouncycastle.odex  core.odex  framework.odex   sec_edm.odex    services.odex
apache-xml.odex      core-junit.odex    ext.odex   framework2.odex  seccamera.odex  uiautomator.odex
baksmali 执行成功后，会产生一个 out 目录，里面放的是中间文件。这时，可以使用这些中间文件来生成dex文件：

D:\test>java -jar smali-2.0.2.jar -a 16 -o classes.dex out
 
## 解压 dex2jar 到 test 目录
D:\test\dex2jar-0.0.9.15>d2j-dex2jar.bat ..\classes.dex
dex2jar classes.dex -> classes-dex2jar.jar
classes-dex2jar.jar 便是我们要得到java jar包。通过JD Compiler打开这个jar可以看到反编译后的java内容。

之所以反编译 uiautomator，是因为Android SDK中给出的 uiautomator.jar 包中很多API都没有包含其中，也没有在其官方文档中给予说明。通过阅读 uiautomator 的源码，发现它有很多可以扩展的地方。
