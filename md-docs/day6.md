


# day6 分割编译与中断处理

首先把一个.c文件拆开,按功能分为几个文件,把定义放在头文件引用.

> 按道理说应该是每一个.c对应一个.h,可能是为了方便吧

GDTR是一个特殊的48位寄存器,给他赋值的时候唯一的方法就是指定一个内存地址,从指定的地址读取6个字节,使用的汇编指令时LGDT

```c
struct SEGMENT_DESCRIPTOR {
	short limit_low, base_low;
	char base_mid, access_right;
	char limit_high, base_high;
};
```

这里对应的每个段的属性:

- 基地址 = (base_high + base_mid + base_low) = 4B
- 段大小 = (limit_low + limit_high) = 3B , 由 `Gbit`来决定,是否使用4KB的页
- 段属性 = access_right = 1B

基地址分成三段是为了和80286时代的程序兼容,这样16位的程序也就可以只使用`base_low`.

作者这里的逻辑是为了更好的让人理解为什么段大小使用了3字节来做的减法判断,事实上并不是因为8-4-1=3所以是3字节,应该是4+3+1=8所以是GDT表是8字节.

那么为什么GDT表要设计成8个字节呢,如果段大小也是4字节这样方便省事9个字节的GDT表不行么? 8个字节是考虑到了32位机器的CPU是32位,读取下一条指令移动的是4字节,如果是9个字节的GDT表那么寻找某一个段(假设为X)的时候就需要CPU先计算 `9X` 是多少,然后再把CPU的SP移动过去,如果是8个字节那么只需要计算 `8X` ,而 `8X` 不需要CPU单独计算,只需要 `X<<3`就可以了,要快很多.

3字节12位的段大小判断输入的limit的大小,如果大于0xffffff,那么说明这个段大于等于0x100000(1MB),则置段属性的最高位为1(ar|0x8000),然后将limit缩小4KB/1b = 0x1000(2^12)大小,采用页来计算.

值得一提是 `&0xff` 用来截断,保证只保留低八位,&0xf0,&0x0f同理

```c
void set_segmdesc(struct SEGMENT_DESCRIPTOR *sd, unsigned int limit, int base, int ar)
{
	if (limit > 0xfffff) {
		ar |= 0x8000; /* G_bit = 1 */
		limit /= 0x1000;
	}
	sd->limit_low    = limit & 0xffff;
	sd->base_low     = base & 0xffff;
	sd->base_mid     = (base >> 16) & 0xff;
	sd->access_right = ar & 0xff;
	sd->limit_high   = ((limit >> 16) & 0x0f) | ((ar >> 8) & 0xf0);
	sd->base_high    = (base >> 24) & 0xff;
	return;
}
```

关于段属性AR也在.h中作为宏定义了出来,用于区分保护模式和用户模式.

```c
#define AR_DATA32_RW	0x4092 // 系统专用,可读写的段,不可执行
#define AR_CODE32_ER	0x409a // 系统专用,可执行的段,可读不可写
```

## 中断的处理

> 这部分有些复杂,作者说了很多,我简要总结一下

