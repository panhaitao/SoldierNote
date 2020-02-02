# import_tasks 和include_tasks 的区别

区别一

* import_tasks(Static)方法会在playbooks解析阶段将父task变量和子task变量全部读取并加载
* include_tasks(Dynamic)方法则是在执行play之前才会加载自己变量

区别二 

* include_tasks方法调用的文件名称可以加变量
* import_tasks方法调用的文件名称不可以有变量 

参考链接

* https://docs.ansible.com/ansible/2.5/user_guide/playbooks_reuse.html#differences-between-static-and-dynamic
* https://docs.ansible.com/ansible/2.5/user_guide/playbooks_conditionals.html#applying-when-to-roles-imports-and-includes

