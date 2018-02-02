# Linux graphic subsytem 

## 前言

图形子系统是linux系统中比较复杂的子系统之一：
* 对下，它要管理形态各异的、性能各异的显示相关的器件；
* 对上，它要向应用程序提供易用的、友好的、功能强大的图形用户界面（GUI）。

因此，它是linux系统中少有的、和用户空间程序（甚至是用户）息息相关的一个子系统。本文是图形子系统分析文章的第一篇，也是提纲挈领的一篇，将会从整体上，对linux显示子系统做一个简单的概述，进而罗列出显示子系统的软件构成，后续的文章将会围绕这些软件一一展开分析。

**本文所有的描述将以原生linux系统为例（如Ubuntu、Debian等），对其它基于linux的系统（如Android），部分内容会不适用.**

## 概念介绍

### GUI（Graphical User Interface，图形用户界面）

linux图形子系统的本质，是提供图形化的人机交互（human-computer interaction）界面，也即常说的GUI（Graphical User Interface）。而人机交互的本质，是人脑通过人的输出设备（动作、声音等），控制电脑的输入设备，电脑经过一系列的处理后，经由电脑的输出设备将结果输出，人脑再通过人的输入设备接收电脑的输出，最终实现“人脑<-->电脑”之间的人机交互。下面一幅摘自维基百科的图片（可从“这里”查看比较清晰的SVG格式的原始图片），对上述过程做了很好的总结：

该图以一个非常前卫的应用场景----虚拟现实（VR，Virtual Reality）游戏，说明了以图形化为主的人机交互过程：

1. 人脑通过动作、声音（对人脑而言，是output），控制电脑的输入设备，包括键盘、鼠标、操作杆、麦克风、游戏手柄（包含加速度计、陀螺仪等传感器）。
2. 电脑通过输入设备，接收人脑的指令，这些指令经过kernel Input subsystem、Middleware Gesture/Speech recognition等软件的处理，转换成应用程序（Game）可以识别的、有意义的信息。
3. 应用程序（Game）根据输入信息，做出相应的反馈，主要包括图像和声音。对VR游戏而言，可能需要3D rendering，这可以借助openGL及其相应的用户空间driver实现。
4. 应用程序的反馈，经由kernel的Video subsystem（如DRM/KMS）、audio subsystem（如ALSA），输出到电脑的输出设备上，包括显示设备（2D/3D）、扬声器/耳机（3D Positional Audio）、游戏手柄（力的反馈）等。
5. 输出到显示设备上时，可能会经过图形加速模块（Graphics accelerator）。
注3：图中提到了VR场景的典型帧率（1280×800@95fps for VR），这是一个非常庞大的信息输出，要求图形子系统能10.5ms的时间内，生成并输出一帧，以RGBA的数据格式为例，每秒需要处理的数据量是1280x800x95x4x8=3.11296Gb，压力和挑战是相当大的（更不用提1080P了）。

* 有关GUI更为详细的解释，请参考：https://en.wikipedia.org/wiki/Graphical_user_interface。

### Windowing system（窗口系统）

窗口系统，是GUI的一种（也是当前计算机设备、智能设备广泛使用的一种），以WIMP （windows、icons、menus、pointer) 的形式，提供人机交互接口。Linux系统中有很多窗口系统的实现，如X Window System、Wayland、Android SurfaceFlinger等，虽然形态各异，但思路大致相同，包含如下要点：

1. 一般都使用client-server架构，server（称作display server，或者windows server、compositor等等）管理所有输入设备，以及用于输出的显示设备。
2. 应用程序作为display server的一个client，在自己窗口（window）中运行，并绘制自己的GUI。
3. client的绘图请求，都会提交给display server，display server响应并处理这些请求，以一定的规则混合、叠加，最终在有限的输出资源上（屏幕），显示多个应用程序的GUI。
4. display server和自己的client之间，通过某种类型的通信协议交互，该通信协议通常称作display server protocol。
5. display server protocol可以是基于网络的，甚至是网络透明的（network transparent），如X Window System所使用的。也可以是其它类型的，如Android SurfaceFlinger所使用的binder。

