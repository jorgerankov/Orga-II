;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	32				; Tamanio de la estructura nodo_s en bytes
LONGITUD_OFFSET	EQU	21			; Tamanio de longitud de nodo_t en bytes

PACKED_NODO_LENGTH	EQU	8		; Tamanio de la estructura packed_nodo_s en bytes
PACKED_LONGITUD_OFFSET	EQU	8	; Tamanio de longitud de packed_nodo_s en bytes

;########### SECCION DE DATOS
section .data
	 format db "Valor en rbx: %u", 10, 0
;########### SECCION DE TEXTO (PROGRAMA)
section .text
	extern printf
;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos:
	push rbp							; Guardo el valor de rbp
	mov rbp, rsp						; rbp = rsp
	push rbx
	xor rax, rax						; rax = 0
	xor rbx, rbx
	mov rdi, [rdi] ; paso de lista_t a un nodo_t

.sumo_nodos:
		test rdi, rdi						; if (rdi == NULL)
		jz .fin								; saltar a fin

		mov ebx, [rdi + 24]       ; rax += lista->longitud (la longitud está en el desplazamiento 16 bytes desde rdi)

		add rax, rbx

		mov rdi, [rdi]						; rdi = nodo->siguiente

		jmp .sumo_nodos						; saltar a sumo_nodos
.fin:

	pop rbx
	pop rbp								; Restauro el valor de rbp
	ret									; Retorno

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[rdi] LO UNICO QUE CAMBIA SON LOS OFFSET
cantidad_total_de_elementos_packed:
	push rbp							; Guardo el valor de rbp
	mov rbp, rsp						; rbp = rsp
	push rbx
	xor rax, rax						; rax = 0
	xor rbx, rbx
	mov rdi, [rdi] ; paso de lista_t a un nodo_t

.sumo_nodos:
		test rdi, rdi						; if (rdi == NULL)
		jz .fin								; saltar a fin

		mov ebx, [rdi + 17]       ; rax += lista->longitud (la longitud está en el desplazamiento 16 bytes desde rdi)

		add rax, rbx

		mov rdi, [rdi]						; rdi = nodo->siguiente

		jmp .sumo_nodos						; saltar a sumo_nodos
.fin:

	pop rbx
	pop rbp								; Restauro el valor de rbp
	ret									; Retorno


