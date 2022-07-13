# WHU-OS

武汉大学操作系统设计课程的大作业: **复现一个操作系统内核**

## 简介

参考: **30天自制操作系统**

该实验所有的过程以及中途遇到的问题,原理和解决思路均记录在[个人博客](https://luzhixing12345.github.io/tags/OS/),每一天的任务和代码内容更新在对应的文件夹下.**对应目录下仅有当天的完成的最终代码文件**

## 编译与使用

每一个文件夹内容都可以直接运行使用,无需其他格外安装

运行第{DAY}天的程序

```bash
make -C day{DAY}
```

- 例如运行第10天

  ```bash
  make -C day10
  ```

- 运行最后修改过的的操作系统

  ```bash
  make -C WHU-OS
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

- day1

  > 基本的启动区

  ![20220705213449](https://raw.githubusercontent.com/learner-lu/picbed/master/20220705213449.png)

- day10

  > GDT IDT,中断处理, 内存管理, 图形的绘制,鼠标的输入

  ![20220708045700](https://raw.githubusercontent.com/learner-lu/picbed/master/20220708045700.png)

- day20

- day30

## 关于

### 关于WHU-OS

WHU-OS基于30天自制操作系统改进之后操作系统,在原先的基础上进行了部分修改,模块的添加,代码的重构.详见[WHU-OS](WHU-OS.md)

### 关于"30天自制操作系统"

对于"30天自制操作系统" 书中内容的记录整理 - [个人博客](https://luzhixing12345.github.io/tags/OS/)

作者提供的代码偶尔在我的电脑中使用QEMU模拟会出现问题,我目前也没有一个很好的解决办法. 实在不行就使用VMWARE用WIN10的ISO镜像开一个虚拟机,本项目不需要任何的环境依赖,所有的编译所需程序都在此文件夹中

### 关于文档

[课程实验相关资料](https://github.com/luzhixing12345/WHU-OS/releases/tag/v0.0.1)

[复现实验-操作系统验收报告](123)