* 有关Windowing system的详细解释，请参考：https://en.wikipedia.org/wiki/Windowing_system。

### X Window System

X Window System是Windowing System一种实现，广泛使用于UNIX-like的操作系统上（当然也包括Linux系统），由MIT（Massachusetts Institute of Technology，麻省理工学院）在1984年发布。下图是它的典型架构：

1. X Window System简称X，或者X11，或者X-Windows。之所以称作X，是因为在字母表中X位于W之后，而W是MIT在X之前所使用的GUI系统。之所以称作X11，是因为在1987年的时候，X Window System已经进化到第11个版本了，后续所有的X，都是基于X11版本发展而来的（变动不是很大）。为了方便，后续我们都以X代指X Window System。
2. X最初是由X.org（XOrg Foundation）维护，后来基于X11R6发展出来了最初专门给Intel X86架构PC使用的X，称作XFree86（提供X服务，它是自由的，它是基于Intel的PC平台）。而后XFree86发展成为几乎适用于所有类UNIX操作系统的X Window系统，因此在相当长的一段时间里，XFree86也是X的代名词。再后来，从2004年的时候，XFree86不再遵从GPL许可证发行，导致许多发行套件不再使用XFree86，转而使用Xorg，再加上Xorg在X维护工作上又趋于活跃，现在Xorg由成为X的代名词（具体可参考“http://www.x.org/”）。
3. X设计之初，制定了很多原则，其中一条----"It is as important to decide what a system is not as to decide what it is”，决定了X的“性格”，即：X只提供实现GUI环境的基本框架，如定义protocol、在显示设备上绘制基本的图形单元（点、线、面等等）、和鼠标键盘等输入设备交互、等等。它并没有实现UI设计所需的button、menu、window title-bar styles等元素，而是由第三方的应用程序提供。这就是Unix的哲学：只做我应该做、必须做的事情。这就是这么多年来，X能保持稳定的原因。也是Linux OS界面百花齐放（不统一）的原因，各有利弊吧，后续文章会展开讨论。
4. X包括X server和X client，它们之间通过X protocol通信。
5. X server接收X clients的显示请求，并输出到显示设备上，同时，会把输入设备的输入事件，转递给相应的X client。X server一般以daemon进程的形式存在。
6. X protocol是网络透明（network-transparently）的，也就是说，server和client可以位于同一台机器上的同一个操作系统中，也可以位于不同机器上的不同操作系统中（因此X是跨平台的）。这为远端GUI登录提供了便利，如上面图片所示的运行于remote computer 的terminal emulator，但它却可以被user computer的鼠标键盘控制，以及可以输出到user computer的显示器上。 

**这种情况下，user computer充当server的角色，remote computer是client，有点别扭，需要仔细品味一下（管理输入设备和显示设备的是server)**

7. X将protocol封装为命令原语（X command primitives），以库的形式（xlib或者xcb）向client提供接口。X client（即应用程序）利用这些API，可以向X server发起2D（或3D，通过GLX等扩展，后面会介绍）的绘图请求。有关X更为详细的介绍，请参考：https://en.wikipedia.org/wiki/X_Window_System，后续蜗蜗可能会在单独的文章中分析它。

### 窗口管理器、GUI工具集、桌面环境及其它

前面讲过，X作为Windowing system中的一种，只提供了实现GUI环境的基本框架，其它的UI设计所需的button、menu、window title-bar styles等基本元素，则是由第三方的应用程序提供。这些应用程序主要包括：窗口管理器（window manager）、GUI工具集（GUI widget toolkit）和桌面环境（desktop environment）。

