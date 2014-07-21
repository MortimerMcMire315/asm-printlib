segment .data
    prompt:       db      '> ',0
    invalid_str:  db      'Invalid input!',0
    exit_str:     db      'exit',0
    valid:        db      '0123456789+=/- ',0
    welcome:      incbin  'data/welcome.dat'

segment .bss
    input_buffer:   resb    4096

segment .text
    global get_stdin
    global repl
    extern print_string
    extern print_signed_dec_int
    extern dump_regs
    extern print_char_from_ptr
    extern print_nl

repl:
                mov     eax, welcome
                call    print_string
                call    print_nl

    .l1:        call    draw_prompt
                call    get_stdin
                call    check_exit
                call    check_valid
                jmp     .l1

exit:
                mov     eax, 1
                mov     ebx, 0
                int     0x80

check_valid:
                mov     eax, [input_buffer]
                and     eax, 0xff
                jz      .exitnl
                mov     eax, input_buffer-1

    .l1:        mov     ebx, valid-1    ;Reset validity string
                inc     eax             ;Move to the next character in input.


        .l2:        mov     edi, eax   ;Prepare for single-byte compare
                    inc     ebx        ;Next character in the set of valid characters.
                    mov     esi, ebx   ;Prepare for single-byte compare

                    cmp     byte [esi], 0  ;If we've hit the end of valid characters,
                    je      .invalid       ;The input was invalid.

                    cmpsb              ;Compare single byte ESI/EDI
                    jne     .l2

                cmp     byte [edi], 0xA
                je      .valid
                cmp     byte [edi], 0
                je      .valid
                jmp     .l1

    .invalid:
                mov     eax, invalid_str
                call    print_string
                call    print_nl
                mov     eax, 0
                ret

    .valid:
                mov     eax, 1
                ret

    .exitnl:    mov     eax, exit_str
                call    print_string
                call    print_nl
                jmp     exit

check_exit:
            mov     eax, input_buffer-1
            mov     ebx, exit_str-1
    .l1:
            inc     eax
            inc     ebx

            mov     esi, ebx
            mov     edi, eax
            cmpsb             ;Compare a single byte.
            jne     .false

            cmp     byte [esi], 0   ;Check if the byte at ESI is 0 (end of string)
            jne      .l1

    .true:
            mov     eax, 1
            call    exit

    .false:
            mov     eax, 0
            ret


draw_prompt:
    mov     eax, prompt
    call    print_string

    ret

get_stdin:
    mov     eax, 3              ;read
    mov     ebx, 0              ;from stdin
    mov     ecx, input_buffer   ;to input_buffer
    mov     edx, 4096           ;4096 bytes (overkill?)
    int     0x80                ;Ask the kernel

    mov     byte [ecx+eax], 0   ;null-terminate!

    ;mov     eax, input_buffer   ;Since stdin is null-terminated, we all good.
    ;call    print_string

    ret
