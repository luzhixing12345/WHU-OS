
TOOLPATH = ../z_tools/
MAKE     = $(TOOLPATH)make.exe -r
NASK     = $(TOOLPATH)nask.exe
EDIMG    = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY     = copy
DEL      = del


default :
	$(MAKE) run

run :
	$(MAKE) img
	$(COPY) day3.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ..\z_tools\qemu

ipl.bin : day3.asm makefile
	$(NASK) day3.asm ipl.bin ipl.lst

day3.img : ipl.bin Makefile
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek wbinimg src:ipl.bin len:512 from:0 to:0   imgout:day3.img

img :
	$(MAKE) day3.img

clean :
	-$(DEL) day3.img ipl.bin ipl.lst