* 窗口管理器负责控制应用程序窗口（application windows）的布局和外观，使每个应用程序窗口尽量以统一、一致的方式呈现给用户，如针对X的最简单的窗口管理程序--twm（Tab Window Manager）。
* GUI工具集是Windowing system之上的进一步的封装。还是以X为例，它通过xlib提供给应用程序的API，仅仅可以绘制基本的图形单元（点、线、面等等），这些基本的图形单元，要组合成复杂的应用程序，还有很多很多细碎、繁杂的任务要做。因此，一些特定的操作系统，会在X的基础上，封装出一些更为便利的GUI接口，方便应用程序使用，如Microwindows、GTK+、QT等等。
* 桌面环境是应用程序级别的封装，通过提供一系列界面一致、操作方式一致的应用程序，使系统以更为友好的方式向用户提供服务。Linux系统比较主流的桌面环境包括GNOME、KDE等等。

### 3D渲染、硬件加速、OpenGL及其它

渲染（Render）在电脑绘图中，是指：用软件从模型生成图像的过程。模型是用严格定义的语言或者数据结构对于三维物体的描述，它包括几何、视点、纹理以及照明信息。图像是数字图像或者位图图像。上面的定义摘录自“百度百科”，它是着重提及“三维物体”，也就是我们常说的3D渲染。其实我们在GUI编程中习以为常的点、线、矩形等等的绘制，也是渲染的过程中，只不过是2D渲染。2D渲染面临的计算复杂度和性能问题没有3D厉害，因此渲染一般都是指3D渲染。

在计算机中，2D渲染一般是由CPU完成（也可以由专门的硬件模块完成）。3D渲染也可以由CPU完成，但面临性能问题，因此大多数平台都会使用单独硬件模块（GPU或者显卡）负责3D渲染。这种通过特定功能的硬件模块，来处理那些CPU不擅长的事务的方法，称作硬件加速（Hardware acceleration），相应的硬件模块，就是硬件加速模块。
众所周知，硬件设备是多种多样的，为了方便应用程序的开发，需要一个稳定的、最好是跨平台的API，定义渲染有关的行为和动作。OpenGL（Open Graphics Library）就是这类API的一种，也是最为广泛接纳的一种。虽然OpenGL只是一个API，但由于3D绘图的复杂性，它也是相当的复杂的。不过，归根结底，它的目的有两个：

1. 对上，屏蔽硬件细节，为应用程序提供相对稳定的、平台无关的3D图像处理API（当然，也可以是2D）。
2. 对下，指引硬件相关的驱动软件，实现3D图像处理相关的功能。

另外，openGL的一个重要特性，是独立于操作系统和窗口系统而存在的，具体可以参考后面软件框架相关的章节。

## 软件框架

通过第2章的介绍，linux系统中图形有关的软件层次已经呼之欲出，具体如下：

该层次图中大部分的内容，已经在第2章解释过了，这里再补充说明一下：

1. 该图片没有体现3D渲染、硬件加速等有关的内容，而这些内容却是当下移动互联、智能化等产品比较关注的地方，也是linux平台相对薄弱的环节。后续会在软件框架有关的内容中再着重说明。
2. 从层次结构的角度看，linux图形子系统是比较清晰的，但牵涉到每个层次上的实现的时候，就比较复杂了，因为有太多的选择了，这可归因于“提供机制，而非策略”的Unix软件准则。该准则为类Unix平台软件的多样性、针对性做出了很大的贡献，但在今天这种各类平台趋于整合的大趋势下，过多的实现会导致用户体验的不一致、开发者开发精力分散等弊端，值得我们思考。
3. 虽然图形子系统的层次比较多，但不同的人可能关注的内容不太一样。例如对Linux系统工程师（驱动&中间件）而言，比较关注hardware、kernel和display server这三个层次。而对Application工程师来说，可能更比较关心GUI Toolkits。本文以及后续display subsystem的文章，主要以Linux系统工程师的视角，focus在hardware、kernel和display server（可能包括windows manager）上面。

以X window为例，将hardware、kernel和display server展开如下（可从“这里”查看比较清晰的SVG格式的原始图片）：
From: https://upload.wikimedia.org/wikipedia/commons/c/c2/Linux_Graphics_Stack_2013.svg

