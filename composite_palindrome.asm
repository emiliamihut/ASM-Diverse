section .text
global check_palindrome
global composite_palindrome
global compare_str

extern malloc
extern free
extern strcat
extern strcpy
extern strlen
extern strcmp

check_palindrome:
    ; Set up stack frame
    enter 0, 0
    ; Save registers
    push esi
    push edi
    ; Load string pointer from stack
    mov esi, [ebp + 8]
    ; Load string length from stack
    mov ecx, [ebp + 12]
    ; Check if length <= 1 (single char or empty is palindrome)
    cmp ecx, 1
    ; Jump to palindrome result if true
    jle .is_palindrome
    ; Set edi to point to the string
    mov edi, esi
    ; Move edi to the last character
    add edi, ecx
    ; Adjust to point to last char (before null terminator)
    dec edi
    ; Divide length by 2 for comparison loop
    shr ecx, 1
.compare_loop:
    ; Load character from start of string
    mov al, [esi]
    ; Compare with character from end
    cmp al, [edi]
    ; If not equal, not a palindrome
    jne .not_palindrome
    ; Move to next character from start
    inc esi
    ; Move to previous character from end
    dec edi
    ; Continue loop until ecx reaches 0
    loop .compare_loop
.is_palindrome:
    ; Set return value to 1 (is palindrome)
    mov eax, 1
    ; Jump to end
    jmp .done
.not_palindrome:
    ; Clear eax to return 0 (not palindrome)
    xor eax, eax
.done:
    ; Restore saved registers
    pop edi
    pop esi
    ; Clean up stack frame
    leave
    ; Return to caller
    ret
composite_palindrome:
    ; Set up stack frame
    enter 0, 0
    ; Load pointer to array of strings
    mov esi, [ebp + 8]
    ; Load number of strings
    mov eax, [ebp + 12]
    ; Allocate 155 bytes for longest_palindrome buffer
    push 155
    ; Call malloc to allocate memory
    call malloc
    ; Clean up stack after malloc
    add esp, 4
    ; Store pointer to longest_palindrome
    mov edi, eax
    ; Initialize longest_palindrome as empty string
    mov byte [edi], 0
    ; Allocate 155 bytes for candidate buffer
    push 155
    ; Call malloc to allocate memory
    call malloc
    ; Clean up stack after malloc
    add esp, 4
    ; Store pointer to candidate
    mov ebx, eax
    ; Initialize mask to (1 << 15) - 1 = 32767
    mov edx, 32767
.loop_mask:
    ; Check if all mask combinations are done
    cmp edx, 0
    ; Exit loop if mask is 0
    je .done_loop
    ; Initialize candidate as empty string
    mov byte [ebx], 0
    ; Save current mask
    push edx
    ; Initialize index i to 0
    xor ecx, ecx
.word_loop:
    ; Check if all strings (up to 15) are processed
    cmp ecx, 15
    ; Jump to palindrome check if done
    jge .check_if_palindrome
    ; Copy mask to eax for bit checking
    mov eax, edx
    ; Shift right by cl (i) to check bit
    shr eax, cl
    ; Mask to get bit i
    and eax, 1
    ; Skip if bit i is 0
    cmp eax, 0
    ; Jump to next word if bit is 0
    je .next_word
    ; Save registers
    push edx
    push ecx
    ; Load pointer to strs[i]
    mov eax, [esi + ecx * 4]
    ; Push strs[i] for strcat
    push eax
    ; Push candidate buffer for strcat
    push ebx
    ; Concatenate strs[i] to candidate
    call strcat
    ; Clean up stack after strcat
    add esp, 8
    ; Restore registers
    pop ecx
    pop edx
.next_word:
    ; Increment index i
    inc ecx
    ; Continue word loop
    jmp .word_loop
.check_if_palindrome:
    ; Check if candidate is empty
    cmp byte [ebx], 0
    ; Skip palindrome check if empty
    je .dec_mask
    ; Save registers
    push edx
    push ecx
    ; Push candidate for strlen
    push ebx
    ; Get length of candidate
    call strlen
    ; Clean up stack after strlen
    add esp, 4
    ; Restore registers
    pop ecx
    pop edx
    ; Save registers again
    push edx
    push ecx
    ; Push length for check_palindrome
    push eax
    ; Push candidate for check_palindrome
    push ebx
    ; Check if candidate is palindrome
    call check_palindrome
    ; Clean up stack after check_palindrome
    add esp, 8
    ; Restore registers
    pop ecx
    pop edx
    ; Check if result is 0 (not palindrome)
    test al, al
    ; Skip if not palindrome
    jz .dec_mask
    ; Save registers
    push edx
    push ecx
    ; Push longest_palindrome for compare_str
    push edi
    ; Push candidate for compare_str
    push ebx
    ; Compare candidate with longest_palindrome
    call compare_str
    ; Clean up stack after compare_str
    add esp, 8
    ; Restore registers
    pop ecx
    pop edx
    ; Check if candidate is not better
    cmp eax, 0
    ; Skip copy if candidate <= longest_palindrome
    jle .dec_mask
    ; Save registers
    push edx
    push ecx
    ; Push candidate for strcpy
    push ebx
    ; Push longest_palindrome for strcpy
    push edi
    ; Copy candidate to longest_palindrome
    call strcpy
    ; Clean up stack after strcpy
    add esp, 8
    ; Restore registers
    pop ecx
    pop edx
.dec_mask:
    ; Restore mask
    pop edx
    ; Decrement mask to try next combination
    dec edx
    ; Continue mask loop
    jmp .loop_mask
.done_loop:
    ; Push candidate buffer for freeing
    push ebx
    ; Free candidate memory
    call free
    ; Clean up stack after free
    add esp, 4
    ; Set return value to longest_palindrome pointer
    mov eax, edi
    ; Clean up stack frame
    leave
    ret

compare_str:
    ; Set up stack frame
    enter 0, 0

    ; Save registers
    push ecx
    push edi
    push esi

    ; Load str1 pointer
    mov edi, [ebp + 8]
    ; Load str2 pointer
    mov esi, [ebp + 12]
    ; Push str1 for strlen
    push edi
    ; Get length of str1
    call strlen
    ; Clean up stack after strlen
    add esp, 4
    ; Store length of str1
    mov ecx, eax
    ; Save ecx
    push ecx
    ; Push str2 for strlen
    push esi
    ; Get length of str2
    call strlen
    ; Clean up stack after strlen
    add esp, 4
    ; Restore ecx
    pop ecx
    ; Compare lengths of str1 and str2
    cmp ecx, eax
    ; str1 is longer, so better
    jg .str1_better
    ; str2 is longer, so better
    jl .str2_better
    ; Save ecx
    push ecx
    ; Push str2 for strcmp
    push esi
    ; Push str1 for strcmp
    push edi
    ; Compare strings lexicographically
    call strcmp
    ; Clean up stack after strcmp
    add esp, 8
    ; Restore ecx
    pop ecx
    ; Check if str1 < str2
    cmp eax, 0
    ; str1 is lexicographically smaller
    jl .str1_better
    ; str2 is lexicographically smaller
    jg .str2_better
    ; Strings are equal
    mov eax, 0
    ; Jump to end
    jmp .done
.str1_better:
    ; Return 1 (str1 is better)
    mov eax, 1
    ; Jump to end
    jmp .done
.str2_better:
    ; Return -1 (str2 is better)
    mov eax, -1
.done:
    ; Restore registers
    pop esi
    pop edi
    pop ecx
    ; Clean up stack frame
    leave
    ret