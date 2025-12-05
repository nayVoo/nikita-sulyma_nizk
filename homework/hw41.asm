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

.conv_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    push edx
    inc ecx
    test eax, eax
    jnz .conv_loop

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

factorial_iter:
    mov dx, 0
    mov cx, ax
    cmp cx, 1
    jbe .done
    mov bx, 1
.loop_fact:
    mul bx
    inc bx
    cmp bx, cx
    jle .loop_fact
.done:
    ret

_start:
    mov ax, 5       ; число для факторіалу
    mov esi, buffer
    call int2str_16bit
    mov edx, eax
    mov esi, buffer
    call print_string

    mov ax, 5
    call factorial_iter

    mov ax, ax      ; AX=результат (частина), DX=0
    mov esi, buffer
    call int2str_16bit
    mov edx, eax
    mov esi, buffer
    call print_string

    mov eax, 1
    xor ebx, ebx
    int 0x80
