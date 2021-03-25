# SSL证书的创建与管理

## 概念与术语

SSL证书属于私钥/公钥的非对称加密方式
1. ca.key ca.crt 默认约定指 根私钥和根证书
2. ca 证书链下认证的其他证书 server.key/server.crt

## 数字证书(Subject)含义
常用字段
1.  C（Country Name）所在国家字母简称，如中国：CN 
2.  ST（State or Province Name), 所在省份简称, 如 Beijing
3.  L （Locality Name）所在城市
4.  O（Organization Name）公司或者机构名称
5.  OU（Organizational Unit Name）部门简称
6.  CN（Common Name）公用名称
    1.  对于 SSL 证书，一般为网站域名；
    2.  而对于代码签名证书则为申请单位名称；
    3.  而对于客户端证书则为证书申请者的姓名

其他常用字段：
7.  E (Email) 电子邮件简称 
8.  G 多个姓名字段简称 
9.  Description 字段, 描述介绍 
10.  Phone 字段，电话号码：格式要求 + 国家区号 城市区号 电话号码，如： +86 732 88888888 
11.  STREET 字段地址 
12.  PostalCode 字段，邮政编码 

## 认证类型

SSL证书管理服务支持的“域名类型”有“单域名”、“多域名”和“泛域名”3种类型

*   单域名证书: 仅支持绑定1个普通域名
*   多域名证书: 几个域名需要绑定在同一个SSL证书里，则需要选择对应的域名数量
*   泛域名证书：仅支持绑定1个泛域名。泛域名一般格式带1个通配符，支持使用泛域名为根域的多个子域名

## 认证级别

以上提到的 DV，OV和EV 是指CA机构颁发的证书的认证类型，常见有3种类型：

域名型SSL证书（DV SSL）：信任等级普通，只需验证网站的真实性便可颁发证书保护网站；

企业型SSL证书（OV SSL）：信任等级强，须要验证企业的身份，审核严格，安全性更高；

增强型SSL证书（EV SSL）：信任等级最高，一般用于银行证券等金融机构，审核严格，安全性最高

# 如何获取证书

## 自签名SSL证书

*   **流程：**手动证书创建，无续订机制
*   **费用：**免费
*   **验证：** DV和OV
*   **信任：**默认为无。因为不涉及通用CA，浏览器和操作系统中默认为不可信，需要手动导入ca证书，并手动将每个证书标记为受信任
*   **通配符证书：**支持
*   **仅限IP证书：**支持**，**任何IP
*   **到期时间：**自定义

## 商业证书

如果是企业/网站对外提供服务，一般按需购买证书服务商颁发的付费证书

*   **流程：**初始设置和续订的手动流程
*   **费用：**大约10美元至1000美元
*   **验证：** DV，OV和EV
*   **信任：**在大多数浏览器和操作系统中默认为可信
*   **通配符证书：**支持
*   **仅IP证书：**有些证书将为**公共** IP地址颁发证书
*   **有效期：** 1 - 3年 

## **国内可用SSL证书提供商参考**

数据来源：参考知乎 https://zhuanlan.zhihu.com/p/340074172

