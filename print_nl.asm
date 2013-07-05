segment .data
        nl      db      0xA
        nl_len  equ     $-nl

segment .text
        global print_nl

print_nl:
        push    dword eax
        push    dword ebx
        push    dword ecx
        push    dword edx
        
        mov     eax, 4
        mov     ebx, 1
        mov     ecx, nl
        mov     edx, nl_len
        int     0x80

        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ret
