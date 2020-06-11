# Vue:准备nodejs/vue开发环境 

## 简介和安装

* npm
Node.js的包管理工具（全称 Node Package Manager 包管理工具），用来管理js的。

* node
node.js是javascript的一种运行环境，是对Google V8引擎进行的封装。是一个服务器端的javascript的解释器。
包含关系，nodejs中含有npm，比如说你安装好nodejs，你打开cmd输入npm -v会发现出啊线npm的版本号，说明npm已经安装好。

* webpack
Webpack 是一个前端资源加载/打包工具。它将根据模块的依赖关系递归地构建一个依赖关系图(dependency graph)，其中包含应用程序需要的每个模块，然后将这些模块按照指定的规则生成对应的静态资源。

* vue 

## 安装

构建一个docker镜像作为应用开发环境

```
cat > Dockerfile <<EOF
FROM alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk --update add nodejs npm git
RUN mkdir -pv /nodejs
RUN cd /nodejs && npm config set registry="http://registry.npm.taobao.org"
RUN npm install --global webpack-cli vue-cli

WORKDIR /nodejs

EXPOSE 8080

CMD ["sh"]
EOF
```

docker build -t nodejs-vue .

## 运行

docker run -t -i -d --net=host --name=nodejs-vue nodejs-vue
docker run -d --name=nodejs-vue nodejs-vue

## 构建一个项目

vue init webpack frontend

```
? Project name frontend
? Project description A Vue.js project
? Author
? Vue build standalone
? Install vue-router? Yes
? Use ESLint to lint your code? Yes
? Pick an ESLint preset Standard
? Set up unit tests Yes
? Pick a test runner jest
? Setup e2e tests with Nightwatch? Yes
? Should we run `npm install` for you after the project has been created? (recommended) npm

   vue-cli · Generated "frontend".

```

npm install
npm run build

sed -i 's|localhost|0.0.0.0|g' config/index.js
npm run dev

## 解释说明

