section .bss
    buffer resb 12

section .text
    global _start

int2str:
    push ebx
    push ecx
    push edx

    mov ebx, 10
    xor ecx, ecx

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

    mov byte [esi], 0x0a
    inc eax

    pop edx
    pop ecx
    pop ebx
    ret

_start:
    mov eax, 1234567
    mov esi, buffer
    call int2str

    mov edx, eax
    mov ecx, buffer
    mov ebx, 1
    mov eax, 4
    int 0x80

    mov eax, 1
    int 0x80
