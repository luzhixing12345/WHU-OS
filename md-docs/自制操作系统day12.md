


# 定时器(1)

说起来定时器这个话题倒是让我想起来之前在知乎看到的一个问题,如何设计一个定时装置,多少多少秒记录一次.因为之前考虑到CPU主频的问题,时钟周期这个东西也没办法具有通用性.看起来似乎作者给了我答案

> 这里直接引用作者书中的原话

在电脑中管理定时器需要对PIT进行设定,PIT是"Programmable Interval Timer"的缩写,可编程的间隔型定时器.

通过谁当PIT,让定时器每个多少秒就产生因此中断,因为电脑中PIT连接着IRQ,所以设定了PIT就可以设定IRQ0的中断间隔.在旧机种上PIT是作为一个独立的芯片安装在主板上的,而现在已经和PIC一样被集成到别的芯片里了.

{% note warning %}
同样出现了这个情况,就是定时器运行一段时间后会异常退出QEMU,我也很困惑,最后实在没办法用VMWARE建了个虚拟机WIN10接着用

> 一般的电脑应该是可以正常运行没有问题的,我不太清楚为什么我的电脑很抽风


将中断周期设定为11932,这样中断频率就是100Hz,也就是说1s发生一百次中断,如果在每一次中断进行计数的话我们就可以计算时间了

```c
void init_pit(void)
{
	io_out8(PIT_CTRL, 0x34);
	io_out8(PIT_CNT0, 0x9c);
	io_out8(PIT_CNT0, 0x2e);
	timerctl.count = 0;
	return;
}
```

接着在主程序中将它打印出来,这样我们就可以在屏幕上看到一个不断跳动增长的计数器了

数字是以每秒钟100的速度增加,**不论是什么CPU处理器时间增加速度都是一样的**

## 超时

超时功能其实是很有用的,计时器只能单纯的计算时间,但是我们经常会需要运行几秒/显示几秒这种需求,所以利用计时器进行计时然后利用超时的机制(判断),这样就可以实现了

> 这里浅浅dis一下java的计时哈哈

接下来作者主要是用来解决超时的问题,并且改进了很多版.书中作者的表述比较清晰,每一次改进也都是很有针对性的,这里我简单的讲解一下这部分

还是先来看结构体是什么

```c
struct TIMERCTL {
    unsigned int count;
    unsigned int timeout;
    struct FIFO8 *fifo;
    unsigned char data;
}
```

其中 `timeout` 用于记录本次设定的时间是多少,使用FIFO的缓冲区输出的方式可以照比键盘鼠标,利用同样的方法来处理,即`fifo8_status`判断如果不为0那么获取缓冲区的输出

接着为了设定多个计时器作者修改了一下结构体,新建了TIMER用于记录每一个计时器,TIMERCTL来表示计时器表

```c
#define MAX_TIMER		500
struct TIMER {
	unsigned int timeout, flags;
	struct FIFO8 *fifo;
	unsigned char data;
};
struct TIMERCTL {
	unsigned int count;
    struct TIMER timer[MAX_TIMER]
};
```

几个基本的函数init, alloc, free, set,也只是稍作修改,看函数名就可以知道作用

光标闪烁这里的处理挺好的,就是使用一个FIFO8 timefifo3用来表示一个计时器的缓冲区,然后把他的时间间隔(timeout)设置为0.5s(50),主函数中判断,fifo中的值是它的data值,使用 i进行判断对应颜色的显示(COL8_FFFFFF和COL8_008484),然后重新设定计时器

```c
...
else if (fifo8_status(&timerfifo3) != 0) {
    i = fifo8_get(&timerfifo3);
    io_sti();
    if (i != 0) {
        timer_init(timer3, &timerfifo3, 0); /* 次は0を */
        boxfill8(buf_back, binfo->scrnx, COL8_FFFFFF, 8, 96, 15, 111);
    } else {
        timer_init(timer3, &timerfifo3, 1); /* 次は1を */
        boxfill8(buf_back, binfo->scrnx, COL8_008484, 8, 96, 15, 111);
    }
    timer_settime(timer3, 50);
    sheet_refresh(sht_back, 8, 96, 16, 112);
}
```

## 加速中断处理(1)

我们先来看现在是如何处理超时的情况的

```c
void inthandler20(int *esp)
{
	int i;
	io_out8(PIC0_OCW2, 0x60);
	timerctl.count++;
	for (i = 0; i < MAX_TIMER; i++) {
		if (timerctl.timer[i].flags == TIMER_FLAGS_USING) {
			timerctl.timer[i].timeout--;
			if (timerctl.timer[i].timeout == 0) {
				timerctl.timer[i].flags = TIMER_FLAGS_ALLOC;
				fifo8_put(timerctl.timer[i].fifo, timerctl.timer[i].data);
			}
		}
	}
	return;
}

```

注意到每一次调用中断inthandler20的时候timerctl.count++,这里的counter是单纯的一个计数器,从系统启动开始每一次调用就++,`timertcl.timer` 是所有的计时器数组,`imerctl.timer[i].timeout`表示的是当前计时器的剩余时间.

所以这里的情况是遍历计时器,对于其中正在使用的,timeout--,如果timeout(剩余时间)为0则结束,将data输出到缓冲区中

