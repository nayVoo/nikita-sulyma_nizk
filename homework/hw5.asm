section .bss
    width       resd 1
    height      resd 1
    k_ratio     resd 1
    w_minus_1   resd 1
    h_minus_1   resd 1
    mid_y       resd 1
    x_offset    resd 1
    x1          resd 1
    x2          resd 1
    char_buffer resb 1

section .data
    newline     db 0x0a
    error_msg   db "Помилка: (Ширина / Висота) не є цілим числом більше 0"
    len_error_msg equ $ - error_msg

section .text
    global _start

_start:
    mov ah, 30
    mov al, 15

    movzx ebx, ah
    movzx ecx, al
    mov [width], ebx
    mov [height], ecx

    mov eax, [width]
    xor edx, edx
    cmp dword [height], 0
    je .handle_error
    div dword [height]
    cmp edx, 0
    jne .handle_error
    cmp eax, 0
    je .handle_error
    mov [k_ratio], eax

    mov ebx, [width]
    mov ecx, [height]
    dec ebx
    dec ecx
    mov [w_minus_1], ebx
    mov [h_minus_1], ecx

    mov eax, [height]
    shr eax, 1
    mov [mid_y], eax

    xor ebp, ebp
.y_loop:
    mov ecx, [height]
    cmp ebp, ecx
    jge .y_loop_end

    mov eax, ebp
    cmp eax, [mid_y]
    jle .top_half

.bottom_half:
    mov eax, [h_minus_1]
    sub eax, ebp

.top_half:
    mul dword [k_ratio]
    mov [x1], eax
    mov edx, [w_minus_1]
    sub edx, eax
    mov [x2], edx

    xor edi, edi
.x_loop:
    mov ebx, [width]
    cmp edi, ebx
    jge .x_loop_end

    cmp ebp, 0
    je .print_star
    cmp ebp, [h_minus_1]
    je .print_star
    cmp edi, 0
    je .print_star
    cmp edi, [w_minus_1]
    je .print_star

    mov eax, [x1]
    cmp edi, eax
    je .print_star
    mov eax, [x2]
    cmp edi, eax
    je .print_star

.print_space:
    mov al, ' '
    call print_char
    jmp .x_loop_next

.print_star:
    mov al, '*'
    call print_char

.x_loop_next:
    inc edi
    jmp .x_loop
.x_loop_end:
    call print_newline
    inc ebp
    jmp .y_loop
.y_loop_end:
    call exit

.handle_error:
    mov ecx, error_msg
    mov edx, len_error_msg
    call print
    call print_newline
    call exit

print:
    pusha
    mov eax, 4
    mov ebx, 1
    int 0x80
    popa
    ret

print_char:
    mov [char_buffer], al
    pusha
    mov eax, 4
    mov ebx, 1
    mov ecx, char_buffer
    mov edx, 1
    int 0x80
    popa
    ret

print_newline:
    pusha
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    popa
    ret

exit:
    mov eax, 1
    int 0x80
    ret
