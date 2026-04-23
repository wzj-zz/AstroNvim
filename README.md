## 简介

这是一个基于 AstroNvim 的 Neovim 配置，包含代码导航、文件搜索、搜索替换、Git、终端、会话、书签，以及一些可选扩展能力。

这份文档只写配置里有哪些功能，以及对应怎么触发。

- `Space` 是 `leader`

## 目录

- [安装](#安装)
- [通用功能](#通用功能)
  - [文件搜索与内容搜索](#文件搜索与内容搜索)
  - [文件浏览与目录切换](#文件浏览与目录切换)
  - [代码跳转与结构查看](#代码跳转与结构查看)
  - [Cscope](#cscope)
  - [Buffer、窗口与 Tab](#buffer窗口与-tab)
  - [Quickfix](#quickfix)
  - [搜索替换](#搜索替换)
  - [Git](#git)
  - [Harpoon](#harpoon)
  - [会话管理](#会话管理)
  - [书签](#书签)
  - [本地快捷操作](#本地快捷操作)
  - [终端与构建](#终端与构建)
  - [编辑与选择](#编辑与选择)
  - [界面](#界面)
  - [调试](#调试)
- [扩展功能](#扩展功能)
  - [AI 对话](#ai-对话)
  - [代码片段执行](#代码片段执行)
  - [HTTP 请求](#http-请求)
  - [Markdown 预览](#markdown-预览)
  - [代理](#代理)
- [VS Code 模式](#vs-code-模式)

## 安装

这里提供两类安装方式：

- 首次安装：本机还没有旧的 Neovim 配置
- 重装：本机已经有旧配置，需要先处理旧目录

### Windows

- 首次安装

```powershell
git clone https://github.com/wzj-zz/AstroNvim.git $env:LOCALAPPDATA\nvim
```

- 备份旧配置

```powershell
Rename-Item -Path $env:LOCALAPPDATA\nvim -NewName $env:LOCALAPPDATA\nvim.bak
Rename-Item -Path $env:LOCALAPPDATA\nvim-data -NewName $env:LOCALAPPDATA\nvim-data.bak
```

- 非彻底重装

```powershell
Remove-Item -Path "$env:LOCALAPPDATA\nvim" -Recurse -Force
git clone https://github.com/wzj-zz/AstroNvim.git $env:LOCALAPPDATA\nvim
```

- 彻底重装

```powershell
Remove-Item -Path "$env:LOCALAPPDATA\nvim" -Recurse -Force
Remove-Item -Path "$env:LOCALAPPDATA\nvim-data" -Recurse -Force
git clone https://github.com/wzj-zz/AstroNvim.git $env:LOCALAPPDATA\nvim
```

- 删除备份

```powershell
Remove-Item -Path "$env:LOCALAPPDATA\nvim.bak" -Recurse -Force
Remove-Item -Path "$env:LOCALAPPDATA\nvim-data.bak" -Recurse -Force
```

### Linux

- 首次安装

```shell
git clone https://github.com/wzj-zz/AstroNvim.git ~/.config/nvim
```

- 备份旧配置

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

- 非彻底重装

```shell
rm -r ~/.config/nvim
git clone https://github.com/wzj-zz/AstroNvim.git ~/.config/nvim
```

- 彻底重装

```shell
rm -r ~/.config/nvim
rm -r ~/.local/share/nvim
rm -r ~/.local/state/nvim
rm -r ~/.cache/nvim
git clone https://github.com/wzj-zz/AstroNvim.git ~/.config/nvim
```

- 删除备份

```shell
rm -r ~/.config/nvim.bak
rm -r ~/.local/share/nvim.bak
rm -r ~/.local/state/nvim.bak
rm -r ~/.cache/nvim.bak
```

## 通用功能

### 文件搜索与内容搜索

- `<Leader>sf`：智能查找文件
- `<Leader>fl`：选择文件类型
- `<Leader>f'`：把所有 marks 列到 quickfix
- `<Leader>sg`：全局 grep
- `<Leader>sw`：搜索当前单词，或搜索当前选中内容
- `<Leader>sb`：搜索当前缓冲区内容
- `<Leader>sB`：搜索所有已打开缓冲区内容
- `<Leader>sr`：查看寄存器
- `<Leader>s/`：搜索历史
- `<Leader>sa`：查看自动命令
- `<Leader>sc`：查看命令列表
- `<Leader>sC`：查看命令历史
- `<Leader>sd`：查看当前文件诊断
- `<Leader>sD`：查看整个项目诊断
- `<Leader>ss`：当前文件符号
- `<Leader>sS`：整个工作区符号
- `<Leader>sk`：查看快捷键列表
- `<Leader>sh`：帮助文档
- `<Leader>sH`：查看高亮组
- `<Leader>sj`：查看跳转列表
- `<Leader>sl`：查看 location list
- `<Leader>sm`：查看 marks
- `<Leader>sM`：查看 man 页面
- `<Leader>sp`：查看插件规格
- `<Leader>sq`：查看 quickfix 列表
- `<Leader>sR`：恢复上一次 picker
- `<Leader>su`：查看撤销历史

### 文件浏览与目录切换

- `<Leader>o`：打开 `mini.files`
- `<Leader>e`：打开 `Neo-tree Explorer`
- `<Leader>se`：打开 `Snacks Explorer`
- `<Leader>fz`：zoxide 目录列表

### 代码跳转与结构查看

- `<M-d>`：定义
- `<M-r>`：引用
- `<M-y>`：类型定义
- `<M-i>`：实现
- `<M-n>`：跳到下一个相同符号引用
- `<M-p>`：跳到上一个相同符号引用
- `gD`：声明
- `<C-g>`：当前文件符号大纲
- `<Leader>lt`：查看语法树
- `s`：输入搜索字符串后，Flash 会给当前屏幕内的匹配位置打标签，再输入标签即可跳转
- `S`：基于 Treesitter 的结构跳转
- `<M-s>`：跳到下一个后面跟 `(`、`{`、`[`、`<` 的符号名
- `<M-S>`：跳到上一个后面跟 `(`、`{`、`[`、`<` 的符号名
- `<M->>`：跳到下一个操作符，并选中右侧表达式
- `<M-<>`：跳到上一个操作符，并选中左侧表达式
- `<C-H>` / `<C-J>` / `<C-K>` / `<C-L>`：按语法树移动到左下上右节点

Namu：

- `<M-f>`：当前文件符号
- `<S-M-f>`：当前文件 ctags 符号
- `<Leader>vx`：watchtower（LSP / Treesitter）
- `<Leader>vn`：watchtower（ctags）
- `<Leader>vs`：工作区符号
- `<Leader>vd`：诊断列表
- `<Leader>vi`：call in
- `<Leader>vo`：call out
- `<Leader>vb`：call both
- `<Leader>vh`：符号帮助
- `<Leader>va`：分析帮助

Treesitter 文本对象跳转：

- `<M-x>` / `<M-X>`：下一个或上一个 block 起点
- `<M-B>`：下一个 block 终点
- `<M-N>` / `<M-P>`：下一个或上一个 function 起点
- `<M-E>`：下一个 function 终点
- `<M-l>` / `<M-h>`：下一个或上一个调用起点
- `<M-v>` / `<M-V>`：下一个或上一个条件分支起点
- `<M-g>` / `<M-G>`：下一个或上一个循环起点
- `<M-z>` / `<M-Z>`：下一个或上一个 class 起点
- `<M-t>` / `<M-T>`：下一个或上一个数字
- `<M-b>`：上一个参数起点
- `<M-.>`：下一个参数终点
- `<M-,>`：上一个参数终点
- `]k` / `[k`：下一个或上一个 block 起点
- `]K` / `[K`：下一个或上一个 block 终点
- `]f` / `[f`：下一个或上一个 function 起点
- `]F` / `[F`：下一个或上一个 function 终点
- `]a` / `[a`：下一个或上一个参数起点
- `]A` / `[A`：下一个或上一个参数终点
- `]s` / `[s`：下一个或上一个调用起点
- `]r` / `[r`：下一个或上一个 return 起点
- `]v` / `[v`：下一个或上一个条件分支起点
- `]g` / `[g`：下一个或上一个循环起点
- `]z` / `[z`：下一个或上一个 class 起点
- `]Z` / `[Z`：下一个或上一个 class 终点
- `]n` / `[n`：下一个赋值右值或上一个赋值左值
- `]h` / `[h`：下一个或上一个数字
- `]]` / `[[`：下一个或上一个注释起点

### Cscope

需要安装 GNU Global，它会提供 `gtags-cscope`。如果要使用 `<C-c>B` 强制重建数据库，还需要安装 `fd`。

Windows：

```powershell
scoop install global fd
```

Ubuntu：

```shell
sudo apt update
sudo apt install global fd-find
```

Ubuntu 下安装后命令名通常是 `fdfind`。如果本机没有 `fd` 命令，需要自己做一个别名或软链接。

- `<C-c>,`：查看调用者栈
- `<C-c>.`：查看被调用栈
- `<C-c>/`：切换上次栈视图
- `<C-c>r`：重载 cscope
- `<C-c>a`：查当前符号的赋值
- `<C-c>c`：查谁调用当前符号
- `<C-c>d`：查当前符号调用了谁
- `<C-c>e`：按 egrep 模式查找
- `<C-c>p`：按文件名查找
- `<C-c>o`：输入全局定义名查找
- `<C-c>g`：查当前符号的全局定义
- `<C-c>i`：查哪些文件包含当前文件
- `<C-c>s`：查当前 C 符号
- `<C-c>x`：先高亮当前符号，再执行 `Cscope find s` 生成 quickfix 列表，适合顺着当前局部变量或符号看数据流
- `<C-c>y`：输入 C 符号查找
- `<C-c>t`：查文本字符串
- `<C-c>b`：构建数据库
- `<C-c>B`：强制重建数据库

### Buffer、窗口与 Tab

- `<M-q>`：关闭当前窗口或当前 tab
- `<C-.>` 或 `<Leader><Tab>`：切换窗口
- `<M-w>`：打开 buffer 列表
- `<S-M-i>`：下一个 buffer
- `<S-M-u>`：上一个 buffer
- `<Leader>bv`：恢复当前文件内容
- `<Leader>bx`：关闭其他 buffer 和窗口
- `<M-1>` 到 `<M-4>`：跳到指定 tab

### Quickfix

- `<M-;>`：打开或关闭 quickfix
- `<M-9>`：上一条 quickfix
- `<M-0>`：下一条 quickfix
- `<M-(>`：跳到第一条 quickfix
- `<M-)>`：跳到最后一条 quickfix
- `<M-8>`：跳转到当前 quickfix 项
- `<M-*>`：跳到离当前光标最近的 quickfix 项
- `<M-7>`：排序 quickfix
- `<M-&>`：只保留当前文件的 quickfix 项
- `<Leader>so`：在当前 quickfix 涉及的文件中重新搜索内容，并把所有匹配行生成新的 quickfix 列表
- `<Leader>sv`：只保留当前 quickfix 涉及文件中包含指定内容的文件，并为每个文件保留一条 quickfix 结果
- Visual 模式下 `<Leader>vv`：只保留当前文件中位于选区行号范围内的 quickfix 结果

### 搜索替换

- `<Leader>ro`：全项目搜索替换
- `<Leader>rr`：只在当前文件搜索替换
- `<Leader>rf`：只在当前文件类型搜索替换
- Visual 模式下 `<Leader>ro`：全项目搜索替换，并将选中内容带入搜索
- Visual 模式下 `<Leader>rr`：只在当前文件搜索替换，并将选中内容带入搜索
- Visual 模式下 `<Leader>rf`：只在当前文件类型搜索替换，并将选中内容带入搜索
- Visual 模式下 `<Leader>rv`：只在选中范围内替换

### Git

- `<Leader>gg`：在当前目录打开 Neogit
- `<Leader>gf`：切到当前 nvim 配置目录并在该目录打开 Neogit
- `<Leader>gx`：切到 `D:\tools` 目录并在该目录打开 Neogit，仅 Windows
- `<Leader>gB`：切换行级 blame
- `<Leader>gG`：查看 Git graph
- `<Leader>gi`：查看 GitHub issues
- `<Leader>gp`：查看 GitHub pull requests

Codediff：

- 用来查看 Git 变更、文件差异和冲突处理
- 在 `Neogit` 里查看 diff 时，会优先使用 `codediff`

Codediff 视图中可用：

- `<M-q>`：关闭 Codediff
- `<Leader>b`：切换文件列表
- `<Leader>e`：聚焦文件列表
- `<M-n>` / `<M-p>`：下一个或上一个 diff hunk
- `<Tab>` / `<S-Tab>`：下一个或上一个文件
- `gf`：在新 tab 打开当前文件
- `g<C-x>`：切换布局
- `g?`：打开帮助

文件列表中可用：

- `Enter`、`o`、`l`：打开选中项
- `<M-e>`：跳到当前文件视图
- `R`：刷新
- `i`：切换视图模式
- `S`：全部 stage
- `U`：全部 unstage
- `X`：恢复改动

冲突处理时可用：

- `,o` / `,O`：接受 ours / 整个文件接受 ours
- `,t` / `,T`：接受 theirs / 整个文件接受 theirs
- `,a` / `,A`：接受 both / 整个文件接受 both
- `dx` / `dX`：删除当前冲突 / 删除整个文件中的冲突
- `<S-M-n>` / `<S-M-p>`：下一个或上一个冲突
- `2do`：取 incoming
- `3do`：取 current

Diffview：

- 用来查看提交差异、文件变更和合并冲突

Diffview 视图中可用：

- `<M-q>`：关闭 Diffview
- `<M-n>` / `<M-p>`：下一个或上一个 diff hunk
- `<Tab>` / `<S-Tab>`：下一个或上一个文件
- `[F` / `]F`：第一个或最后一个文件
- `gf`：在新 tab 打开当前文件
- `<Leader>b`：切换文件面板
- `g<C-x>`：切换布局
- `g?`：打开帮助

冲突处理时可用：

- `,o` / `,O`：接受 ours / 整个文件接受 ours
- `,t` / `,T`：接受 theirs / 整个文件接受 theirs
- `,b` / `,B`：接受 base / 整个文件接受 base
- `,a` / `,A`：接受 all / 整个文件接受 all
- `dx` / `dX`：删除当前冲突 / 删除整个文件中的冲突
- `<S-M-n>` / `<S-M-p>`：下一个或上一个冲突
- `1do` / `2do` / `3do`：从 base、ours、theirs 取改动

文件面板中可用：

- `<M-e>`：跳到当前文件视图
- `<M-q>`：关闭 Diffview
- `j` / `k`：上下移动
- `Enter`、`o`、`l`：打开选中项
- `s`：stage / unstage 当前项
- `S`：stage 全部
- `U`：unstage 全部
- `X`：恢复当前项
- `L`：打开提交日志面板
- `i`：切换 list / tree 视图
- `zo` / `zc` / `za` / `zR` / `zM`：折叠操作
- `<C-b>` / `<C-f>`：滚动视图

### Harpoon

- `<S-M-m>`：把当前文件加入 Harpoon
- `<M-m>`：打开 Harpoon 列表
- `<M-[>`：上一个 Harpoon 文件
- `<M-]>`：下一个 Harpoon 文件
- `<Leader>1` 到 `<Leader>5`：跳到第 1 到第 5 个 Harpoon 文件

### 会话管理

- `<Leader>,>`：保存当前标签页会话
- `<Leader>,.`：加载会话
- `<Leader>,/`：从当前会话分离
- `<Leader>,?`：删除会话

### 书签

- `<Leader>mn`：新建书签列表
- `<Leader>mm`：添加书签
- `<Leader>m;`：给当前书签写说明
- `<Leader>ma`：打开书签命令列表
- `<Leader>mf`：跳转到书签
- `<Leader>mg`：只在已加书签的文件里搜索
- `<Leader>mr`：重绑失效书签
- `<Leader>mv`：查看当前书签信息
- `<Leader>mi`：跳到当前书签的入链书签
- `<Leader>mo`：跳到当前书签的出链书签
- `<Leader>ml`：链接书签
- `<Leader>ms`：批量给选中文件加书签
- `<Leader>mq`：查询书签
- `<M-{>`：跳到上一个书签
- `<M-}>`：跳到下一个书签
- `<M-/>`：打开书签树

### 本地快捷操作

- `<Leader>,a`：全选当前文件
- `<Leader>,e`：把工作目录切到当前文件所在目录，聚焦 Neo-tree，并输出当前目录
- `<Leader>,1`：复制当前文件所在目录
- `<Leader>,2`：复制当前文件名
- `<Leader>,3`：复制当前文件完整路径
- `<Leader>,c`：复制当前工作目录
- `<Leader>,,`：把剪贴板内容当路径处理，目录则切换工作目录，文件则直接打开
- `<Leader>,dd`：当前窗口进入 diff 模式
- `<Leader>,dc`：关闭 diff 模式
- `<Leader>,dg`：从对侧获取变更
- `<Leader>,dp`：把当前变更送到对侧
- `<Leader>,hh`：切换到 hex 视图
- `<Leader>,hr`：从 hex 视图切回二进制
- `<Leader>,ho`：以二进制方式重新打开文件

### 终端与构建

- `<Leader>,s`：打开系统 shell 终端，垂直分屏
- `<Leader>,S`：打开 `xs` 终端，垂直分屏
- `<Leader>xf`：打开 `mf-runner`
- `<Leader>xx`：编辑 `mf-runner` 的 Makefile

Xmake：

- `<Leader>xb`：快速构建
- `<Leader>xr`：快速运行
- `<Leader>xd`：快速调试
- `<Leader>xc`：快速清理
- `<Leader>xB`：输入 `Xmake build ...`
- `<Leader>xR`：输入 `Xmake run ...`
- `<Leader>xD`：输入 `Xmake debug ...`
- `<Leader>xm`：输入 `Xmake mode ...`
- `<Leader>xp`：输入 `Xmake plat ...`
- `<Leader>xt`：输入 `Xmake toolchain ...`

终端窗口中可用：

- `Esc` 或 `jk`：退出终端输入模式
- `<M-w>`：打开终端选择器
- `<M-q>`：关闭当前终端窗口或当前 tab

### 编辑与选择

插入模式：

- `<C-s>`：保存
- `<C-v>`：粘贴系统剪贴板
- `<C-h>`：删除前一个单词

结构编辑：

- `<Leader>j`：把当前参数列表、对象或数组展开成多行，或再合并回一行

包围符：

- `ys`：添加包围符
- `yss`：给当前行添加包围符
- `yS`：给当前行添加换行包围符
- Visual 模式下 `gs`：给选区添加包围符
- Visual 模式下 `gS`：给选区添加换行包围符
- `ds`：删除包围符
- `cs`：替换包围符
- `cS`：替换包围符并换行

Treesitter 文本对象：

- `ak` / `ik`：选择 block 外层或内层
- `af` / `if`：选择 function 外层或内层
- `aa` / `ia`：选择参数外层或内层
- `as` / `is`：选择调用外层或内层
- `ar` / `ir`：选择 return 外层或内层
- `av` / `iv`：选择条件分支外层或内层
- `al` / `il`：选择循环外层或内层
- `az` / `iz`：选择 class 外层或内层
- `an` / `in`：选择赋值外层或内层
- `ah` / `ih`：选择数字

Treesitter 文本对象交换：

- `>K` / `<K`：和下一个或上一个 block 交换
- `>F` / `<F`：和下一个或上一个 function 交换
- `>A` / `<A`：和下一个或上一个参数交换

多光标：

- `<Leader>A`：对齐多光标列
- `<M-c>`：切换多光标
- `Up` / `Down`：向上或向下添加多光标
- `gj` / `gk`：按匹配向下或向上添加多光标
- `ga`：`ga + 范围`，给范围内每一行添加多光标，例如 `gaip`
- `gb`：`gb + 文本对象 + 范围`，给范围内所有匹配添加多光标，例如 `gbiwap`
- Visual 模式下 `m`：按正则匹配添加多光标
- Visual 模式下 `I`：在每行前插入
- Visual 模式下 `A`：在每行后追加
- `Alt + 左键`：鼠标添加多光标
- 多光标模式中，`<Left>` / `<Right>`：切换主光标
- 多光标模式中，`Esc`：退出多光标模式

高亮：

- `t<CR>`：只高亮当前行里的当前单词
- `f<CR>`：高亮当前单词的所有出现位置
- `f<BS>`：取消当前高亮
- `f<C-l>`：清空全部高亮
- `f<Tab>`：跳到高亮结果
- `f<C-s>`：保存当前文件的高亮
- `f<C-h>`：加载当前文件的高亮
- `f<C-x>`：删除当前文件对应的高亮保存文件
- `<S-M-j>` / `<S-M-k>`：在当前高亮分组内切换下一个或上一个结果
- `<S-M-h>` / `<S-M-l>`：跳到离光标最近的下一个或上一个高亮，不限分组

### 界面

- `<Leader>sz`：切换 Zen 模式
- `<Leader>sx`：切换 dim 模式
- `<Leader>sn`：查看通知历史
- `<Leader>.`：打开 scratch buffer
- `<Leader>s.`：选择 scratch buffer
- `<Leader>uT`：切换透明背景
- `<Leader>u(`：切换当前 buffer 的 rainbow delimiters

### 调试

- `<Leader>de`：添加调试表达式
- `<Leader>dE`：添加调试表达式
- `<Leader>du`：切换调试 UI

## 扩展功能

下面这些功能依赖额外工具或属于扩展用途。

### AI 对话

需要安装 `opencode`：

- `<M-o>`：打开或关闭 AI 窗口
- `<Leader>an`：新建会话输入框
- `<Leader>aa`：选择会话
- `<Leader>a/`：快速对话
- Visual 模式下 `<Leader>ay`：把选中代码加入上下文
- Visual 模式下 `<Leader>aY`：以内联方式加入选中代码
- `<Leader>ax`：重启 opencode 服务

AI 输入窗口中可用：

- `<C-s>`：发送当前输入
- `<C-r>`：重命名会话
- `<C-a>`：切换会话
- `<C-b>`：查看子会话
- `<C-o>`：MCP 选择器
- `<C-z>`：切换窗口缩放
- `<C-x>`：切换 provider / model
- `<C-e>`：切换 variant
- `<C-t>`：查看时间线
- `<C-c>`：取消当前任务
- `<Tab>`：切换 pane
- `<Up>` / `<Down>`：上一条或下一条输入历史
- `<M-m>`：切换模式
- `<M-v>`：粘贴图片
- `<M-t>`：切换 tool output
- `<M-r>`：切换 reasoning output
- `~`：插入文件引用
- `@`：插入 mention
- `/`：插入 slash 命令
- `#`：插入上下文项

AI 输出窗口中可用：

- `i`：回到输入框
- `gr`：查看引用
- `<C-z>`：切换窗口缩放
- `<C-x>`：切换 provider / model
- `<C-e>`：切换 variant
- `<C-t>`：查看时间线
- `<C-c>`：取消当前任务
- `<Tab>`：切换 pane
- `a` / `A`：接受权限请求
- `d`：拒绝权限请求
- `<M-t>`：切换 tool output
- `<M-r>`：切换 reasoning output
- `<C-n>` / `<C-p>`：上下切换消息
- `<Leader>adm`：调试当前消息
- `<Leader>ado`：调试输出内容
- `<Leader>ads`：调试当前会话

### 代码片段执行

需要安装 `xt` / `xs`：

- `<Leader>,x`：在垂直终端运行当前文件或选中代码
- `<Leader>,f`：在浮动窗口运行当前文件或选中代码
- `<Leader>,v`：执行并弹出结果窗口
- `<Leader>,z`：把当前文件或选中内容当 Lua 执行

### HTTP 请求

编辑 `.http` 或 `.rest` 文件时可使用 `kulala.nvim`：

- `<Leader>h`：HTTP 请求相关命令入口

### Markdown 预览

- `<C-M-m>`：预览当前 Markdown

### 代理

- `<Leader>P`：切换代理

当前配置会在以下两种状态之间切换：

- 开启：`http://127.0.0.1:1080`
- 关闭：只保留 `NO_PROXY`

## VS Code 模式

如果在 VS Code 中通过扩展使用这套配置，会自动切换成兼容模式。

文件与窗口：

- `<Leader>n`：新建文件
- `<Leader>ff`：快速打开文件
- `<Leader>fo`：打开最近文件
- `<Leader>e`：聚焦文件资源管理器
- `<Leader>c`：关闭当前标签页
- `<Leader>C`：强制关闭当前标签页
- `<Leader>bx`：只保留当前标签页
- `<Leader>bv`：恢复当前文件内容

搜索与列表：

- `<Leader>fa`：打开设置
- `<Leader>sw`：按当前单词全局搜索
- `<Leader>sg`：全局搜索
- `<Leader>sb`：当前文件内查找
- `<Leader>sc`：命令面板
- `<Leader>sk`：打开快捷键设置
- `<Leader>sd`：打开 Problems 面板
- `<Leader>sn`：打开通知列表

代码跳转与 LSP：

- `K`：悬停说明
- `gd`：跳到定义
- `gD`：跳到声明
- `gy`：跳到类型定义
- `grr`：跳到引用
- `gri`：跳到实现
- `<M-d>`：跳到定义
- `<M-r>`：查看引用
- `<M-y>`：跳到类型定义
- `<M-i>`：查看实现
- `<Leader>la`：快速修复
- `<Leader>lG`：工作区符号
- `<Leader>lR`：引用
- `<Leader>lr`：重命名符号
- `<Leader>ls`：当前文件符号
- `<Leader>lf`：格式化文档
- `<Leader>vs`：工作区符号
- `<Leader>vb`：调用层级
- `<Leader>vt`：类型层级

Git：

- `<Leader>gg`：打开 Source Control

本地快捷操作：

- `<Leader>,a`：全选当前文件
- `<Leader>,1`：复制当前文件所在目录
- `<Leader>,2`：复制当前文件名
- `<Leader>,3`：复制当前文件完整路径
- `<Leader>,s`：切换 VS Code 终端

Harpoon：

- `<M-m>`：打开 Harpoon 列表
- `<M-M>`：添加当前编辑器到 Harpoon
- `<Leader>1`：跳到 Harpoon 1
- `<Leader>2`：跳到 Harpoon 2
- `<Leader>3`：跳到 Harpoon 3
- `<Leader>4`：跳到 Harpoon 4

CodeQL：

- `<Leader>qh`：打开 Query History
- `<Leader>qq`：打开 Queries
- `<Leader>qr`：运行 Query
- `<Leader>qe`：Quick Eval
- `<Leader>qo`：选择数据库目录
- `<Leader>qO`：选择数据库归档

诊断与缩进：

- `]d`：下一条诊断
- `[d`：上一条诊断
- Visual 模式下 `<Tab>`：增加缩进
- Visual 模式下 `<S-Tab>`：减少缩进

选择：

- Visual 模式下 `<C-S-Left>`：按单词向左扩展
- Visual 模式下 `<C-S-Right>`：按单词向右扩展
- Visual 模式下 `<S-Up>` / `<S-Down>` / `<S-Left>` / `<S-Right>`：按方向扩展选择
- Visual 模式下 `<S-PageUp>` / `<S-PageDown>`：按页扩展选择
