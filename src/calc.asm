segment .data
    prompt:         db      '> ',0
    invalid_str:    db      'Invalid input!',0
    exit_str:       db      'exit',0
    valid:          db      '0123456789+*/- ',0
    welcome:        incbin  'data/welcome.dat'
    PRE_INT:        equ     1
    PRE_OPR:        equ     2
    STACK_END:      equ     0xFFFFFFFF
    NUM_MODE:       equ     0
    DESC_MODE:      equ     1


segment .bss
    input_buffer:   resb    4096
    endinputf:      resd    1
    pushnum:        resd    1

segment .text
    global get_stdin
    global REPL
    extern print_string
    extern print_signed_dec_int
    extern dump_regs
    extern print_char_from_ptr
    extern print_nl
    extern is_ascii_num
    extern print_unsigned_hex_int

;===============================================================================
;   Read-Eval-Print loop for the RPN calculator.
;===============================================================================
REPL:
                mov     eax, welcome
                call    print_string
                call    print_nl

    .l1:        call    draw_prompt
                call    get_stdin
                call    check_exit
                call    check_valid_chars
                cmp     eax, 1
                jne     .l1

                call    evaluate_input
                jmp     .l1

;===============================================================================
;   Given EAX=45 and EBX='8', will return EAX=458.
;
;    PARAMETERS:
;        EAX = The "running total", a 4-byte integer.
;        EBX = An ASCII value representing a digit to tack onto the number. 
;              THIS MUST BE A CORRECT ASCII VALUE REPRESENTING A DIGIT.
;        
;    RETURNS:
;        EAX = the resulting 4-byte integer
;
;    PRESERVES: EBX ECX EDX
;===============================================================================
concat_ascii_num:
                    push    ebx
                    push    ecx
                    push    edx

                    ;Multiply by 10, add the int value of ebx
                    mov     ecx, 10
                    mul     ecx    ;EDX:EAX = EAX * ECX
                    sub     ebx, 48                    
                    add     eax, ebx

                    pop     edx
                    pop     ecx
                    pop     ebx

                    ret

;===============================================================================
;    PARAMETERS:
;        EAX = first operand
;        EBX = operator
;        EDX = second operand
;        
;    RETURNS:
;        Result in EAX.
;
;    PRESERVES: ECX
;===============================================================================
perform_operation:
                    ;We have to be very careful not to pop past the end of the stack,
                    ;in case of bad user input.
                    cmp     ebx, 43
                    je      .add
                    cmp     ebx, 45
                    je      .subtract
                    cmp     ebx, 42
                    je      .multiply
                    cmp     ebx, 47
                    je      .divide

                    ;If the operator is not recognized, it will be caught here.

       .bad_input:  mov     eax, invalid_str
                    call    print_string
                    call    print_nl
                    jmp     exit


       .add:        add     eax, edx
                    ret

       .subtract:   sub     edx, eax
                    mov     eax, edx
                    ret

       .multiply:   mul     edx
                    ret

       .divide:     
                    push    ecx
                    mov     ecx, eax
                    mov     eax, edx
                    cdq
                    idiv    ecx
                    pop     ecx
                    ret

;===============================================================================
;       Parses user input and prints the result of the RPN calculation. Errors
;       in input are handled on the fly.
;===============================================================================
evaluate_input:
                    mov     ecx, input_buffer-1
                    mov     edx, 0              ;Numbers will be parsed byte-by-byte into EDX.
                    mov     dword [pushnum], 1
                    push    STACK_END
                    
       .eat_val:    inc     ecx
                    mov     ebx, [ecx]
                    and     ebx, 0xFF

                    cmp     ebx, 0xA
                    je      .end
                    cmp     ebx, 0x0
                    je      .end

                    cmp     ebx, 0x20
                    je      .consume_space

                    mov     eax, ebx
                    call    is_ascii_num
                    cmp     eax, 1
                    je      .concat_num

                    ;otherwise, it is an operator. Just push and loop.
                    pop     eax
                    cmp     eax, STACK_END
                    je      perform_operation.bad_input
                    pop     edx
                    cmp     edx, STACK_END
                    je      perform_operation.bad_input

                    call    perform_operation
                    mov     edx, 0          ;EDX continues to signify whether we have an unpushed number.
                    push    eax             ;Push the result of the operation.
                    jmp     .eat_val
                    
                    ;--------------------------
    .concat_num:    mov     dword [pushnum], 1
                    push    eax
                    mov     eax, edx
                    call    concat_ascii_num    ;concat_ascii_num(edx, ebx)
                    mov     edx, eax
                    pop     eax
                    jmp     .eat_val
                    
                    ;--------------------------
    .consume_space: 
                    cmp     dword [pushnum], 0          ;If we don't need to push a number,
                    je      .eat_val                    ;don't push a number.

                    push    edx                         ;push it and set edx=0.
                    mov     edx, 0
                    mov     dword [pushnum], 0          ;We have pushed the number that was being built.
                    jmp     .eat_val

    .end:
                    cmp     edx, 0
                    jne     perform_operation.bad_input

                    pop     eax
                    mov     ebx, eax

                    pop     eax
                    cmp     eax, STACK_END
                    jne     perform_operation.bad_input

                    mov     eax, ebx
                    call    print_signed_dec_int
                    call    print_nl

                    ret


;===============================================================================
;    Exits with EXIT_SUCCESS
;===============================================================================
exit:
                mov     eax, 1
                mov     ebx, 0
                int     0x80

;===============================================================================
;   Reads the input buffer and finds the newline or null-terminator (whichever 
;   comes first), and returns the address of the byte preceding it (the last byte
;   in the input that we care about). 
;
;   Returns:
;        EAX = address of last character
;===============================================================================
find_input_end:
                mov     eax, input_buffer-1
        
        .loop:  inc     eax
                cmp     byte [eax], 0xA     ;al = newline?
                je      .end

                cmp     byte [eax], 0
                je      .end

                jmp     .loop

        .end:   dec     eax

                ret
                

;===============================================================================
;    Params:
;       EAX - Address of the input to check
;
;    Returns:
;       EAX = 1 if the input is made up of "valid" characters.
;===============================================================================
check_valid_chars:
                mov     al, [input_buffer]
                cmp     al, 0
                je      .exitnl
                mov     eax, input_buffer-1

    .l1:        mov     ebx, valid-1       ;Reset validity string
                inc     eax                ;Move to the next character in input.


        .l2:        mov     edi, eax       ;Prepare for single-byte compare
                    inc     ebx            ;Next character in the set of valid characters.
                    mov     esi, ebx       ;Prepare for single-byte compare

                    cmp     byte [esi], 0  ;If we've hit the end of valid characters,
                    je      .invalid       ;The input was invalid.

                    cmpsb                  ;Compare single byte ESI/EDI
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


;===============================================================================
;   Checks the input buffer to see if the user has typed 'exit'.
;
;   RETURNS:
;       EAX = 1 if the program should exit.
;===============================================================================
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


;===============================================================================
;   Draw the REPL prompt.
;===============================================================================
draw_prompt:
    mov     eax, prompt
    call    print_string

    ret


;===============================================================================
;   Consumes up to 4096 bytes from stdin and stores them in input_buffer.
;===============================================================================
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
