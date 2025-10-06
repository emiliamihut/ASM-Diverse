section .text
global sort

sort:
    ; Set up stack frame
    enter 0, 0

    ; Load n (number of nodes)
    mov ecx, [ebp + 8]
    ; Load the pointer to the node vector
    mov esi, [ebp + 12]

    ; Initialize head to NULL (will store the address of the first node)
    xor edi, edi
    ; Initialize current to NULL (current node in the constructed list)
    xor ebx, ebx

    ; Set val_curent to 1 (search for the node with val = 1)
    mov edx, 1

.find_val_loop:
    ; Compare val_curent with n
    cmp edx, ecx
    ; If val_curent > n, jump to set_null_next to finalize the list
    ja .set_null_next

    ; Initialize i (index in the vector) to 0
    xor eax, eax

.search_loop:
    ; Compare i with n
    cmp eax, ecx
    jge .done

    ; Compare nod[i].val with val_curent
    cmp dword [esi + eax*8], edx
    je .found_node

    ; Increment i
    inc eax
    jmp .search_loop

.found_node:
    ; Calculate the address of the current node: nod[i] (esi + eax*8)
    lea eax, [esi + eax*8]
    ; Check if head is NULL (first node)
    test edi, edi
    ; If head is not NULL, jump to not_first
    jne .not_first

    ; Set head to the address of the node with val = 1
    mov edi, eax
    ; Set current to the address of the node with val = 1
    mov ebx, eax
    jmp .inc_val

.not_first:
    ; Set current->next to the address of the current node
    mov [ebx + 4], eax
    ; Update current to the address of the current node
    mov ebx, eax

.inc_val:
    ; Increment val_curent
    inc edx
    jmp .find_val_loop

.set_null_next:
    ; Check if current is NULL
    test ebx, ebx
    ; If current is NULL, jump to done
    jz .done
    ; Set current->next to NULL
    mov dword [ebx + 4], 0

.done:
    ; Move head to eax for return
    mov eax, edi
    ; Clean up stack frame
    leave
    ret