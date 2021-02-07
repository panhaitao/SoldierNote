# x509 证书使用指南

## 概念和术语

x509 证书一般会用到三类文件，key，csr，crt。

* Key 是私用密钥 openssl格式，通常是rsa算法。
* csr 是证书请求文件 (certificate signing request)，用于申请证书。在制作csr文件的时候，必须使用自己的私钥来签署申请，还可以设定一个密钥。
* crt 是CA认证后的证书文件 (certificate)，签署人用自己的key给你签署的凭证。

## openssl 使用方式

CA根证书的生成步骤:

生成CA私钥（.key）-->生成CA证书请求（.csr）-->自签名得到根证书（.crt）（CA给自已颁发的证书）。

本质上就是用私钥去获取证书，然后把这两个文件一起放到server，以此来证明我就是我


## 创建自签名根证书

```
openssl genrsa -out root.key 2048
openssl req -new -key root.key -out root.csr -subj "/C=CN/ST=LiaoNing/L=DaLian/O=kaisawind/OU=wind.kaisa/CN=www.kaisawind.com/emailAddress=wind.kaisa@gmail.com"
openssl x509 -req -sha256 -extensions v3_ca -days 3650 -in root.csr -signkey root.key -out root.crt

```

以上也可以简写为

` 
openssl req -new -x509       \
            -keyout root.key \
            -out root.crt    \
            -days 3650       \
            -subj '/C=CN/ST=beijing/L=beijing/O=lql/OU=security/CN=hadoop.com'
`
## 创建服务证书

CAcreateserial会自动为根证书生成16hex编码字符串

```
openssl genrsa -out server.key 2048 
openssl req -new -key server.key -out server.csr -subj "/C=CN/ST=LiaoNing/L=DaLian/O=kaisawind/OU=wind.kaisa/CN=server.kaisawind.com/emailAddress=wind.kaisa@gmail.com"
if [ -f "../root/root.srl" ];then
openssl x509 -req -sha256 -extensions v3_req -days 3650 -in server.csr -CAkey ../root/root.key -CA ../root/root.crt -CAserial ../root/root.srl -out server.crt;
else
openssl x509 -req -sha256 -extensions v3_req -days 3650 -in server.csr -CAkey ../root/root.key -CA ../root/root.crt -CAcreateserial -out server.crt;
fi

```

## 创建客户端证书

```

openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr -subj "/C=CN/ST=LiaoNing/L=DaLian/O=kaisawind/OU=wind.kaisa/CN=client.kaisawind.com/emailAddress=wind.kaisa@gmail.com"
if [ -f "../root/root.srl" ];then
openssl x509 -req -sha256 -extensions v3_req -days 3650 -in client.csr -CAkey ../root/root.key -CA ../root/root.crt -CAserial ../root/root.srl -out client.crt;
else
openssl x509 -req -sha256 -extensions v3_req -days 3650 -in client.csr -CAkey ../root/root.key -CA ../root/root.crt -CAcreateserial -out client.crt;
fi

```


## keytool和openssl生成的证书转换

### keytool生成证书示例

1生成私钥+证书：
keytool -genkey -alias client -keysize 2048 -validity 3650 -keyalg RSA -dname "CN=localhost" -keypass $client_passwd -storepass $client_passwd -keystore ClientCert.jks
生成文件文件ClientCert.jks。

导出证书: keytool -export -alias client -keystore ClientCert.jks -storepass $client_passwd -file ClientCert.crt

keytool工具不支持导出私钥。

### 转换

keytool和openssl生成的证书相互之间无法识别，keytool生成的为jsk文件，openssl默认生成的为PEM格式文件。需要先转换成pkcs12格式，然后再使用对方的命令转换成需要的格式。

1. keytool生成的证书转换为PEM格式
# keytool -importkeystore -srcstoretype JKS -srckeystore ServerCert.jks -srcstorepass 123456 -srcalias server -srckeypass 123456 -deststoretype PKCS12 -destkeystore client.p12 -deststorepass 123456 -destalias client -destkeypass 123456 -noprompt

导出证书：openssl pkcs12 -in client.p12 -passin pass:$passwd -nokeys -out client.pem
导出私钥：openssl pkcs12 -in client.p12 -passin pass:$passwd -nocerts -out client.crt

PEM格式证书转换为jks文件
转换为pkcs12格式：

~/tmp/cert# openssl pkcs12 -export -in public.crt -inkey private.pem -out server.p12 -name server -passin pass:${passwd} -passout pass:${passwd}
导入到jks中：

~/tmp/cert# keytool -importkeystore -srckeystore server.p12 -srcstoretype PKCS12 -srcstorepass ${passwd} -alias server -deststorepass ${passwd} -destkeypass ${passwd} -destkeystore ServerCert.jks
