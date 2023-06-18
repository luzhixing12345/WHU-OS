


# day7 FIFO与鼠标控制

显示按键的信息

通知PIC已经知道发生IRQ-x中断了,PIC继续监视IRQ-x中断是否发生,否则不管下次键盘输出什么信息系统都不做反应

```c
io_out8(PIC0_OCW2, 0x61);	// 通知PIC IRQ-01已经发生 (0x60+IRQ)
```

![20220526220135](https://raw.githubusercontent.com/learner-lu/picbed/master/20220526220135.png)

作者制作了FIFO缓冲区,不过数据移送的方式实在是太愚蠢了,于是作者用使用了一个类似循环队列的方式

关于FIFO的改进和鼠标/键盘的控制电路,这部分内容我是一口气看完的,我觉得作者讲的也很明白了,代码写的也是清晰易懂

不过这里有些奇怪,如果直接运行的话一开始如果去按键盘中部的按键ABC之类的会卡住,但是其他的012这种就没有问题,过了一段时间之后就所有的按键都可以很稳定的触发了.我去尝试作者的源代码编译之后的操作系统也是一样的,按道理来说不应该会出现这种情况.

后来检查了一下原来是中文输入法的原因,切换为英文就可以了

获取到来自鼠标的中断信号

![20220526234517](https://raw.githubusercontent.com/learner-lu/picbed/master/20220526234517.png)

接收鼠标的移动信号

![20220526235330](https://raw.githubusercontent.com/learner-lu/picbed/master/20220526235330.png)


不得不感叹,作者真的很厉害,要写一个操作系统要查好多好多信息,作者把这些内容都直接提供了,不然我都不知道从哪里入手
