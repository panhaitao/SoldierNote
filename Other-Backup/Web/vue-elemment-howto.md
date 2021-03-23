#  vue/ElementUI 使用指南

## 前提

开发前务必熟悉的文档：

* vue.js2.0中文,项目所使用的js框架
* vue-router,vue.js配套路由
* vuex      状态管理
* Element UI框架

## 构建项目框架


全局安装脚手架环境
npm install -g vue-cli
创建一个基于webpack模板项目my-project
vue init webpack my-project
进入项目
cd my-project
安装依赖
npm install
启动项目
npm run dev
3.运行项目之后看到下面界面，说明安装成功


4.安装element-ui


npm install element-ui -S
S代表save 安装到本地开发者环境中
检查一下package.json看看是否安装成功，如果有element-ui 表示安装成功


5.导入element-ui


import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
Vue.use(ElementUI)//全局使用ElementUI
如果没报错的话，就可以正常使用啦

6.接下来我们就可以参照Element的官方文档上手开发了

demo:

我们只需要改动HelloWorld.vue的内容

<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <el-progress type="circle" :percentage="0"></el-progress>
    <el-progress type="circle" :percentage="25"></el-progress>
    <el-progress type="circle" :percentage="100" status="success"></el-progress>
    <el-progress type="circle" :percentage="50" status="exception"></el-progress>
  </div>
</template>
 
<script>
export default {
  name: 'HelloWorld',
  data () {
    return {
      msg: 'Welcome to Your Vue.js App',
    }
  }
}
</script>

效果如下图所示：




————————————————
版权声明：本文为CSDN博主「a_Keri」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/a_Keri/article/details/79159463
