%include "../include/io.mac"

extern printf
global check_row
global check_column
global check_box

section .data
	digit_exists db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

section .text

; int check_row(char* sudoku, int row);
check_row:
	;; DO NOT MODIFY
	push    ebp
	mov     ebp, esp
	push    ebx
	push    ecx
	push    edx
	push    esi
	push    edi

	mov     esi, [ebp + 8]      ; char* sudoku, pointer to 81-long char array
	mov     edx, [ebp + 12]     ; int row
	;; DO NOT MODIFY

	;; Initialize digit_exists[1-9] to 0
	mov     ecx, 9
	mov     edi, digit_exists
clear_digit_exists_row:
	mov     byte [edi], 0       ; Clear current digit_exists entry
	inc     edi                 ; Move to next digit_exists entry
	loop    clear_digit_exists_row

	;; Start checking the row
	xor     ebx, ebx            ; Initialize column index (0 to 8)
	mov     eax, edx
	imul    eax, 9
	add     esi, eax            ; Move to the start of the row in sudoku
	mov     edi, digit_exists

check_row_loop:
	cmp     ebx, 9
	jge     row_good            ; If reached end of row, it's good

	mov     cl, byte [esi + ebx] ; Get the value at sudoku[row * 9 + col]
	cmp     cl, 1
	jl      row_bad             ; If less than 1, it's invalid
	cmp     cl, 9
	jg      row_bad             ; If greater than 9, it's invalid

	dec     cl                  ; Convert to 0-8 for index
	mov     dl, byte [edi + ecx] ; Check if digit already exists
	cmp     dl, 0
	jne     row_bad             ; If it exists, it's invalid
	mov     byte [edi + ecx], 1 ; Mark digit as seen

	inc     ebx
	jmp     check_row_loop

row_bad:
	mov     eax, 2              ; Set EAX to 2 (incorrect)
	jmp     end_check_row

row_good:
	mov     eax, 1              ; Set EAX to 1 (correct)
end_check_row:
	;; DO NOT MODIFY
	pop     edi
	pop     esi
	pop     edx
	pop     ecx
	pop     ebx
	leave
	ret
	;; DO NOT MODIFY

; int check_column(char* sudoku, int column);
check_column:
	;; DO NOT MODIFY
	push    ebp
	mov     ebp, esp
	push    ebx
	push    ecx
	push    edx
	push    esi
	push    edi

	mov     esi, [ebp + 8]      ; char* sudoku, pointer to 81-long char array
	mov     edx, [ebp + 12]   ; int column
	;; DO NOT MODIFY

	;; Initialize digit_exists[1-9] to 0
	mov     ecx, 9
	mov     edi, digit_exists
clear_digit_exists_column:
	mov     byte [edi], 0       ; Clear current digit_exists entry
	inc     edi
	loop    clear_digit_exists_column

	;; Start checking the column
	xor     ebx, ebx            ; Initialize row index (0 to 8)
	add     esi, edx            ; Move to the start of the column in sudoku
	mov     edi, digit_exists

check_column_loop:
	cmp     ebx, 9              ; If reached end of column, it's good
	jge     column_good
	mov     eax, ebx
	imul    eax, 9               ; Calculate row offset
	mov     cl, byte [esi + eax] ; Get the value at sudoku[row * 9 + column]
	cmp     cl, 1
	jl      column_bad          ; If less than 1, it's invalid
	cmp     cl, 9
	jg      column_bad          ; If greater than 9, it's invalid

	dec     cl                   ; Convert to 0-8 for index
	mov     dl, byte [edi + ecx] ; Check if digit already exists
	cmp     dl, 0
	jne     column_bad          ; If it exists, it's invalid
	mov     byte [edi + ecx], 1 ; Mark digit as seen
	inc     ebx
	jmp     check_column_loop

column_bad:
	mov     eax, 2              ; Set EAX to 2 (incorrect)
	jmp     end_check_column
column_good:
	mov     eax, 1              ; Set EAX to 1 (correct)
end_check_column:
	;; DO NOT MODIFY
	pop     edi
	pop     esi
	pop     edx
	pop     ecx
	pop     ebx
	leave
	ret
	;; DO NOT MODIFY

; int check_box(char* sudoku, int box);
check_box:
	;; DO NOT MODIFY
	push    ebp
	mov     ebp, esp
	push    ebx
	push    ecx
	push    edx
	push    esi
	push    edi

	mov     esi, [ebp + 8]      ; char* sudoku, pointer to 81-long char array
	mov     edx, [ebp + 12]     ; int box
	;; DO NOT MODIFY

	;; Initialize digit_exists[1-9] to 0
	mov     ecx, 9
	mov     edi, digit_exists
clear_digit_exists_box:
	mov     byte [edi], 0       ; Clear current digit_exists entry
	inc     edi                 ; Move to next digit_exists entry
	loop    clear_digit_exists_box

	;; Calculate starting position of the box
	mov     eax, edx            ; box number (0-8)
	xor     edx, edx
	mov     ebx, 3
	div     ebx                 ; eax = box / 3, edx = box % 3 
	imul    eax, 27             ; Start row offset = (box / 3) * 3 * 9
	imul    edx, 3              ; Start col offset = (box % 3) * 3
	add     esi, eax            ; Add row offset to sudoku pointer
	add     esi, edx            ; Add col offset to sudoku pointer
	mov     edi, digit_exists

	;; Iterate over 3x3 box
	xor     ebx, ebx            ; Box cell index (0-8)
check_box_loop:
	cmp     ebx, 9              ; If checked all 9 cells, box is good
	jge     box_good

	;; Calculate offset within box: (ebx / 3) * 9 + (ebx % 3)
	mov     eax, ebx
	xor     edx, edx
	mov     ecx, 3
	div     ecx
	imul    eax, 9
	add     eax, edx

	mov     cl, byte [esi + eax] ; Get value at sudoku[box_start + offset]
	cmp     cl, 1
	jl      box_bad             ; If less than 1, invalid
	cmp     cl, 9
	jg      box_bad             ; If greater than 9, invalid

	dec     cl                  ; Convert to 0-8 for digit_exists index
	mov     dl, byte [edi + ecx] ; Check if digit exists
	cmp     dl, 0
	jne     box_bad             ; If it exists, it's invalid
	mov     byte [edi + ecx], 1 ; Mark digit as seen

	inc     ebx
	jmp     check_box_loop

box_bad:
	mov     eax, 2              ; Return 2 (incorrect)
	jmp     end_check_box
box_good:
	mov     eax, 1              ; Return 1 (correct)

end_check_box:
	;; DO NOT MODIFY
	pop     edi
	pop     esi
	pop     edx
	pop     ecx
	pop     ebx
	leave
	ret
	;; DO NOT MODIFY