# WHU-OS

武汉大学操作系统设计课程的大作业: **复现一个操作系统内核**

## 简介

参考: **30天自制操作系统**

该实验所有的过程以及中途遇到的问题,原理和解决思路均记录在[这里](https://luzhixing12345.github.io/WHU-OS/),每一天的任务和代码内容更新在对应的文件夹下.**对应目录下仅有当天的完成的最终代码文件**

## 编译与使用

每一个文件夹内容都可以直接运行使用,无需其他格外安装, 运行在 Windows 操作系统下

运行第{DAY}天的程序

```bash
make -C day{DAY}
```

例如运行第10天

```bash
make -C day10
```

清除生成的文件

```bash
make -C day{DAY} clean
```

> QEMU在我的电脑中会存在部分操作系统状态模拟出现错误的情况, day10 day11会出现异常中断退出. 
>
> day7键盘输入卡住, day14及以后对于字母的输入重复且无法中断是由于中文输入法的原因,在输入的时候切换为英文输入法即可解决
> 但是在我室友和同学的电脑上并未出现此情况.在我的VMWARE虚拟机的WIN10操作系统中也未出现,故无法复现此错误. 如果遇到这种错误可以编译出img软盘映像文件之后导入VMWARE虚拟机.VMWARE相关使用方法见day1的博客

## 阶段展示

键盘输入时请切换为英文输入法,否则会出现异常情况

- day1

  > 基本的启动区

  ![20220705213449](https://raw.githubusercontent.com/learner-lu/picbed/master/20220705213449.png)

- day10

  > 输入输出缓冲区,GDT IDT,中断处理,内存管理,图形的绘制,鼠标的输入,叠加处理

  ![20220708045700](https://raw.githubusercontent.com/learner-lu/picbed/master/20220708045700.png)

- day20

  > 窗口优化,定时器,中断处理优化,多任务的进程调度,命令行窗口,键盘输入的优化,执行应用程序,API
  >
  > 支持dir mem type cls hello 指令

  ![20220714023429](https://raw.githubusercontent.com/learner-lu/picbed/master/20220714023429.png)

- day30

  基本使用

  - <kbd>Tab</kbd> 切换窗口
  - 选中窗口时使用鼠标点击 x 或按下 <kbd>enter</kbd> 可关闭窗口
  - <kbd>shift</kbd> + <kbd>F1</kbd> 强制关闭窗口
  - <kbd>shift</kbd> + <kbd>F2</kbd> 新建console控制台
  - 鼠标点击切换窗口
  - <kbd>-</kbd> 和 <kbd>=</kbd> 这两个键不能与shift组合打出,  需要一个数字键盘

  命令行相关指令

  - dir : 查看目录文件
  - mem : 查看内存及剩余
  - cls : 清除控制台内容
  - ncst : 使用ncst + 以下指令可以运行程序且并不影响当前控制台的输入
  - star1 : 绘制一点(星星)
  - stars : 绘制一群点
  - walk  : 移动光标(上下左右)
  - color, color2 : 两个颜色盘
  - notrec : 一个非矩形窗口
  - bball : 一个线条绘制的圆
  - invader : 一个外星人打飞机的应用程序
  - langmode + {MODE} : 语言模式切换,langmode 0为英文模式,1为日文模式,2为日文EUC模式
  - type + {FILENAME} : 查看文件内容(注意langmode,langmode不正确会出现乱码,一些奇怪的格式的图片也不要试图去查看)
  - tview + {FILENAME} : 新建一个文本框查看文件内容
  - mmlplay + {FILENAME} : 打开音乐播放器

    ```bash
    mmlplay daigo.mml
    ```

  - gview + {FILENAME} : 预览图片

    ```bash
    gview night.bmp
    gview fujisan.jpg
    ```

  - calc + {FORMAT} : 计算器

    > 我自己的键盘的输入似乎有些问题,有点奇怪

  下图为部分功能演示

  ![20220714205951](https://raw.githubusercontent.com/learner-lu/picbed/master/20220714205951.png)

### 关于文档

[课程实验相关资料](https://github.com/luzhixing12345/WHU-OS/releases/tag/v0.0.1)

[光盘文件下载](https://github.com/luzhixing12345/L-OS/releases/download/v0.0.2/OS.rar)

本系列会记录笔者的学习心得和历程,尽可能给出较为详细的过程和具体实践方法,所有的代码文件同步在仓库[WHU-OS](https://github.com/luzhixing12345/WHU-OS)
