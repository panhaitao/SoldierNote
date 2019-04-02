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
