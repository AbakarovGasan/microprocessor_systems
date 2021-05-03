.model small
.stack  100h
.code

main    proc
    mov ax, @data  
    mov ds, ax
    
    push offset msg0   ; 
    call print         ; вывод сообщения msg0
    add sp, 2          ;
    
    cmp ax, 5
    je exit
    
    push offset pass         ;
    push 200                 ;
    push offset buffer1      ; ввод в buffer1 
    call input               ;
    add sp, 6                ;
    
    push offset task_msg     ;
    call print               ; вывод сообщения task_msg
    add sp, 2                ;
    
    push offset buffer1      ;
    call sort                ; отсортировать символы по ANSII коду 
    add sp, 2                ;
   
    push offset buffer1      ;
    call print               ; вывод результата
    add sp, 2                ;
    
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

sort proc
 push bp
 mov bp, sp
 
 sub sp, 4
 a1 equ bp+4
 buf1 equ bp-2     
 buf2 equ bp-4

; Отсортировать символы в строке по значению ASCII кода символа.
 push [a1]
 call strlen ; сначала нужно найти длину строки
 add sp, 2   
  
 mov [buf2], ax             ; ax - длина строки, возвращаемое функцией strlen
 mov [buf1], word ptr 1     ; 
 
 L1:
 mov ax, [buf1]
 mov bx, [buf2]

 cmp ax, bx
 jge L2
 cmp ax, 0
 je L3
 
 mov cx, [a1]    ;  cx - 
 add cx, [buf1]  ;

 mov di, cx      ;
 mov dh, [di]    ;
 
 dec cx
 mov di, cx
 mov dl, [di]
 
 cmp dl, dh
 jle L3
 
 mov di, cx
 mov [di], dh
 
 inc cx
 mov di, cx
 mov [di], dl
 
 dec word ptr [buf1]
 jmp L1
 
 L3:
 inc word ptr [buf1]
 jmp L1
 
 L2: 
 add sp, 4
 pop bp
 ret
sort endp

print proc
 push bp
 mov bp, sp

 a1 equ bp+4

 push [a1]      ;
 call strlen    ; 
 add sp, 2      ;
 
 mov cx, ax
 mov ah, 40h
 mov dx, [a1]
 mov bx, 1
 int 21h
 
 pop bp
 ret
print endp

strlen proc 
 ; cтроки в данной программе
 ; заканчиваются с нулевым символом
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
