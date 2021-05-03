.model small
.stack  100h
.code

main    proc
    mov ax, @data
    mov ds, ax
    
    push offset msg0
    call print
    add sp, 2
    
    push offset pass
    push 200
    push offset buffer1
    call input
    add sp, 6
    
    push offset task_msg
    call print
    add sp, 2
    
    push offset buffer3
    push offset buffer2
    push offset buffer1
    call sort_words
    add sp, 6
    
    push offset buffer2
    call print
    add sp, 2
    
    call newline
    
    exit:
    mov ax,4C00h
    int 21h 
    ret
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


split proc
 push bp
 mov bp, sp
 a1 equ bp+4
 a2 equ bp+6
 sub sp, 4
 buf1 equ bp-2
 buf2 equ bp-4
 
 mov [buf2], 0
 
 mov ax, [a2]
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
 
 mov di, [buf1];
 mov [di], ax
 add di, 2
 mov [di], bx
 inc word ptr [buf2]
 add [buf1], 4
 
 jmp J1
 
 J2:
 mov di, [a2]
 mov ax, [buf2]
 mov [di], ax
 
 add sp, 4
 pop bp
 ret
endp


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

sort_words proc
 push bp
 mov bp, sp
 a1 equ bp+4
 a2 equ bp+6
 a3 equ bp+8
 sub sp, 16
 buf5 equ bp-2
 buf6 equ bp-4
 buf7 equ bp-6
 buf8 equ bp-8
 buf9 equ bp-10
 buf10 equ bp-12
 buf11 equ bp-14
 buf12 equ bp-16

 ; функция сортирует слова по ANSII коду
 push [a3]
 push [a1]
 call split
 add sp, 4
 ; [buf7] - начало массива
 ; [buf6] - длина массива
 ; [buf5] - индекс в массиве
 mov ax, [a3]
 mov [buf7], ax
 add [buf7], word ptr 2
 mov di, ax
 mov ax, [di]
 mov cl, 4
 mul cl
 mov [buf6], ax
 mov [buf5], word ptr 4
 L_6:
 mov ax, [buf5]
 mov bx, [buf6]
 cmp ax, bx
 jge L_71 ; здесь произошла ошибка 'relative jump out of range', 
 ; поэтому jump разделил на 2 команды
 cmp ax, 0
 je L_81 ; здесь тоже произошла ошибка 'relative jump out of range'
 mov cx, [buf7]
 add cx, [buf5]
 ;сравнить строки
 mov di, cx
 mov dx, [di]
 mov [buf8], dx ; [buf8] - указатель на первую строку
 add cx, 2
 ;
 mov di, cx
 mov dx, [di]
 mov [buf9], dx ; [buf9] - длина первой строки
 sub cx, 6
 ;
 mov di, cx
 mov dx, [di]
 mov [buf10], dx ; [buf10] - указатель на вторую строку
 add cx, 2
 ;
 mov di, cx
 mov dx, [di]
 mov [buf11], dx ; [buf11] - длина второй строки
 sub cx, 2
 ;
 mov [buf12], cx
 ;
 
 jmp L_72
 L_71: jmp L_7
 L_72:
 
 jmp L_82
 L_81: jmp L_8
 L_82:
 
 push [buf11]
 push [buf9]
 push [buf10]
 push [buf8]
 call strcmpA
 add sp, 8
 
 cmp ax, 0
 je L_8
 cmp ax, 1
 je L_8
 ;
 mov cx, [buf12]
 ;
 mov dx, [buf8] ; перестановка строк местами
 mov di, cx 
 mov [di], dx
 add cx, 2
 ;
 mov dx, [buf9] ; 
 mov di, cx 
 mov [di], dx
 add cx, 2
 ;
 mov dx, [buf10] ; 
 mov di, cx 
 mov [di], dx
 add cx, 2
 ;
 mov dx, [buf11] ;
 mov di, cx 
 mov [di], dx
 add cx, 2
 ;
 sub [buf5], word ptr 4
 jmp L_6
 L_8:
 add [buf5], word ptr 4
 jmp L_6
 L_7:
 
 ;;; 
 mov ax, [a3]
 mov [buf5], ax
 add [buf5], word ptr 2
 
 mov di, ax
 mov ax, [di]
 mov [buf6], ax
 
 cmp ax, 0
 je V1
 jmp V2
 
 V:
 mov cx, [a2]
 mov di, cx
 mov [di], byte ptr 32
 inc [a2]
 V2:
 mov ax, [buf5]
 mov di, ax
 mov ax, [di]
 add [buf5], word ptr 2
 
 mov bx, [buf5]
 mov di, bx
 mov bx, [di]
 add [buf5], word ptr 2
 
 mov cx, [a2]
 add [a2], bx
 
 push bx
 push cx
 push ax
 call copyA
 add sp, 6
 
 dec [buf6]
 mov ax, [buf6]
 cmp ax, 0
 jne V
 
 V1:
 mov cx, [a2]
 mov di, cx
 mov [di], byte ptr 0
 
 add sp, 16
 pop bp
 ret
sort_words endp

strcmpA proc
 push bp
 mov bp, sp
 a1 equ bp+4
 a2 equ bp+6
 a3 equ bp+8
 a4 equ bp+10
 
 ; a1 - первая строка
 ; а2 - вторая строка
 ; а3 - длина первой строки
 ; а4 - длина второй строки
 mov ax, [a3]
 mov bx, [a4]
 cmp ax, bx
 jle _l1
 mov ax, bx
 _l1:
 mov bx, [a1]
 mov cx, [a2]
 _l2:
 cmp ax, 0
 je _l4
 dec ax
 mov di, bx ; 
 mov dl, [di]
 mov di, cx
 mov dh, [di]
 cmp dl, dh
 je _l2
 _l3:
 cmp dl, dh
 jg _l5
 jl _l6
 _l4:
 mov bx, [a3]
 mov cx, [a4]
 cmp bx, cx
 jg _l5
 jl _l6
 mov ax, 0
 
 pop bp
 ret
 _l5:
 mov ax, 1
 
 pop bp
 ret
 _l6:
 mov ax, -1
 
 pop bp
 ret 
strcmpA endp

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
task_msg db 'Sort characters in the string by ASCII character code: ', 10, 0
end main
