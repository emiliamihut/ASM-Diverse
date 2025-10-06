section .text
global get_words
global sort
global comparator

extern qsort
extern strcmp
extern strlen

; int comparator(const void *a, const void *b);
comparator:
    ; Set up stack frame
    enter 0, 0

    ; Save registers
    push esi
    push edi
    push ebx

    ; Load a pointer
    mov esi, [ebp+8]
    ; Load b pointer
    mov edi, [ebp+12]

    ; Get string *a
    mov esi, [esi]
    ; Get string *b
    mov edi, [edi]

    ; Push *a for strlen
    push esi
    ; Call strlen to get length of *a
    call strlen
    ; Clean up stack
    add esp, 4
    ; Store length of *a in ebx
    mov ebx, eax

    ; Push *b for strlen
    push edi
    ; Call strlen to get length of *b
    call strlen
    ; Clean up stack
    add esp, 4
    ; Store length of *b in edx
    mov edx, eax

    ; Compare lengths
    cmp ebx, edx
    ; Jump to length_diff if lengths are not equal
    jne .length_diff

    ; Push *b for strcmp
    push edi
    ; Push *a for strcmp
    push esi
    ; Call strcmp
    call strcmp
    ; Clean up stack
    add esp, 8
    ; Jump to done to return strcmp result
    jmp .done

.length_diff:
    ; Move length of *a to eax
    mov eax, ebx
    ; Subtract length of *b from eax (length_a - length_b)
    sub eax, edx

.done:
    ; Restore registers
    pop ebx
    pop edi
    pop esi
    ; Clean up stack frame
    leave
    ret

; void sort(char **words, int number_of_words, int size);
sort:
    ; Set up stack frame
    enter 0, 0
    ; Load words (char **)
    mov esi, [ebp+8]
    ; Load number_of_words
    mov ecx, [ebp+12]
    ; Load size
    mov edx, [ebp+16]

    ; Push comparator function pointer
    push comparator
    ; Push size
    push edx
    ; Push number_of_words
    push ecx
    ; Push words
    push esi
    ; Call qsort
    call qsort
    ; Clean up stack
    add esp, 16

.done:
    ; Clean up stack frame
    leave
    ret

; void get_words(char *s, char **words, int number_of_words);
get_words:
    ; Set up stack frame
    enter 0, 0
    ; Load address of string s
    mov esi, [ebp+8]
    ; Load address of words array
    mov edi, [ebp+12]
    ; Load maximum number of words
    mov ecx, [ebp+16]

    ; Initialize word count to 0
    xor ebx, ebx
    ; in_word flag = 0 (false)
    xor edx, edx

.loop:
    ; Load current character
    mov al, [esi]
    ; If null terminator, jump to last word check
    test al, al
    jz .check_last_word

    ; Compare with delimiters
    cmp al, ' '
    je .delimiter
    cmp al, ','
    je .delimiter
    cmp al, '.'
    je .delimiter
    cmp al, '\n'
    je .delimiter

    ; Non-delimiter character
    ; Check if already inside a word
    test edx, edx
    jnz .next_char
    ; Save pointer to start of new word
    mov [edi + ebx*4], esi
    ; Increment word count
    inc ebx
    ; If reached maximum number of words, finish
    cmp ebx, ecx
    jge .done
    ; Set in_word flag to true
    mov edx, 1
    jmp .next_char

.delimiter:
    ; If current char is a delimiter
    ; Check if we are inside a word
    test edx, edx
    jz .next_char
    ; Null-terminate the current word
    mov byte [esi], 0
    ; Reset in_word flag
    mov edx, 0

.next_char:
    ; Move to next character
    inc esi
    jmp .loop

.check_last_word:
    ; If we were inside a word at string end
    test edx, edx
    jz .done
    ; Null-terminate last word
    mov byte [esi], 0
    ; Increment word count
    inc ebx

.done:
    ; Clean up stack frame
    leave
    ret