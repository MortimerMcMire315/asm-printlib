segment .text
    global strlen
    global capitalize
    global lowercase
    global reversecopy
    global strcopy
    extern mallocwrap
    extern dump_regs
    extern print_signed_dec_int
    extern print_nl
    extern print_string

;Given a string address in EAX
;Returns string length in EAX
strlen:
                push    ebx
                mov     ebx, 0

    .loooop:
                add     ebx, 1
                add     eax, 1
                cmp     byte [eax], 0
                jne     .loooop

                mov     eax, ebx

                pop     ebx
                ret

lowercase:
                mov     ebx, eax    ; ebx = eax
                call    strlen     ; eax = strlen(eax)

                add     eax,1       ;Add one byte to null-terminate

                call    mallocwrap  ;eax = malloc(eax) (so eax is now an address, not a size.)

                push    eax         ;Save that address for later.

    .loop:
                cmp     byte [ebx],0       ;Check if the current character is null.
                je      .end

                cmp     byte [ebx],65         ;Compare to ascii code 65 ('A')
                    cmovl ecx, [ebx]          ;ecx will carry the value.
                    jl .copy

                cmp     byte [ebx],90         ;Compare to ascii code 90 ('Z')
                    cmovg ecx, [ebx]          ;ecx as a temporary carrier
                    jg .copy

                mov     edx,[ebx]             ;Move the current character into edx as a workspace.
                add     edx,32                ;lowercase by adding 32
                mov     ecx, edx              ;Move new lowercased value into ecx

    .copy:
                mov     [eax],ecx             ;Copy the character into memory.

                add     eax,1
                add     ebx,1
                jmp     .loop

    .end:
                mov     byte [eax],0         ;Null-terminate!
                pop     eax                   ;And here's our address of the new string.
                ret

capitalize:
                mov     ebx, eax    ; ebx = eax
                call    strlen     ; eax = strlen(eax)

                add     eax,1       ;Add one byte to null-terminate

                call    mallocwrap  ;eax = malloc(eax) (so eax is now an address, not a size.)

                push    eax         ;Save that address for later.

    .loop:
                cmp     byte [ebx],0       ;Check if the current character is null.
                je      .end

                cmp     byte [ebx],97        ;Compare to ascii code 97 ('a')
                    cmovl ecx, [ebx]          ;ecx will carry the value.
                    jl .copy

                cmp     byte [ebx],122       ;Compare to ascii code 122 ('z')
                    cmovg ecx, [ebx]          ;ecx as a temporary carrier
                    jg .copy

                mov     edx,[ebx]             ;Move the current character into edx as a workspace.
                sub     edx,32                ;capitalize by subtracting 32
                mov     ecx, edx              ;Move new capitalized value into ecx

    .copy:
                mov     [eax],ecx             ;Copy the character into memory.

                add     eax,1
                add     ebx,1
                jmp     .loop

    .end:
                mov     byte [eax],0         ;Null-terminate!
                pop     eax                   ;And here's our address of the new string.
                ret

;Given a string address in EAX, return a pointer to a reversed version of the string
reversecopy:
            mov     ebx, eax                ;ebx contains the old string address.
            call    strlen
            mov     ecx, eax                ;ecx contains the string length.
            add     eax, 1                  ;add a byte for null termination
            call    mallocwrap              ;eax contains a new address to use.

            add     ecx, eax                ;ecx points to the end of the new memory space.
                                            ;ecx will move backward through the new memory space.
            mov     byte [ecx], 0           ;First, null-terminate.

    .l1:
            cmp     ecx, eax                ;If ecx is at the beginning of the new memory space, break.
              je      .end
            dec     ecx

            mov     esi, ebx
            mov     edi, ecx
            movsb                           ;Copy a single byte from ebx to ecx.

            inc     ebx                     ;Move ebx up a byte.
            jmp     .l1                     ;loop back.

    .end:
            ret

strcopy:
            mov     ebx, eax                ;ebx gets the old address.
            call    strlen
            mov     ecx, eax                ;ecx gets string length.
            add     eax, 1                  ;1byte for null termination.
            call    mallocwrap              ;eax gets a new address to use.

            push    eax

            add     ecx, eax                ;ecx points to the end of the new memory space.

    .l1:    cmp     eax, ecx                ;If eax gets to the end of the memory space, break.
              je      .end

            mov     esi, ebx
            mov     edi, eax
            movsb

            inc     eax
            inc     ebx

            jmp     .l1

    .end:
            mov     byte [eax], 0
            pop     eax
            ret
