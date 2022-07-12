
#include "bootpack.h"

#define FLAGS_OVERRUN		0x0001

void fifo8_init(struct FIFO8 *fifo, int size, unsigned char *buf)
// 初始化FIFO缓冲区
{
	fifo->size = size;
	fifo->buf = buf;
	fifo->free = size; // 缓冲区大小
	fifo->flags = 0;
	fifo->p = 0;  // 写入位置
	fifo->q = 0;  // 读取位置
	return;
}

int fifo8_put(struct FIFO8 *fifo, unsigned char data)
// 向FIFO传送数据并且保存
{
	if (fifo->free == 0) {
		// 如果缓冲区已满，则清除标志位
		fifo->flags |= FLAGS_OVERRUN;
		return -1;
	}
	fifo->buf[fifo->p] = data;
	fifo->p++;
	if (fifo->p == fifo->size) {
		fifo->p = 0;
	}
	fifo->free--;
	return 0;
}

int fifo8_get(struct FIFO8 *fifo)
// 从FIFO中读取数据
{
	int data;
	if (fifo->free == fifo->size) {
		// 如果缓冲区为空，则清除标志位
		return -1;
	}
	data = fifo->buf[fifo->q];
	fifo->q++;
	if (fifo->q == fifo->size) {
		fifo->q = 0;
	}
	fifo->free++;
	return data;
}

int fifo8_status(struct FIFO8 *fifo)
// 返回FIFO缓冲区的状态
{
	return fifo->size - fifo->free;
}
