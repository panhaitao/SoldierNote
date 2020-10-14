# QT/DTK HowTo

## 准备工作

* 开发环境:deepin 15.9.2/stable
* 安装开发包:`apt install g++ qtcreator libdtkcore-dev libdtkwidget-dev`

## 创建第一个 DTK Demo

1. 打开 QTcreater-> 文件-> 新建文件或项目 -> Application -> Qt Widgets Application 一直点击"下一步"直到完成项目创建;
2. 编辑项目中 .pro  文件加入如下两行配置 `CONFIG   += c++11 link_pkgconfig` `PKGCONFIG += dtkwidget` ;
3. 编辑:界面文件-> mainwindow.ui 从左侧选择一个控件 buttons -> Push Button 拖入右侧编辑区; 选中这个控件，右键转到槽,
   选择默认的clicked() 信号,点击OK, 会跳转到源文件 mainwindow.cpp　生成一段新的代码，补全为如下:
```
void MainWindow::on_pushButton_clicked()
{
    QLayout *l = ui->centralWidget->layout();
    if (l == nullptr)
    {
        l = new QVBoxLayout;
        ui->centralWidget->setLayout(l);
    }

    Dtk::Widget::DBaseButton *a = new Dtk::Widget::DBaseButton();
    a->setText("Dtk Base Button");
    QPushButton *b = new QPushButton();
    b->setText("Qt Push Button");

    l->addWidget(a);
    l->addWidget(b);
}
```
4. 最后在mainwindw.app 加入需要引用的头文件代码,如下:
```
#include "QLayout"
#include <libdtk-2.0.9/DWidget/dbasebutton.h>
``` 
5. 保存并构建当前项目，如果一切顺利，点击最下角的运行按钮
