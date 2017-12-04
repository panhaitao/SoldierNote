
# 设置系统LOCALE

系统范围的区域设置存储在/etc/locale.conf文件中，该文件是在systemd守护程序的早期启动时读取的。 中配置的区域设置由每个服务或用户继承，除非个别程序或个别用户覆盖它们。
/etc/locale.conf的基本文件格式是以换行符分隔的变量赋值列表。 例如，在/etc/locale.conf中使用英文消息的德语语言环境如下所示：

```
LANG=de_DE.UTF-8
LC_MESSAGES=C
```

在这里，LC_MESSAGES选项确定用于写入标准错误输出的诊断消息的区域设置。 要进一步指定/etc/locale.conf中的区域设置，可以使用其他几个选项，最相关的选项在表1.1“可配置的/etc/locale.conf中的选项”中进行了总结。 有关这些选项的详细信息，请参阅locale（7）手册页。 请注意，不应在/etc/locale.conf中配置代表所有可能选项的LC_ALL选项。
表1.1。 可以在/etc/locale.conf中配置选项

|  Option	 |                  Description                                                                                          |
|----------- |---------------------------------------------------------------------------------------------------------------------- |
| LANG	     | 提供系统区域设置的默认值。                                                                                                 |
| LC_COLLATE | 更改比较本地字母表中的字符串的函数的行为。                                                                                    |
| LC_CTYPE	 | Changes the behavior of the character handling and classification functions and the multibyte character functions.    |
| LC_NUMERIC |	Describes the way numbers are usually printed, with details such as decimal point versus decimal comma.              |
| LC_TIME	 | Changes the display of the current time, 24-hour versus 12-hour clock.                                                |
| LC_MESSAGES| 	Determines the locale used for diagnostic messages written to the standard error output.                             |

## 1.1.1 显示当前状态

localectl命令可用于查询和更改系统区域设置和键盘布局设置。 要显示当前设置，请使用状态选项：
localectl状态
⁠
Example 1.1. Displaying the Current Status

上一个命令的输出列出了为控制台和X11窗口系统配置的当前设置的区域设置，键盘布局。
```
~]$ localectl status
   System Locale: LANG=en_US.UTF-8
       VC Keymap: us
      X11 Layout: n/a
```


## 1.1.2。 列出可用的语言环境

要列出系统可用的所有区域设置，请键入：

```
localectl list-locales
⁠```

示例1.2。 列出区域设置

想象一下，您想要选择一个特定的英语区域设置，但是您不确定系统是否可用。 您可以通过以下命令列出所有英语语言环境来检查：
```
~]$ localectl list-locales | grep en_
en_AG
en_AG.utf8
en_AU
en_AU.iso88591
en_AU.utf8
en_BW
en_BW.iso88591
en_BW.utf8
```

output truncated

### 1.1.3. Setting the Locale


534/5000
要设置默认系统区域设置，请使用以下命令作为root：
localectl set-locale LANG = locale
使用localectl list-locales命令替换语言环境名称。 上述语法也可用于从表1.1“可配置在/etc/locale.conf中的选项”配置参数。
⁠
示例1.3。 更改默认区域设置

例如，如果要将英国英语设置为默认语言环境，请首先使用列表语言环境查找此语言环境的名称。 然后，以root身份键入以下格式的命令：

~]# localectl set-locale LANG=en_GB.utf8
