mpstat 提供多处理器系统中的CPU的利用率的统计，mpstat 也可以加参数，用-P来指定哪个 CPU，处理器的ID是从0开始的。
 
Mpstat语法
mpstat [ -A ] [ -u ] [ -V ] [ -I { SUM | CPU | SCPU | ALL } ] [ -P 	{ cpu  [,...] | ON | ALL } ] [ interval [ count ] ]
 
其中-P {|ALL} 表示监控哪个CPU， cpu在[0,cpu个数-1]中取值，internal 相邻的两次采样的间隔时间、count 采样的次数，count只能和delay一起使用，当没有参数时，mpstat则显示系统启动以后所有信息的平均值。有interval时，第一行的信息自系统启动以来的平均信息。从第二行开始，输出为前一个interval时间段的平均信息。
 
mpstat命令常用参数及其含义如表5.4所示。
 
表5.4 mpstat命令常用参数及其含义
参数
含义
-A
统计所有cpu的所有信息
-P
统计指定的cpu信息
-u
统计cpu的利用率
-I
统计中断信息
-V
打印版本信息
 
mpstat命令的其他更多参数及其含义，用户可以直接运行man mpstat即可查看。
 