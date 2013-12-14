
segment .data
        nl:      db      0xA
        nl_len:  equ     $-nl
        reg_a:   db      "EAX: ",0
        reg_b:   db      "EBX: ",0
        reg_c:   db      "ECX: ",0
        reg_d:   db      "EDX: ",0
            
segment .bss
        to_print:   resb 1
        data_save:  resd 1

segment .text
        global print_char_from_val
        global print_nl
        global print_char_from_ptr
        global print_string
        global print_signed_dec_int
        global print_unsigned_bin_int
        global dump_regs

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
            
            ret
            
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
                push    dword eax
                push    dword ebx   ;save whatever is in ebx
                
        l1:     call    print_char_from_ptr  ;cout<<*eax;
                add     eax, 1       ;eax++
                mov     bl, [eax]   ;ebx = eax
                cmp     bl, 0       ;if (ebx != 0) {  //Strings are null-terminated!
                jne     l1          ;   goto label
                                    ;}
                pop     ebx         ;restore ebx
                pop     eax

                ret                 ;return

print_signed_dec_int:
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
                neg     eax
                
  realbegin:    mov     ecx, 0      ;ecx will be our counter
                mov     ebx, 10     ;keep dividing by 10

    divloop:    cdq                 ;extend eax into edx.
                div    ebx         ;signed division... quotient goes
                                    ;into eax, remainder goes into edx.
                push    dword edx   ;push the decimal LSD (heh) onto the stack
                add     ecx, 1      ;increment ecx
                cmp     eax, 0
                jne     divloop
                
    prntloop:   pop     eax         ;pop the LSD into eax
                
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

print_unsigned_bin_int:
                push    dword eax
                push    dword ebx
                push    dword ecx
                push    dword edx
                mov     ebx, 31
                
  binprntloop:  rol     eax, 1
                jc      print_1

   print_0:     push    eax
                mov     eax, 48
                call    print_char_from_val
                pop     eax
                jmp     endprintbin
   
   print_1:     push    eax
                mov     eax, 49
                call    print_char_from_val
                pop     eax
                jmp     endprintbin

   endprintbin: push    eax
                mov     eax, ebx
                mov     ecx, 8
                cdq
                div     ecx
                cmp     edx,0
                jne     noprintspace
                mov     eax,32
                call    print_char_from_val
                
  noprintspace: pop     eax
                dec     ebx
                cmp     ebx,0
                jge     binprntloop

                pop     edx
                pop     ecx
                pop     ebx
                pop     eax

                ret

dump_regs:
                push    eax
                
                push    eax
                mov     eax,reg_a
                call    print_string
                pop     eax
                call    print_unsigned_bin_int

                call    print_nl
                
                mov     eax,reg_b
                call    print_string
                mov     eax,ebx
                call    print_unsigned_bin_int

                call    print_nl

                mov     eax,reg_c
                call    print_string
                mov     eax,ecx
                call    print_unsigned_bin_int
                
                call    print_nl

                mov     eax,reg_a
                call    print_string
                mov     eax,edx
                call    print_unsigned_bin_int
                
                call    print_nl

                pop     eax
                
                ret
