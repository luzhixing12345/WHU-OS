; hello-os
; TAB=4

; 标准FAT12格式软盘专用的代码 Stand FAT12 format floppy code
        ORG     0x7c00
        JMP     entry
        DB      0x90
        DB      "HELLOIPL"      ; 启动扇区名称（8字节）
        DW      512             ; 每个扇区（sector）大小（必须512字节）
        DB      1               ; 簇（cluster）大小（必须为1个扇区）
        DW      1               ; FAT起始位置（一般为第一个扇区）
        DB      2               ; FAT个数（必须为2）
        DW      224             ; 根目录大小（一般为224项）
        DW      2880            ; 该磁盘大小（必须为2880扇区1440*1024/512）
        DB      0xf0            ; 磁盘类型（必须为0xf0）
        DW      9               ; FAT的长度（必须是9扇区）
        DW      18              ; 一个磁道（track）有几个扇区（必须为18）
        DW      2               ; 磁头数（必须是2）
        DD      0               ; 不使用分区，必须是0
        DD      2880            ; 重写一次磁盘大小

        ; 书中作者说原因不明的两行代码我查到了，see https://www.ntfs.cocdm/fat-partition-sector.htm
        DB      0               ; BPB_Physical_Disk_Number    DB   (This is related to the BIOS physical disk number. Floppy drives are numbered starting with 0x00 for the A disk. Physical hard disks are numbered starting with 0x80. The value is typically 0x80 for hard disks, regardless of how many physical disk drives exist, because the value is only relevant if the device is the startup disk.)
        DB      0               ; BPB_Current_Head            DB   (Not used by FAT file system)
        DB      0x29            ; BPB_Signature               DB   (Must be either 0x28 or 0x29 in order to be recognized by Windows NT.)
        DD      0xffffffff      ; BPB_Volume_Serial_Number    DD



        DB      "HELLO-OS   "   ; 磁盘的名称（必须为11字节，不足填空格）
        DB      "FAT12   "      ; 磁盘格式名称（必须是8字节，不足填空格）
        RESB    18              ; 先空出18字节

; 程序主体

entry:
		MOV		AX,0			; 初始化寄存器
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX
; 读取磁盘
		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁头0
		MOV		CL,2		    	; 读取第2个扇区
		MOV		AH,0x02			; AH=0x02 : 读取磁盘
		MOV		AL,1			; AL=1 : 读取第1个扇区
		MOV		BX,0
		MOV		DL,0x00			; DL=0x00 : 读取第1个簇(A驱动器)
		INT		0x13			; 读取磁盘
		JC		error

fin:
		HLT			
		JMP		fin

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			
		MOV		BX,15			
		INT		0x10			
		JMP		putloop
msg:
		DB		0x0a, 0x0a		
		DB		"load error"
		DB		0x0a			
		DB		0
		RESB	0x7dfe-$		
		DB		0x55, 0xaa
