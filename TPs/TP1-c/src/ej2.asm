section .rodata
alfa:    dd 0xFF_00_00_00, 0xFF_00_00_00, 0xFF_00_00_00, 0xFF_00_00_00
limpiar: dd 0x00_00_00_FF, 0x00_00_00_FF, 0x00_00_00_FF, 0x00_00_00_FF
un_tercio: dd 0.33333333
menos_uno: dd -1
const_192: dd 192 ; Constante 192
const_384: dd 384 ; Constante 384
const_255: dd 255
verde_salida: dd 64 ; Offset para canal verde
azul_salida: dd 128 ; Offset para canal azul

section .text
global ej2

FALSE EQU 0
TRUE  EQU 1

global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

ej2:
	push rbp
	mov rbp, rsp

	imul rdx, rcx ; r8 = width * height (cantidad total de pixeles)
	
	; Guardo los registros que voy a usar para las operaciones
	movd xmm4, [menos_uno]
	pshufd xmm4, xmm4, 0; xmm4 = -1
	movss xmm5, [un_tercio]; xmm5 = 1/3
	shufps xmm5, xmm5, 0
	movdqu xmm6, [limpiar]
	movdqu xmm7, [alfa] ; xmm7 = alfa
	movd xmm8, [const_192] ; xmm8 = const_192
	pshufd xmm8, xmm8, 0
	movd xmm10, [const_384] ; xmm10 = const_384
	pshufd xmm10, xmm10, 0
	movd xmm11, [verde_salida] ; xmm11 = verde_salida (64)
	pshufd xmm11, xmm11, 0
	movd xmm12, [azul_salida] ; xmm12 = azul_salida (128)
	pshufd xmm12, xmm12, 0
	pxor xmm13, xmm13
	movd xmm14, [const_255]; xmm14 = const_255
	pshufd xmm14, xmm14, 0

.loop:
	cmp rdx, 0
	je .fin

	movdqu xmm0, [rsi]; xmm0 = 4 pixeles (ABGR)
	
	;copio el registro xmm0 que tiene 4 pixeles
	movdqa xmm1, xmm0 ;rojo
	movdqa xmm2, xmm0 ;verde
	movdqa xmm3, xmm0 ;azul

	;reordeno los bytes para obtener cada color en un registro
	pand xmm1, xmm6 

	psrld xmm2, 8
	pand xmm2, xmm6

	psrld xmm3, 16
	pand xmm3, xmm6
	
	;calculo temperatura
	paddd xmm1, xmm2
	paddd xmm1, xmm3; xmm1 = temperatura

	; xmm1 = temperatura / 3
	cvtdq2ps xmm1, xmm1
	mulps xmm1, xmm5
	cvttps2dq xmm1, xmm1

	movdqa xmm2, xmm1
	paddd xmm2, xmm11 ; temperatura+ offset de verde
	
	movdqa xmm3, xmm1 
	paddd xmm3, xmm12 ; temperatura + offset en azul


	; Funcion temperatura:
	psubd xmm1, xmm8
	pabsd xmm1, xmm1 
	pslld xmm1, 2
	pmulld xmm1, xmm4
	paddd xmm1, xmm10
	pmaxsd xmm1, xmm13
	pminsd xmm1, xmm14 ; xmm1 = min(255, max(0, 384 - 4 * |src (r g b) - 192|)

	psubd xmm2, xmm8
	pabsd xmm2, xmm2 
	pslld xmm2, 2
	pmulld xmm2, xmm4
	paddd xmm2, xmm10
	pmaxsd xmm2, xmm13
	pminsd xmm2, xmm14 ; xmm2 = min(255, max(0, 384 - 4 * |src (r g b) - 192|)

	psubd xmm3, xmm8
	pabsd xmm3, xmm3
	pslld xmm3, 2
	pmulld xmm3, xmm4
	paddd xmm3, xmm10 
	pmaxsd xmm3, xmm13 
	pminsd xmm3, xmm14 ; xmm3 = min(255, max(0, 384 - 4 * |src (r g b) - 192|)

	pslld xmm2, 8 	; desplazo 8 bits verde
	pslld xmm3, 16  ; desplazo 16 bits azul

	por xmm1, xmm2
	por xmm1, xmm3
	por xmm1, xmm7	; rojo + verde + azul + alfa

	movdqu [rdi], xmm1; guardo los 4 pixeles modificados en dst

	;siguiente iteracion
	add rsi, 16		; avanzo 16 bytes en src
	add rdi, 16		; avanzo 16 bytes en dst
	sub rdx, 4		; resto 4 pixeles a rdx

	jmp .loop; vuelvo a iterar

.fin:
	pop rbp
	ret
