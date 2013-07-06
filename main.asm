segment .data
        test_str   db      "I do not know how long this string is, and that is an okay thing.", 0

segment .text
        extern print_nl
        extern print_string
        extern print_char_from_val
        extern print_signed_int_val
        extern print_n_fib_nums
        global main

main:
        enter   0,0
        
        mov     eax, -124578
        
        call    print_signed_int_val
        call    print_nl

        mov     ebx, 0          ;exit code = 0 (normal)
        mov     eax, 1          ;exit command
        int     0x80            ;ask for interrupt at 0x80
