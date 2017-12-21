# OpenSSL组件
-----------

OpenSSL 是一个开源项目，其组成主要包括一下三个组件：

-   openssl：多用途的命令行工具
-   libcrypto：加密算法库
-   libssl：加密模块应用库，实现了ssl及tls

openssl可以实现：秘钥证书管理、对称加密和非对称加密 。

## 术语
----

openssl中有如下约定熟成的后缀名称：

    * .key：  私有的密钥
    * .csr：   证书签名请求（证书请求文件），含有公钥信息，certificate signing request的缩写
    * .crt：   证书文件，certificate的缩写
    * .crl：   证书吊销列表，Certificate Revocation List的缩写
    * .pem：用于导出，导入证书时候的证书的格式，有证书开头，结尾的格式

## 加密和签名
----------

-   加密: 公钥用于对数据进行加密，私钥用于对数据进行解密
-   签名: 私钥用于对数据进行签名，公钥用于对签名进行验证

## Openssl 操作指南
----------------

### 生成密钥

-   生成私钥: openssl genrsa -out private.key 2048
-   到出公钥: openssl rsa -in private.key -pubout -out public.key

<!-- -->

    genrsa       产生RSA密钥命令。
    -aes256      使用AES算法（256位密钥）对产生的私钥加密。可选算法包括DES，DESede，IDEA和AES。
    -out         输出路径,这里指private/server.key.pem。
    2048         指RSA密钥长度位数，默认长度为512位。

### 创建CA

CA是专门签发证书的权威机构，处于证书的最顶端。自签是用自己的私钥给证书签名，CA签发则是用CA的私钥给自己的证书签名来保证证书的可靠性
CA根证书的生成步骤：
生成CA私钥（.key）--&gt;生成CA证书请求（.csr）--&gt;自签名得到根证书（.crt）（CA给自已颁发的证书）。

`   openssl genrsa -out ca.key 2048     `\
`   openssl req -new -key ca.key -out ca.csr    `\
`   openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt  `\
`   `\
`  以上操作合并操作如下：`\
`   openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ca.key -out ca.crt`

    req
    -x509
    -nodes 本option被set的话,生成的私有密钥文件将不会被加密
    -days 365 

-   查看自签名CA证书：openssl x509 -text -in ca.crt

### 颁发证书

颁发证书就是用CA的秘钥给其他人签名证书，输入需要证书请求，CA的私钥及CA的证书，输出的是签名好的还给用户的证书.
用户的证书请求信息填写的国家省份等需要与CA配置一致，否则颁发的证书将会无效。

用户证书的生成步骤

生成私钥（.key）--&gt;生成证书请求（.csr）--&gt;CA的私钥及CA的证书签名得到用户证书（.crt）

-   生成密钥： openssl genrsa -out client.key 2048
-   生成请求: openssl req -new -subj -key client.key -out client.csr
-   签发证书: openssl x509 -req -days 3650 -sha1 -extensions v3\_req -CA
    ca.crt -CAkey ca.key -CAserial ca.srl -CAcreateserial -in client.csr
    -out client.crt

<!-- -->

    req          产生证书签发申请命令
    -new         表示新请求。
    -key         密钥,这里为client.key文件
    -out         输出路径,这里为client.csr文件
    -subj        指定用户信息

    x509           签发X.509格式证书命令。
    -req            表示证书输入请求。
    -days          表示有效天数,这里为3650天。
    -sha1           表示证书摘要算法,这里为SHA1算法。
    -extensions    表示按OpenSSL配置文件v3_req项添加扩展
    -CA            表示CA证书,这里为ca.cert
    -CAkey         表示CA证书密钥,这里为ca.key
    -CAserial      表示CA证书序列号文件,这里为ca.srl
    -CAcreateserial表示创建CA证书序列号
    -in            表示输入文件,这里为private/client.csr
    -out           表示输出文件,这里为certs/client.crt

-   验证CA颁发的证书提取的公钥和私钥导出的公钥是否一致 openssl x509 -in
    client.cert -pubkey
-   验证server证书 openssl verify -CAfile ca.crt client.crt
-   生成pem格式证书有时需要用到pem格式的证书，可以用以下方式合并证书文件（crt）和私钥文件（key）来生成
    cat client.crt client.key&gt; client.pem

## 参考
----

-   OpenSSL Command-Line HOWTO: <https://www.madboa.com/geek/openssl/>
-   自建 CA 和颁发 SSL证书 : <http://www.jianshu.com/p/79c284e826fa>
-   OpenSSL 标准命令详细解释 :
    <http://blog.csdn.net/scuyxi/article/details/54884976>
-   openssl详解:
    <http://blog.csdn.net/w1781806162/article/details/46358747>
## 未整理部分
---
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
OpenSSL组件
