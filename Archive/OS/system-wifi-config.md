# LINUX终端下配置WPA2加密无线网络

## 生成配置文件模版
 
    wpa_passphrase <yourAPssid> <yourpassphrase> > /etc/wpa_supplicant/wpa_supplicant.conf

## 参考下面的配置将上面的配置补充完整

For WPA2-Personal

```  
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
ap_scan=1
network={
        ssid="my_network"
        proto=RSN
        key_mgmt=WPA-PSK
        pairwise=CCMP TKIP
        group=CCMP TKIP
        psk=secret_password
}
```


## 配置关键点说明

```
network={
ssid="Mywireless" 	# 请非常注意 ssid 名的大小写。
proto=RSN 		# Robust Security Network:强健安全网络，表示这个网络配置比WEP模式要更安全。
key_mgmt=WPA-PSK 	# 请无论你是使用WPA-PSK，WPA2-PSK，都请在这里输入 WPA-PSK。这在wpa_supplicant看来WPA-PSK，WPA2-PSK都是 WPA-PSK
pairwise=CCMP TKIP 	# 关键点，wpa_supplicant目前还不认AES的加密标准
group=CCMP TKIP 	# 同上
psk=7b271c9a7c8a6ac07d12403a1f0792d7d92b5957ff8dfd56481ced43ec6a6515 #wpa_supplicant算出来的加密密码 注意这里不要代引号"" 
```

##  手动应用配置

```
wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
dhclient wlan0
```

## 将配置写入 /etc/network/interfaces (在debian 8.0 下测试通过，其他版本没有测试)

```
allow-hotplug wlan0
iface wlan0 inet static
address 192.168.1.101
netmask 255.255.255.0
gateway 192.168.1.1
pre-up wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```

## 参考文档

* <http://blog.wp08.com/article/uncategorized/754.html>
* <http://www.360doc.com/content/12/0709/15/9424702_223191508.shtml>
* https://blog.csdn.net/fxfzz/article/details/6179055
