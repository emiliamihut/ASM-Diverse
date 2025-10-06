section .text
global kfib
; kfib(n, k) computes the k-Fibonacci number for n with respect to k
; kfib(n, k) = 0 if n < k
; kfib(n, k) = 1 if n == k and implicitly if n == k + 1
; kfib(n, k) = 2 * kfib(n-1, k) - kfib(n-k-1, k) if n > k + 1
kfib:
    ; Set up stack frame
    enter 0, 0

    ; Save registers
    push ebx
    push edx

    ; Load n from stack into ebx
    mov ebx, [ebp + 8]
    ; Load k from stack into edx
    mov edx, [ebp + 12]
    ; Compare n with k
    cmp ebx, edx
    ; If n < k, return 0
    jl .lower
    ; If n == k, return 1
    je .equal
    ; Increment edx to check n == k + 1
    inc edx
    ; Compare n with k + 1
    cmp ebx, edx
    ; If n == k + 1, return 1
    je .equal
    ; Restore edx to original k
    dec edx
    ; Prepare n-1 for first recursive call
    mov ecx, ebx
    dec ecx
    ; Push parameters: k, n-1 for kfib(n-1, k)
    push edx
    push ecx
    ; Call kfib(n-1, k)
    call kfib
    ; Clean up stack
    add esp, 8
    ; Multiply result of kfib(n-1, k) by 2
    shl eax, 1
    ; Save 2 * kfib(n-1, k) in edi
    mov edi, eax
    ; Save 2 * kfib(n-1, k) on stack
    push edi
    ; Prepare n-k-1 for second recursive call
    mov ecx, ebx
    sub ecx, edx
    dec ecx
    ; Push parameters: k, n-k-1 for kfib(n-k-1, k)
    push edx
    push ecx
    ; Call kfib(n-k-1, k)
    call kfib
    ; Clean up stack
    add esp, 8
    ; Restore 2 * kfib(n-1, k) from stack
    pop edi
    ; Compute kfib(n, k) = 2 * kfib(n-1, k) - kfib(n-k-1, k)
    sub edi, eax
    ; Move result to eax for return
    mov eax, edi
    ; Jump to end
    jmp .done
.lower:
    ; Return 0 when n < k
    mov eax, 0
    ; Jump to end
    jmp .done
.equal:
    ; Return 1 when n == k or n == k + 1
    mov eax, 1
.done:
    ; Restore registers
    pop edx
    pop ebx
    ; Clean up stack frame
    leave
    ret