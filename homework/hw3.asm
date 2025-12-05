section .data
    msg_prime       db ' is a prime number', 0x0a
    len_prime       equ $ - msg_prime

    msg_not_prime   db ' is NOT a prime number', 0x0a
    len_not_prime   equ $ - msg_not_prime

    msg_one_or_zero db '1 or 0 is NOT a prime number', 0x0a
    len_one_or_zero equ $ - msg_one_or_zero

section .bss
    buffer resb 8

section .text
    global _start

int2str_16bit:
    push ebx
    push ecx
    push edx
    push eax

    mov ebx, 10
    xor ecx, ecx

    pop eax
    xor edx, edx

.conversion_loop:
    xor edx, edx
    div ebx
    add edx, '0'
    push edx
    inc ecx
    test eax, eax
    jnz .conversion_loop

    mov eax, ecx

.store_loop:
    pop edx
    mov [esi], dl
    inc esi
    loop .store_loop

    pop edx
    pop ecx
    pop ebx
    ret

print_string:
    push eax
    push ebx
    push ecx

    mov ecx, esi
    mov ebx, 1
    mov eax, 4
    int 0x80

    pop ecx
    pop ebx
    pop eax
    ret

_start:
    mov ax, 13

    push ax
    mov esi, buffer
    call int2str_16bit
    mov edx, eax
    mov esi, buffer
    call print_string
    pop ax

    cmp ax, 2
    jl .is_not_prime_one_or_zero

    mov cx, ax
    mov bx, 2

.check_loop:
    cmp bx, cx
    jge .is_prime

    xor dx, dx
    mov ax, cx
    div bx

    cmp dx, 0
    je .is_not_prime

    inc bx
    mov ax, cx
    jmp .check_loop

.is_not_prime:
    mov esi, msg_not_prime
    mov edx, len_not_prime
    jmp .print_result

.is_prime:
    mov esi, msg_prime
    mov edx, len_prime
    jmp .print_result

.is_not_prime_one_or_zero:
    mov esi, msg_one_or_zero
    mov edx, len_one_or_zero
    jmp .print_result

.print_result:
    call print_string

    mov eax, 1
    xor ebx, ebx
    int 0x80