对于软件架构而言，这张来自维基百科的图片并不是特别合适，因为它包含了太多的细节，从而显得有些杂乱。不过瑕不掩瑜，对本文的描述，也足够了。从向到下，图中包括如下的软件的软件模块：

1. 3D-game engine、Applications和Toolkits，应用软件，其中3D-game engine是3D application的一个特例。
2. Display Server  图片给出了两个display server：Wayland compositor和X-Server（X.Org）。X-Server是linux系统在PC时代使用比较广泛的display server，而Wayland compositor则是新设计的，计划在移动时代取代X-Server的一个新的display server。
3. libX/libXCB和libwayland-client
display server提供给Application（或者GUI Toolkits）的、访问server所提供功能的API。libX/libXCB对应X-server，libwayland-client对已Wayland compositor。
4. libGL: 
libGL是openGL接口的实现，3D application（如这里的3D-game engine）可以直接调用libGL进行3D渲染。
libGL可以是各种不同类型的openGL实现，如openGL（for PC场景）、openGL|ES（for嵌入式场景）、openVG（for Flash、SVG矢量图）。
libGL的实现，既可以是基于软件的，也可以是基于硬件的。其中Mesa 3D是OpenGL的一个开源本的实现，支持3D硬件加速。

5. libDRM和kernel DRM
DRI（Direct Render Infrastructure）的kernel实现，及其library。X-server或者Mesa 3D，可以通过DRI的接口，直接访问底层的图形设备（如GPU等）。

6. KMS（Kernel Mode Set）
一个用于控制显示设备属性的内核driver，如显示分辨率等。直接由X-server控制。

4. 后续工作
本文有点像一个大杂烩，丢进去太多的东西，每个东西又不能细说。觉得说了很多，又觉得什么都没有说。后续蜗蜗将有针对性的，focus在某些点上面，更进一步的分析，思路如下：
1）将会把显示框架限定到某个确定的实现上，初步计划是：Wayland client+Wayland compositor+Mesa+DRM+KMS，因为它们之中，除了Mesa之外，其它的都是linux系统中显示有关的比较前沿的技术。当然，最重要的，是比较适合移动端的技术。
2）通过单独的一篇文章，更详细的分析Wayland+Mesa+DRM+KMS的软件框架，着重分析图像送显、3D渲染、Direct render的过程，以此总结出DRM的功能和工作流程。
3）之后，把重心拉回kernel部分，主要包括DRM和KMS，当然，也会顺带介绍framebuffer。
4）kernel部分分析完毕后，回到Wayland，主要关心它的功能、使用方式等等。
5）其它的，边学、边写、边看吧。
原创文章，转发请注明出处。蜗窝科技，www.wowotech.net。

## DRI

在GUI环境中，一个Application想要将自身的UI界面呈现给用户，需要2个步骤：
1）根据实际情况，将UI绘制出来，以一定的格式，保存在buffer中。该过程就是常说的“Rendering”。
不知道为什么，wowo一直觉得“Render”这个英文单词太专业、太抽象了，理解起来有些困难。时间久了，也就不再执著了，看到它时，就想象一下内存中的图像数据（RGB或YUV格式），Rendering就是生成它们的过程。
通常来说，Rendering有多种表现形式，但可归结为如下几类：
a）2D的点、线、面等绘图，例如，“通过一个for循环，生成一个大小为640x480、格式为RGB888、填充颜色为红色的矩形框”，就是一个2D rendering的例子。
b）3D渲染。该过程牵涉比较复杂的专业知识，这里先不举例了。
c）图片、视频等多媒体解码。
d）字体渲染，例如直接从字库中抽出。
2）将保存在buffer中的UI数据，显示在display device上。该过程一般称作“送显”。
然后问题就来了：这两个步骤中，display server要承担什么样的角色？回答这个问题之前，我们需要知道这样的一个理念：
在操作系统中，Application不应该直接访问硬件，通常的软件框架是（从上到下）：Application<---->Service<---->Driver<---->Hardware。这样考虑的原因主要有二：安全性和共享硬件资源（例如显示设备只有一个，却有多个应用想要显示）。
对稍微有经验的软件开发人员（特别是系统工程师和驱动工程师）来说，这种理念就像杀人偿命、欠债还钱一样天经地义。但直到X server+3D出现之后，一切都不好了。因为X server大喊的着：“让我来！”，给出了这样的框架：

