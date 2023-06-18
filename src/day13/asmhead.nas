; haribote-os
; TAB=4

BOTPAK	EQU		0x00280000		; botpak address
DSKCAC	EQU		0x00100000		; dsk cache address
DSKCAC0	EQU		0x00008000		; dsk cache address

CYLS        EQU     0x0ff0
LEDS        EQU     0x0ff1
VMODE       EQU     0x0ff2
SCRNX       EQU     0x0ff4
SCRNY       EQU     0x0ff6
VRAM        EQU     0x0ff8


            ORG     0xc200             ;这个程序要被装载到内存的地址

            MOV     AL,0x13            ;VGA显卡,320x200x8位彩色
            MOV     AH,0x00            ;
            INT     0x10
            MOV     BYTE [VMODE],8     ;记录显卡模式
            MOV     WORD [SCRNX],320    ;记录显卡宽度
            MOV     WORD [SCRNY],200    ;记录显卡高度
            MOV     DWORD [VRAM],0x000a0000;记录显卡显存地址

; 用BIOS 取得键盘上各种LED状态

            MOV     AH,0x02             ;设置键盘状态
            INT     0x16
            MOV     [LEDS],AL           ;记录键盘状态

; PIC关闭一切中断
;   根据AT兼容机的规格,如果要初始化PIC
;   必须在CLI之前进行,否则有时会挂起
;   随后进行PIC的初始化

            MOV     AL,0xff             ;设置键盘状态
            OUT     0x21,AL
            NOP                         ;如果连续执行OUT指令,有些电脑会无法正常运行
            OUT     0xa1,AL

            CLI                         ;禁止CPU级别的中断

; 为了能让CPU访问1MB以上的内存空间,设定A20GATE
; waitkbdout 等同于 wait_KBC_sendready

            CALL    waitkbdout           ;等待键盘输出缓冲区空
            MOV     AL,0xd1            ;发送键盘指令
            OUT     0x64,AL
            CALL    waitkbdout           ;等待键盘输出缓冲区空
            MOV     AL,0xdf              ; enable A20
            OUT     0x60,AL
            CALL    waitkbdout           ;等待键盘输出缓冲区空

; 切换到保护模式

[INSTRSET "i486p"] ; 想要使用486指令的叙述

            LGDT    [GDTR0]             ;设置临时GDTR
            MOV     EAX,CR0             ;设置CR0
            AND     EAX,0x7fffffff      ;清除PE位,设bit31为0,为了禁止分页
            OR      EAX,0x00000001      ;设置PE位,设bit0为1,为了切换到保护模式
            MOV     CR0,EAX             ;设置CR0
            JMP     pipelineflush
pipelineflush:
            MOV     AX,1*8              ;设置CR0
            MOV     DS,AX
            MOV     ES,AX
            MOV     FS,AX
            MOV     GS,AX
            MOV     SS,AX
; bootpack 运送
            MOV     ESI,bootpack         ; 转送源
            MOV     EDI,BOTPAK           ; 转送目的地
            MOV     ECX,512*1024/4       ;512KB
            CALL    memcpy

; 磁盘数据最终转送到他本来的位置去
; 首先从启动扇区开始

            MOV		ESI,0x7c00		
		    MOV		EDI,DSKCAC		
		    MOV		ECX,512/4
		    CALL	memcpy

; 所有剩下的,也就是 bootpack.hrb

            MOV     ESI,DSKCAC0+512
            MOV     EDI,DSKCAC+512
            MOV     ECX,0
            MOV     CL,BYTE [CYLS]
            IMUL    ECX,512*18*2/4
            SUB     ECX,512/4
            CALL    memcpy

; bootpack的启动

            MOV     EBX,BOTPAK
            MOV     ECX,[EBX+16]
            ADD     ECX,3
            SHR     ECX,2
            JZ      skip
            MOV     ESI,[EBX+20]
            ADD     ESI,EBX
            MOV     EDI,[EBX+12]
            CALL    memcpy

skip:
            MOV     ESP,[EBX+12]
            JMP     DWORD 2*8:0x0000001b

waitkbdout:
            IN      AL,0x64
            AND     AL,0x02
            JNZ     waitkbdout
            RET

memcpy:
            MOV     EAX,[ESI]
            ADD     ESI,4
            MOV     [EDI],EAX
            ADD     EDI,4
            SUB     ECX,1
            JNZ     memcpy
            RET

            ALIGNB  16
GDT0:
            RESB    8
            DW      0xffff,0x0000,0x9200,0x00cf
            DW      0xffff,0x0000,0x9a28,0x0047
            DW      0

GDTR0:
            DW      8*3-1
            DD      GDT0

            ALIGNB  16
bootpack:
