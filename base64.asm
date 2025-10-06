%include "../include/io.mac"

extern printf
global base64

section .data
	alphabet db 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
	fmt db "%d", 10, 0

section .text

base64:
	;; DO NOT MODIFY
	push ebp
	mov ebp, esp
	pusha

	mov esi, [ebp + 8]          ; source array
	mov ebx, [ebp + 12]         ; n
	mov edi, [ebp + 16]         ; dest array
	mov edx, [ebp + 20]         ; pointer to dest length
	;; DO NOT MODIFY

	; -- Your code starts here --
	xor eax, eax                ; dest_length = 0
	xor ecx, ecx                ; i = 0 (index for source array)
	dec ebx                     ; n = n - 1 (to handle 3-byte groups)

base64_loop:
	cmp ecx, ebx                ; if i >= n-1, stop
	jge base64_end

	push eax
	push ebx

	; Combine the 3 bytes into a 24-bit value in eax
	xor eax, eax                ; Clear eax
	mov al, [esi + ecx]         ; First byte
	shl eax, 8                  ; Shift left 8 bits
	mov al, [esi + ecx + 1]     ; Second byte
	shl eax, 8                  ; Shift left 8 bits
	mov al, [esi + ecx + 2]     ; Third byte

	mov bl, [esi + ecx + 1]     ; Load second byte into bl

	; First 6 bits
	mov ebx, eax
	shr ebx, 18                 ; Get first 6 bits
	and ebx, 0x3F               ; Mask to 6 bits
	movzx ebx, byte [alphabet + ebx] ; Get Base64 char
	mov [edi], bl               ; Store at [edi + j]

	; Second 6 bits
	mov ebx, eax
	shr ebx, 12
	and ebx, 0x3F
	movzx ebx, byte [alphabet + ebx]
	mov [edi+1], bl

	; Third 6 bits
	mov ebx, eax
	shr ebx, 6
	and ebx, 0x3F
	movzx ebx, byte [alphabet + ebx]
	mov [edi+2], bl

	; Fourth 6 bits
	mov ebx, eax
	and ebx, 0x3F
	movzx ebx, byte [alphabet + ebx]
	mov [edi+3], bl

	; Update indices
	add ecx, 3                  ; Move to next 3 bytes in source
	add edi, 4                  ; Move to next 4 bytes in destination
	pop ebx
	pop eax
	;; Increment length by 4
	add eax, 4
	jmp base64_loop

base64_end:
	; Store length in dest length pointer
	mov [edx], dword eax
	; -- Your code ends here --

	;; DO NOT MODIFY
	popa
	leave
	ret
	;; DO NOT MODIFY