先不考虑上面的GLX、Utah GLX等术语，我们只需要理解一点即可：
基于OpenGL的3D program需要进行3D rendering的时候，需要通过X server的一个扩展（GLX），请求X server帮忙处理。X server再通过底层的driver（位于用户空间），通过kernel，访问硬件（如GPU）。
其它普通的2D rendering，如2D绘图、字体等，则直接请求X server帮忙完成。
看着不错哦，完全满足上面的理念。但计算机游戏、图形设备硬件等开发人员不乐意了：请让我们直接访问硬件！因为很多高性能的图形设备，要求相应的应用程序直接访问硬件，才能实现性能最优[1]。
好像每个人都是对的，怎么办？妥协的结果是，为3D Rendering另起炉灶，给出一个直接访问硬件的框架，DRI就应运而生了，如下：

上面好像讲的都是Rendering有关的内容，那送显呢？还是由display server统一处理比较好，因为显示设备是有限的，多个应用程序的多个界面都要争取这有限的资源，server会统一管理、叠加并显示到屏幕上。而这里叠加的过程，通常称作合成（Compositor），后续文章会重点说明。
3. 软件架构
DRI是因3D而生，但它却不仅仅是为3D而存在，这背后涉及了最近Linux图形系统设计思路的转变，即：


从以前的：X serve是宇宙的中心，其它的接口都要和我对话。
转变为：Linux kernel及其组件为中心，X server（如Wayland compositor等）只是角落里的一员，可有可无。
最终，基于DRI的linux图形系统如下（参考自[4][5]）：

