.model small
.stack  100h
.code

main    proc
    mov ax, @data
    mov ds, ax
    
    push offset msg0           ; 
    call print                 ; вывести строку msg0 
    add sp, 2                  ;
    
    push offset pass           ;
    push 200                   ;
    push offset buffer1        ; ввести строку в buffer1
    call input                 ;
    add sp, 6                  ;
    
    push offset msg1           ;
    call print                 ; вывести строку msg1
    add sp, 2                  ;
    
    push offset is_not_space   ;
    push 200                   ;
    push offset buffer2        ; ввести слово в buffer2
    call input                 ;
    add sp, 6                  ;
    
    push offset buffer3        ;
    push offset buffer2        ; удалить слово buffer2 
    push offset buffer1        ; из строки buffer1
    call delete_word           ; и записать результат в buffer3
    add sp, 6
    
    cmp ax, -1                 ; если строка не найдена, то
    jne .ll_1                  ; вывести ошибку
                               ; иначе вывести результат выполнения
                               
    push offset error_message1     ;
    call print                     ;
    add sp, 2                      ;
    push offset buffer2            ;
    call print                     ; вывести ошибку и завершить
    add sp, 2                      ;
    push offset error_message2     ;
    call print                     ;
    add sp, 2                      ;

    jmp exit
    
    .ll_1:
    
    push offset task_msg1          ;
    call print                     ;
    add sp, 2                      ;
    push offset buffer2            ;
    call print                     ;
    add sp, 2                      ;
    push offset task_msg2          ; вывести результат и завершить
    call print                     ;
    add sp, 2                      ;
    push offset buffer3            ;
    call print                     ;
    add sp, 2                      ;
    call newline                   ;
    
    exit:
    mov ax,4C00h
    int 21h 
    
main    endp

is_not_space proc
 push bp
 mov bp, sp
 a1 equ bp+4
 mov ax, [a1]
 cmp al, 32
 je e2
 pop bp
 ret
 e2:
 mov ax, 0
 pop bp
 ret
is_not_space endp

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

copyA proc 
 push bp
 mov bp, sp
 
 a1 equ bp+4
 a2 equ bp+6
 a3 equ bp+8
 
 ; функция копирует а3 символов из а1 строки в а2 строку 
 mov ax, [a1];ax - указатель на строку а1
 mov bx, [a2];bx - указатель на строку а2
 mov cx, [a3]
 add cx, ax  ;cx - указатель на конец строки а1
 ._l9:
 cmp ax, cx
 je ._l10
 mov di, ax
 mov dh, [di]
 mov di, bx
 mov [di], dh
 inc ax
 inc bx
 jmp ._l9
 ._l10:
 
 pop bp
 ret
copyA endp

delete_word proc
 ; функция удаляет 
 ; подстроку a1 из 
 ; строки а2
 push bp
 mov bp, sp
 sub sp, 6
 
 a1 equ bp+4
 a2 equ bp+6
 
 buf17 equ bp-2
 buf18 equ bp-4
 buf19 equ bp-6

 push [a2]
 push [a1]
 call find
 add sp, 4
 
 cmp ax, -1
 je _L21
 mov [buf17], ax
 mov [buf18], bx
 
 mov ax, [a3]
 mov [buf19], ax
 
 push [buf17]
 push [buf19]
 push [a1]
 call copyA
 add sp, 6
 
 mov ax, [a1]
 add ax, [buf17]
 add ax, [buf18]
 mov bx, [buf19]
 add bx, [buf17]
 
 push bx
 push ax
 call copy
 add sp, 4
 
 mov ax, [buf19]
 _L21:
 
 add sp, 6
 pop bp
 ret
delete_word endp

copy proc
 push bp
 mov bp, sp
 a1 equ bp+4
 a2 equ bp+6
 
 mov ax, [a1]
 mov bx, [a2]
 .l9:
 mov di, ax
 mov dh, [di]
 mov di, bx
 mov [di], dh
 inc ax
 inc bx
 
 cmp dh, 0
 jne .l9
 
 pop bp
 ret
copy endp

find proc
 ; функция ищет в строке а1 подстроку а2
 ; и возвращает индекс подстроки
 push bp
 mov bp, sp
 sub sp, 2
 
 a1 equ bp+4
 a2 equ bp+6
 
 buf16 equ bp-2
 mov ax, [a1]
 mov [buf16], ax
 dec [buf16]
 _L17:
 inc [buf16]
 mov ax, [buf16]
 mov bx, [a2]
 _L19:
 mov di, ax
 mov dh, [di]
 mov di, bx
 mov dl, [di]
 inc ax
 inc bx
 cmp dl, 0
 je _L20
 cmp dh, 0
 je _L18
 cmp dh, dl
 je _L19
 jne _L17
 _L20:
 mov bx, ax
 sub bx, [buf16]
 dec bx
 mov ax, [buf16]
 sub ax, [a1]
 add sp, 2
 pop bp
 ret
 _L18:
 mov ax, -1
 
 add sp, 2
 pop bp
 ret
find endp

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


find_any_word proc
 push bp
 mov bp, sp
 
 a1 equ bp+4
 ; функция ищет первое слово 
 ; в строке а1 и возвращает 
 ; индекс и размер слова в строке а1
 ; если слово не найдено, возвращается 0
 mov ax, [a1]
 
 .l16:          ;  
 mov di, ax     ;
 mov dh, [di]   ;
 inc ax         ;
 cmp dh, 32     ;   пропустить пробелы
 je .l16        ;
 cmp dh, 0      ;
 je .l17        ;
 dec ax         ;
 
 mov bx, ax     ; ax - индекс слова в строке
 .l18:
 inc bx         ;
 mov di, bx     ;
 mov dh, [di]   ;
 
 cmp dh, 32     ;
 je .l19        ; 
 cmp dh, 0      ;
 je .l19        ;
 
 jmp .l18
 .l19:
 sub bx, ax
 
 pop bp
 ret
 .l17:
 mov ax, 0
 mov bx, 0
 
 pop bp
 ret
find_any_word endp


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
 ._ll10:
 
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
 je ._ll10
 
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
 
 jmp ._ll10     ; вернуться в ._l10
 
 
 
 ._l12:
 mov ax, [a1]
 mov bx, [buf0] 
 cmp ax, bx ; eсли указатель в начале строки, то 
 je ._ll10   ; вернуться в ._l10
 
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
 
 jmp ._ll10   ; вернуться в ._l10
 
 ._l14:
 mov ah, 07h ;
 int 21h     ; выполняется до тех пор, 
 cmp al, 8   ; пока не нажата кнопка backspace
 je ._l12    ; если нажата кнопка enter, 
 cmp al, 13  ; то вывести новую линию 
 je ._l15    ; записать 0 в конец строки и завершить
 
 jmp ._l14
 
 ._l15:
 
 call newline ; вывести новую линию
 
 mov di, [a1]
 mov [di], byte ptr 0 ; записать 0 в конец строки
  
 add sp, 2 ;
 pop bp    ; завершить подпрограмму, освободить стек
 ret       ;  
 
input endp

.data
buffer1 db 201 dup(0) 
buffer2 db 201 dup(0)
buffer3 db 201 dup(0)

__buf0 dw 201 dup (0)

msg0 db 'Enter a string: ', 10, 0
msg1 db 'Enter a word: ', 10, 0
task_msg1 db 'Delete a word "',0 
task_msg2 db '" in the line: ', 10, 0
error_message1 db 'The word "',0
error_message2 db '" not found', 10, 0
end main
