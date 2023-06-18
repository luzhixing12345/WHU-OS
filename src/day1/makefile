
TOOLPATH = ../z_tools/
MAKE     = $(TOOLPATH)make.exe -r
NASK     = $(TOOLPATH)nask.exe
COPY     = copy
DEL      = del


default :
	$(MAKE) run

day1.img : day1.asm
	$(NASK) day1.asm day1.img

# 这里使用的是 ..\z_tools而不是 $(TOOLPATH)是因为windows的复制命令不支持路径
run :
	$(MAKE) img
	$(COPY) day1.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ..\z_tools\qemu

img :
	$(MAKE) day1.img

clean :
	-$(DEL) day1.img
