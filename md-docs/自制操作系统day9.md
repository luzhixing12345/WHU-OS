


# day9 内存管理

![20220707180754](https://raw.githubusercontent.com/learner-lu/picbed/master/20220707180754.png)

作者这里的思路还是蛮有趣的,从编译器优化后的汇编语言代码反推编译器对C语言代码的优化过程

最后既想保留编译器的优化,也想实现按页对内存进行访问,所以直接手写了汇编

![fdslhoaisdhoq](https://raw.githubusercontent.com/learner-lu/picbed/master/fdslhoaisdhoq.png)

## 挑战内存管理

作者这里介绍了两种内存管理的方式,一种是位图(bit map),一种是空闲链表

### 位图

对于第一种方式,先使用char的数组存储,每个数组元素代表该页(4KB)是否占用,0代表未占用,1代表占用

对于128MB内存128MB/4KB=0x8000=32768个页,如果使用char类型的数组来存储的话一共需要8x32768b = 32KB大小用于存储表


但是作者这里的代码我个人有一点小疑问

```c
char s[32768];
for (i=0; i<1024; i++) {
    s[i] = 1;
}
for (i=1024; i<32768; i++) {
    a[i] = 0;
}
```

这里为什么要用 `i<1024`? 分配了4MB的空间用于干什么了呢?



### 空闲链表

空闲链表的管理方法就是在表中记录从(xxx)开始的(yyy)字节的空间是空闲的


这两种方式各有优缺点,位图的话首先存储空间要相比空闲链表大一些,其次在分配连续内存空间的时候很不方便,因为需要查找一段连续的空间是否都没有被使用,如果分配的内存空间很大很容易搜索很长时间. 相比之下空闲链表对于大整型的内存分配就要有好很多,但是如果处理剩余的空间,10MB的空间分配了9.8MB那么剩下的零散的空间如何有效利用? 不同剩余空间的大小如何选择一个进行分配,如何回收. 这些系统性的知识点在操作系统课程中作为前置知识都介绍过了,我在这里就不再赘述


## 实现内存管理

作者在这里也没有纠结,选择了简单化处理,割舍到多出来的内存空间,使用了空闲链表的形式

首先构建了两个结构体,用于存储表中的信息.

创建了四个函数:

- `memman_init` 用于初始化内存表基本信息
- `memman_total` 用于计算可用内存单元总量
- `memman_alloc` 用于为在表中寻找一块内存大小为size的区域分配给应用程序
- `memman_free` 用于释放内存空间


对于memman_alloc我有一些想法,作者这里是当free\[i].size==0的时候将这条信息删除,然后数组后续所有项向前移动一格,但是我感觉这种方式并不好,我感觉可以设置一个 `MIN_SIZE` 用于判断最小的空间,如果小于MIN_SIZE那么我们就认为这块内存空间已经不可以再分配了. 而且也没必要数组后续的元素向前移动,这样做感觉很麻烦,我认为完全可以在结构体中多设计一个 `bool enable` 用于判断该信息是否可用,如果剩余内存大小小于 `MIN_SIZE` 那么将 `enable=true`,这样还可以节约这个移动元素的事件

> 这里可以后续修改一下

```c
unsigned int memman_alloc(struct MEMMAN *man, unsigned int size)
// 分配内存
{
	unsigned int i, a;
	for (i = 0; i < man->frees; i++) {
		if (man->free[i].size >= size) {
			// 找到足够大的空间
			a = man->free[i].addr;
			man->free[i].addr += size;
			man->free[i].size -= size;
			if (man->free[i].size == 0) {
				// 如果free[i] 剩余大小为0，那么删掉一条可用信息
				man->frees--;
				for (; i < man->frees; i++) {
					man->free[i] = man->free[i + 1]; // 代入结构体
				}
			}
			return a;
		}
	}
	return 0; // 无可用空间则返回0
}
```



最后这个`memman_free` 函数还是比较有趣的,看看完整代码对于理解struct中的int frees, maxfrees, lostsize, losts的含义还是很有帮助的,这里我来结合实例代码讲解一下.

首先在`HariMain`中定义了内存管理表的位置,`0x003c0000`的地址(宏)

```c
struct MEMMAN *memman = (struct MEMMAN *) MEMMAN_ADDR;
```

首先在`memman_init`函数中初始化了 frees, maxfrees, lostsize, losts 四个变量为1

```c
memman_init(memman);
...
void memman_init(struct MEMMAN *man)
{
	man->frees = 0;			// 可用信息数目
	man->maxfrees = 0;		// 用于观察的可用状态，frees的最大值
	man->lostsize = 0;		// 释放失败的内存大小综合
	man->losts = 0;			// 释放失败的册数
	return;
}
```

但是并没有初始化`free`数组,作为一个结构体类型的数组它没有被初始化是可能会存在一些问题的,但是作者没有初始化也是有原因的,我们接着往下看.

接着调用了 `memman_free` , 这个函数很长,但是第一次被调用的时候 `man->frees=0` `i=0`,这两个条件可以让我们过滤代码段然后清晰看到程序执行了哪一个分支

```c
memman_free(memman, 0x00001000, 0x0009e000); /* 0x00001000 - 0x0009efff */
...
int memman_free(struct MEMMAN *man, unsigned int addr, unsigned int size) {
	// 既不能与前面的归纳到一起，也不能与后面的归纳到一起
	if (man->frees < MEMMAN_FREES) {
		// free[i]之后的向后移动，腾出一点可用空间
        // 这里也不执行
		// for (j = man->frees; j > i; j--) {
		// 	man->free[j] = man->free[j - 1];
		// }
		man->frees++;
		if (man->maxfrees < man->frees) {
			man->maxfrees = man->frees; // 更新最大值
		}
		man->free[i].addr = addr;
		man->free[i].size = size;
		return 0; // 成功完成
	}
	// 不能往后移动
	man->losts++;
	man->lostsize += size;
	return -1; // 失败
}
```

man完成了第一次初始化,即

- man->frees = 1
- man->free[0].addr = 0x00001000
- man->free[0].size = 0x0009e000

第二次memman_free的时候释放了32MB-4MB=28MB的一段内存空间,所以现在frees中有两项,所有可用的内存大小是(0x9e000+28MB)


有点没太搞懂的地方就是为什么要第一次释放一块 0x00001000 - 0x0009efff 范围的内存


关于memman_free函数的代码我觉得作者写的注释还算清晰,我根据这里的内存分配和释放也做了[可视化演示](123)

![20220707220949](https://raw.githubusercontent.com/learner-lu/picbed/master/20220707220949.png)