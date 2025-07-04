extern malloc
extern free
extern fprintf
extern fopen
extern fclose

section .data
nullMsg db "NULL", 0		; mensaje para imprimir si el string es NULL
format db "%s", 0			; formato para imprimir un string
section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen


; strLen OK, strClone OK, strCmp NO, strDelete OK, strPrint NO

; ** String **
; strLen function to calculate the length of the string
strLen:
	push rbp			; guardar el puntero de pila
	mov rbp, rsp		; rbp = rsp
	mov rsi, 0

.contador:
	mov al, [rdi]		; al = *a

	test al, al			; si *a == 0, salgo
	je .fin				; si no, sigo

	inc rdi				; rdi++
	inc rsi				; rax++

	jmp .contador		; vuelvo a contador
	
.fin:
	mov rax, rsi		; rax = rsi
	pop rbp
	ret

	
; char* strClone(char* a)
strClone:
	push rbp			; guardar el puntero de pila
	mov rbp, rsp		; rbp = rsp

	test rdi, rdi		; si a es NULL, voy a fin
	je .fin

	push rdi			; guardo rdi 
	call strLen			; rax = strLen(a)
	pop rdi				; restauro rdi
	inc rax				; rax++
	
	push rdi			; guardo rdi 
	push rax			; guardar el tamaño de a
	call malloc			; reservo memoria para el clon
	pop rcx				; rcx = tamaño de a
	pop rdi				; restauro rdi

	mov r8, 0			; r8 valor para el loop

	.loop:						;copia cada byte
		mov sil, [rdi + r8]		;sil representa los 8 bits bajos del registro esi
		mov [rax + r8], sil		
		inc r8					;r8++
		cmp r8, rcx				;si r8 = rcx, voy a fin
		je .fin					
		jmp .loop				;continua loop
	
.fin:
	pop rbp						;restaura el puntero de pila
	ret


; int32_t strCmp(char* a, char* b)
strCmp:
	push rbp			; guardar el puntero de pila
	mov rbp, rsp		; rbp = rsp
	push rbx


	xor rax, rax		; rax = 0

	.while:
		mov al, [rdi]	; al = *a
		mov bl, [rsi]	; bl = *b

		cmp al, bl		; si *a != *b, salgo
		jne .fin_while

		cmp al, 0		; si *a == 0, salgo
		je .fin

		inc rdi			; rdi++
		inc rsi			; rsi++

		jmp .while		; vuelvo a while

	.fin_while:
		cmp al, bl		; si *a < *b, rax = -1
		jl .a_menor
		mov rax, -1		; si no, rax = 1
		jmp .fin

	.a_menor:
		mov rax, 1		; rax = 1

	.fin:
		pop rbx
		pop rbp				; estaurar el puntero de pila
		ret


; void strDelete(char* a)
strDelete:
	push rbp			; guardar el puntero de pila
	mov rbp, rsp		; rbp = rsp

	test rdi, rdi		; si a es NULL, voy a fin
	je .fin

	call free			; libero la memoria de a

.fin:
	pop rbp				; restaurar el puntero de pila
	ret


; void strPrint(char* a, FILE* pFile)
strPrint:
	push rbp			; guardar el puntero de pila
	mov rbp, rsp		; rbp = rsp

	cmp rdi, 0			; si a es NULL, salgo
	je .printear_null

	mov rdx, rdi		; rdx = a
	mov rdi, rsi		; rdi = pFile
	mov rsi, format		; rsi = format
	call fprintf		; fprintf(pFile, format, a)
	jmp .fin_de_printeo	; salgo

.printear_null:
	mov rdx, nullMsg	; rdx = nullMsg
	mov rdi, rsi		; rdi = pFile
	mov rsi, format		; rsi = format
	call fprintf		; fprintf(pFile, format, nullMsg)

.fin_de_printeo:
	pop rbp				; restaurar el puntero de pila
	ret




