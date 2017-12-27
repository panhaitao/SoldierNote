
挂起是一种省电模式，系统将机器的硬盘、显示器等外部设备停止工作，而CPU、内存仍然工作，等待用户随时唤醒，再次唤醒需要按键盘上的键数次。
体眠是一种更加省电的模式，它将内存中的数据保存于硬盘中，使CPU也停止工作，当再次使用时需按开关机键，机器将会恢复到您的执行休眠时的状态，而不用再次执行启动操作系统复杂的过程。
待机是将当前处于运行状态的数据保存在内存中，机器只对内存供电，而硬盘、屏幕和CPU等部件则停止供电。由于数据存储在速度快的内存中，因此进入等待状态和唤醒的速度比较快。不过这些数据是保存在内存中，如果断电则会使数据丢失。



立刻关机：
halt
init 0
shutdown -h now
shutdown -h 0

定时/延时关机：
shutdown -h 10:00
shutdown -h +30    //单位为分钟

重启：
reboot
init 6
shutdown -r now

休眠：
sudo pm-hibernate
echo "disk" > /sys/power/state
sudo hibernate-disk

待机/挂起：
sudo pm-suspend
sudo pm-suspend-hybrid
echo “mem” > /sys/power/state
sudo hibernate-ram
