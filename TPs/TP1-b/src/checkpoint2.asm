extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global product_9_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4:
	;prologo
	; COMPLETAR
		
	add rdi, rdx
	sub rdi, rsi
	sub rdi, rcx


	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	mov rax, rdi
; COMPLETAR
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp

	call restar_c ;a = hago x1 - x2

	mov rdi, rdx 
	mov rsi, rcx

	mov rdx, rax

	call restar_c ;b = hago x3 - x4

	mov rdi, rdx ; muevo a rdi a
	mov rsi, rax ; muevo a rsi b

	call sumar_c ; a + b

	; COMPLETAR

	;epilogo
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_simplified:
	push rbp
	mov rbp, rsp

	call alternate_sum_4
	
	pop rbp
	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[pila], x8[pila]
alternate_sum_8:
	;prologo
	push rbp
	mov rbp, rsp

	call alternate_sum_4

	mov rdi, r8
	mov rsi, r9

	mov rdx, [rbp + 0x10]
	mov rcx, [rbp + 0x18]

	mov r8, rax

	call alternate_sum_4

	add rax, r8

	;epilogo
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm0]
product_2_f:
    push rbp				; Guardar el puntero de pila
    mov rbp, rsp			; rbp = rsp

    cvtsi2ss xmm1, rsi     	; Convierto entero a float y lo cargo en xmm1

    mulss xmm0, xmm1       	; xmm0 = xmm0 * xmm1

    cvttss2si eax, xmm0    	; Convertir el valor en xmm0 a entero truncado y lo guardo en eax

    mov [rdi], eax         	; Guardo eax en [rdi]

    pop rbp					; Restaurar el puntero de pila
    ret						; Retornar


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[xmm0], x2[rdx], f2[xmm1], x3[rcx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[stack], f6[xmm5], x7[stack], f7[xmm6], x8[stack], f8[xmm7],
;	, x9[stack], f9[stack]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles, usando cvtsss2sd
	cvtss2sd xmm0, xmm0
	cvtss2sd xmm1, xmm1
	cvtss2sd xmm2, xmm2
	cvtss2sd xmm3, xmm3
	cvtss2sd xmm4, xmm4
	cvtss2sd xmm5, xmm5
	cvtss2sd xmm6, xmm6
	cvtss2sd xmm7, xmm7

	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5
	mulsd xmm0, xmm6
	mulsd xmm0, xmm7

	cvtss2sd xmm1, [rbp + 6*8]
	mulsd xmm0, xmm1

	; convertimos los enteros en doubles y los multiplicamos por xmm0. usamos cvtsi2sd
	; los ultimos enteros esta en x9 rbp + 32 y x8 en rbp + 24 y x9 en rbp + 16
	
	cvtsi2sd xmm1, rsi
	cvtsi2sd xmm2, rdx
	cvtsi2sd xmm3, rcx
	cvtsi2sd xmm4, r8
	cvtsi2sd xmm5, r9

	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5

	cvtsi2sd xmm1, [rbp + 2*8]
	cvtsi2sd xmm2, [rbp + 3*8]
	cvtsi2sd xmm3, [rbp + 4*8]
	cvtsi2sd xmm4, [rbp + 5*8]
	
	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4

	movsd [rdi], xmm0
; epilogo
	pop rbp
	ret