该框架以基于Wayland的Windowing system为例，描述了linux graphic系统在DRI框架下，通过两条路径（DRM和KMS），分别实现Rendering和送显两个显示步骤。从应用的角度，显示流程是：
1）Application（如3D game）根据用户动作，需要重绘界面，此时它会通过OpenGL|ES、EGL等接口，将一系列的绘图请求，提交给GPU。
a）OpenGL|ES、EGL的实现，可以有多种形式，这里以Mesa 3D为例，所有的3D rendering请求，都会经过该软件库，它会根据实际情况，通过硬件或者软件的方式，响应Application的rendering请求。
b）当系统存在基于DRI的硬件rendering机制时，Mesa 3D会通过libGL-meas-DRI，调用DRI提供的rendering功能。
c）libGL-meas-DRI会调用libdrm，libdrm会通过ioctl调用kernel态的DRI驱动，这里称作DRM（Direct Rendering Module）。
d）kernel的DRM模块，最终通过GPU完成rendering动作。
2）GPU绘制完成后，将rendering的结果返回给Application。
rendering的结果是以image buffer的形式返回给应用程序。
3）Application将这些绘制完成的图像buffer（可能不知一个）送给Wayland compositor，Wayland compositor会控制硬件，将buffer显示到屏幕上。
Wayland compositor会搜集系统Applications送来的所有image buffers，并处理buffer在屏幕上的坐标、叠加方式后，直接通过ioctl，交给kernel KMS（kernel mode setting）模块，该模块会控制显示控制器将图像显示到具体的显示设备上。
4. DRM和KMS
DRM是Direct Rendering Module的缩写，是DRI框架在kernel中的实现，负责管理GPU（或显卡，graphics card）及相应的graphics memory，主要功能有二：
1）统一管理、调度多个应用程序向显卡发送的命令请求，可以类比为管理CPU资源的进程管理（process management）模块。
2）统一管理显示有关的memory（memory可以是GPU专用的，也可以是system ram划给GPU的，后一种方法在嵌入式系统比较常用），该功能由GEM（Graphics Execution Manager）模块实现，主要包括：
a） 允许用户空间程序创建、管理、销毁video memory对象（称作“"GEM objects”，以handle为句柄）。
b）允许不同用户空间程序共享同一个"GEM objects”（需要将不唯一的handle转换为同一个driver唯一的GEM name，后续使用dma buf）。
c）处理CPU和GPU之间内存一致性的问题。
d）video memory都在kernel管理，便于给到display controller进行送显（Application只需要把句柄通过Wayland Compositor递给kernel即可，kernel会自行获取memory及其内容）。
KMS是Kernel Mode Setting的缩写，也称作Atomic KMS，它是一个在linux 4.2版本的kernel上，才最终定性的技术。从字面意义上理解，它要实现的功能比较简单，即：显示模式（display mode）的设置，包括屏幕分辨率（resolution）、颜色深的（color depth）、屏幕刷新率（refresh rate）等等。一般来说，是通过控制display controller的来实现上述功能的。
也许大家会有疑问：这些功能和DRI有什么关系？说实话，关系不大，之所以要在DRI框架里面提及KMS，完全是历史原因，导致KMS的代码，放到DRM中实现了。目前的kernel版本（如4.2之后），KMS和DRM基本上没有什么逻辑耦合（除了代码位于相同目录，以及通过相同的设备节点提供ioctl之外），可以当做独立模块看待。
继续上面的话题，只是简单的display mode设置的话，代码实现不复杂吧？还真不一定！相反，KMS有关的技术背景、软件实现等，是相当复杂的，因此也就不能三言两语说得清，我会在单独的文章中重点分析KMS。
5. 参考文档
[1]: https://en.wikipedia.org/wiki/Direct_Rendering_Infrastructure
[2]: https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)
[3]: http://wayland.freedesktop.org/architecture.html
[4]: Linux_kernel_and_daemons_with_exclusive_access.svg
[5]: Wayland_display_server_protocol.svg

## framebuffer 帧缓冲

帧缓冲（framebuffer）是Linux 系统为显示设备提供的一个接口，它将显示缓冲区抽象，屏蔽图像硬件的底层差异，允许上层应用程序在图形模式下直接对显示缓冲区进行读写操作。用户不必关心物理显示缓冲区的具体位置及存放方式，这些都由帧缓冲设备驱动本身来完成。

framebuffer机制模仿显卡的功能，将显卡硬件结构抽象为一系列的数据结构，可以通过framebuffer的读写直接对显存进行操作。用户可以将framebuffer看成是显存的一个映像，将其映射到进程空间后，就可以直接进行读写操作，写操作会直接反映在屏幕上。

framebuffer是个字符设备，主设备号为29，对应于/dev/fb%d 设备文件。

通常，使用如下方式（前面的数字表示次设备号）

* 0 = /dev/fb0 第一个fb 设备
* 1 = /dev/fb1 第二个fb 设备

fb 也是一种普通的内存设备，可以读写其内容。例如，屏幕抓屏：cp /dev/fb0 myfilefb 虽然可以像内存设备（/dev/mem）一样，对其read,write,seek 以及mmap。但区别在于fb 使用的不是整个内存区，而是显存部分。

### fb与应用程序的交互

对于用户程序而言，它和其他的设备并没有什么区别，用户可以把fb看成是一块内存，既可以向内存中写数据，也可以读数据。fb的显示缓冲区位于内核空间，应用程序可以把此空间映射到自己的用户空间，在进行操作。

在应用程序中，操作/dev/fbn的一般步骤如下：
（1）打开/dev/fbn设备文件。
（2）用ioctl()操作取得当前显示屏幕的参数，如屏幕分辨率、每
个像素点的比特数。根据屏幕参数可计算屏幕缓冲区的大小。
（3）用mmap()函数，将屏幕缓冲区映射到用户空间。
（4）映射后就可以直接读/写屏幕缓冲区，进行绘图和图片显示了。

