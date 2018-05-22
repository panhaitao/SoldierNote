# go 语言基础语法袖珍笔记

## 基础

### 程序结构

* 从 Hello World 开始

```
package main

import "fmt"

func main() {
	fmt.Printf(“Hello，world！”)
}
```

1. 所有的Go 源码文件以 package <something> 开始
2. 导入提供格式化输出的fmt包,
3. 使用fmt包提供的Println函数来输出"hello world"字符串

** package总是首先出现，然后是import，然后是其他所有内容。当Go程序在执行的时候，首先调用的函数是main.main()，这是从C语继承来的！**

### 名称

函数，变量，常量，类型，语句标签，和包名 命名规则：
** 只能以字母或者下划线开头，后面可以跟任意的字符，数字，下划线, 区分大小写 **

### 关键字

```
package
import
interface
var
break
default
func
select
case
defer
go
map
struct
chan
if
else
goto
switch
const
fallthrough
range
type
continue
for
return
```

### 声明，赋值

四个主要声明：
* 变量(var)
  * var name type = expression
  * var name := expression
* 常量(const)
* 类型(type)
* 函数(func)

### 包和文件

## 数据类型

* 整数
* 浮点数
* 复数
* 布尔
* 字符串

## 数据结构

* 数组
* slice
* map
* 结构体

## 函数

* 函数声明
* 递归
* 多返回值
* 错误
* 函数变量
* 匿名函数
* 变长函数
* 延迟函数调用
* 宕机
* 恢复

## 方法

* 方法声明
* 指针接收者
* 方法变量与表达式
* 封装