所以很容易就可以看出来count和timeout在这里功能是类似的,执行`timectl.timer[i].timeout--`实际是读取一次内存,CPU计算,然后再写入内存,耗时过长.现在的做法就可以避免这样的操作了

同时我们也应该注意time_settime函数的修改

```c
void timer_settime(struct TIMER *timer, unsigned int timeout)
{
	timer->timeout = timeout + timerctl.count;
	timer->flags = TIMER_FLAGS_USING;
	return;
}
```

这里需要设定的时间就要加上`timerctl.count`,因为count是随操作系统运行增加的一个量,而设定计时器的时机不确定,相当于做了一个相对位移.我相信也很好理解


这里多提一句,因为我第一次遇到的时候思考了一段时间

我们注意到`inthandler20` 函数是使用了 `for (i = 0; i < MAX_TIMER; i++)`这样一个循环来遍历所有的计时器,然后在其中选择flag使用的,那么为什么不使用一个变量记录当前有多少个计时器呢?这样根本不需要遍历`MAX_TIMER(500)`次啊

这是因为计时器的alloc和free的时机并不确定,可能出现的情况是设定了1234号计时器开始计时,我们每次只需要循环number(4)次.

这时候2号率先结束了,free掉了2号,这时候还在计时的是134.我们仍然需要循环4次,效果大差不差.


## 加速中断处理(2)

`inthandler20`函数每一次执行的时候都需要进入for循环判断,所以这一次的优化思路就是我们使用一个变量(next)来记录当前计时器组中最小的值,这样如果说现在的 `count<next` , 那么就直接return.否则才会进入for循环,寻找下一个最小的计时器的值

```c
void inthandler20(int *esp)
{
	int i;
	io_out8(PIC0_OCW2, 0x60);
	timerctl.count++;
	if (timerctl.next > timerctl.count) {
		return;
	}
	timerctl.next = 0xffffffff;
	for (i = 0; i < MAX_TIMER; i++) {
		if (timerctl.timer[i].flags == TIMER_FLAGS_USING) {
			if (timerctl.timer[i].timeout <= timerctl.count) {
				timerctl.timer[i].flags = TIMER_FLAGS_ALLOC;
				fifo8_put(timerctl.timer[i].fifo, timerctl.timer[i].data);
			} else {
				if (timerctl.next > timerctl.timer[i].timeout) {
					timerctl.next = timerctl.timer[i].timeout;
				}
			}
		}
	}
	return;
}

```

同步更新的timer_settime函数就是在设置time的时候判断一下,如果设置的timeout的值小于next,那么说明新加入的计时器就是最小的.直接更新next的值

## 加速中断处理(3)

最后又更新了数据结构,引入using变量,用于记录现在的定时器中有几个处于活动中,缩短了MAX_TIMER的循环次数

我们先来看一下设置计时器的函数`timer_settime`

```c
void timer_settime(struct TIMER *timer, unsigned int timeout)
{
	int e, i, j;
	timer->timeout = timeout + timerctl.count;
	timer->flags = TIMER_FLAGS_USING;
	e = io_load_eflags();
	io_cli();

	for (i = 0; i < timerctl.using; i++) {
		if (timerctl.timers[i]->timeout >= timer->timeout) {
			break;
		}
	}

	for (j = timerctl.using; j > i; j--) {
		timerctl.timers[j] = timerctl.timers[j - 1];
	}
	timerctl.using++;
	timerctl.timers[i] = timer;
	timerctl.next = timerctl.timers[0]->timeout;
	io_store_eflags(e);
	return;
}

```

大致意思是在0-using范围内搜索第一个大于timeout的计时器的位置i,然后将i-using的计时器依次向后移动一个位置,最后将这个新建的计时器插入到i的位置上.这里可以保证timectl中的所有timer都是按照timeout递增的.

接下来再看一下新的`inthandler20`

```c
void inthandler20(int *esp)
{
	int i, j;
	io_out8(PIC0_OCW2, 0x60);
	timerctl.count++;
	if (timerctl.next > timerctl.count) {
		return;
	}
	for (i = 0; i < timerctl.using; i++) {

		if (timerctl.timers[i]->timeout > timerctl.count) {
			break;
		}

		timerctl.timers[i]->flags = TIMER_FLAGS_ALLOC;
		fifo8_put(timerctl.timers[i]->fifo, timerctl.timers[i]->data);
	}
	timerctl.using -= i;
	for (j = 0; j < timerctl.using; j++) {
		timerctl.timers[j] = timerctl.timers[i + j];
	}
	if (timerctl.using > 0) {
		timerctl.next = timerctl.timers[0]->timeout;
	} else {
		timerctl.next = 0xffffffff;
	}
	return;
}

```

还是之前的next思路,如果还没到下一个计时器的时间那么直接返回,如果到了,由于按timeout递增,所以就去查找第一个满足`timeout>timectl.count`的计时器的位置i.删除这些计时器,并且移动之后所有的计时器位置

> 注意这里的判断条件是`timerctl.timers[i]->timeout > timerctl.count`,也就是确定timeout大于count,所以说如果多个计时器设定的相同的值那么会一直向下去寻找第一个超过count的计时器位置

![20220712230812](https://raw.githubusercontent.com/learner-lu/picbed/master/20220712230812.png)