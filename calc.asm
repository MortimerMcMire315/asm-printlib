segment .data
    prompt:     db      '>',0
    valid:      db      '0123456789+=/-'

segment .bss
    input_buffer:   resb    200

segment .text
    global get_stdin
