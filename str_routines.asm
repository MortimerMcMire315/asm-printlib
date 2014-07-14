segment .data
    errorstr:       db      "Critical error. Aborting.",0xA,0

segment .text
    global str_len
    global capitalize
    extern malloc
    extern print_string
    extern print_nl
    extern print_char_from_val
    extern print_char_from_ptr

;Given a string address in EAX
;Returns string length in EAX
str_len:
                push    ebx
                mov     ebx, 0

  strlenloop:   
                add     ebx, 1
                add     eax, 1
                cmp     dword [eax], 0
                jne     strlenloop

                mov     eax, ebx

                pop     ebx
                ret

capitalize:
                mov     ebx, eax    ; ebx = eax
                call    str_len     ; eax = strlen(eax)

                add     eax,1       ;Add one byte to null-terminate

                push    dword eax   ;calling convention for malloc
                call    malloc      ;Allocate enough bytes to copy the string.
                test    eax, eax
                jz      kill_me
                add     esp,4

                push    eax         ;Save that address for later.

    caploop:    
                cmp     byte [ebx],0       ;Check if the current character is null.
                je      capend
                
                cmp     byte [ebx],97        ;Compare to ascii code 97 ('a')
                    cmovl ecx, [ebx]          ;ecx will carry the value.
                    jl capcopy

                cmp     byte [ebx],122       ;Compare to ascii code 122 ('z')
                    cmovg ecx, [ebx]          ;ecx as a temporary carrier
                    jg capcopy

                mov     edx,[ebx]             ;Move the current character into edx as a workspace.
                sub     edx,32                ;capitalize by subtracting 32
                mov     ecx, edx              ;Move new capitalized value into ecx

    capcopy:    
                mov     [eax],ecx             ;Copy the character into memory.

                add     eax,1
                add     ebx,1
                jmp     caploop

    capend:
                mov     byte [eax],0         ;Null-terminate!
                pop     eax                   ;And here's our address of the new string.
                ret

                

kill_me:
                mov     eax, errorstr
                call    print_string

                mov     eax, 1
                mov     ebx, 1
                int     0x80
