.intel_syntax noprefix
.global _start

_start:
    xor r8, r8
    call print
    mov r8, [rsp + 24]

    xor edi, edi                # Status 0
    mov eax, 60                 # exit
    syscall

print:
    mov rsi, QWORD PTR [rsp + 24]

    loop:
        cmp BYTE PTR [rsi], 0
        je end_print

        check_line:
            jmp check_new_line
        check_dash:
            jmp check_double_dash
        check_percentage:
            jmp check_double_percentage
        check_decimal:
            jmp check_decimal_mark
        check_string:
            jmp check_string_mark
        check_hex:
            jmp check_hex_mark

        print_char:
            #write(1, buffer, length)
            mov eax, 1                      # Broj syscall-a: write
            mov edi, 1                      # Prvi argument: stdout
            mov rdx, 1                      # Treći argument: broj bajtova

            syscall
            inc rsi
            jmp loop

            

check_new_line:
    cmp BYTE PTR [rsi], 92
    jne check_dash

    cmp BYTE PTR [rsi + 1], 'n'
    jne check_dash

    jmp print_new_line

check_double_dash:
    cmp BYTE PTR [rsi], 92
    jne check_percentage

    cmp BYTE PTR [rsi + 1], 92
    jne check_percentage

    inc rsi
    jmp print_char

check_double_percentage:
    cmp BYTE PTR [rsi], '%'
    jne check_decimal

    cmp BYTE PTR [rsi + 1], '%'
    jne check_decimal

    inc rsi
    jmp print_char

check_string_mark:
    cmp BYTE PTR [rsi], 37
    jne check_hex

    cmp BYTE PTR [rsi + 1], 's'
    jne check_hex

    jmp print_next_var

check_decimal_mark:
    cmp BYTE PTR [rsi], 37
    jne check_string

    cmp BYTE PTR [rsi + 1], 'd'
    jne check_string


    print_next_var:
        push rsi

        mov rsi, QWORD PTR [rsp + 40 + r8 * 8]
        inc r8  
        print_while_decimal:
            cmp BYTE PTR [rsi], 0
            je end_check_decimal_mark

            mov eax, 1
            mov edi, 1
            mov edx, 1
            syscall

            inc rsi                  
            jmp print_while_decimal

        end_check_decimal_mark:
            pop rsi
            add rsi, 2                  
            jmp loop



print_new_line:
    push rsi                   # Sacuvaj pokazivac na string
    sub rsp, 8                 # Rezerviši prostor
    mov BYTE PTR [rsp], 10      # Newline bajt

    mov rsi, rsp               # Adresa newline bajta
    mov eax, 1
    mov edi, 1
    mov edx, 1
    syscall

    add rsp, 8
    pop rsi
    add rsi, 2                 
    jmp loop

check_hex_mark:
    cmp BYTE PTR [rsi], 92       # '\'
    jne print_char

    cmp BYTE PTR [rsi + 1], 'x'
    jne print_char

    push rax
    push r8

    movzx eax, BYTE PTR [rsi + 2]
    call hex_digit

    mov r8d, eax                

    movzx eax, BYTE PTR [rsi + 3]
    call hex_digit

    shl r8d, 4
    or r8d, eax                 # prva * 16 + druga

    push rsi
    sub rsp, 8
    mov BYTE PTR [rsp], r8b

    mov rsi, rsp
    mov eax, 1
    mov edi, 1
    mov edx, 1
    syscall

    add rsp, 8
    pop rsi
    pop r8
    pop rax

    add rsi, 4                  
    jmp loop


hex_digit:
    cmp eax, '0'
    jb invalid_hex
    cmp eax, '9'
    jbe decimal_digit

    cmp eax, 'a'
    jb check_uppercase
    cmp eax, 'f'
    jbe lowercase_digit

check_uppercase:
    cmp eax, 'A'
    jb invalid_hex
    cmp eax, 'F'
    ja invalid_hex

    sub eax, 'A'
    add eax, 10
    ret

lowercase_digit:
    sub eax, 'a'
    add eax, 10
    ret

decimal_digit:
    sub eax, '0'
    ret

invalid_hex:
    mov eax, -1
    ret


end_print:
    ret


