# Centos7版本定制指南 

centos7-custom-iso-build 是一个能快速定制centos7 iso 的脚本

# 准备工作

* 工作系统  : centos7
* 运行依赖  : yum install lorax yum-uilts genisoimage createrepo -y

# 构建ISO

    git clone https://github.com/panhaitao/centos7-custom-iso-build.git
    bash build.sh <Produce_Name> <Version>
    例如:
    bash build.sh SHENLAN 17

# 最小定制修改参考列表

```
* centos-release        # 名称标志
* redhat-bookmarks      # firefox默认书签
* redhat-indexhtml      # firefox默认主页
* firefox               # 首次启动主页
* redhat-logos          # 默认主题背景资源
* adwaita-icon-theme    # 替换自定义 icon
* grub2                 # 定义 /boot/efi/EFI/目录： 修改 efidir变量
* shim                  # 定义 /boot/efi/EFI/目录： 修改 efidir变量
* shim-signed           # 定义 /boot/efi/EFI/目录： 修改 efidir变量
* anaconda              # 添加 pyanaconda/installclasses/custom.py 
                        # 主题微调可修改 /usr/share/anaconda/anaconda-gtk.css 
* gdm                   # 修改默认logo
```

# 参考

* [gdm默认logo定制](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/desktop_migration_and_administration_guide/customizing-login-screen)
* [anaconda定制开发](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/anaconda_customization_guide/index)
* [lorax 源码](https://github.com/rhinstaller/lorax)
* [anaconda 源码](https://github.com/rhinstaller/anaconda)
