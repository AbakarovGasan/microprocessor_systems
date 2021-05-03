.model small
.stack  100h
.code

main    proc
    mov ax, @data
    mov ds, ax
    
    push offset msg0     ;
    call print           ; вывод сообщения msg0 
    add sp, 2            ;  
      
    push offset pass     ;
    push 200             ;
    push offset buffer1  ; ввод строки в буфер buffer1
    call input           ;
    add sp, 6            ;
    
    push offset msg1          ;
    call print                ; вывод сообщения msg1
    add sp, 2                 ;
    
    push offset is_not_space  ;
    push 200                  ;
    push offset buffer2       ; ввод строки без пробелов в буфер buffer2
    call input                ; (buffer2 - набор букв)
    add sp, 6                 ;
    
    push offset buffer3       ;    
    push offset buffer2       ; отсортировать слова из buffer1, 
    push offset buffer1       ; содержащие набор букв buffer2
    call filter               ; и сохранить отсортированный массив
    add sp, 6                 ; в buffer 3

    push offset buffer4       ;
    push offset buffer3       ; удалить все слова из строки, 
    push offset buffer1       ; содержащиеся в массиве,
    call delete_words         ; и сохранить результат в buffer4
    add sp, 6                 ;
    
    push offset task_msg1     ; 
    call print                ;
    add sp, 2                 ; 
    push offset buffer2       ;
    call print                ; 
    add sp, 2                 ;
    push offset task_msg2     ;
    call print                ;
    add sp, 2                 ;
    push offset buffer4       ;
    call print                ;
    add sp, 2                 ;
    
    call newline
    
    exit:
    mov ax,4C00h
    int 21h 
    ret
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

delete_words proc 
 push bp
 mov bp, sp
 sub sp, 2
 
 a1 equ bp+4
 a2 equ bp+6
 a3 equ bp+8
 buf35 equ bp-2
 ;
 ; функция удаляет из строки все слова из массива а2
 ; и записывает результат в a3
 ; а1 - указатель на строку
 ; а2 - указатель на массив слов в строке
 ; а3 - новая строка
 ;
 mov di, [a2]
 mov ax, [di]
 mov [buf35], ax ; buf35 - длина массива
 add [a2], word ptr 2
 
 _L31:
 cmp [buf35], word ptr 0  ; 
 je _L32                  ; цикл (повторить buf35 раз)
 dec word ptr [buf35]     ; 
 
 mov di, [a2]             ;
 mov ax, [di]             ;  ax - индекс слова в строке
 add [a2], word ptr 2     ;
 
 mov di, [a2]             ;
 mov bx, [di]             ;  bx - длина слова
 add [a2], word ptr 2     ;
 
 mov cx, [a1]             ; cx = a1
 
 mov [a1], ax      ;
 add [a1], bx      ;  a1 = ax+bx 
 
 mov dx, [a1]      ;
 sub dx, cx        ; длина части строки от сx до индекса слова в строке 
 sub dx, bx        ;
 
 mov bx, [a3]
 add [a3], dx
 
 push dx
 push bx
 push cx
 call copyA
 add sp, 6

 jmp _L31       ; конец цикла
 
 _L32:
 
 push [a3]
 push [a1]
 call copy
 add sp, 4
 
 add sp, 2
 pop bp
 ret
delete_words endp

