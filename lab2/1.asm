format          PE GUI 4.0
entry           start
include         '%include%\win32a.inc'
 
IDD_MAIN        equ 44

IDD_EDIT_1      equ 101
IDD_EDIT_2      equ 102
IDD_EDIT_3      equ 103

IDD_SOLVE       equ 100

 
section         '.text' code readable executable
 
  start: 
                invoke          InitCommonControlsEx                                    ;
                invoke          GetModuleHandle,0                                       ; 
                invoke          DialogBoxParam,eax,IDD_MAIN,HWND_DESKTOP,DialogProc,0   ; 
    exit:
                invoke          ExitProcess,0                                           
                
                
proc            DialogProc      hWnd,wMsg,wParam,lParam
                push            ebx esi edi                                             ; 
                cmp             [wMsg],WM_COMMAND                                       ;
                je              .wmcommand                                              ; 
                cmp             [wMsg],WM_CLOSE                                         ;
                je              .wmclose                                                ; 
                xor             eax,eax                                                 ; 
                jmp             .finish                                                 ; 

  .wmcommand:

        cmp     [wParam],BN_CLICKED shl 16 + IDD_SOLVE
        jne     .finish


        invoke  GetDlgItemText,[hWnd],IDD_EDIT_1,result,20
        invoke wsprintf,X,formatX,result,0
        invoke  GetDlgItemText,[hWnd],IDD_EDIT_2,result,20
        invoke wsprintf,Y,formatY,result,0
        invoke  GetDlgItemText,[hWnd],IDD_EDIT_3,result,20
        invoke wsprintf,M,formatM,result,0




        ._l1:

         mov [C], 0
         cinvoke atoi, X
         add [C], eax
         cinvoke atoi, Y
         add [C], eax
         cinvoke atoi, M
         add [C], eax



        invoke wsprintf,result,formatR,X,Y,M,[C],0
        invoke MessageBox,0,result,empty,MB_OK ;


  .wmclose:                                                                             ; 
                invoke          EndDialog,[hWnd],0                                      ; 
  .done:
                mov             eax,1                                                   ;
  .finish:
                pop             edi esi ebx                                             ;
                ret



endp
 
section         '.data' data readable writeable

formatR db "%s + %s + %s = %0d",0
formatX db "42%s2",0
formatY db "4%s2",0
formatM db "2%s2",0
empty db "",0
result rb 256

X rb 20
Y rb 20
M rb 20

C dd 0
 
flags           dd              ?

editOutput      rb 256
                db 0
 

 
section         '.idata' import data readable writeable
 
library         kernel32,'KERNEL32.DLL',user32,'USER32.DLL',comctl32,'COMCTL32.DLL',msvcrt,'msvcrt.dll'
 
include         'api\kernel32.inc'
include         'api\user32.inc'
include         'api\comctl32.inc'

import msvcrt,\
atoi,'atoi'
 
 
section         '.rsrc' resource data readable
 
directory       RT_DIALOG,dialogs
 
resource        dialogs,\
                IDD_MAIN,LANG_ENGLISH+SUBLANG_DEFAULT,rsrc_dialog
 
dialog          rsrc_dialog,'',70,70,70,70,WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+DS_SYSMODAL+DS_MODALFRAME+DS_CENTER,0,0,'Arial',10
  dialogitem    'STATIC','X = ',        -1,1,3,15,10,WS_VISIBLE
  dialogitem    'EDIT',  '',                  IDD_EDIT_1,16,1,40,11,WS_VISIBLE
  dialogitem    'STATIC','Y = ',        -1,1,19,15,10,WS_VISIBLE
  dialogitem    'EDIT',  '',                  IDD_EDIT_2,16,17,40,11,WS_VISIBLE
  dialogitem    'STATIC','M = ',        -1,1,36,15,10,WS_VISIBLE
  dialogitem    'EDIT',  '',                  IDD_EDIT_3,16,34,40,11,WS_VISIBLE
  dialogitem    'BUTTON',  'solve',                  IDD_SOLVE,16,50,30,11,WS_VISIBLE

enddialog
