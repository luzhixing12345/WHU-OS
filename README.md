# WHU-OS

武汉大学操作系统设计课程的大作业: **复现一个操作系统内核**

## 简介

参考: **30天自制操作系统**

该实验所有的过程以及中途遇到的问题,原理和解决思路均记录在[个人博客](https://luzhixing12345.github.io/tags/OS/),每一天的任务和代码内容更新在对应的文件夹下.**对应目录下仅有当天的完成的最终代码文件**

## 编译与使用

每一个文件夹内容都可以直接运行使用,除c语言基本环境外无需其他格外安装

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

## 可视化展示

- day1

  ![20220705213449](https://raw.githubusercontent.com/learner-lu/picbed/master/20220705213449.png)

- day10

- day20

- day30

## 关于

### 关于WHU-OS

WHU-OS基于30天自制操作系统最后的操作系统,在原先的基础上进行了部分修改,模块的添加,代码的重构.详见[WHU-OS](WHU-OS.md)

### 关于操作系统

对于"30天自制操作系统" 书中内容的记录整理 - [个人博客](https://luzhixing12345.github.io/tags/OS/)

对于操作系统的浅薄理解 - [视频](123)

### 关于文档

[课程实验相关资料](https://github.com/luzhixing12345/WHU-OS/releases/tag/v0.0.1)

[复现实验-操作系统验收报告](123)

[视频中的PPT](123)
