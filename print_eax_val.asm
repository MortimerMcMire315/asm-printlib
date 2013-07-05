segment .bss
    to_print:   resb 1
    data_save:  resd 1

segment .text
        global print_string
        global print_char_from_val
        global print_char_from_ptr
        global print_signed_int_val

print_char_from_val:
        push    dword ebx
        push    dword ecx
        push    dword edx
        push    dword eax

        mov     [to_print], eax
        mov     eax, 4
        mov     ebx, 1
        mov     ecx, to_print
        mov     edx, 1
        int     0x80

        pop     eax
        pop     edx
        pop     ecx
        pop     ebx
        
;PRE: An ASCII character pointer will be given in eax
;POST: The character will be printed to stdout.
print_char_from_ptr:
        push    dword ebx
        push    dword ecx
        push    dword edx

        ;eax is an int*
        mov     ecx, eax    ;ecx = eax
        mov     eax, 4      ;sys_write
        mov     ebx, 1      ;to stdout (whatever is in ecx)
        mov     edx, 1      ;1 byte
        int     0x80        ;kernel, please?

        mov     eax, ecx    ;eax = ecx
        pop     edx         ;restore everything we saved on the stack
        pop     ecx
        pop     ebx

        ret                 ;return
        

;PRE: An ASCII string pointer will be given in eax
;POST: Will print the string to stdout.
print_string:
                push    dword ebx   ;save whatever is in ebx
                
        l1:     call    print_char_from_ptr  ;cout<<*eax;
                add     eax, 1      ;eax++
                mov     ebx, [eax]  ;ebx = *eax
                cmp     ebx, 0      ;if (ebx != 0) {  //Strings are null-terminated!
                jne     l1          ;   goto label
                                    ;}
                pop     ebx         ;restore ebx

                ret                 ;return

print_signed_int_val:
                push    dword edx
                push    dword ecx
                push    dword ebx
                push    dword eax
                
                cmp     eax, 0      ;if eax > 0:
                jge     realbegin   ;goto realbegin. else:
                mov     ebx, eax    ;print me a '-'...
                mov     eax, 45     ;...
                call    print_char_from_val
                mov     eax, ebx
                
  realbegin:    mov     ecx, 0      ;ecx will be our counter
                mov     ebx, 10     ;keep dividing by 10

    divloop:    cdq                 ;extend eax into edx.
                idiv    ebx         ;signed division... quotient goes
                                    ;into eax, remainder goes into edx.
                push    dword edx   ;push the decimal LSD (heh) onto the stack
                add     ecx, 1      ;increment ecx
                cmp     eax, 0
                jne     divloop
                
    prntloop:   pop     eax         ;pop the LSD into eax
                cmp     eax, 0      ;if the digit is positive, goto pos
                jge     pos         
                                    ;else...
                                    ;we have a negative int. so
                neg     eax         ;negate it.
                
         pos:   add     eax, 48     ;add 48 so we can ASCII
                call    print_char_from_val
                sub     ecx, 1      ;decrement ecx
                cmp     ecx, 0      ;check if ecx = 0
                jne     prntloop
                
                pop     eax
                pop     ebx
                pop     ecx
                pop     edx

                ret
