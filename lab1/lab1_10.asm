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
    
    
    push offset buffer3       ; отсортировать слова из buffer1, 
    push offset buffer1       ; содержащие только цифры
    call filter_numbers       ; и сохранить отсортированный массив
    add sp, 6                 ; в buffer 3
    
  ;  push offset buffer3
  ;  call print_array
  ;  add sp, 2
    
  ;  jmp exit

    push offset buffer4            ;
    push offset message            ;
    push offset buffer3            ; вставить перед всеми числами из строки, 
    push offset buffer1            ; содержащиеся в массиве, слово "number",
    call insert_word_after_words   ; и сохранить результат в buffer4
    add sp, 6                      ;
    
    push offset task_msg      ; 
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

insert_word_after_words proc
 push bp
 mov bp, sp
 sub sp, 6
 
 a1 equ bp+4
 a2 equ bp+6
 a3 equ bp+8
 a4 equ bp+10
 buf35 equ bp-2
 buf36 equ bp-4
 buf37 equ bp-6
; 
; функция вставляет перед всеми словами строк из массива а2 слово а3 
; а1 - строка
; а2 - массив слов в строке
; а3 - слово
; а4 - новая строка
 
 push [a3]
 call strlen
 add sp, 2
 
 mov [buf36], ax

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
 add dx, bx        ;
 sub dx, cx        ; dx - длина части строки от сx до индекса конца слова в строке 
 sub dx, bx        ;
 
 mov bx, [a4]
 add [a4], dx
 
 push dx      ;
 push bx      ;
 push cx      ; cкопировать в новую строку от
 call copyA   ; сx до индекса конца слова в строке
 add sp, 6    ;  

 push [a4]    ;
 push [a3]    ; скопировать новое слово в 
 call copy    ; новую строку
 add sp, 4    ;
 
 mov ax, [buf36]
 add [a4], ax

 jmp _L31       ; конец цикла
 
 _L32:
 
 push [a4]
 push [a1]
 call copy
 add sp, 4
 
 add sp, 6
 pop bp
 ret
insert_word_after_words endp

filter_numbers proc 
 ; входные данные:
 ; a1 - строка
 ; а2 - буффер массива, в котором будут слова, 
 ; содержащие только цифры
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
 
 push bx
 push ax
 
 call is_num
 
 mov cx, ax
 
 pop ax
 pop bx
 
 mov [a1], ax
 add [a1], bx

 cmp cx, 0
 je J1
 
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

filter_numbers endp

is_num proc
 push bp
 mov bp, sp
 
 a1 equ bp+4
 a2 equ bp+6
 ; проверяет, является ли слово номером
 ; возвращает 1 если да
 ; 0 если нет
 
 mov bx, [a2]
 mov di, [a1]
 
 __l:
 cmp bx, 0
 je ._U1
 
 mov al, [di]
 cmp al, '0'
 jl ._U2
 cmp al, '9'
 jg ._U2
 
 dec bx
 inc di
 
 jmp __l
 
 ._U1:
 mov ax, 1
 pop bp
 ret
 
 ._U2:
 mov ax, 0
 pop bp
 ret
is_num endp

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
 
 .l16l:         ;  
 mov di, ax     ;
 mov dh, [di]   ;
 inc ax         ;
 cmp dh, 32     ;   пропустить пробелы
 je .l16l       ;
 cmp dh, 0      ;
 je .l17l       ;
 dec ax         ;
 
 mov bx, ax     ; ax - индекс слова в строке
 .l18l:
 inc bx         ;
 mov di, bx     ;
 mov dh, [di]   ;
 
 cmp dh, 32     ;
 je .l19        ; 
 cmp dh, 0      ;
 je .l19        ;
 
 jmp .l18l
 .l19:
 sub bx, ax
 
 pop bp
 ret
 .l17l:
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
buffer5 db 201 dup(0)

message db ' number ', 0

fuck db '123', 0

msg0 db 'Enter a string: ', 10, 0
task_msg db 'Insert in all lines of text the word "number" before words consisting of numbers',10, 0
end main
