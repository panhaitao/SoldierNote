3.6.3. MySQL数据库的备份和还原
备份全部数据库：
mysqldump -uroot -p -A > backup.sql
从备份文件还原：
mysql -u root -p < backup.sql 
其他更多参考 man mysql 。
3.7. PostgreSQL数据库
    PostgreSQL (也叫 Postgres)，起源于加州大学伯克利分校（UCB）的数据库研究计划，是一个对象-关系数据库服务器(ORDBMS)。PostgreSQL包含很多高级的特性，拥有良好的性能和适用性。
3.7.1. PostgreSQL的安装和初始化配置 
1. 安装软件 yum install postgresql-server -y
2. 初始化配置 service postgresql initdb
3. 重启数据库服务 service postgresql restart 
3.7.2. PostgreSQL的基本操作
连接数据库，PostgreSQL的默认认证用户是postgres，可以到切换到postgres然后通过psql连接数据库：

# su - postgres
$ psql
创建数据库
postgres=# CREATE DATABASE test_db；
CREATE DATABASE
在数据库中创建表
postgres=# \c test_db
pstgdatabase=# create table users(sid integer， sname text， sex char， score integer)；
向表中插入记录
pstgdatabase=#insert into users	values(001，'zhang'，'f'，75)；
从表中是删除记录
pstgdatabase=# delete from users where sid='001'；
执行`\q`命令，即可退出postgresql
3.7.3. 数据库的备份和恢复
备份数据库
su - postgres && pg_dumpall > /backup/pg_all.dmp
还原数据库： PostgreSQL恢复数据的时候需要创建空数据库或删除原有数据库
dropdb test_db && psql -f /backup/pg_all.dmp