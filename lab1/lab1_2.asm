.model small
.stack  100h
.code

main    proc
    mov ax, @data
    mov ds, ax
    
    push offset msg0
    call print
    add sp, 2
    
    cmp ax, 5
    je exit
    
    push offset pass
    push 200
    push offset buffer1
    call input
    add sp, 6
    
    push offset task_msg
    call print
    add sp, 2
    
    push offset buffer1
    call reverse
    add sp, 2
   
    push offset buffer1
    call print
    add sp, 2
    
    call newline
    
    exit:
    mov ax,4C00h
    int 21h 
    ret
main    endp

newline proc
 mov ah, 06h ;
 mov dl, 13  ; вывести новую линию
 int 21h     ;
 mov ah, 06h ;
 mov dl, 10  ; 
 int 21h     ;
newline endp

pass proc
 push bp
 mov bp, sp
 
 mov ax, [bp+4]
 
 pop bp
 ret
pass endp


reverse proc
 push bp
 mov bp, sp
 
 sub sp, 6
 a1 equ bp+4
 buf4 equ bp-2
 buf5 equ bp-4
 buf6 equ bp-6
 
 mov cx, [a1]
 mov [buf4], cx
 L11:
 mov cx, [buf4]
 mov [buf5], cx
 L6:
 mov ax, [buf5]
 mov di, ax
 mov dh, [di]
 inc [buf5]
 cmp dh, 32
 je L6
 cmp dh, 0
 je L10
 mov ax, [buf5]
 mov [buf6], ax
 dec [buf6]
 L7:
 mov ax, [buf5]
 mov di, ax
 mov dh, [di]
 inc [buf5]
 cmp dh, 0
 je L8
 cmp dh, 32
 jne L7
 L8:
 mov ax, [buf5]
 mov [buf4], ax
 sub [buf5], 2
 L9:
 mov ax, [buf5]
 mov bx, [buf6]
 cmp ax, bx
 jle L11
 mov di, ax
 mov dh, [di]
 mov di, bx
 mov dl, [di]
 mov di, ax
 mov [di], dl
 mov di, bx
 mov [di], dh
 dec [buf5]
 inc [buf6]
 jmp L9
 L10:
 
 add sp, 6
 pop bp
 ret
reverse endp


print proc
 push bp
 mov bp, sp

 a1 equ bp+4

 push [a1]
 call strlen
 add sp, 2
 
 mov cx, ax
 mov ah, 40h
 mov dx, [a1]
 mov bx, 1
 int 21h
 
 pop bp
 ret
print endp

strlen proc 
 push bp
 mov bp, sp
 
 a1 equ bp+4

 mov ax, 0
 mov ax, [a1]
 .l1:
 mov di, ax
 mov dl, [di]
 inc ax
 cmp dl, 0
 jne .l1
 sub ax, [a1]
 dec ax
 
 pop bp
 ret
strlen endp

input proc
 push bp
 mov bp, sp
 
 sub sp, 2 ; зарезервировать для новой переменной

 a1 equ bp+4 ; a1 - указатель на начало буффер
 a2 equ bp+6 ; a2 - длина буффера
 
 a3 equ bp+8 ; а3 - функция, которая сбрасывает недопустимые символы
 buf0 equ bp-2 ; новая переменная (указатель)
 

 mov ax, [a1]
 mov [buf0], ax ; сохраняем значение а1 в buf0
 add [a2], ax ; помещаем в а2 указатель на конец буффера
 ._l10:
 
 mov ah, 07h ; ввод
 int 21h
 
 cmp al, 8 ; если нажата кнопка backspace, то
 je ._l12 ; выполнить ._l12
 cmp al, 13 ; если нажат enter, то
 je ._l15 ; выполнить ._l15
 
 push ax
 call [a3] ; проверить символ на недопустимые значения
 add sp, 2
 
 cmp al, 0 ; если символ недопустимый, то оно обращается в ноль
 je ._l10
 
 mov si, [a1] ; записать символ
 mov [si], al ;
 
 mov ah, 06h
 mov dl, al ; вывести символ 
 int 21h
 
 inc word ptr [a1] ; переместить указатель вперед

 mov ax, [a1]  ;  
 mov bx, [a2]  ;
 cmp ax, bx    ;  если указатель в конце строки, то
 je ._l14      ;  выполнить ._l14
 
 jmp ._l10     ; вернуться в ._l10
 
 ._l15:
 
 call newline ; вывести новую линию
 
 mov di, [a1]
 mov [di], byte ptr 0 ; записать 0 в конец строки
  
 add sp, 2 ;
 pop bp    ; завершить подпрограмму, освободить стек
 ret       ;  
 
 ._l12:
 mov ax, [a1]
 mov bx, [buf0] 
 cmp ax, bx ; eсли указатель в начале строки, то 
 je ._l10   ; вернуться в ._l10
 
 dec word ptr [a1] ; cместить указатель назад
 
 mov ah, 06h ;
 mov dl, 8   ;
 int 21h     ;
 mov ah, 06h ;
 mov dl, 32  ; cтереть символ
 int 21h     ;
 mov ah, 06h ;
 mov dl, 8   ;
 int 21h     ;
 
 jmp ._l10   ; вернуться в ._l10
 
 ._l14:
 mov ah, 07h ;
 int 21h     ; выполняется до тех пор, 
 cmp al, 8   ; пока не нажата кнопка backspace
 je ._l12    ; если нажата кнопка enter, 
 cmp al, 13  ; то вывести новую линию 
 je ._l15    ; записать 0 в конец строки и завершить
 
 jmp ._l14
 
input endp

.data
buffer1 db 201 dup(0) 
buffer2 db 201 dup(0)

msg0 db 'Enter a string: ', 10, 0
task_msg db 'Sort characters in the string by ASCII character code: ', 10, 0
end main
