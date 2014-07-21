segment .data
    errorstr:       db      "Critical error - malloc failed. Aborting.",0xA,0

segment .text
    global kill_me
    global mallocwrap
    extern print_string
    extern malloc
    extern dump_regs

kill_me:
                mov     eax, errorstr
                call    print_string

                mov     eax, 1
                mov     ebx, 1
                int     0x80

;Given number of bytes to allocate
mallocwrap:
    push    dword ebx
    push    dword ecx
    push    dword edx

    push    dword eax   ;calling convention for malloc
    call    malloc      ;Allocate enough bytes to copy the string.
    test    eax, eax    ;sanity test
    jz      kill_me
    add     esp,4       ;Un-stack eax

    pop     edx
    pop     ecx
    pop     ebx
    ;eax should now point to our new memory.

    ret
