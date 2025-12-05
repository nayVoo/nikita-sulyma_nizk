section .data
    ; Исходный массив
    src_array dd 5, 2, 9, 1, 55, 12, 0, 8
    ELEMENT_COUNT equ 8
    ELEMENT_SIZE equ 4

    msg_orig db "Original: ",0
    msg_sorted db "Sorted: ",0
    newline db 0x0a

section .bss
    dest_array resd ELEMENT_COUNT
    print_buf resb 12

section .text
    global _start

_start:
    ; --- Копируем и сортируем массив ---
    mov esi, src_array
    mov edi, dest_array
    mov ecx, ELEMENT_COUNT
    mov ebx, ELEMENT_SIZE
    call sort_array

    ; --- Печатаем исходный массив ---
    mov esi, src_array
    mov ecx, ELEMENT_COUNT
    mov ebx, ELEMENT_SIZE
    mov edx, msg_orig
    call print_string
    call print_array
    call print_newline

    ; --- Печатаем отсортированный массив ---
    mov esi, dest_array
    mov ecx, ELEMENT_COUNT
    mov ebx, ELEMENT_SIZE
    mov edx, msg_sorted
    call print_string
    call print_array
    call print_newline

    ; --- Завершение ---
    mov eax, 1
    xor ebx, ebx
    int 0x80

; ---------------------------
; Функция сортировки (пузырьком)
; Вход:
;   ESI - исходный массив
;   EDI - целевой массив
;   ECX - количество элементов
;   EBX - размер элемента (только 4 байта)
; ---------------------------
sort_array:
    pusha
    ; Копируем массив
    mov eax, ecx
.copy_loop:
    cmp eax, 0
    je .copy_done
    mov edx, [esi]
    mov [edi], edx
    add esi, 4
    add edi, 4
    dec eax
    jmp .copy_loop
.copy_done:

    ; Bubble sort
    mov eax, ecx
    dec eax
.outer_loop:
    cmp eax, 0
    je .sort_done
    mov edi, dest_array
    xor edx, edx
.inner_loop:
    cmp edx, eax
    jge .inner_done
    mov ebp, [edi]
    mov esi, [edi+4]
    cmp ebp, esi
    jle .no_swap
    mov [edi], esi
    mov [edi+4], ebp
.no_swap:
    add edi, 4
    inc edx
    jmp .inner_loop
.inner_done:
    dec eax
    jmp .outer_loop
.sort_done:
    popa
    ret

; ---------------------------
; Печать массива
; ---------------------------
print_array:
    pusha
.loop:
    cmp ecx, 0
    je .done
    mov eax, [esi]
    mov edi, print_buf
    call int2str
    mov ecx, print_buf
    mov edx, eax
    call print_string
    mov ecx, newline
    mov edx, 1
    call print_string
    add esi, ebx
    dec ecx
    jmp .loop
.done:
    popa
    ret

; ---------------------------
; int2str: EAX -> строка в [EDI]
; Возвращает длину в EAX
; ---------------------------
int2str:
    pusha
    mov ebx, 10
    add edi, 12
    mov byte [edi], 0
    xor ecx, ecx
.conv_loop:
    inc ecx
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .conv_loop
    mov eax, ecx
    popa
    ret

; ---------------------------
; Печать строки в ECX, длина EDX
; ---------------------------
print_string:
    pusha
    mov eax, 4
    mov ebx, 1
    int 0x80
    popa
    ret

; ---------------------------
; Печать новой строки
; ---------------------------
print_newline:
    pusha
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    popa
    ret
