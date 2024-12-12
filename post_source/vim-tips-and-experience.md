---
title: Vim tips
date: 2012-04-25 09:25:00
updated: 2017-06-25
---

这篇博客分享一些个人觉得有用的 Vim 插件和配置。

首先明确一些环境和一些术语说明：  
我所使用的是 Ubuntu 17.04 上的 vim8.0 版本；    
下面的配置中，`<C` 表示 `Ctrl` 键，比如 `<C-v>` 表示按住 `Ctrl` 后按 `v` 键；   
下面的配置中，`<M` 表示 `Alt` 键，比如 `<M-t>` 表示按住 `Alt` 后按 `t` 键；   
我在说明中提到的“前”，一般的意思是“右或者下”，“后”的意思一般是“左或者上”；  
我提到的“字”一般表示一个英文字母或者一个汉字；    
我提到的“词”表示一个英文单词，对于中文的话，被英文/标点符号等隔开的就算一个词而不是逻辑上的一个词语。

### 一、基本操作
这部分的内容，不需要使用额外的外挂和配置文件，事实上我觉得这也是使用Vim首先必须熟悉掌握的一些操作。

#### 1. 切换模式

```bash
Esc C-[ C-c i I o O a A v V <C-v>
```

这些是切换模式的键，可以从在 Vim 的各种模式之间切换。  

* `Esc C-c C-[`: 是从其他模式回到普通模式的操作。     
* ``i/a``: 在当前提示符前/后插入  
* ``I/A``: 在vim中，大写的命令其实可以分为对相应的小写字母代表的命令的作用进行反向或者对整行作用，这里的 `I/A` 命令，就是作用与整行，也就是在行首/末插入     
* ``o/O``: 在当前行下/上行插入     
* ``v/V/<C-v>``: 可视模式命令，大写 V 代表行选择， `<C-v>` 代表块选择     

#### 2. 重复命令

```bash
. [N]
```
这两个是非常有用的命令.  

* ``.`` 是重复执行上一次的动作，``[N]`` 代表一个数字，跟移动、编辑、选择命令一起使用，可以更加快速的进行以上操作。   

#### 3. 移动命令

```bash
h j k l 0 ^ $ e E b B w W f F t ; , gg G H L M ENTER [[ ]] % :[N] 
```
这些是Vim中的移动命令，就是在 Normal 模式下定位光标位置。  

* `j/ENTER`: 移动到下一行，需要移动到下 N 行的话，参考下面的 ``[N]`` 这一段。  
* `k`: 上一行  
* `h/l`: 左/右移一个字符    
* `0 ^`, 这两个命令都是把光标移动到行首，有一点区别，`^` 是移动到本行的第一个可见字符,而 `0` 是移到整行的行首。   
* `$`: 定位到行末   
* `e/b`往前/后移一个词, `e` 命令移到到下个单词后会定位到单词的最后一个字符。   
* `w` 同样往前移到一个单词, 移到到下个单词的第一个字符  
* `f/F` 是快速的移动, f我这里理解成find的意思，比如在 `this is a text line.` 这样的一行文本中，假设现在光标所处的位置是a，那么我 `fn`，就会定位到 line 这个单词的 n 字符处，同理，`F` 就是逆向查找的意思了。    
* `t` 命令和 `f` 差不多, 不过上还是上个例子，如果用 `tn` 的话，就会定位到 line 这个单词的 i 字母处，也就是需要查找的前一个字符处。  
* `;` 使用在上面的 `f/t` 命令后，如果需要查找下一个字符，就使用 `;`。   
* `gg/G`：跳到文件开始/末尾。   
* `H/M/L`：跳到当前屏幕的顶部/中间/底部。  
* ``[[/]] ``: 移动到上/下一个段落，在 C 程序中，一般是上/下一个函数。  
* ``%``: 用来跳到匹配的括号/引号等,甚至可以在对应的条件编译 #if，#endif 之间跳转。   
* ``:[N]``:跳到指定行号N的行。比如 ``:67`` 就会跳到第 67 行。   
移动命令中当然还要提到跳转命令 ``m '``，其实也是移动命令    
这两个命令是配合使用的，跳转命令, 也可以叫做 marks 命令，就是在文件的某些位置做上标记然后方便以后回到这个位置继续编辑, 比如在文件的某个位置使用 ``ma``, 然后在文件的另一个位置 ``'a`` 之后就跳当刚才使用 ``ma``记录的位置。   
然而，最常使用的跳转命令是：

