


# day5 结构体/文字显示与GDT/IDT初始化

到现在看到这个结构体就能明白作者当初的用意了

```c
struct BOOTINFO {
	char cyls, leds, vmode, reserve;
	short scrnx, scrny;
	char *vram;
};
```

与asmhead.nas中的

```asm
CYLS        EQU     0x0ff0
LEDS        EQU     0x0ff1
VMODE       EQU     0x0ff2
SCRNX       EQU     0x0ff4
SCRNY       EQU     0x0ff6
VRAM        EQU     0x0ff8
```

字符显示这里作者的做法也是比较巧妙的,每一个字符都是一个8x16的矩阵,每一行一个字节,所以每一个字符是长度为16的数组.

从 0x80 - 0x01 对于每一个字节的八位从高到低(从左至右)依次按位与判断,如果为1则将该位的 `p[i]` 置为 c 的颜色

```c
void putfont8(char *vram, int xsize, int x, int y, char c, char *font)
{
    int i;
    char *p, d /* data */;
    for (i = 0; i < 16; i++) {
        p = vram + (y + i) * xsize + x;
        d = font[i];
        if ((d & 0x80) != 0) { p[0] = c; }
        if ((d & 0x40) != 0) { p[1] = c; }
        if ((d & 0x20) != 0) { p[2] = c; }
        if ((d & 0x10) != 0) { p[3] = c; }
        if ((d & 0x08) != 0) { p[4] = c; }
        if ((d & 0x04) != 0) { p[5] = c; }
        if ((d & 0x02) != 0) { p[6] = c; }
        if ((d & 0x01) != 0) { p[7] = c; }
    }
    return;
}
```

我们之前在函数中定义过所有的颜色,对应的RGB数值. 字体使用了一个字体库, 纯文字就是白(0xFFFFFFFF), 对于鼠标的绘制就是边缘是`COL8_000000`(黑) , 内部是 `COL8_FFFFFF`(白) , 其余部分就是背景颜色,对于这个操作系统的界面来说就是`COL8_008484`(浅暗蓝)

```c
#define COL8_000000		0
#define COL8_FF0000		1
#define COL8_00FF00		2
#define COL8_FFFF00		3
#define COL8_0000FF		4
#define COL8_FF00FF		5
#define COL8_00FFFF		6
#define COL8_FFFFFF		7
#define COL8_C6C6C6		8
#define COL8_840000		9
#define COL8_008400		10
#define COL8_848400		11
#define COL8_000084		12
#define COL8_840084		13
#define COL8_008484		14
#define COL8_848484		15
```

好耶,一个A

![20220526021405](https://raw.githubusercontent.com/learner-lu/picbed/master/20220526021405.png)

hankanku字体

![20220526024750](https://raw.githubusercontent.com/learner-lu/picbed/master/20220526024750.png)

![20220526025108](https://raw.githubusercontent.com/learner-lu/picbed/master/20220526025108.png)

![20220526025737](https://raw.githubusercontent.com/learner-lu/picbed/master/20220526025737.png)

鼠标这里蛮坑的,作者突然把原来的init_screen改成init_screen8

![20220526030252](https://raw.githubusercontent.com/learner-lu/picbed/master/20220526030252.png)

## GDT IDT初始化

终于到了有意思一点的地方了,作者一开始打算用分段的方式处理任务

GDT 是 `global (segment) descriptor table` 的缩写,全局段号记录表.

每一个段需要使用8字节保存信息:

- 段的大小
- 段的起始地址
- 段的管理属性(禁止写入,禁止执行,系统专用)

(8192x8=64KB),实际上如果每个段的大小都相同,那么我们只需要知道段的起始地址和固定的段大小就可以直接计算出当前段应该处于内存的什么位置.不需要每一个段都存储段大小了,可以节约空间

IDT 是 `interrupt descriptor table` 的缩写,中断记录表

对于外设的IO相对于CPU的主频要慢很多,目前CPU一般都是在 `2.3GHz` 左右,与键盘鼠标等外设的频率相比要低很多,所以正常情况下CPU处理任务,如果外设有IO输入那么通过中断机制来执行中断程序

所以先进行段的设定(GDT),然后就可以设定中断映射表(IDT),这样就把中断号码和调用函数对应起来了

在定义的过程中将 `0x00270000 - 0x0027ffff` 内存部分用于GDT表,`0x0026f800 - 0x0026ffff` 用于IDT

> 中断向量表只需要256个就足够了,所以只需要 256x8 = 2048 = 0x800

这两个起始地址也是作者随意规定的,没有什么特殊含义.关于这部分代码会在下一篇博客讲解

段号为1的段上限值为0xffffffff(4GB),起始地址是0,代表CPU所能管理的全部内存本身.

段号为2的段大小为0x7ffff(512KB),起始地址是0x280000,是为c语言程序编译出的bootpack.hrb准备的
