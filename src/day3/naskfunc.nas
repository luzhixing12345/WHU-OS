; naskfunc
; TAB=4

[FORMAT "WCOFF"]
[BITS 32]
[FILE "naskfunc.nas"]

        GLOBAL      _io_hlt

[SECTION .text]

_io_hlt:
        HLT
        RET