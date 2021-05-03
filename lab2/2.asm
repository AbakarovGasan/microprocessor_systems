format          PE GUI 4.0
entry           start
include         '%include%\win32a.inc'
 


 
section         '.text' code readable executable
 
  start: 

mov eax, 2
mov dl, [z]
mul dl

mov [R], eax
mov eax, 1
mov dl, [x]
mul dl
mov dl, [y]
mul dl

add [R], eax
mov eax, 15
mov dl, [y]
mul dl
mov dl, [z]
mul dl

add [R], eax
add [R], 3
invoke wsprintf,result,formatd,[R],0 ; 
invoke MessageBox,0,result,empty,MB_OK ;
         invoke          ExitProcess,0                                           
                
 
 
section         '.data' data readable writeable

formatd db "2*z+x*y+15*y*z+3 = %0d; x=1, y=2, z=3 ",0 ;  
result db 256 dup(?) ; 
empty db "",0

x db 1 ;
y db 2 ; 
z db 3 ; 
R dd 0 ;  2*z+x*y+15*y*z+3; x=1, y=2, z=3

 
section         '.idata' import data readable writeable
 
library         kernel32,'KERNEL32.DLL',user32,'USER32.DLL'
 
include         'api\kernel32.inc'
include         'api\user32.inc'


