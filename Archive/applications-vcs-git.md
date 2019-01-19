---
title: Git使用笔记
date: 2018/09/2９
categories: 版本控制
---


## 创建一个新仓库，并推到远端

```
echo "# hexo-blog" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin git@github.com:panhaitao/hexo-blog.git
git push -u origin master
```


## 将一个已有的仓库，推到远端

```
git remote add origin git@github.com:panhaitao/hexo-blog.git
git push -u origin master
```


## clone remote repo

git clone git@github.com:panhaitao/hexo-blog.git _posts/
git pull 

