
# include "bootpack.h"
#include <stdio.h>

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

void inthandler27(int *esp)
{
	io_out8(PIC0_OCW2, 0x67);
	return;
}
