# nginx 

## 正向代理

nginx http proxy 正向代理, 配置 Nginx Http Proxy 代理服务器，与 [Squid] 功能一样，适用于正向代理 Http 网站。 Nginx 正向代理配置文件：

```
server {
    resolver 8.8.8.8;
    resolver_timeout 5s;
 
    listen 0.0.0.0:8080;
 
    access_log  /home/reistlin/logs/proxy.access.log;
    error_log   /home/reistlin/logs/proxy.error.log;
 
    location / {
        proxy_pass $scheme://$host$request_uri;
        proxy_set_header Host $http_host;
 
        proxy_buffers 256 4k;
        proxy_max_temp_file_size 0;
 
        proxy_connect_timeout 30;
 
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 301 1h;
        proxy_cache_valid any 1m;
    }
}
``` 

二，Nginx 正向代理配置说明：
1，配置 DNS 解析 IP 地址，比如 Google Public DNS，以及超时时间（5秒）。

resolver 8.8.8.8;
resolver_timeout 5s;
2，配置正向代理参数，均是由 Nginx 变量组成。其中 proxy_set_header 部分的配置，是为了解决如果 URL 中带 "."（点）后 Nginx 503 错误。

proxy_pass $scheme://$host$request_uri;
proxy_set_header Host $http_host;
3，配置缓存大小，关闭磁盘缓存读写减少I/O，以及代理连接超时时间。

proxy_buffers 256 4k;
proxy_max_temp_file_size 0;
proxy_connect_timeout 30;
4，配置代理服务器 Http 状态缓存时间。

proxy_cache_valid 200 302 10m;
proxy_cache_valid 301 1h;
proxy_cache_valid any 1m;
三，不支持代理 Https 网站
因为 Nginx 不支持 CONNECT，所以无法正向代理 Https 网站（网上银行，Gmail）。
如果访问 Https 网站，比如：https://www.google.com，Nginx access.log 日志如下：

"CONNECT www.google.com:443 HTTP/1.1" 400
分类: nginx
