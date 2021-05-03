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
    call reverse_symbols
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


reverse_symbols proc
 push bp
 mov bp, sp
 a1 equ bp+4
 
 dec [a1]
 
 L11:
 inc [a1]
 
 mov si, [a1]
 mov bl, [si]
 mov al, 0
 
 cmp bl, 0   ; если это конец строки,
 je L10      ; то завершить подпрограмму
 
 cmp bl, 32  ; если символ - пробел,
 je L11      ; то пропустить
 
  mov cx, 8
  L9:
  dec cx
  shr al, 1
  shl bl, 1
 
  jc L8
  inc al
  L8:
 
  cmp cx, 0
  je L9
 
 mov si, [a1]
 mov [si], al
 
 jmp L11
 
 L10:
 pop bp
 ret
reverse_symbols endp


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

.data
buffer1 db 201 dup(0) 
buffer2 db 201 dup(0)

msg0 db 'Enter a string: ', 10, 0
task_msg db 'Sort characters in the string by ASCII character code: ', 10, 0
end main
