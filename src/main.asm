segment .data
    st:     db      'Hello World!',0

segment .bss
    buf:    resb    4096

segment .text
    global main
    extern print_string
    extern print_char_from_ptr
    extern capitalize
    extern dump_regs
    extern get_stdin
    extern REPL

main:
        call    REPL

cap_stdin:

   .l1:
        mov     eax, 3
        mov     ebx, 0
        mov     ecx, buf
        mov     edx, 1
        int     0x80

        cmp     eax, 0     ;Is the last (least significant) byte a newline? If so, exit.
        jle     .end

        mov     eax, ecx
        call    capitalize
        call    print_char_from_ptr
        jmp     .l1

  .end:
        ret
