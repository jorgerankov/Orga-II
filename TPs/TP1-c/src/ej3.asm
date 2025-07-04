section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 3A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3a
global EJERCICIO_3A_HECHO
EJERCICIO_3A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen escribe en el destino `scale * px + offset` por cada
; píxel en la imagen.
;
; Parámetros:
;   - dst_depth: La imagen destino (mapa de profundidad). Está en escala de
;                grises a 32 bits con signo por canal.
;   - src_depth: La imagen origen (mapa de profundidad). Está en escala de
;                grises a 8 bits sin signo por canal.
;   - scale:     El factor de escala. Es un entero con signo de 32 bits.
;                Multiplica a cada pixel de la entrada.
;   - offset:    El factor de corrimiento. Es un entero con signo de 32 bits.
;                Se suma a todos los píxeles luego de escalarlos.
;   - width:     El ancho en píxeles de `src_depth` y `dst_depth`.
;   - height:    El alto en píxeles de `src_depth` y `dst_depth`.
global ej3a
ej3a:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; rdi/m64 = int32_t* dst_depth
	; rsi/m64 = uint8_t* src_depth
	; edx/m32 = int32_t  scale
	; ecx/m32 = int32_t  offset
	; r8d/m32 = uint32_t      width
	; r9d/m32 = uint32_t      height
	push rbp
	mov rbp, rsp

	imul r8, r9 ; r8 = width * height cantidad total de pixeles

		;cargo en xmm1 y xmm2 los coeficientes
		movd xmm1, edx ; muevo el scale
		pshufd xmm1, xmm1, 0b0000 

		movd xmm2, ecx ; muevo el offset
		pshufd xmm2, xmm2, 0b0000
		; ambos quedan en cada parte del packed
		;0xabcd -> 0xdcab

	.loop:
		cmp r8, 0
		je .fin

		;cargo 4 pixeles como dword, y cada byte lo extiendo a 32 sin signo
		movd xmm0, [rsi]
		pmovzxbd xmm0, xmm0 ;xmm0 0x0000 0000 0000 xxxx -> xmm0 000x 000x 000x 000x


		;transformacion lineal
		; se puede asumir que es siempre representable como entero de 32 bits con signo 
		pmulld xmm0, xmm1 ; scale x profundidad

		paddd xmm0, xmm2 ; sumo offset 

		;muevo los pixeles de 32 bits a dst
		movdqu [rdi], xmm0

		;siguiente iteracion
		add rsi, 4 ; avanzo 4 bytes en src
		add rdi, 16 ; avanzo 16 bytes en dst
		sub r8, 4   ; proceso de a 4 pixeles
		jmp .loop
		
	.fin:


	pop rbp
	ret

; Marca el ejercicio 3B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3b
global EJERCICIO_3B_HECHO
EJERCICIO_3B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dadas dos imágenes de origen (`a` y `b`) en conjunto con sus mapas de
; profundidad escribe en el destino el pixel de menor profundidad por cada
; píxel de la imagen. En caso de empate se escribe el píxel de `b`.
;
; Parámetros:
;   - dst:     La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - a:       La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_a: El mapa de profundidad de A. Está en escala de grises a 32 bits
;              con signo por canal.
;   - b:       La imagen origen B. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_b: El mapa de profundidad de B. Está en escala de grises a 32 bits
;              con signo por canal.
;   - width:  El ancho en píxeles de todas las imágenes parámetro.
;   - height: El alto en píxeles de todas las imágenes parámetro.
global ej3b
ej3b:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; rdi/m64 = rgba_t*  dst
	; rsi/m64 = rgba_t*  a
	; rdx/m64 = int32_t* depth_a
	; rcx/m64 = rgba_t*  b
	; r8/m64 = int32_t* depth_b
	; r9/m32 = uint32_t width
	; (rbp + 0x10)/m32 = uint32_t height
	
	push rbp
	mov rbp, rsp
	imul r9, [rbp + 0x10] ;r9 = width * height cantidad total de pixeles
	
	.for_ej3:

		cmp r9,0
		je .termina

		movdqu xmm0, [rsi]	; xmmo = a
		movdqu xmm1, [rdx]	; xmm1 = depth_a 
		movdqu xmm2, [rcx] ; xmm2 = b
		movdqu xmm3, [r8]  ;xmm3 = depth_b 

		pcmpgtd xmm3, xmm1 ;Compare Packed Signed Integers for Greater Than

		pand xmm0, xmm3 ;and a
		pcmpeqd xmm1, xmm1 
		pxor xmm3, xmm1	;pand xmm3 xmm3 me fallan los tests 3AB
		pand xmm2, xmm3 ;and b con 

		por xmm0, xmm2 ; a + b

		movdqu [rdi], xmm0

		add rsi, 16 ; avanzo 16 bytes en img_a
		add rdx, 16 ; avanzo 16 bytes en depth_a
		add rcx, 16 ; avanzo 16 bytes en img_b
		add r8, 16 	; avanzo 16 bytes en depth_b
		add rdi, 16 ; avanzo 16 bytes en dst
		sub r9, 4 	; proceso de a 4 pixeles
		jmp .for_ej3	;vuelvo al loop

	.termina:
	pop rbp
	ret
