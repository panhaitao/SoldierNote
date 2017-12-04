e2fsprogs概述
e2fsprogs是一个使用proc文件系统的公用软件包，而不是一个单独的应用程序。此软件包被成功安装后，安装的程序如下：
Ø e2undo	将重放 ext2/3/4文件系统的 undo log
Ø e2image
Ø dumpe2fs	将会把 super block上的信息dump到stdin
Ø Badblocks	对指定的设备检查坏掉的块
Ø resize2fs	调整ext2/3/4文件系统尺寸
Ø debugfs	是ext2文件系统交互式除错工具
Ø e2fsck	linux的ext2/ext3/ext4文件系统检查程序
Ø tune2fs	调整和查看ext2/ext3文件系统的文件系统参数程序
Ø mke2fs	创建ext2/ext3/ext4文件系统
Ø Logsave	保存一个命令的输出到一个日志文件
Ø e4defrag	ext4文件系统碎片整理程序
Ø e2freefrag	在ext2/ext3/ext4文件系统报告碎片剩余空间选项
Ø Filefrag	报告某指定文件碎片情况
Ø chattr	对ext2/3/4文件系统特有的属性进行更变
Ø lsattr	对ext2/3/4 文件系统特有的属性进行查阅
Ø fsck.ext4	ext4文件系统检查一般性的命令
Ø fsck.ext3	ext3文件系统检查一般性的命令
Ø e2label	设定 LABEL
Ø mkfs.ext3	创建一个ext3文件系统
Ø mkfs.ext4	创建一个ext4文件系统
Ø mkfs.ext4dev	创建一个ext4文件系统
Ø fsck.ext4dev	检查linux的ext4文件系统
Ø fsck.ext2	ext2文件系统检查一般性的命令
Ø mkfs.ext2	创建一个ext2文件系统
 
/sbin/fsck.ext2rogs软件包安装
深度服务器操作系统默认已经集成了e2fsprogs软件包。
 
e2fsprogs所包含应用程序用法
e2undo语法：
e2undo [ -f ] undo_log device
 
e2image语法
e2image [ -r|Q ] [ -fr ] device image-file
e2image -I device image-file
e2image -ra  [  -cfnp  ] [ -o src_offset ] [ -O dest_offset ] src_fs 	[ dest_fs ]
 
dumpe2fs语法
 dumpe2fs  [ -bfhixV ] [ -o superblock=superblock ] [ -o blocksize=block‐size ] device
 
Badblocks语法
badblocks  [  -svwnfBX  ]  [  -b block-size ] [ -c blocks_at_once ] [ -e  max_bad_blocks ] [ -d read_delay_factor ] [ -i input_file ]  [  -o  out‐put_file ] [ -p num_passes ] [ -t test_pattern ] device [ last-block ] [ first-block ]
 
resize2fs语法
resize2fs [ -fFpPM ] [ -d debug-flags ] [ -S RAID-stride ] device [ size ]
 
debugfs语法
debugfs [-b blocksize] [-s superblock] [-f cmd_file] [-R request] [-V] [[-w] [-c] device]
 
e2fsck语法
 
e2fsck [-panyrcdfvtDFV] [-b superblock] [-B blocksize]
[-I inode_buffer_blocks] [-P process_inode_size]
[-l|-L bad_blocks_file] [-C fd] [-j external_journal]
[-E extended-options] device
 
tune2fs语法
 tune2fs [ -l ] [ -c max-mount-counts ] [ -e errors-behavior ] [ -f  ]  [ -i  interval-between-checks  ]  [  -j  ]  [  -J  journal-options  ] [ -m reserved-blocks-percentage ]  [  -o  [^]mount-options[,...]   ]  [   -r  reserved-blocks-count  ] [ -s sparse-super-flag ] [ -u user ] [ -g group] [ -C mount-count ] [ -E extended-options ] [ -L  volume-name  ]  [  -M last-mounted-directory ] [ -O [^]feature[,...]  ] [ -Q quota-options ] [  -T time-last-checked ] [ -U UUID ] device
 
mke2fs语法
 mke2fs  [ -c | -l filename ] [ -b block-size ] [ -D ] [ -f fragment-size  ] [ -g blocks-per-group ] [ -G number-of-groups ] [ -i bytes-per-inode ] [  -I inode-size ] [ -j ] [ -J journal-options ] [ -N number-of-inodes ][ -n ] [ -m reserved-blocks-percentage ] [ -o creator-os ] [ -O  [^]fea‐ture[,...]   ] [ -q ] [ -r fs-revision-level ] [ -E extended-options ] [-v ] [ -F ] [ -L volume-label ] [ -M last-mounted-directory ] [ -S  ]  [ -t fs-type ] [ -T usage-type ] [ -U UUID ] [ -V ] device [ fs-size ] 
 
 mke2fs  -O journal_dev [ -b block-size ] [ -L volume-label ] [ -n ] [ -q ] [ -v ] external-journal [ fs-size ]
 
