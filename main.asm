segment .data
    st:     db      "Hello World!",0

segment .text
    global main
    extern print_string
    extern print_nl
    extern str_len
    extern print_signed_dec_int
    extern print_unsigned_bin_int
    extern capitalize

main:
        mov     eax, st
        call    capitalize
        call    print_string
        call    print_nl

        mov     eax, 1
        mov     ebx, 0
        int     0x80
