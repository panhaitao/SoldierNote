
HTTP Basic Authentication认证的各种语言 后台用的
访问需要HTTP Basic Authentication认证的资源的各种语言的实现
无聊想调用下嘀咕的api的时候，发现需要HTTP Basic Authentication，就看了下。

什么是HTTP Basic Authentication？直接看http://en.wikipedia.org/wiki/Basic_authentication_scheme吧。

在你访问一个需要HTTP Basic Authentication的URL的时候，如果你没有提供用户名和密码，服务器就会返回401，如果你直接在浏览器中打开，浏览器会提示你输入用户名和密码(google浏览器不会，bug？)。你可以尝试点击这个url看看效果：http://api.minicloud.com.cn/statuses/friends_timeline.xml

要在发送请求的时候添加HTTP Basic Authentication认证信息到请求中，有两种方法：

一是在请求头中添加Authorization：
Authorization: "Basic 用户名和密码的base64加密字符串"
二是在url中添加用户名和密码：
http://userName:password@api.minicloud.com.cn/statuses/friends_timeline.xml
下面来看下对于第一种在请求中添加Authorization头部的各种语言的实现代码。
