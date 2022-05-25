# L-OS

## Introduction

武汉大学操作系统设计课程的大作业: **复现一个操作系统内核**

所有本次课程实验相关资料上传至[releases](https://github.com/luzhixing12345/L-OS/releases/tag/v0.0.1)

## Record

参考: **30天自制操作系统**

该实验所有的过程以及中途遇到的问题,原理和解决思路均记录在[个人博客](https://luzhixing12345.github.io/tags/OS/),每一天的任务和代码内容更新在对应的文件夹下.

**本目录下仅有当天的完成的最终代码文件**,无生成文件,无结果文件.

## Use

每一个文件夹内容都可以直接运行使用,不需要复制/移动,只在Windows系统测试运行

- 运行第一天的程序

  ```bash
  make -C day1
  ```

  ![QQ截图20220525151559](https://raw.githubusercontent.com/learner-lu/picbed/master/QQ%E6%88%AA%E5%9B%BE20220525151559.png)

- 运行最后一天的程序

  ```bash
  make -C day30
  ```

清除生成的文件

```bash
make -C {DAY} clean
```

## Visualization Result
