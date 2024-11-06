; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - Arquitectura y Organizacion de Computadoras - FCEN
; ==============================================================================

%include "print.mac"

global start

; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern A20_enable
extern A20_check
extern screen_draw_layout
extern kernel_exception
extern process_scancode
extern next_clock

extern GDT_DESC
extern IDT_DESC
extern idt_init

extern pic_reset
extern pic_enable
extern pic_finish1
extern pic_finish2

extern _isr32
extern _isr33
extern _isr88
extern _isr98

extern mmu_init
extern mmu_init_kernel_dir
extern mmu_init_task_dir

extern copy_page
extern page_fault_handler

extern tss_init
extern sched_init
extern tasks_init
extern tasks_syscall_draw
extern tasks_screen_draw


%define CS_RING_0_SEL 1 << 3 | 0      ; Selector de segmento de código de nivel 0 (kernel)
%define DS_RING_0_SEL (3 << 3) | 0    ; Selector de segmento de datos de nivel 0 (kernel)
%define TSS_INITIAL_SEL (11 << 3) | 0 ; Selector de segmento tss de nivel 0 (kernel)
%define TSS_IDLE_SEL (12 << 3) | 0    ; Selector de segmento tss de nivel 0 (kernel)

%define KERNEL_PAGE_DIR     0x00025000
%define TASK_CODE_VIRTUAL   0x08000000
%define PHY_START           0x400000

BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;
;; Punto de entrada del kernel.
BITS 16
start:
    cli                 ; Deshabilita las interrupciones de hardware

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; Imprimir mensaje de bienvenida - MODO REAL
    print_text_rm start_rm_msg, start_rm_len, 0x07, 0, 0
    ; print_text_rm: Imprime un mensaje en la pantalla en modo real
    ; start_rm_msg: Mensaje de bienvenida en modo real
    ; start_rm_len: Longitud del mensaje de bienvenida en modo real
    ; 0x07: Color del mensaje
    ; 0: Fila
    ; 0: Columna

    call A20_enable     ; Habilita el bit A20
    call A20_check
    lgdt [GDT_DESC]     ; Carga la GDT

    ; Setear el bit PE del registro CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Saltar a modo protegido (far jump)
    jmp CS_RING_0_SEL:modo_protegido

BITS 32
modo_protegido:
    ; A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    mov ax, DS_RING_0_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    mov ss, ax

    ; Establecer el tope y la base de la pila
    mov esp, 0x25000
    mov ebp, esp

    ; Imprimir mensaje de bienvenida - MODO PROTEGIDO
    print_text_pm start_pm_msg, start_pm_len, 0x07, 3, 0

    call screen_draw_layout ; Inicializar pantalla

    .test:

    call mmu_init_kernel_dir    ; Inicializar el directorio de paginas

    ; Cargar directorio de paginas
    mov eax, KERNEL_PAGE_DIR
    mov cr3, eax

    ; Habilitar paginacion
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    ; TAREAS
    ; Inicializar tss
    call tss_init

    ; Preparar la pantalla para nuestras tareas
    call tasks_screen_draw

    ; Cargar tarea inicial
    mov ax, TSS_INITIAL_SEL
    ltr ax

    ; Inicializar el scheduler
    call sched_init

    ; Inicializar las tareas
    call tasks_init

    ; INTERRUPCIONES
    ; Cargar e inicializar la IDT
    call idt_init   ; Inicializar la IDT
    lidt [IDT_DESC] ; Cargar la IDT

    ; Reiniciar y habilitar el controlador de interrupciones
    call pic_reset
    call pic_enable

    ; Inicializar el PIT para aumentar la frecuencia de las interrupciones del reloj
    mov al, 0x36
    out 0x43, al
    mov ax, 0x400        ; Ajustar este valor según sea necesario
    out 0x40, al
    mov al, ah
    out 0x40, al

    ; Saltar a la tarea idle
    jmp TSS_IDLE_SEL:0

    sti ; Habilita las interrupciones de hardware
    ; NOTA: Pueden chequear que las interrupciones funcionen forzando a que se
    ;       dispare alguna excepción (lo más sencillo es usar la instrucción
    ;       `int3`)

; Pruebas que no se ejecutan
    ; Probar Sys_call
    ; interrupcion syscall 88 (0x52)
    mov eax, 0x1    ; Codigo de operacion
    int 88          ; Llamada al sistema

    ; interrupcion syscall 98 (0x62)
    mov eax, 0x1
    int 98
    
    .test2:
    ; Pruebas de Paginación

    ; Comprobar el funcionamiento de copy_page
    push 0        ; Direccion fisica origen
    push 0x501000 ; Direccion fisica destino

    call copy_page

    pop eax
    pop eax

    ; Comprobar el funcionamiento de mmu_init_task_dir
    ; Guardar el CR3 actual (del kernel) en una variable
    mov eax, cr3
    push eax

    ; Llamar a mmu_init_task_dir con la dirección física 0x18000 de la tarea ficticia
    push 0x18000
    call mmu_init_task_dir
    pop ebx

    ; Cambiar CR3 al de la tarea ficticia
    mov cr3, eax

    ; Realizar escrituras en la memoria compartida mapeada
    mov dword [0x07000000], 0x12345678  ; Deberia generar page fault
    mov dword [0x07000001], 0x87654321  ; No deberia generar page fault

    ; Restaurar el CR3 del kernel
    pop eax
    mov cr3, eax

    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
