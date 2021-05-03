.model small
.stack 100h
DATASG SEGMENT PARA
color equ 12 ; цвет ярко красный на черном фоне
string db "A", [color], "b", [color], "a", [color], "k", [color], "a", [color], "r", [color], "o", [color],\
 "v", [color], " ", [color], "G", [color], "a", [color], "s", [color], "a", [color],\
 "n", [color], ",", [color], " ", [color], "B", [color], "a", [color], "s", [color],\
 "k", [color], "a", [color], "e", [color], "v", [color], "a", [color], " ", [color],\ 
 "M", [color], "a", [color], "r", [color], "i", [color], ",", [color], " ", [color],\ 
 "B", [color], "a", [color], "t", [color], "u", [color], "e", [color], "v", [color],\ 
 " ", [color], "K", [color], "i", [color], "r", [color], "i", [color], "l", [color],\ 
 "l"
strlen equ $-string
DATASG ENDS
CODESG SEGMENT PARA
ASSUME DS:DATASG
ASSUME CS:CODESG
BEGIN PROC PARA
push ds
mov ax, 0
push ax
mov ax, DATASG
mov ds, ax
mov ax, 0B800h
mov es, ax
lea si, string
mov di, 80+56
cld
mov cx, [strlen]
rep movsb
ret
BEGIN ENDP
CODESG ENDS
END BEGIN
