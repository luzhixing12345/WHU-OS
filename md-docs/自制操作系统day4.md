


# day4 C语言与画面显示

```asm
_write_mem8:    ; void write_mem8(int addr, int data)
        MOV     ECX,[ESP+4]     ; [ESP+4] = addr
        MOV     AL,[ESP+8]      ; [ESP+8] = data
        MOV     [ECX],AL
        RET
```

ESP栈指针,传入两个参数 addr,data,分别在栈(栈指针ESP)中的\[ESP+4]和\[ESP+8]中的位置,因为int是32位,四个字节.

一个简单的修改显示白屏. 15为1111是白色,13为1101是紫色

![QQ截图20220526010741](https://raw.githubusercontent.com/learner-lu/picbed/master/QQ%E6%88%AA%E5%9B%BE20220526010741.png)

`i&0x0f`  的条纹

![QQ截图20220526011055](https://raw.githubusercontent.com/learner-lu/picbed/master/QQ%E6%88%AA%E5%9B%BE20220526011055.png)

## 指针

这一部分作者讲的真的挺好的,清晰明了浅显易懂,如果尚不熟悉指针看看这个应该可以明白个大概

汇编语言中IN OUT 用于CPU读写外设

对于IN8/16/32的区别就是最后的位数,EAX是32位的寄存器,首先将栈中的参数(int port)32位的值取出放入EDX,然后将EAX寄存器置零,最后使用从DX端口读取数据

> 值得一提的是读取的数据位数是根据IN的第一个参数 AL/AX/EAX来确定8/16/32位的,DX只是端口号.最后返回值通过EAX寄存器传出,这样CPU就得到了来自外设的输入

OUT同理,将EAX寄存器输送给DX端口,CPU将数据传出给外设

![20220705164915](https://raw.githubusercontent.com/learner-lu/picbed/master/20220705164915.png)

CLI禁止中断发生,STI允许中断发生.在改变段寄存器SS SP时候必须要禁止中断,当改变完成后再恢复中断.

> [参考汇编指令CLI/STI](https://blog.csdn.net/zang141588761/article/details/52325106)

EFLAGS的第九位IF用于判断是否产生中断,整个`set_palette`函数的流程如下所示

![20220705181435](https://raw.githubusercontent.com/learner-lu/picbed/master/20220705181435.png)

## 绘图

![QQ截图20220526013910](https://raw.githubusercontent.com/learner-lu/picbed/master/QQ%E6%88%AA%E5%9B%BE20220526013910.png)

可以说,进入了C语言就进入了主场,一切都变得清晰了起来. 不过还是尚不清楚C和操作系统之间如何联系的

![QQ截图20220526014753](https://raw.githubusercontent.com/learner-lu/picbed/master/QQ%E6%88%AA%E5%9B%BE20220526014753.png)

![QQ截图20220526015031](https://raw.githubusercontent.com/learner-lu/picbed/master/QQ%E6%88%AA%E5%9B%BE20220526015031.png)

现在看起来有模有样了,确实图形化界面给人感觉很直观~
