segment .data
        hello   db      "Pointer arithmetic is great!", 0
        newline db      0xA

segment .text
        extern print_nl
        extern print_string
        extern print_char_from_val
        extern print_signed_int_val
        global main

main:
        enter   0,0
        
        mov     eax, -5235
        
        call    print_signed_int_val
        call    print_nl

        mov     ebx, 0          ;exit code = 0 (normal)
        mov     eax, 1          ;exit command
        int     0x80            ;ask for interrupt at 0x80
