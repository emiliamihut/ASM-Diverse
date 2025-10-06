%include "../include/io.mac"

extern printf
global remove_numbers

section .data
	fmt db "%d", 10, 0

section .text

; function signature: 
; void remove_numbers(int *a, int n, int *target, int *ptr_len);

remove_numbers:
	;; DO NOT MODIFY
	push    ebp
	mov     ebp, esp
	pusha

	mov     esi, [ebp + 8] ; source array
	mov     ebx, [ebp + 12] ; n
	mov     edi, [ebp + 16] ; dest array
	mov     edx, [ebp + 20] ; pointer to dest length

	;; DO NOT MODIFY
   

	;; Your code starts here
	
	xor 	ecx, ecx
	
loop_st:
	cmp ebx, 0
	jz loop_end
	
	mov     eax, [esi]
	test    eax, 1 ;; check if odd
	jnz     next

	;; check if power of 2
	sub     eax, 1
	and     eax, [esi]
	jz     next

	mov    eax, [esi]
	mov    [edi +  ecx * 4], eax
	inc    ecx

next:
	dec    ebx
	add    esi, 4
	jmp	loop_st

loop_end:
	mov     [edx], ecx
	;; Your code ends here
	;; DO NOT MODIFY

	popa
	leave
	ret
	
	;; DO NOT MODIFY
