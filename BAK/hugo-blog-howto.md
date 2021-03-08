# 使用 GoHugo 搭建个人博客  

## 安装

1. 获取 hugo 0.65 版本
2. 获取 hugo-geekdoc 主题文件 

```
hugo new site blog_dir
cd blog_dir
mkdir -p themes/hugo-geekdoc/
curl -L https://github.com/thegeeklab/hugo-geekdoc/releases/latest/download/hugo-geekdoc.tar.gz | tar -xz -C themes/hugo-geekdoc/ --strip-components=1
```

## 配置

```
cd  blog_dir

cat > config.toml <<EOF  
baseURL = "http://doc.blog.net"
title = "Geekdocs"
theme = "hugo-geekdoc"

pluralizeListTitles = false
pygmentsUseClasses = true
pygmentsCodeFences = true
disablePathToLower = true

[markup]
  [markup.goldmark.renderer]
    # Needed for mermaid shortcode
    unsafe = true
  [markup.tableOfContents]
    startLevel = 1
    endLevel = 9
EOF

```

## 编写文档
 
blog_dir/content/ 目录就是用于存放Markdown文件

## 启动服务

cd blog_dir && hugo server -D  

## 参考文档

https://geekdocs.de/usage/getting-started/