3、fb的结构及其相关结构体

在linux中，fb设备驱动的源码主要在Fb.h (linux2.6.28\include\linux)和Fbmem.c (linux2.6.28\drivers\video)两个文件中，它们是fb设备驱动的中间层，为上层提供系统调用，为底层驱动提供接口。


## VBE

VBE (VESA BIOS Extension) 全称是Video Electronics Standards Association即视频电子标准协会，是由代表来自世界各地的、享有投票权利的超过165家成员公司的董事会领导的非盈利国际组织。VESA致力于开发、制订和促进个人计算机（PC）、工作站以及消费类电子产品的视频接口标准，为显示及显示接口业界提供及时、开放的标准，保证其通用性并鼓励创新和市场发展。

VBE视频模式
先来看看VBE的模式号及其对应的分辨率与颜色：

VBE模式
VBE最高可以支持1280X1024的分辨率，24位真彩色，完全可以满足我们创建图形化操作系统的需求。

下面是一张视频标准图：

视频标准: VBE的标准比较老，不支持宽屏显示器。

用到的VBE函数
要实现图形模式就要用到vbe函数，vbe函数标准定义了一系列VGA ROM BIOS服务扩展。这些vbe函数可以在实模式下通过10h中断调用或者直接通过高性能的32位程序和操作系统调用。

我们的demo是通过实模式下的int 10h中断来调用VBE函数的

## LINUX 图形支持汇总

1. DRI+Xsever，例如   ：drm: mgag200 + xerver-xorg-video-mga
2. framebuffer 帧缓冲 ：fb: video= 看Documentation/fb/xxxfb.txt选参数
3. bios: vbe + int10 + ddc。 vga=x11B之类的不知道有没有用。根本不需要/dev/fbxx，弄好了直接int10用bios初始化的fb显示的

这里明显是用的第3种，最不可靠也是最后的手段. 要么是vbe的问题，要么是bios的问题，说是支持1280x1024，其实不支持，或者vbe查询就错了


解决问题
经过多次尝试，发现从grub引导开始分辨率就不正常了，猜想是grug配置的问题，然后就去看/etc/default/grub文件内容，在第一台主机上然后尝试注释掉 
GRUB_GFXMODE=640x480 
加上语句 
GRUB_GFXMODE=1920x1080 
运行 
#sudo update-grub2 
重启，分辨率又回来了1920x1080。 
再尝试几台，发现可以更改，找到解决办法了。不过不同的主板最大分辨率支持不一样，不需要太高，不过改成1024*768就可以看了。


如果你需要在linux上设置显示屏的分辨率，分两种情况：分辨率模式存在与分辨率模式不存在，具体如下。

1，分辨率模式已存在
1）如何查询是否存在：

图形界面：在System Settings/Displays/Resolution栏查看下拉列表。

控制台：在控制台输入命令：xrandr，即会输出当前已存在的分辨率模式。

2）如何配置：

图形界面：在System Settings/Displays/Resolution栏下拉列表中设置。

控制台：使用命令xrandr --output 显示器名称 --mode 模式名称，如：xrandr --output Virtual1 --mode "1440x900"  



2，分辨率模式不存在
总体操作流程如下：

1）使用ctv或gtf命令计算mode line参数；

2）使用xrandr --newmode 新建一个模式；

3）使用xrandr --add添加一个模式到指定的显示器；

4）使用xrandr -s 设置指定显示器的分辨率；

5）持久化模式与设置，即设置参数重启后有效。


以下为操作实例，新建一个分辨率模式1600x900_60.00，并将分辨率设置为该模式，同时持久化该配置：

测试环境：

1）ubuntu16.04（运行在win7 + vmware workstation 12）

2）对ubunut的显示器Virtual1进行设置



操作与输出如下：

