iostat 是用来显示系统CPU使用状态，硬盘设备的吞吐率的工具。
 
iostat语法
 iostat [ -c ] [ -d ] [ -h ] [ -k | -m ] [ -N ] [ -t ] [ -V ] [ -x ] 	 [ -y   ]  [  -z  ]  [  -j  {  ID  |  LABEL  | PATH | UUID | ... } ] 	 [ [ -T ] -g  group_name ] [ -p [ device [,...] | ALL ] ] [ device 	 [...]  |  ALL  ]  [ interval [ count ] ]
 
iostat命令常用参数及其含义如表5.3所示。
 
表5.3 iostat命令常用参数及其含义
参数
含义
-c
仅显示cpu利用率的统计信息
-d
仅显示硬盘利用率的统计报告
-k
以K为单位显示每秒的磁盘请求数,默认单位块
-m
以m为单位显示每秒的磁盘请求数,默认单位块
-p
用于显示块设备及系统分区的统计信息.也可以在-p后指定一个设备名,如:
 iostat -p sda
-t
在输出数据时,打印搜集数据的时间
-V
打印版本信息
-x
显示扩展统计信息
 
iostat命令的其他更多参数及其含义，用户可以直接运行man iostat即可查看。