* ``‘[`` 跳到上一次被改变的文本的第一个字符  
* ``'.`` 跳到上一次文本被修改的地方   
* ``''`` 跳回上一次跳转的地方   
* ``'^`` 跳到插入模式最后一次结束的地方     
这里提到的移动命令，很多可以和前面提到的重复命令 ``[N]`` 一起使用，比如 ``5j`` 表示向下移动5行， ``5w`` 表示向前移动5个单词等等。  

#### 4. 编辑命令

```bash
x X d y p P "ayy "ap r R c o D C s S Y u C-r .  << >>
```

* ``x/X``是删除当前光标下/光标前的一个字符。  
* ``d/c/y``是删除/修改/复制命令，之所以把这三个命令放在一组介绍是以为这三个命令都可以和前面介绍的移动跳转等命令一起使用，比如 ``dd/yy`` 表示删除/复制一行，``dw/cw/yw`` 是删除/修改/复制一个单词, ``d$/c$/y$`` 表示删除/修改/复制到行末，``d^/y^`` 表示删除/复制到行首,当然，这些命令还可以和重复命令组合，比如 ``5dd`` 表示删除5行，``d/c/yfx`` 就是删除/修改/复制到字符 x，以此类推，还可以这样使用的命令还有下面提到的 ``v`` 命令。    
灵活的组合前面介绍的这几个命令，在写代码的过程中使用起来非常方便，比如:  
* ``df), yf), cf), vf)`` 从当前字符开始删除(复制,改变,选中),直到遇到=之后   
* `di), yi), ci), vi)` 删除（复制，修改，选择）括号内的内容   
* `dt”, yt”, ct”, vt”` 从当前字符开始删除(复制,改变,选中),直到遇到”之前   
* `diw, yiw, ciw, viw` 删除(复制,改变,选中)光标所在单词    
* `da”, ya”, ca”, va”` 删除(复制,改变,选中)”"号内所有文本,包括引号本身  
事实上删除命令，在 vim 中就是剪切命令的意思。  
* `p/P`命令，这两个命令是粘贴的意思，分别表示在当前字符的前/后粘帖前面使用 `y/d` 复制或者剪切的内容。   
当然，我们在使用的过程中，会遇到这样的问题，分别在两个地方删除内容，然后需要分别粘贴，这样的情况就需要用到 `"ayy "ap` 这样的命令了，`"ayy` 是把当前行复制到名字为a的寄存器中，`"ap` 就是在这里粘帖a寄存器中的内容。   

#### 5. 查找/替换
从这里开始，就要介绍一种 Vim 中的另一种模式：命令模式，在 Normal 模式下输入 `:` 就可以进入命令模式，`Esc` 返回普通模式。

* `/` 向前查找   
* `?` 向后查找   
* `n` 重做最后一次/或?   
* `N` 反方向重做最后一次/或?   
* `\c` 查找时忽略大小写   
* `\C` 查找时大小写相关   
* `*` 向前查找当前光标下的单词   
* `#` 反方向查找当前光标下的单词   
这里，查找和替换都可以配合正则表达式来使用。 

#### 6. record

```bash
q @
```
q 命令在使用过程中需要使用两次： 第一次表示开
始记录，第一次按下 q 之后还需要输入一个字符表示要把记录的宏存到哪个位置，第二次表示记录的结束。
q 需要 @ 配合使用。 @ 是读取指定寄存器中的操作记录，并将这些操作顺序
地重新执行一遍, 这里举一个例子说明，输入 1 到 100 的数：

```bash
i
1
<ESC>
qa
yyp
<C-a>
q
100@a
```

#### 7. tab
在编辑多个文件的时候，使用多标签可以方便的在不同文件之间切换。

* `:tabnew` 新建 tab  
* `:tabclose` 关闭 tab   
* `:tabedit {file}` 新建 tab,并在新创建的 tab 打开 file   

* `gt` 下一 tab   
* `gT` 上一 tab  

#### 8. 多窗口

如果屏幕够大的话，使用多个窗口来编辑文件要比多标签更舒服，比如我可以在写.c文件的时候在旁边用个窗口显示对应的.h文件的内容。   

* `:sp {file}` 横向切割窗口,并在新窗口打开 file   
* `:vsp {file}` 竖向切割窗口,并在新窗口打开 file   
* `C-w w` 命令在不同窗口之间切换，在后面的配置文件中，我会提到通过定义配置文件来更加方便的在多个窗口之间进行切换。  

### 二、配置文件篇
这部分，是通过配置文件，对 vim 进行定制使得更加符合自己的编辑习惯，我的完整配置文件在[这里]()，这里对其中的部分进行说明。  

#### 关于备份文件的配置
```
set backup " Enable backup
set backupdir=~/.vim/backup " Set backup directory
set directory=~/.vim/swap,/tmp " Set swap file directory
autocmd BufWritePre * let &backupext = strftime(".%m-%d-%H-%M") " Keep more backups for one file
```

#### 搜索模式里面的一些配置
```
set magic " Enable magic matching
set showmatch " Show matching bracets
set hlsearch " Highlight search things
set smartcase " Ignore case when searching
set ignorecase
```

#### 有用的键盘绑定

关于多标签和多窗口编辑的键绑定   