logsave语法
logsave [ -asv ] logfile cmd_prog [ ... ]
 
e4defrag语法
e4defrag [ -c ] [ -v ] target ...
 
e2freefrag语法
e2freefrag [ -c chunk_kb ] [ -h ] filesys
 
filefrag语法
filefrag [ -bblocksize ] [ -BeksvxX ] [ files...  ]
 
chattr语法
chattr [ -RVf ] [ -v version ] [ mode ] files...
 
lsattr语法
lsattr [ -RVadv ] [ files...  ]
 
fsck.ext4语法
fsck.ext4 [-panyrcdfvtDFV] [-b superblock] [-B blocksize]
[-I inode_buffer_blocks] [-P process_inode_size]
[-l|-L bad_blocks_file] [-C fd] [-j external_journal]
[-E extended-options] device
 
 
fsck.ext3语法
fsck.ext3 [-panyrcdfvtDFV] [-b superblock] [-B blocksize]
[-I inode_buffer_blocks] [-P process_inode_size]
[-l|-L bad_blocks_file] [-C fd] [-j external_journal]
[-E extended-options] device
 
e2label语法
e2label device [ new-label ]
 
mkfs.ext3语法
 mkfs.ext3 [-c|-l filename] [-b block-size] [-C cluster-size]
[-i bytes-per-inode] [-I inode-size] [-J journal-options]
[-G flex-group-size] [-N number-of-inodes]
[-m reserved-blocks-percentage] [-o creator-os]
[-g blocks-per-group] [-L volume-label] [-M 	last-mounted-directory]
[-O feature[,...]] [-r fs-revision] [-E extended-option[,...]]
[-t fs-type] [-T usage-type ] [-U UUID] [-jnqvDFKSV] device 	[blocks-count]
[-G flex-group-size] [-N number-of-inodes]
[-m reserved-blocks-percentage] [-o creator-os]
[-g blocks-per-group] [-L volume-label] [-M 	last-mounted-directory]
[-O feature[,...]] [-r fs-revision] [-E extended-option[,...]]
[-t fs-type] [-T usage-type ] [-U UUID] [-jnqvDFKSV] device 	[blocks-count
 
mkfs.ext4语法
mkfs.ext4 [-c|-l filename] [-b block-size] [-C cluster-size]
[-i bytes-per-inode] [-I inode-size] [-J journal-options]
[-G flex-group-size] [-N number-of-inodes]
[-m reserved-blocks-percentage] [-o creator-os]
[-g blocks-per-group] [-L volume-label] [-M 	 	last-mounted-directory][-O feature[,...]] [-r fs-revision] [-E 	extended-option[,...]][-t fs-type] [-T usage-type ] [-U UUID] 	[-jnqvDFKSV] device [blocks-count]
 
mkfs.ext4dev语法
mkfs.ext4dev [-c|-l filename] [-b block-size] [-C cluster-size]
[-i bytes-per-inode] [-I inode-size] [-J journal-options]
[-G flex-group-size] [-N number-of-inodes]
[-m reserved-blocks-percentage] [-o creator-os]
[-g blocks-per-group] [-L volume-label] [-M 	last-mounted-directory][-O feature[,...]] [-r fs-revision] [-E 	extended-option[,...]][-t fs-type] [-T usage-type ] [-U UUID] 	[-jnqvDFKSV] device [blocks-count]
 
fsck.ext4dev语法
fsck.ext4dev [-panyrcdfvtDFV] [-b superblock] [-B blocksize]
[-I inode_buffer_blocks] [-P process_inode_size]
[-l|-L bad_blocks_file] [-C fd] [-j external_journal]
[-E extended-options] device
 
fsck.ext2语法
fsck.ext2 [-panyrcdfvtDFV] [-b superblock] [-B blocksize]
[-I inode_buffer_blocks] [-P process_inode_size]
[-l|-L bad_blocks_file] [-C fd] [-j external_journal]
[-E extended-options] device
 
mkfs.ext2语法
mkfs.ext2 [-c|-l filename] [-b block-size] [-C cluster-size]
[-i bytes-per-inode] [-I inode-size] [-J journal-options]
[-G flex-group-size] [-N number-of-inodes]
[-m reserved-blocks-percentage] [-o creator-os]
[-g blocks-per-group] [-L volume-label] [-M 	last-mounted-directory]	[-O feature[,...]] [-r fs-revision] [-E 	extended-option[,...]]	[-t fs-type] [-T usage-type ] [-U UUID] 	[-jnqvDFKSV] device [blocks-count]
 
P
e2fsprogs所包含应用程序应用举例
实例1 设置强制检查前文件系统可以挂载的次数
tune2fs -c 30 /dev/sda1
