


# 定时器(2)

开始是一些结构化的调整和测试速度,我也就没测~~懒~~

然后是对缓冲区的调整FIFO32,将所有外部IO的输入和输出全部整合到一个缓冲区的队列中

这一部分我重点说明一下线性表和哨兵,这里的处理思路很好

## 线性表的处理

由于中断处理中不应该耗时过长,而作者提及的这两处都涉及到了内存单元的读写,这显然是不希望看到的

![20220713034652](https://raw.githubusercontent.com/learner-lu/picbed/master/20220713034652.png)

![20220713034714](https://raw.githubusercontent.com/learner-lu/picbed/master/20220713034714.png)

那么如何避免这种内存单元的移动呢? 新加了一个指针next

```c
struct TIMER {
    struct TIMER *next;
	unsigned int timeout, flags;
	struct FIFO32 *fifo;
	int data;
};
```

注意此时有两个next变量,一个是timectl表中的next(unsigned int),用于记录下一个(最近的)计时器时间,另一个是timer的next(TIMER *),用于记录下一个计时器的地址

回忆一下现在所有的timectl中的timer都是按照timeout从小到大排序好的,`inthandler20`的处理思路类似,唯一的改变就是避免了移动,直接将timectl中timer的头指针指向下一个计时器的位置即可.

`timer_settime`函数的思路下图很清晰,在一个链表中查找设置的timeout对应的位置,然后将这个计时器插入进去.

![sklj9](https://raw.githubusercontent.com/learner-lu/picbed/master/sklj9.jpg)

这样一种链表的结构就要比数组方便很多了

## 哨兵

我们首先观察一下上图中的timer_settime函数,作者提到的四种情况

- 运行中的定时器只有一个
- 插入到最前面的情况
- 插入到s,t之间的情况
- 插入到最后面的情况

以下代码的注释部分代表了不同情况对应的条件分支

```c
void timer_settime(struct TIMER *timer, unsigned int timeout)
{
	int e;
	struct TIMER *t, *s;
	timer->timeout = timeout + timerctl.count;
	timer->flags = TIMER_FLAGS_USING;
	e = io_load_eflags();
	io_cli();
	timerctl.using++;
	// state-1
	if (timerctl.using == 1) {
		timerctl.t0 = timer;
		timer->next = 0;
		timerctl.next = timer->timeout;
		io_store_eflags(e);
		return;
	}
	t = timerctl.t0;
	// state-2
	if (timer->timeout <= t->timeout) {
		timerctl.t0 = timer;
		timer->next = t;
		timerctl.next = timer->timeout;
		io_store_eflags(e);
		return;
	}
	for (;;) {
		s = t;
		t = t->next;
		// state-4
		if (t == 0) {
			break;
		}
		// state-3
		if (timer->timeout <= t->timeout) {
			s->next = timer;
			timer->next = t;
			io_store_eflags(e);
			return;
		}
	}
	s->next = timer;
	timer->next = 0;
	io_store_eflags(e);
	return;
}
```

那么哨兵,就是用于简化这四个条件的一个"留守者",我们先来看一下`init_pic`的变化

```c
void init_pit(void)
{
	int i;
	struct TIMER *t;
	io_out8(PIT_CTRL, 0x34);
	io_out8(PIT_CNT0, 0x9c);
	io_out8(PIT_CNT0, 0x2e);
	timerctl.count = 0;
	for (i = 0; i < MAX_TIMER; i++) {
		timerctl.timers0[i].flags = 0; /* 未使用 */
	}
	t = timer_alloc();
	t->timeout = 0xffffffff;
	t->flags = TIMER_FLAGS_USING;
	t->next = 0;
	timerctl.t0 = t;
	timerctl.next = 0xffffffff;
	return;
}
```

也就是在初始化的时候就设置了一个计时器,timeout是0xffffffff(unsigned int的最大值),然后初始化next.

由于多了一个已经设置为最大时间的计时器,所以现在对于上方的四种情况有两种情况肯定不会发生

- 运行中的定时器只有一个(不会发生,至少有两个计时器)
- 插入到最前面的情况
- 插入到s,t之间的情况
- 插入到最后面的情况(哨兵计时器时间最大值,一定在最后)

所以可以删掉之前的两个条件判断,并且精简所有的函数.

> 这里没什么技术含量就不做展开了


其实这里的哨兵就是一个稳定排在最后面的计时器,用于压缩状态.关于这个技巧可以参考[文章](https://blog.csdn.net/m0_60090611/article/details/118803146)

除此之外哨兵还有很多其他的含义,可以参考[哨兵机制](https://blog.csdn.net/universsky2015/article/details/102590330)

