segment .text
    global str_len
    global capitalize
    global lowercase
    extern mallocwrap

;Given a string address in EAX
;Returns string length in EAX
str_len:
                push    ebx
                mov     ebx, 0

 .strlenloop:
                add     ebx, 1
                add     eax, 1
                cmp     dword [eax], 0
                jne     .strlenloop

                mov     eax, ebx

                pop     ebx
                ret

lowercase:
                mov     ebx, eax    ; ebx = eax
                call    str_len     ; eax = strlen(eax)

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
                add     edx,32                ;lowercase by subtracting 32
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

capitalize:
                mov     ebx, eax    ; ebx = eax
                call    str_len     ; eax = strlen(eax)

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