- PIC(programmable interrupt controller)的缩写,意思是 可编程中断控制器.

  ![sdfksldhjf](https://raw.githubusercontent.com/learner-lu/picbed/master/sdfksldhjf.jpg)

- 由于CPU只能单独处理一个中断,PIC就是将多个IRQ(中断信号-interrupt request)集合成一个信号然后告知CPU发生了什么中断,一个主PIC,一个从PIC用来接收(8+8-1=15)个中断信号

  > 关于[IRQ参考](https://kb.iu.edu/d/ailq)

- PIC 的寄存器是 IMR( interrupt mask register)中断屏蔽寄存器,8位分别对应8路IRQ信号,某一位值为1则屏蔽此路信号

  > 为了防止在对中断设定进行更改的时候在接受别的中断会引起混乱

- ICW (initial control word)是初始化控制数据,在电脑PC上每一个PIC有4个ICW,每个ICW一个字节
- ICW1 ICW3 ICW4都不可使用,ICW2可以被操作系统修改,设定自己的中断信号表

  ICW3是主从PIC的设定,电脑上接了第二个引脚,所以设定为00000100,对应代码为 `io_out8(PIC0_ICW3, 1 << 2);`

- INT 0x00 - 0x1f 是BIOS的中断向量表,保存着类似"除数为0"等中断,我们使用INT 0x20-0x2f来接收中断信号IRQ 0-15

```c
void init_pic(void)
{

    io_out8(PIC0_IMR,  0xff  ); // 禁止所有中断
    io_out8(PIC1_IMR,  0xff  ); // 禁止所有中断

    io_out8(PIC0_ICW1, 0x11  ); // 边沿触发模式 (edge trigger mode)
    io_out8(PIC0_ICW2, 0x20  ); // IRQ0-7由INT20-27接收
    io_out8(PIC0_ICW3, 1 << 2); // PIC1由IRQ2接收
    io_out8(PIC0_ICW4, 0x01  ); // 无缓冲模式 (non-buffer mode)

    io_out8(PIC1_ICW1, 0x11  ); // 边沿触发模式 (edge trigger mode)
    io_out8(PIC1_ICW2, 0x28  ); // IRQ8-15由INT28-2f接收
    io_out8(PIC1_ICW3, 2     ); // PIC1由IRQ2接收
    io_out8(PIC1_ICW4, 0x01  ); // 无缓冲模式 (non-buffer mode)

    io_out8(PIC0_IMR,  0xfb  ); // 11111011 PIC1以外全禁止
    io_out8(PIC1_IMR,  0xff  ); // 11111111 PIC1中断禁止

    return;
}
```

仍然是一脸懵逼的写完了,虽然效果是一样的不过还是很迷惑...

## 中断处理程序的制作

这里作者针对键盘和鼠标分别设计了两个中断处理函数 `inthandler21` 和 `inthandler2c`,函数的内容也十分容易看懂,就是首先获取到显示器的基本信息,然后画一个(0,0)到(32*8-1,15)的方块,颜色为`COL8_000000`(黑),然后输出一行文字,颜色为白,挂起.另一个函数同理

```c
void inthandler21(int *esp)
/*
  INT 0X21 对应键盘的中断处理程序
  IRQ1 对应键盘的中断处理程序
*/
{
	struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
	boxfill8(binfo->vram, binfo->scrnx, COL8_000000, 0, 0, 32 * 8 - 1, 15);
	putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF, "INT 21 (IRQ-1) : PS/2 keyboard");
	for (;;) {
		io_hlt();
	}
}
```

两个处理中断的函数完成之后就需要调用他们了,我们期望按下鼠标或键盘之后产生中断信号,中断信号被PIC处理之后发送给CPU,CPU根据接收到了中断信号执行相关处理函数,这样就可以得到我们期待的结果了(输出方块和文字信息)

作者改进了之前的`dsctbl.c`中的`init_gdtidt`函数,将原先数字的形式的地址使用宏定义(看起来直观一些),然后将三个中断注册到IDT表中,分别是0x21,0x27,0x2c中断

> dsctbl 这个名字是 descriptor table 的缩写,用于表的处理

```c
void init_gdtidt(void)
{
	struct SEGMENT_DESCRIPTOR *gdt = (struct SEGMENT_DESCRIPTOR *) ADR_GDT;
	struct GATE_DESCRIPTOR    *idt = (struct GATE_DESCRIPTOR    *) ADR_IDT;
	int i;

	for (i = 0; i <= LIMIT_GDT / 8; i++) {
		set_segmdesc(gdt + i, 0, 0, 0);
	}
	set_segmdesc(gdt + 1, 0xffffffff,   0x00000000, AR_DATA32_RW);
	set_segmdesc(gdt + 2, LIMIT_BOTPAK, ADR_BOTPAK, AR_CODE32_ER);
	load_gdtr(LIMIT_GDT, ADR_GDT);

	for (i = 0; i <= LIMIT_IDT / 8; i++) {
		set_gatedesc(idt + i, 0, 0, 0);
	}
	load_idtr(LIMIT_IDT, ADR_IDT);

	set_gatedesc(idt + 0x21, (int) asm_inthandler21, 2 * 8, AR_INTGATE32);
	set_gatedesc(idt + 0x27, (int) asm_inthandler27, 2 * 8, AR_INTGATE32);
	set_gatedesc(idt + 0x2c, (int) asm_inthandler2c, 2 * 8, AR_INTGATE32);

	return;
}
```


这里的`(int)asm_inthandler21`这个传参方式我没太看懂,似乎是传入了一个函数在内存中的位置,以后C语言学明白了把这里补上


2*8表示的是asm_inthandler21属于2号段,乘8是因为低三位不表示段号,和之前的8192个段对应

AR_INTGATE32 = 0x008e 表示中断处理的设定

然后我们来看一下汇编语言的处理方式,

```asm
_asm_inthandler21:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler21
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD
```

将ES DS两个段寄存器压栈,将所有寄存器压栈,将ESP(栈指针)的值压栈,然后设定SS ES DS相同都为SS,然后调用中断函数`_inthandler21`,这时候传入的一个值就是栈指针ESP,可以通过这个指针找到栈中所有寄存器的值,对应`int.c`中的  `void inthandler21(int *esp)`,虽然现在还没有用到

汇编中也是用`EXTERN`关键字使得汇编语言也可以调用外部的C语言函数,函数执行完毕返回后将所有值出栈

![20220526201403](https://raw.githubusercontent.com/learner-lu/picbed/master/20220526201403.png)
