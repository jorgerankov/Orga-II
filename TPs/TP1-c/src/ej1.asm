section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro

float_rojo dd 0.2126		; Defino los coeficientes para la conversión a escala de grises
float_verde dd 0.7152
float_azul dd 0.0722

limpiar: dd 0x00_00_00_FF, 0x00_00_00_FF, 0x00_00_00_FF, 0x00_00_00_FF,

alfa:    dd 0xFF_00_00_00, 0xFF_00_00_00, 0xFF_00_00_00, 0xFF_00_00_00

pixel_mask: dq 0xFF_01_01_01_FF_00_00_00, 0xFF_03_03_03_FF_02_02_02 
; f 4 f 0  - f c f 8

section .text
global ej1
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1
; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej1

global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.
; Convierte una imagen dada (`src`) a escala de grises y la escribe en el
; canvas proporcionado (`dst`).
;
; Para convertir un píxel a escala de grises alcanza con realizar el siguiente
; cálculo:
; ```
; luminosidad = 0.2126 * rojo + 0.7152 * verde + 0.0722 * azul 
; ```
;
; Como los píxeles de las imágenes son RGB entonces el píxel destino será
; ```
; rojo  = luminosidad
; verde = luminosidad
; azul  = luminosidad
; alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
ej1:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; rdi/m64 = rgba_t*  dst
	; rsi/m64 = rgba_t*  src
	; edx/m32 = uint32_t width
	; ecx/m32 = uint32_t height
	
	push rbp
	mov rbp, rsp

	imul rdx, rcx   ; rdx = width * height cantidad total de pixeles

	movdqu xmm4, [limpiar] ;uso xmm4 para limpiar los registros despues de los desplazamientos
	movdqu xmm5, [alfa] ;uso xmm5 para colocar alfa en cada pixel
	movdqu xmm6, [pixel_mask] ; reordeno el valor para los pixeles

	;mascaras para obtener el float de forma packed en 32 bits
	;de cada coeficiente de colores
	movss xmm7, [float_rojo]
	shufps xmm7, xmm7, 0

	movss xmm8, [float_verde]
	shufps xmm8, xmm8, 0

	movss xmm9, [float_azul]
	shufps xmm9, xmm9, 0

.loop:
	cmp rdx, 0      ; si rdx == 0, termino
	je .fin         ; salto a fin

	movdqu xmm0, [rsi]   ; rgba-rgba-rgba-rgba
	
	;copio el registro xmm0 que tiene 4 pixeles
	movdqa xmm1, xmm0 ;rojos
	movdqa xmm2, xmm0 ;verdes
	movdqa xmm3, xmm0 ;azules

	;reordeno los bytes aplicando cada mascara
	 
	pand xmm1, xmm4 

	psrld xmm2, 8
	pand xmm2, xmm4

	psrld xmm3, 16
	pand xmm3, xmm4

	;convierto los packed integer dwords a packed floats
	cvtdq2ps xmm1, xmm1
	cvtdq2ps xmm2, xmm2
	cvtdq2ps xmm3, xmm3

	;multiplico los coeficientes para cada color
	mulps xmm1, xmm7    
			;  float -  float -  float -  float
			; xfloat - xfloat - xfloat - xfloat
			; ---------------------------------
			;  res   -  res   -  res   - res

	mulps xmm2, xmm8

	mulps xmm3, xmm9


	;sumar rojos verdes y azules
	addps xmm1, xmm2
	addps xmm1, xmm3

	;reconvierto los packed floats a packed integers
	cvtps2dq xmm1, xmm1

	;comprimo, saturacion
	packusdw xmm1, xmm1
	packuswb xmm1, xmm1


	;preparo el pixel
	;distribuyo los valores, no haria falta xq pack los copia?
	pshufb xmm1, xmm6

	;cargo alfa
	por xmm1, xmm5

	;muevo todo el registro que contiene los 4 pixeles
	movdqu [rdi], xmm1

	
	;preparo siguiente iteracion
	add rsi, 16		; avanzo 16 bytes en src
	add rdi, 16		; avanzo 16 bytes en dst
	sub rdx, 4		; resto 4 pixeles a rdx

	jmp .loop		; salto a loop

.fin:
	pop rbp
	ret
