# Linux 系统故障分析记录


##  kernel:NMI watchdog: BUG: soft lockup - CPU#0 stuck for 26s

* 原因: 服务器跑大量高负载程序，造成cpu soft lockup
* 内核软死锁（soft lockup）bug原因分析

Soft lockup名称解释：所谓，soft lockup就是说，这个bug没有让系统彻底死机，但是若干个进程（或者kernel thread）被锁死在了某个状态（一般在内核区域），很多情况下这个是由于内核锁的使用的问题。
lockup分为soft lockup和hard lockup。 soft lockup是指内核中有BUG导致在内核模式下一直循环的时间超过10s（根据实现和配置有所不同），而其他进程得不到运行的机会。hard softlockup是指内核已经挂起，可以通过watchdog这样的机制来获取详细信息。

* 缓解办法

echo 30 > /proc/sys/kernel/watchdog_thresh  

临时生效 sysctl -w kernel.watchdog_thresh=30
永久配置 修改 /etc/sysctl.conf  kernel.watchdog_thresh=30

##  k8s 节点异常 OOM 负载高  

* 现象 k8s get nodes 返回某节点异常

1. 观察系统top 负载异常高，free 查看内存只有 几百M free 
2. 观察日志 journalctl -fu kubelet 看到不断有pod crashoff 其中有kafka nxs 等 
3. 观察系统 dmesg 不断返回某java进程 被内核OOM 机制杀掉
4. 查看kafka 配置参数不合理，容器资源限制8G kafka运行参数却只分了一个1G，将1G->6G kafka 重新调度到其他节点，kakfa运行正常，故障节点问题依旧没有缓解，排除kafka 引发
5. 执行docker stats 能看到 某个业务容器实例 BLOCK/IO 达到10G 
6. 执行top -> F 选中DATA  空格确认 -> ESC -> M 发现某个java 进程 DATA 使用量惊人 和docker  stats看到的一致，猜测和可能刚才这个业务有关，将对应容器停掉，节点负载恢复正常
7. 反馈问题给对应业务应用研发人员

其他参考 docker stats --format "table {{.Name}} \t {{.MemUsage}}" 
 
## 收集日志
sosreport --tmp-dir /root/tmp --batch 
