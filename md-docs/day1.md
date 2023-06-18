
# day1 从计算机结构到汇编程序入门

## 创建第一个 Hello world

> 参考[博客](https://www.cnblogs.com/yucloud/p/13054367.html)

[Bz1621下载](https://github.com/luzhixing12345/L-OS/releases/download/v0.0.2/Bz1621.lzh_jb51.rar)

这个软件emm怎么说呢,容易闪退,而且书里给的汇编代码也不是特别好看,我本身是不建议手动敲一遍的,因为我自己确实敲了一遍,确实挺费劲的...

我们可以直接使用作者光盘中提供的`day1/helloos0/helloos.img`

Vscode有很优雅的方式查看这个文件,下载插件 `hexodump for VSCode`,`x86 and x86_64 Assembly`,`The Netwide Assembler (NASM)`

右键选择 `Show Hexdump`

![20220514222002](https://raw.githubusercontent.com/learner-lu/picbed/master/20220514222002.png)

可以观察到这个十六进制文件和书中的例子是相同的,作者的图片中似乎没有给出所有的十六进制数值有些奇怪

![20220514222121](https://raw.githubusercontent.com/learner-lu/picbed/master/20220514222121.png)

接着按着书上的步骤,成功使用QEMU启动

![20220514223552](https://raw.githubusercontent.com/learner-lu/picbed/master/20220514223552.png)

接着作者又提供了汇编的代码,但是首先是日语,我并不认识,感谢前辈汉化翻译[仓库](https://github.com/yourtion/30dayMakeOS)

其次作者的汇编器nask是自己写的,作者认为nasm的性能太差,于是自己做了个nask,作者将其放在了z_tools目录下了,但是这对我们使用来说并不方便,我们可以将z_tools的目录配置在环境变量path里

```bash
nask helloos.nas helloos.img
```

就可以得到一个img文件了,接着使用qemu启动也是可以的

![20220514230908](https://raw.githubusercontent.com/learner-lu/picbed/master/20220514230908.png)

## 使用其他的方式启动该操作系统

### NASM

我们可以直接下载[NASM](https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/win64/),目录加入环境变量,重启vscode终端

接下来是汇编的代码,nask和nasm的语法有些许差距,所以源文件并不能直接编译

```asm
JMP entry -> JMP SHORT entry

RESB <填充字节数> -> TIMES <填充字节数> DB <填充数据>

RESB 0x7dfe-$ -> TIMES 0x1fe-($-$$) DB 0

ALIGNB 16 -> ALIGN 16, DB 0
```

所以对于给出的 `helloos.nas`汇编代码我们需要做如下修改

- 替换24/48/50: `RESB x` 为 `TIMES x DB 0`
- 替换41: `RESB	0x1fe-$` 为 `TIMES   0x1fe-($-$$) DB 0x00`

> 参考 https://blog.csdn.net/firedom/article/details/18968109



修改完成之后就可以使用nasm进行编译了

> 我的仓库中给了一个helloos.nas和一个day1.asm,它们的汇编内容相同的,都可以编译成功,后缀无影响.前者是作者源文件的nas文件,后者是中文注释,修改后的nasm对应的汇编

```bash
nasm -f bin day1.asm -o day1.img
```

### QEMU(推荐)

我们也可以选择直接下载[QEMU](http://www.qemu.org/download),然后将目录配置到环境变量之中,重启vscode终端然后输入

```bash
qemu-system-i386 helloos.img
```

也可以得到类似的界面,只不过上方的文字有些不同,也许是版本的原因吧

![20220514173841](https://raw.githubusercontent.com/learner-lu/picbed/master/20220514173841.png)


顺便在这里科普一下,QEMU的作者Fabrice Bellard很厉害,如果你接触过音视频相关的知识,那么你对FFmpeg一定不陌生

QEMU可以在不同的机器上运行独自开发的操作系统与软件,编写此程序需要对计算机底层/汇编等相当的熟悉

感兴趣的朋友可以去google或者知乎了解一下


### VMware

> 参考[VMware下载安装](https://blog.csdn.net/qq_40950957/article/details/80467513)

VMware Workstation 是一个很好用的虚拟机启动软件

进入官网的[下载界面](https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html)

下载后安装,一路下一步,许可证使用下面对应版本的任意一个即可,然后重启

- VMware Workstation Pro 16

  - ZF3R0-FHED2-M80TY-8QYGC-NPKYF
  - YF390-0HF8P-M81RQ-2DXQE-M2UT6
  - ZF71R-DMX85-08DQY-8YMNC-PPHV8

- VMware Workstation Pro 15

  - FG78K-0UZ15-085TQ-TZQXV-XV0CD
  - ZA11U-DVY97-M81LP-4MNEZ-X3AW0
  - YU102-44D86-48D2Z-Z4Q5C-MFAWD


接着依次执行

- 创建新的虚拟机
- 典型
- 稍后安装操作系统
- 其他
- 给虚拟机起个名字,或者就默认MS-DOC就可以,然后把虚拟机的保存地址放到一个能找到的文件夹里
- 2G,多文件(不用动)
- 完成

不要直接启动,接下来需要导入我们的操作系统

- 编辑虚拟机设置,**添加软盘驱动器**

  ![20220523172628](https://raw.githubusercontent.com/learner-lu/picbed/master/20220523172628.png)

- 选择之前的img文件,确认

  ![20220523172723](https://raw.githubusercontent.com/learner-lu/picbed/master/20220523172723.png)

- 接着正常启动,不用管提示信息确认就行,就可以看到文字了

  ![20220523172834](https://raw.githubusercontent.com/learner-lu/picbed/master/20220523172834.png)

- 退出的时候会报错,因为我们现在的操作系统很简陋是一个异常退出,不需要担心

### U盘启动

其实我们也可以利用U盘制作一个启动器,在我们自己的电脑上真实的运行这个操作系统,只不过现在的操作系统太过简陋,完全没必要大费周章.

我们将会在后面使用一个较为完善的操作系统,制作U盘启动器

## 一些补充



```asm
DB 0x1fe-$
```

512(0x200)字节一个扇区,减去最后的启动程序字节`0x55 0xaa`两个字节剩下510(0x1fe)个字节,计算与当前位置的差自动填充0x00


