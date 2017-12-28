# gpg 


## 

备份密钥分为备份公钥和私钥两个部分，备份公钥：
gpg -o keyfilename --export KeyID
如果没有KeyID则是备份所有的公钥，-o表示输出到文件keyfilename中，如果加上-a的参数则输出文本格式的信息，否则输出的是二进制格式信息。
备份私钥：
gpg -o keyfilename --export-secret-keys KeyID
如果没有KeyID则是备份所有的私钥，-o表示输出到文件keyfilename中，如果加上-a的参数则输出文本格式的信息，否则输出的是二进制格式信息。
然后在别的机器上可以通过
gpg --import filename
导入这些信息。
