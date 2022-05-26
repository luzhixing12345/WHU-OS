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


            MOV     AL,0xff             ;设置键盘状态
            OUT     0x21,AL
            NOP
            OUT     0xa1,AL

            CLI                         ;关闭中断


            CALL    waitkbdout           ;等待键盘输出缓冲区空
            MOV     AL,0xd1            ;发送键盘指令
            OUT     0x64,AL
            CALL    waitkbdout           ;等待键盘输出缓冲区空
            MOV     AL,0xdf              ; enable A20
            OUT     0x60,AL
            CALL    waitkbdout           ;等待键盘输出缓冲区空

[INSTRSET "i486p"]

            LGDT    [GDTR0]             ;设置GDTR
            MOV     EAX,CR0             ;设置CR0
            AND     EAX,0x7fffffff      ;清除PE位
            OR      EAX,0x00000001      ;设置PE位
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
            MOV     ESI,bootpack        
            MOV     EDI,BOTPAK
            MOV     ECX,512*1024/4       ;512KB
            CALL    memcpy

            MOV		ESI,0x7c00		
		    MOV		EDI,DSKCAC		
		    MOV		ECX,512/4
		    CALL	memcpy

            MOV     ESI,DSKCAC0+512
            MOV     EDI,DSKCAC+512
            MOV     ECX,0
            MOV     CL,BYTE [CYLS]
            IMUL    ECX,512*18*2/4
            SUB     ECX,512/4
            CALL    memcpy

            
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