wqb@ubuntu:~$ gtf 1600 900 60


  # 1600x900 @ 60.00 Hz (GTF) hsync: 55.92 kHz; pclk: 119.00 MHz
  Modeline "1600x900_60.00"  119.00  1600 1696 1864 2128  900 901 904 932  -HSync +Vsync



wqb@ubuntu:~$ xrandr --newmode "1600x900_60.00"  119.00  1600 1696 1864 2128  900 901 904 932  -HSync +Vsync  //新建一个显示模式，将上一行的后半部分作为xrandr --newmode的参数



wqb@ubuntu:~$ xrandr --addmode Virtual1 "1600x900_60.00"   //增加一个显示模式到Virtual1 



//设置Virtual1的显示模式为"1600x900_60.00"，此时分辨率设置已起效（屏幕显示宽度会变化），但未持久化显示模式，如果没有持久化显示模式，每次启动时都将提示无法找到显示模式"1600x900_60.00"

//你还可以通过编辑配置文件~/.config/monitors.xml来配置分辨率大小，但需要等到下一次重启时才起效。

wqb@ubuntu:~$ xrandr --output Virtual1 --mode "1600x900_60.00"   



//以下为持久化显示模式

wqb@ubuntu:~$ sudo vi /etc/X11/xorg.conf    //打开（或新建）xorg.conf文件，初始系统没有该文件，创建即可。

打开后，在文件中添加以下内容：

Section "Monitor"

    Identifier "Configured Monitor"
    Modeline "1600x900_60.00"  119.00  1600 1696 1864 2128  900 901 904 932  -HSync +Vsync    #来自命令gtf的输出
    Option "PreferredMode" "1600x900_60.00"    #模式名为"1600x900_60.00"
EndSection


Section "Screen"
    Identifier "Default Screen"
    Monitor "Configured Monitor"
    Device "Configured Video Device"
EndSection


Section "Device"
    Identifier "Configured Video Device"
EndSection



完成以上操作后，即添加一个显示模式"1600x900_60.00"到Virtual1，并持久设置分辨率为1600x900。



　　1. 调节屏幕对比度参数gamma值

　　》 xgamma -gamma .75

　　如果不理想可以尝试将.75修改成0.5~1.0之间测试一下。我用1.0后感觉和Vista下亮度一致。

　　该命令无须管理员权限。

　　2. 调节本本屏幕背光亮度pci

　　》 sudo setpci -s 00:02.0 F4.B=xx

　　xx就是16进制表示的屏幕亮度值，范围0（最亮）～FF（最暗）。

　　00:02.0是你的显示器VGA设备代码。

　　用lspci命令查一下你的VGA设备代码：

　　》 lspci 00:00.0 Host bridge： Intel Corporation Mobile PM965/GM965/GL960 Memory Controller Hub （rev 03） 00:02.0 VGA compatible controller： Intel Corporation Mobile GM965/GL960 Integrated Graphics Controller （rev 03） 00:02.1 Display controller： Intel Corporation Mobile GM965/GL960 Integrated Graphics Controller （rev 03） 00:1a.0 USB Controller： Intel Corporation 82801H （ICH8 Family） USB UHCI Controller #4 （rev 03）

　　注意第二行00:02.0 VGA compatible controller。

　　sudo setpci -s 00:02.0 F4.B=FF

　　解释一下：

　　setpci是修改设备属性的命令

　　-s表示接下来输入的是设备的地址

　　00:02.0 VGA设备地址（：。）

　　F4 要修改的属性的地址，这里应该表示“亮度”

　　.B 修改的长度（B应该是字节（Byte），还有W（应该是Word，两个字节）、L（应该是Long，4个字节））

　　=FF 要修改的值（可以改）

　　我这里00是最暗，FF是最亮，不同的电脑可能不一样。

　　比如说我嫌FF太闪眼了，我就可以sudo setpci -s 00:02.0 F4.B=CC，就会暗一些

　　上面就是Ubuntu使用命令调节屏幕亮度的方法介绍了，本文一共介绍了2种方法，使用任何一种都能够实现屏幕亮度的调节。