```
nnoremap tp :tabprevious<CR>
nnoremap tn :tabnext<CR>
nnoremap to :tabnew<CR>
nnoremap tc :tabclose<CR>
nnoremap gf <C-W>gf 

nmap <silent> <C-k> <C-W><C-k>
nmap <silent> <C-j> <C-W><C-j>
nmap <silent> <C-h> <C-W><C-h>
nmap <silent> <C-l> <C-W><C-l>
```

F[N]键的绑定:

```bash
nnoremap <silent> <F2> :TlistToggle<CR>:TlistUpdate<CR>
nnoremap <F3> :Rgrep<CR>
nmap <F4> :noh<cr><ESC>
inoremap <F5> <C-R>=strftime("%Y-%m-%d %T %Z")<CR>
nnoremap <F5> :w<CR>:make!<CR>
nnoremap <F6> :w<CR>:make! %< CC=gcc CFLAGS="-Wall -g -O2"<CR>:!./%<<CR>
inoremap <F6> <ESC>:w<CR>:make! %< CC=gcc CFLAGS="-Wall -g -O2"<CR>:!./%<<CR>
nnoremap <silent> <F7> :botright copen<CR>
nnoremap <silent> <F8> :cclose<CR>
nnoremap <silent> <F9> :NERDTreeToggle<CR>
nnoremap <silent> <F10> :set number!<CR>
```

禁用了方向键：

```
map <UP> <NOP>
map <DOWN> <NOP>
map <LEFT> <NOP>
map <RIGHT> <NOP>
inoremap <UP> <NOP>
inoremap <DOWN> <NOP>
inoremap <LEFT> <NOP>
inoremap <RIGHt> <NOP>
```

#### autocmd

autocmd, 就是 vim 根据判断文件格式自动执行的一些命令，具体关于autocmd的配置，可以参考我的[完整配置文件](https://github.com/imtxc/dotfiles/blob/master/.vim/vimrc),在配置文件中，对所有的配置都进行了注释，有了前面这些命令和配置介绍的基础，应该可以看明白并且根据自己的需要进行修改。

### 三、插件介绍篇
使用vim，就免不了用到一些外挂来增强功能，我使用 vim 主要是编辑 C、Makefile、Markdown 等文件，因此我用到的插件列表是这些
这里对其中的部分插件进行介绍

#### 1. Vundle
首先是 Vundle 插件，没有用这个插件之前，管理 vim 的插件是一件很头疼的事情，特别是安装了某个插件但是试用后觉得不好用然后要删除那个插件的时候，总是很麻烦，经过搜索，终于让我找到了 Vundle, vundle 插件需要安装 git。   

安装&配置：   

```bash
git clone http://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
```
然后在 `vimrc` 中添加如下内容：

```bash
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
Bundle 'vim-plugin-foo'
Bundle 'vim-plugin-bar'
```
使用：   
先在 `vimrc` 中添加需要安装的插件比如：`Bundle 'a.vim'`, 然后 `:BundleInstall` 就可以安装插件。    
在 `vimrc` 中移除添加的插件，然后 `:BundleClean` 就可以删除对应的插件，下面介绍到的插件都使用这种方式安装。

#### 2. SnipMate&SuperTab-continued   
这组插件用来自动补全一些内容，在写代码的时候非常方便使用。
使用：输入某些文本（在 snipmate 插件中进行定义）内容后，按 ``tab`` 就可以补全，比如在 C 语言代码文件中可以补全的有 main, if, inc, Inc, for等等。

#### 3. DoxygenToolkit&The-NERD-Commenter     
这一组插件来给代码文件添加注释。   
配置：

```bash
let g:DoxygenToolkit_authorName="Vortex - txc DOT yang AT gmail DOT com"
let g:DoxygenToolkit_briefTag_funcName="yes"
let s:licenseTag = "Copyleft(C)\<enter>"
let s:licenseTag = s:licenseTag . "For free\<enter>"
let g:DoxygenToolkit_licenseTag = s:licenseTag
let g:doxygen_enhanced_color=1
map <leader>da :DoxAuthor<CR>
map <leader>df :Dox<CR>
map <leader>db :DoxLic<CR>
map <leader>dc a /*  */<LEFT><LEFT><LEFT>
```
使用：   
在函数名称上面 ``,df`` 为改函数添加函数头注释   
``,da`` 可以添加文件头，其中的信息在上面的配置文件中修改   
``,cc`` 注释当前行   
``,cs`` 更性感的方式注释代码区域   
``,cu`` 取消注释   
``,cA`` 在不同的注释风格之间切换   

#### 4. repeat.vim&surround.vim  
这一组插件用来重复一些操作，是 ``.`` 命令的加强版，具体的使用可以查看各自插件的文档，都有很详细的例子。  

#### 5. vim-powerline    
非常漂亮的状态栏定制插件. 

---
上面这些配置和插件，是我在使用Vim过程中总结的一点知识，记录在这里方便遗忘的时候查阅, 也供同样跟我一样刚开始使用 Vim 的朋友们参考。

参考文章：

[vim入门进阶与折腾](http://godorz.info/2012/01/vim/)
