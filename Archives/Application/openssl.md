若服务端要求客户端认证，需要将pfx证书转换成pem格式

openssl pkcs12 -clcerts -nokeys -in cert.pfx -out client.pem    #客户端个人证书的公钥  
openssl pkcs12 -nocerts -nodes -in cert.pfx -out key.pem #客户端个人证书的私钥

也可以转换为公钥与私钥合二为一的文件

openssl pkcs12 -in  cert.pfx -out all.pem -nodes                                   #客户端公钥与私钥，一起存在all.pem中

执行curl命令

１、使用client.pem+key.pem

curl -k --cert client.pem --key key.pem https://www.xxxx.com

2、使用all.pem

curl -k --cert all.pem  https://www.xxxx.com

使用-k，是不对服务器的证书进行检查，这样就不必关心服务器证书的导出问题了。
