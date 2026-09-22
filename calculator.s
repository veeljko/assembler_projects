.intel_syntax noprefix
.global _start
.global atoi
.global itoa

_start:
    mov r8,  [rsp + 16]         # argv[1] = "broj1"
    mov r9,  [rsp + 24]         # argv[2] = "operator"
    mov r10, [rsp + 32]         # argv[3] = "broj2"

    cmp BYTE PTR [r9], '+'
    je handle_addition

    cmp BYTE PTR [r9], '-'
    je handle_subtraction

    cmp BYTE PTR [r9], '*'
    je handle_multiply

    cmp BYTE PTR [r9], '&'
    je handle_and

    cmp BYTE PTR [r9], '|'
    je handle_or

    cmp BYTE PTR [r9], '^'
    je handle_xor

    cmp BYTE PTR [r8], '-'
    je handle_neg

    cmp BYTE PTR [r8], '~'
    je handle_flip

    mov rdi, 1
    mov rax, 60
    syscall

handle_addition:
    mov rdi, r8
    call atoi
    mov r8, rax

    mov rdi, r10
    call atoi
    add rax, r8

    sub rsp, 32                 # Bafer za rezultat
    mov rdi, rax
    mov rsi, rsp
    call itoa                   # rax = duzina

    mov rdx, rax
    mov rsi, rsp
    mov edi, 1
    mov eax, 1                  # write
    syscall

    add rsp, 32

    xor edi, edi                # Status 0
    mov eax, 60                 # exit
    syscall

handle_subtraction:
    mov rdi, r8
    call atoi
    mov r8, rax

    mov rdi, r10
    call atoi
    sub r8, rax
    mov rax, r8

    sub rsp, 32                 # Bafer za rezultat
    mov rdi, rax
    mov rsi, rsp
    call itoa                   # rax = duzina

    mov rdx, rax
    mov rsi, rsp
    mov edi, 1
    mov eax, 1                  # write
    syscall

    add rsp, 32

    xor edi, edi                # Status 0
    mov eax, 60                 # exit
    syscall

handle_multiply:
    mov rdi, r8
    call atoi
    mov r8, rax

    mov rdi, r10
    call atoi
    imul rax, r8

    sub rsp, 32                 # Bafer za rezultat
    mov rdi, rax
    mov rsi, rsp
    call itoa                   # rax = duzina

    mov rdx, rax
    mov rsi, rsp
    mov edi, 1
    mov eax, 1                  # write
    syscall

    add rsp, 32

    xor edi, edi                # Status 0
    mov eax, 60                 # exit
    syscall

handle_and:
    mov rdi, r8
    call atoi
    mov r8, rax

    mov rdi, r10
    call atoi
    and rax, r8

    sub rsp, 32                 # Bafer za rezultat
    mov rdi, rax
    mov rsi, rsp
    call itoa                   # rax = duzina

    mov rdx, rax
    mov rsi, rsp
    mov edi, 1
    mov eax, 1                  # write
    syscall

    add rsp, 32

    xor edi, edi                # Status 0
    mov eax, 60                 # exit
    syscall

handle_or:
    mov rdi, r8
    call atoi
    mov r8, rax

    mov rdi, r10
    call atoi
    or rax, r8

    sub rsp, 32                 # Bafer za rezultat
    mov rdi, rax
    mov rsi, rsp
    call itoa                   # rax = duzina

    mov rdx, rax
    mov rsi, rsp
    mov edi, 1
    mov eax, 1                  # write
    syscall

    add rsp, 32

    xor edi, edi                # Status 0
    mov eax, 60                 # exit
    syscall

handle_xor:
    mov rdi, r8
    call atoi
    mov r8, rax

    mov rdi, r10
    call atoi
    xor rax, r8

    sub rsp, 32                 # Bafer za rezultat
    mov rdi, rax
    mov rsi, rsp
    call itoa                   # rax = duzina

    mov rdx, rax
    mov rsi, rsp
    mov edi, 1
    mov eax, 1                  # write
    syscall

    add rsp, 32

    xor edi, edi                # Status 0
    mov eax, 60                 # exit
    syscall

handle_neg:
    mov rdi, r9
    call atoi
    

    imul rax, -1

    sub rsp, 32                 # Bafer za rezultat
    mov rdi, rax
    mov rsi, rsp
    call itoa                   # rax = duzina

    mov rdx, rax
    mov rsi, rsp
    mov edi, 1
    mov eax, 1                  # write
    syscall

    add rsp, 32

    xor edi, edi                # Status 0
    mov eax, 60                 # exit
    syscall

handle_flip:
    mov rdi, r9
    call atoi
    

    not rax

    sub rsp, 32                 # Bafer za rezultat
    mov rdi, rax
    mov rsi, rsp
    call itoa                   # rax = duzina

    mov rdx, rax
    mov rsi, rsp
    mov edi, 1
    mov eax, 1                  # write
    syscall

    add rsp, 32

    xor edi, edi                # Status 0
    mov eax, 60                 # exit
    syscall

# rdi = adresa stringa
# rax = označen broj
atoi:
    push rdi
    push rdx
    push r8

    xor eax, eax
    xor r8d, r8d

    cmp BYTE PTR [rdi], '-'
    je atoi_negative

    cmp BYTE PTR [rdi], '+'
    jne atoi_digits
    inc rdi
    jmp atoi_digits

atoi_negative:
    mov r8d, 1
    inc rdi

atoi_digits:
    movzx edx, BYTE PTR [rdi]
    cmp edx, '0'
    jb atoi_finish
    cmp edx, '9'
    ja atoi_finish

    sub edx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rdi
    jmp atoi_digits

atoi_finish:
    test r8d, r8d
    jz atoi_return
    neg rax

atoi_return:
    pop r8
    pop rdx
    pop rdi
    ret


# rdi = oznacen broj
# rsi = adresa bafera
# rax = duzina stringa 
itoa:
    push rsi
    push rcx
    push rdx
    push r8
    push r9

    mov rax, rdi
    xor r8d, r8d                # Dužina
    xor r9d, r9d                # Broj cifara na steku

    test rax, rax
    jns itoa_positive

    mov BYTE PTR [rsi], '-'
    inc rsi
    inc r8
    neg rax

itoa_positive:
    mov ecx, 10

itoa_push:
    xor edx, edx
    div rcx
    push rdx
    inc r9

    test rax, rax
    jne itoa_push

itoa_pop:
    pop rdx
    add dl, '0'
    mov BYTE PTR [rsi], dl
    inc rsi
    inc r8

    dec r9
    jne itoa_pop

    mov BYTE PTR [rsi], 0
    mov rax, r8

    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rsi
    ret