![image](https://upload-images.jianshu.io/upload_images/5592768-2dd37162711113e7?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-7fa392cf46c2f3de?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 创建自签名SSL证书

证书按照用途定义分类，一般分为 CA根证书，服务端证书, 客户端证书：

## 创建自签名根根证书（CA）

```
openssl genrsa -out root.key 2048 -passout pass:"ca_key_密码"
openssl req -new -key root.key          \
            -out root.csr               \
            -passin pass: "ca_key_密码"  \
            -subj "/C=CN/ST=Bejing/L=BJ/O=RD/OU=RDTEAM/CN=hadoop.com"
openssl x509 -req -sha256         \
             -extensions v3_ca    \
             -days 3650           \
             -in ca.csr           \
             -signkey ca.key      \
             -passin pass: "ca_key_密码" \ 
             -out ca.crt
```
以上也可以简写为
```
openssl req -newkey rsa:2048           \
            -keyout ca.key                        \
            -out ca.crt                               \
            -days 3650                             \
            -x509                                      \
            -passout pass:"ca_key_密码" \
            -subj '/C=CN/ST=beijing/L=BJ/O=RD/OU=RDTEAM/CN=hadoop.com'

```

*   genrsa 是私钥创建子命令
*   req 是证书请求的子命令
*   -newkey rsa:2048 -keyout private_key.pem 表示生成私钥(PKCS8格式)
*   -passout 
*   -passin 
*   -x509表示输出证书
*   -days365 为有效期 
*   -subj 
*   -passin是-in <file name>的密码，
*   -passout是-out <file name>的密码

创建自签名根根证书过程：生成CA私钥（.key）-->生成CA证书请求（.csr）-->自签名得到根证书（.crt）（CA给自已颁发的证书）

最终生成文件列表

1.  ca.key 私钥（有私钥口令保护，对应创建过程的ca_key_密码）
2.  ca.crt 根证书

## 创建服务端证书, 客户端证书

```
#!/bin/bash

for cert_name in client  server
do
   openssl genrsa -out ${cert_name}.key 2048             \
                  -passout pass:111111
   openssl req -new -key ${cert_name}.key                \
                    -out ${cert_name}.csr                \
                    -passin pass:111111                  \
                    -subj "/C=CN/ST=beijing/L=BJ/O=RD/OU=RDTEAM/CN=${cert_name}.hadoop.com"
  if [ -f ca.srl ];then
    openssl x509 -req -sha256                            \
                 -extensions v3_req                      \
                 -days 3650                              \
                 -in ${cert_name}.csr                    \
                 -CAkey ca.key                           \
                 -CA ca.crt                              \
                 -CAserial ca.srl                        \
                 -passin pass:"ca_key_密码"              \
                 -out ${cert_name}.crt
  else
 openssl x509 -req -sha256                               \
                 -extensions v3_req                      \
                 -days 3650                              \
                 -in ${cert_name}.csr                    \
                 -CAkey ca.key                           \
                 -CA ca.crt                              \
                 -CAcreateserial                         \
                 -passin pass:"ca_key_密码"              \
                 -out ${cert_name}.crt
  fi
done

```

创建自签名根根证书过程：生成server私钥（.key）-->生成server证书请求（.csr）-->使用CA根证书为server证书签名，生成server证书文件（.crt）

最终生成文件

1.  client.key
2.  client.crt
3.  server.key
4.  server.crt

# 证书的格式转换

## 证书文件

常见的证书格式有，pem格式，PFX格式，JKS格式

### PEM

x509 证书常见的文件后缀为.pem、.crt、.cer、.key

*   Key后缀一般是私用密钥 openssl格式，通常是rsa算法。
*   csr 是证书请求文件 (certificate signing request)，用于申请证书。在制作csr文件的时候，必须使用自己的私钥来签署申请，还可以设定一个密钥。
*   crt 后缀一般是CA认证后的证书文件 (certificate)，签署人用自己的key给你签署的凭证
*   适用于Apache、Nginx、Candy Server等Web服务器

### PFX

*   常见的文件后缀为.pfx、.p12
*   同时包含证书和私钥，且一般有密码保护
*   适用于IIS等Web服务器

### JKS

*   适用于Tomcat、HDFS 等java语言编写的应用
*   常见的文件后缀为.jks
    *   keystore 可以看成一个放key的库，key就是公钥，私钥，数字签名等组成的一个信息。
    *   truststore 是放信任的证书的一个store.

truststore和keystore的性质是一样的，都是存放key的一个仓库，区别在于，

*   A **KeyStore** consists of a database containing a private key and an associated certificate, or an associated certificate chain. The certificate chain consists of the client certificate and one or more certification authority (CA) certificates.
*   A **TrustStore** contains only the certificates trusted by the client (a “trust” store). These certificates are CA root certificates, that is, self-signed certificates. The installation of the Logical Host includes a TrustStore file named **cacerts.jks** in the location:


## 证书格式互转示意图

![image](https://upload-images.jianshu.io/upload_images/5592768-3f5f2e2c9a33ac64?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## PEM 格式转为PFX格式

```
#!/bin/bash
for item in ca:ca_key_pw server:server_key_pw client:client_key_pw
do

cert_name=`echo $item | awk -F: '{print $1}'`
key_pass=`echo $item | awk -F: '{print $2}'`

openssl pkcs12 -export                   \
               -name ${cert_name}        \
               -inkey ${cert_name}.key   \
               -passin pass:${key_pass}  \
               -passout pass:${key_pass} \
               -in ${cert_name}.crt      \
               -out ${cert_name}.p12
done                   

```

最终生成文件

1.  ca.p12
2.  client.p12
3.  server.p12

由于PKCS12格式是包含私钥和证书，使用的时候存在如何问题：如果作为客户端，需要CA证书做验证，导入ca.p12证书的同时也会将ca.key导入；对于CA的私钥的使用范围要严格限制的，做客户端证书格式转换的时候，可以通过 -chain 参数将 ca.crt 包含进去，以下是推荐用法：

```
for item in client:client_key_pw
do

cert_name=`echo $item | awk -F: '{print $1}'`
key_pass=`echo $item | awk -F: '{print $2}'`

openssl pkcs12 -export                   \
               -name ${cert_name}        \
               -chain -CAfile ca.crt     \
               -inkey ${cert_name}.key   \
               -passin pass:${key_pass}  \
               -passout pass:${key_pass} \
               -in ${cert_name}.crt      \
               -out ${cert_name}.p12
done       

```

以MacOS 系统，浏览器作为客户端访问，为例:

系统设置-> 钥匙串访问 -> 文件 -> 导入项目 导入 client.p12 证书,并设置为ca证书为始终信任，如果是双向认证模式，浏览器访问对应 https 服务，选择client证书即可访问

## PFX格式转换为JKS格式

#### 创建TrustStore

```
keytool -import -trustcacerts        \
        -alias ca                    \
        -file ca.crt                 \
        -storepass ca_store_pass     \
        -keystore ca.jks             \
        -noprompt

```

最终生成文件

1.  ca.jks

#### 创建KeyStore

```
#!/bin/bash

export store_pass=store_pw_xxxx

for item in server:key_pass_xxx:new_pass_xxx client:key_pass_xxx:new_pass_xxx
do

cert_name=`echo $item | awk -F: '{print $1}'`
key_pass=`echo $item | awk -F: '{print $2}'`
new_pass=`echo $item | awk -F: '{print $3}'`

keytool -importkeystore                    \
        -srckeystore ${cert_name}.p12      \
        -srcstoretype PKCS12               \
        -srcstorepass ${key_pass}          \
        -alias ${cert_name}                \
        -deststorepass ${store_pass}       \
        -destkeypass ${new_pass}           \
        -destkeystore ${cert_name}.jks     \
        -noprompt
done

```

*   keypass <arg> 密钥口令
*   storepass <arg> 密钥库口令

最终生成文件

1.  client.jks
2.  server.jks

#### 查看JKS证书

```
keytool -list -v -keystore xxx.jks 输入 storepass

```

## PFX 格式 转换为 PEM 格式

```
导出私钥:
openssl pkcs12 -in client.p12 -passin pass:$passwd -nokeys -out client.pem

导出证书：
openssl pkcs12 -in client.p12 -passin pass:$passwd -nocerts -out client.crt

```

# 证书的使用示例

1.  nginx单向认证 SSL证书配置示例

修改nginx配置文件，server字段

```
server {
        listen 443 ssl;
        server_name _;
        root         /usr/share/nginx/html;

        ssl_certificate server.crt;
        ssl_certificate_key server.key; 

    }

```

重启nginx服务，执行命令验证https服务:

```
echo "127.0.0.1  server.hadoop.com" >> /etc/hosts
curl https://server.hadoop.com:443 --cacert /root/KEY/ca.crt

```

2.  Nginx双向认证SSL证书 配置示例

修改nginx配置文件，server字段

```
    server {
        listen       443 ssl;
        server_name  ttt.com;

        ssl_certificate      /data/sslKey/server.crt;  #server证书公钥
        ssl_certificate_key  /data/sslKey/server.key;  #server私钥
        ssl_client_certificate /data/sslKey/ca.crt;    #根级证书公钥，用于验证各个二级client
        ssl_verify_client on;  #开启客户端证书验证  
    }
} 

```

重启nginx服务，执行命令验证https服务 :

```
echo "127.0.0.1  server.hadoop.com" >> /etc/hosts
curl https://server.hadoop.com:443 \
     --cacert /root/KEY/ca.crt     \
     --cert /root/KEY/client.crt   \
     --key /root/KEY/client.key

```

3.  tomcat应用单向认证 jks格式证书配置示例

1.  准备好证书: server.jks 
2.  安装docker部署tomcat服务

```
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y

```

3.  修改 server.xml SSL配置部分，参考如下:

```
<Connector port="443" protocol="org.apache.coyote.http11.Http11NioProtocol" maxThreads="150" SSLEnabled="true">
  <SSLHostConfig>
    <Certificate 
        certificateKeystoreFile="/usr/local/tomcat/cert/server.jks"
        certificateKeystorePassword="store_pass_xxx"
        certificateKeystoreType="JKS"
        type="RSA" />
    </SSLHostConfig>
</Connector>

```

Tomcat官方文档: https://tomcat.apache.org/tomcat-9.0-doc/config/http.html#HTTP/1.1_and_HTTP/1.0_Support

```
docker run -d                                                          \
       -v /data/server.jks:/usr/local/tomcat/cert/server.jks           \
       -v /data/server.xml:/usr/local/tomcat/conf/server.xml           \
       --name=tomcat                                                   \
       --net=host                                                      \
       uhub.service.ucloud.cn/ucloud_pts/tomcat:9.0
docker exec -t -i tomcat sh -c "rm -rvf webapps; mv webapps.dist/ webapps"
docker restart tomcat 

```

验证java应用https服务

```
echo "127.0.0.1  server.hadoop.com" >> /etc/hosts
curl https://server.hadoop.com:443 --cacert /root/KEY/ca.crt

```

4.  Tomcat应用双向认证 jks格式证书配置示例

准备好证书：

1.  ca.jks
2.  server.jks

```
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y

```

修改 server.xml SSL配置部分，参考如下:

```
<Connector port="9443" protocol="org.apache.coyote.http11.Http11NioProtocol" maxThreads="150"  scheme="https"  SSLEnabled="true" secure="true">
  <SSLHostConfig
        protocols="all"
        certificateVerification="required"
        truststoreFile="/usr/local/tomcat/cert/ca.jks"
        truststorePassword="store_pass_xxx" >
    <Certificate
        certificateKeystoreType="JKS"
        certificateKeystoreFile="/usr/local/tomcat/cert/server.jks"
        certificateKeystorePassword="store_pass_xxx"
        type="RSA" />
    </SSLHostConfig>
</Connector>

```

Tomcat官方文档: https://tomcat.apache.org/tomcat-9.0-doc/config/http.html#HTTP/1.1_and_HTTP/1.0_Support

```
docker run -d                                                          \
       -v /data/ca.jks:/usr/local/tomcat/cert/ca.jks                   \ 
       -v /data/server.jks:/usr/local/tomcat/cert/server.jks           \
       -v /data/server.xml:/usr/local/tomcat/conf/server.xml           \
       --name=tomcat                                                   \
       --net=host                                                      \
       uhub.service.ucloud.cn/ucloud_pts/tomcat:9.0
docker exec -t -i tomcat sh -c "rm -rvf webapps; mv webapps.dist/ webapps"
docker restart tomcat 

```

验证java应用https服务:

```
echo "127.0.0.1  server.hadoop.com" >> /etc/hosts
curl https://server.hadoop.com:443 \
     --cacert /root/KEY/ca.crt     \
     --cert /root/KEY/client.crt   \
     --key /root/KEY/client.key

```