filter proc 
 push bp
 mov bp, sp
 sub sp, 10
 
 a1 equ bp+4
 a2 equ bp+6
 a3 equ bp+8
 
 buf1 equ bp-2
 buf2 equ bp-4
 buf3 equ bp-6
 buf4 equ bp-8
 buf5 equ bp-10
 
 ; входные данные:
 ; a1 - строка
 ; а2 - строка с заданным набором букв
 ; а3 - буффер массива, в котором будут слова, 
 ; содержащие набор букв а2
 
 push [a2]
 call strlen
 add sp, 2
 
 mov [buf3], ax
 
 mov [buf2], word ptr 0
 
 mov ax, [a3]
 add ax, 2
 mov [buf1], ax 

 J1:

 push [a1]
 call find_any_word
 add sp, 2
 
 cmp bx, 0
 je J2
 
 mov [a1], ax
 add [a1], bx
 
 mov [buf4], ax
 mov [buf5], bx
 
 push [buf3]
 push [a2]
 push bx
 push ax
 call findA
 add sp, 8
 
 cmp ax, -1
 je J1
 
 mov ax, [buf4]
 mov bx, [buf5]
 
 mov di, [buf1];
 mov [di], ax
 add di, 2
 mov [di], bx
 inc word ptr [buf2]
 add [buf1], word ptr 4
 
 jmp J1
 
 J2:
 mov di, [a3]
 mov ax, [buf2]
 mov [di], ax
 
 add sp, 10
 pop bp
 ret
filter endp

findA proc
 push bp
 mov bp, sp
 sub sp, 2
 
 a1 equ bp+4 
 a2 equ bp+6 
 a3 equ bp+8 
 a4 equ bp+10 
 buf16 equ bp-2
 
 ; функция ищет в строке а1 подстроку а3
 ; и возвращает индекс подстроки
 ; a2 - размер строки а1
 ; a4 - размер строки а3
 ; если подстрока не найдена, возвращает ах=-1
 
 mov ax, [a1]  ; 
 add [a2], ax  ; a2 указывает на конец строки а1
 mov ax, [a3]  ;
 add [a4], ax  ; a4 указывает на конец строки а3
 
 mov ax, [a1]     ;
 mov [buf16], ax  ;
 dec [buf16]      ; 
 
 _L17_:
 inc [buf16]
 mov ax, [buf16]
 mov bx, [a3]
 _L19_:
 
 mov di, ax
 mov dh, [di]
 mov di, bx
 mov dl, [di]
 
 cmp [a4], bx
 je _L20_
 cmp [a2], ax
 je _L18_
 
 inc ax
 inc bx
 
 cmp dh, dl
 je _L19_
 jne _L17_
 
 _L20_:
 mov bx, ax
 sub bx, [buf16]
 dec bx
 mov ax, [buf16]
 sub ax, [a1]
 
 add sp, 2
 pop bp
 ret
 _L18_:
 mov ax, -1
 
 add sp, 2
 pop bp
 ret
findA endp


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
 push bp
 mov bp, sp
 sub sp, 2
 
 a1 equ bp+4
 a2 equ bp+6
 
 buf16 equ bp-2
 ; функция ищет в строке а1 подстроку а2
 ; и возвращает индекс подстроки
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



printA proc
 push bp
 mov bp, sp
 a1 equ bp+4
 a2 equ bp+6
 
 mov cx, [a2]
 mov ah, 40h
 mov dx, [a1]
 mov bx, 1
 int 21h
 
 pop bp
 ret
printA endp

print_array proc
 push bp
 mov bp, sp
 sub sp, 2
 a1 equ bp+4
 buf_ equ bp+6

 mov ax, [a1]
 mov di, ax
 mov ax, [di]
 mov [buf_], ax
 add [a1], 2
 .l2:
 cmp [buf_], 0
 je .l3
 mov bx, [a1]
 mov di, bx
 mov bx, [di]
 add [a1], 2
 mov cx, [a1]
 mov di, cx
 mov cx, [di]
 add [a1], 2
 
 dec [buf_]
 
 push cx
 push bx
 call printA
 add sp, 4 
 
 call newline
 jmp .l2 
 .l3:
 add sp, 2
 pop bp
 ret
print_array endp



.data
buffer1 db 201 dup(0) 
buffer2 db 201 dup(0)
buffer3 db 201 dup(0)
buffer4 db 201 dup(0)

__buf0 dw 201 dup (0)

msg0 db 'Enter a string: ', 10, 0
msg1 db 'Enter an set of letters: ', 10, 0
task_msg1 db 'Delete in all lines of text words containing a set of letters (', 0
task_msg2 db '): ', 10, 0
end main
