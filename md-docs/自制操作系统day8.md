


# day8 鼠标控制与32位模式切换

如作者所言,左右键/移动鼠标传出的三个值都有变化,鼠标键的状态取出低三位来判断,然后赋值给X Y

照葫芦画瓢就完事了

![20220707014320](https://raw.githubusercontent.com/learner-lu/picbed/master/20220707014320.png)

## asmhead.nas的讲解

这段汇编还是很有难度的,要是看不懂就一听一过就行了

我比较关心的是这里,之前提到的 bootpack.hrb复制到0x00280000地址的处理,512KB.

```asm
; 所有剩下的,也就是 bootpack.hrb

            MOV     ESI,DSKCAC0+512
            MOV     EDI,DSKCAC+512
            MOV     ECX,0
            MOV     CL,BYTE [CYLS]
            IMUL    ECX,512*18*2/4
            SUB     ECX,512/4
            CALL    memcpy
```

最后就是整个操作系统的内存分配图

- 0x00000000 - 0x000fffff : 在启动中多次使用(启动区0x7c00),BIOS,VRAM
- 0x00100000 - 0x00267fff : 用于保存软盘中的内容(1440KB)
- 0x00268000 - 0x0026f7ff : 空(30KB)
- 0x0026f800 - 0x0026ffff : IDT(2KB)
- 0x00270000 - 0x0027ffff : GDT(64KB)
- 0x00280000 - 0x002fffff : bootpack.hrb(512KB)
- 0x00300000 - 0x003fffff : 栈及其他
- 0x00400000 -            : 空

看完了我只能说,这一节实在是有点夸张,好复杂...

最后鼠标的活动基本实现了,但是在图像的叠加处理的上还不太行,我猜测作者应该打算在多任务窗口的时候处理一下,图像的层次之类的.
