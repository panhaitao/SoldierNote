# Vue 读取static静态资源MD文件

1. 首先下载 vue-loader 和 vue-markdown 组件
　　npm install --sava markdown-loader vue-markdown

2. 然后获取对应的资源对象
　　const url = `./xxx.md`;
　　axios.get(url).then((response) => {
   　　this.htmlMD = response.data;
});

3. 最后在 vue-markdown 组件上展示即可，记得在 components 上先导入
　　<VueMarkdown :source="htmlMD"></VueMarkdown>

```

// 拉取该文件夹下所有文件信息
const filesMD = require.context('@/../static/xxxxMD', true, /\.md$/);
const filesMDNames = filesMD.keys();
const tmepListDatas = [];
filesMDNames.map((item) => {
    const listObj = {};
    const listItemS = item.split('/');
    if (listItemS.length > 0) {
        listObj.name = listItemS[1].replace('.md', '');
        listObj.path = item;
        listObj.children = [];
        listObj.showChild = false;
    }
　　return tmepListDatas.push(listObj);
}); 

```
