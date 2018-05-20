
```
mkdir -p ~/.vim/bundle
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
apt install ctags
go get -u github.com/jstemmer/gotags
cp /root/go/bin/gotags /usr/bin/
```

```
cat > ~/.vimrc << EOF
syntax on
" tab宽度和缩进同样设置为4
set tabstop=4
set softtabstop=4
set shiftwidth=4
set nocompatible

" 你在此设置运行时路径
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

" Vundle 本身就是一个插件
Plugin 'Tagbar'
Plugin 'fatih/vim-go'
Plugin 'gmarik/Vundle.vim'
Plugin 'scrooloose/nerdtree'

call vundle#end()

" 插件设置选项
" 设置tagbar的窗口宽度, 映射Tagbar的快捷键,按F8自动打开

let g:tagbar_width=30
map <F7> :NERDTreeToggle<CR>
map <F8> :TagbarToggle<CR>

" gocode函数提示功能配置

filetype off
filetype plugin indent on
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType java set omnifunc=javacomplete#Complete
autocmd FileType go set omnifunc=gocomplete#Complete
EOF
```

## 安装插件

vim 命令模式 `:PluginInstall`

## 基本操作

```
"CTRL+W+方向键" 实现窗口切换
“Ctrl + ]”      跳至函数定义处
“Ctrl + t”      返回
```

## 参考

* Vim go语言基础IDE开发环境安装(Vundle/vim-go):  <http://aiezu.com/article/vim_golang_ide_vundle_vim_go.html>
* vim go语言IDE环境Tagbar插件和NERDTree插件安装: <http://aiezu.com/article/linux_vim_golang_tagbar_nerdtree.html>

