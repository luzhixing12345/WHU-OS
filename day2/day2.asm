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

        ; 书中作者说原因不明的两行代码我查到了，see https://www.ntfs.com/fat-partition-sector.htm
        DB      0               ; BPB_Physical_Disk_Number    DB   (This is related to the BIOS physical disk number. Floppy drives are numbered starting with 0x00 for the A disk. Physical hard disks are numbered starting with 0x80. The value is typically 0x80 for hard disks, regardless of how many physical disk drives exist, because the value is only relevant if the device is the startup disk.)
        DB      0               ; BPB_Current_Head            DB   (Not used by FAT file system)
        DB      0x29            ; BPB_Signature               DB   (Must be either 0x28 or 0x29 in order to be recognized by Windows NT.)
        DD      0xffffffff      ; BPB_Volume_Serial_Number    DD



        DB      "HELLO-OS   "   ; 磁盘的名称（必须为11字节，不足填空格）
        DB      "FAT12   "      ; 磁盘格式名称（必须是8字节，不足填空格）
        TIMES   18  DB 0        ; 先空出18字节

; 程序主体

        DB      0xb8, 0x00, 0x00, 0x8e, 0xd0, 0xbc, 0x00, 0x7c
        DB      0x8e, 0xd8, 0x8e, 0xc0, 0xbe, 0x74, 0x7c, 0x8a
        DB      0x04, 0x83, 0xc6, 0x01, 0x3c, 0x00, 0x74, 0x09
        DB      0xb4, 0x0e, 0xbb, 0x0f, 0x00, 0xcd, 0x10, 0xeb
        DB      0xee, 0xf4, 0xeb, 0xfd

; 信息显示部分

        DB      0x0a, 0x0a      ; 换行两次
        DB      "hi, I'm kamilu"
        DB      0x0a         ; 换行
        DB      0

        TIMES   0x1fe-($-$$) DB 0x00         ; 填写0x00直到0x001fe

        DB      0x55, 0xaa

; 启动扇区以外部分输出

        DB      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
        TIMES   4600    DB 0
        DB      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
        TIMES   1469432 DB 0
; 只是把 RESB 20 改成了 TIMES 20 DB 0
