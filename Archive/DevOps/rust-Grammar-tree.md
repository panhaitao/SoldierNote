# Rust

基础概念
1. 变量 - let
2. ownership borrow - &
3. 可变性 - mut
4. 可变引用 - &mut


复合数据类型
1. String - String::from("") // 非基本类型
2. Slice - "" or vec[..]
2. struct - struct {}

集合及其操作
1. Vec<_> - Vec::new() // 考虑到集合需要自动扩展
2. iter()
3. .map()
4. .enumerate()
5. .flatten()
6. .collect()
7. .extend() //集合拼接

控制语句
1. if Expressions - if {} else {}
2. recursions

模块
1. fn - fn x(s: String) -> Vec<String>

功能组件
1. Path
2. fs
3. env
