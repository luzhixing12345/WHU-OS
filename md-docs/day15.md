


# 多任务(1)

> 要开始进行进程调度了,关于这里的概念就不多说了,我们直接开始吧

```c
struct TSS32 {
	int backlink, esp0, ss0, esp1, ss1, esp2, ss2, cr3;
	int eip, eflags, eax, ecx, edx, ebx, esp, ebp, esi, edi;
	int es, cs, ss, ds, fs, gs;
	int ldtr, iomap;
};
```

TSS(task status segment)是任务状态段,用于保存进程的信息,这个结构体可以被分为四个部分

- 第一行保存的是任务设置的相关信息,在任务切换的时候也不会被写入
- 第二行是32位寄存器,其中EIP寄存器用于保存CPU指针的位置
- 第三行是16位寄存器,代码段数据段栈指针等相关寄存器
- 第四行是任务设置的部分,在任务切换的时候也不会被写入

  ldtr设置为0,iomap设置为0x40000000

> 关于各种寄存器的含义可以参考[文章](https://www.cnblogs.com/mumuliang/archive/2010/07/26/1873493.html)

JMP指令分为两种,一种是near,一种是far

> 其实far指令就是因为JMP的跳转位数不够,跳转的地址范围有限(-128到 +127),所以如果需要跳转到一个更大的范围需要加上段寄存器.

TR(task register)寄存器很关键,用于让CPU记住当前正在运行的是哪一个任务,当任务切换的时候TR寄存器的值也会自动变化,给TR寄存器赋值的时候需要用到LTR指令

## 任务切换

首先我们考虑一下两个任务之间的切换,将两个任务在GDT中进行定义,注册对应的段号

> 如果不记得GDT的作用了可以回看一下day5

```c
	tss_a.ldtr = 0;
	tss_a.iomap = 0x40000000;
	tss_b.ldtr = 0;
	tss_b.iomap = 0x40000000;
	set_segmdesc(gdt + 3, 103, (int) &tss_a, AR_TSS32);
	set_segmdesc(gdt + 4, 103, (int) &tss_b, AR_TSS32);
```

这里是将任务A注册到了3号段,任务B注册到了4号段,所以下方是先使用`load_tr(3*8)`,表示先运行的是任务A

接着我们来看一下`taskswitch4()`,这个汇编函数是单独为任务B编写的,表示跳转到4号段的位置(4*8:0)

在`init_gdtidt`函数中我们已经使用了1,2号段,这里设置任务B的相关寄存器信息倒也是完全无所谓,因为他现在这个`task_b_main`什么也没有用到.不同任务切换的时候要完整的保存栈的信息,为了恢复的时候使用.这里为任务B单独开辟了一个栈task_b_esp并且分配了64KB空间.

对于双任务的讨论作者说的还是比较详细的,计时,栈传值传指针等等

## 任务切换进阶

进阶部分也比较简单,初始化部分就是设定一个0.02s的计时器,把初始tr设置为3

```c
void mt_init(void)
{
	mt_timer = timer_alloc();
	timer_settime(mt_timer, 2);
	mt_tr = 3 * 8;
	return;
}
```

在交换任务的函数也不难,首先判断是3/4哪一个任务,然后切换为另一个,然后重新设定一个0.02s的计时器,跳转到新的地址(另一个任务)

```c
void mt_taskswitch(void)
{
	if (mt_tr == 3 * 8) {
		mt_tr = 4 * 8;
	} else {
		mt_tr = 3 * 8;
	}
	timer_settime(mt_timer, 2);
	farjmp(0, mt_tr);
	return;
}

```

然后就是最后作者提到的问题,何时进行`mt_taskswitch`?


这里我一开始也没太看懂,两个版本的代码的不同之处就是一个是计时器到达后使用ts变量记录,在`inthandler20`的最后使用了mt_taskswitch,另一个是计时器到达后直接使用mt_taskswitch切换.
