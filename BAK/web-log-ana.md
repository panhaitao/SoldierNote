# Web Log Ana

文章节选自《Netkiller Monitoring 手札》
 
20.2. Web
20.2.1. Apache Log
1、查看当天有多少个IP访问：
awk '{print $1}' log_file|sort|uniq|wc -l

2、查看某一个页面被访问的次数：
grep "/index.php" log_file | wc -l

3、查看每一个IP访问了多少个页面：
awk '{++S[$1]} END {for (a in S) print a,S[a]}' log_file

4、将每个IP访问的页面数进行从小到大排序：
awk '{++S[$1]} END {for (a in S) print S[a],a}' log_file | sort -n

5、查看某一个IP访问了哪些页面：
grep ^111.111.111.111 log_file| awk '{print $1,$7}'

6、去掉搜索引擎统计当天的页面：
awk '{print $12,$1}' log_file | grep ^\"Mozilla | awk '{print $2}' |sort | uniq | wc -l

7、查看2009年6月21日14时这一个小时内有多少IP访问:
awk '{print $4,$1}' log_file | grep 21/Jun/2009:14 | awk '{print $2}'| sort | uniq | wc -l		
20.2.1.1. 刪除日志
刪除一个月前的日志

rm -f /www/logs/access.log.$(date -d '-1 month' +'%Y-%m')*			
20.2.1.2. 统计爬虫
grep -E 'Googlebot|Baiduspider'  /www/logs/www.example.com/access.2011-02-23.log | awk '{ print $1 }' | sort | uniq			
20.2.1.3. 统计浏览器
cat /www/logs/example.com/access.2010-09-20.log | grep -v -E 'MSIE|Firefox|Chrome|Opera|Safari|Gecko|Maxthon' | sort | uniq -c | sort -r -n | head -n 100			
20.2.1.4. IP 统计
# grep '22/May/2012' /tmp/myid.access.log | awk '{print $1}' | awk -F'.' '{print $1"."$2"."$3"."$4}' | sort | uniq -c | sort -r -n | head -n 10
   2206 219.136.134.13
   1497 182.34.15.248
   1431 211.140.143.100
   1431 119.145.149.106
   1427 61.183.15.179
   1427 218.6.8.189
   1422 124.232.150.171
   1421 106.187.47.224
   1420 61.160.220.252
   1418 114.80.201.18			
统计网段

# cat /www/logs/www/access.2010-09-20.log | awk '{print $1}' | awk -F'.' '{print $1"."$2"."$3".0"}' | sort | uniq -c | sort -r -n | head -n 200			
压缩文件处理

zcat www.example.com.access.log-20130627.gz | grep '/xml/data.json' | awk '{print $1}' | awk -F'.' '{print $1"."$2"."$3"."$4}' | sort | uniq -c | sort -r -n | head -n 20			
20.2.1.5. 统计域名
# cat  /www/logs/access.2011-07-27.log |awk '{print $2}'|sort|uniq -c|sort -rn|more			
20.2.1.6. HTTP Status
# cat  /www/logs/access.2011-07-27.log |awk '{print $9}'|sort|uniq -c|sort -rn|more
5056585 304
1125579 200
   7602 400
      5 301			
20.2.1.7. URL 统计
cat  /www/logs/access.2011-07-27.log |awk '{print $7}'|sort|uniq -c|sort -rn|more			
20.2.1.8. 文件流量统计
cat /www/logs/access.2011-08-03.log |awk '{sum[$7]+=$10}END{for(i in sum){print sum[i],i}}'|sort -rn|more

grep ' 200 ' /www/logs/access.2011-08-03.log |awk '{sum[$7]+=$10}END{for(i in sum){print sum[i],i}}'|sort -rn|more			
20.2.1.9. URL访问量统计
			# cat www.access.log | awk '{print $7}' | egrep '\?|&' | sort | uniq -c | sort -rn | more			
			
20.2.1.10. 脚本运行速度
查出运行速度最慢的脚本

grep -v 0$ access.2010-11-05.log | awk -F '\" ' '{print $4" " $1}' web.log | awk '{print $1" "$8}' | sort -n -k 1 -r | uniq > /tmp/slow_url.txt			
20.2.1.11. IP, URL 抽取
# tail -f /www/logs/www.365wine.com/access.2012-01-04.log | grep '/test.html' | awk '{print $1" "$7}'
