# 系统性能测试

1. cpu
2. 

## 内存带宽

```
yum groupinstall 'Development Tools' -y | apt install build-essential -y 
git clone http://github.com/raas/mbw
cd mbw
make
```
确认内存通道: dmidecode -t memory | grep DIMM

./mbw -q -n 10 256

* -q 隐藏日志
* 10 测试次数
* 1000 内存大小（单位是M）


git clone https://github.com/jeffhammond/STREAM
make

