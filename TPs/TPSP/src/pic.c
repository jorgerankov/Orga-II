/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Rutinas del controlador de interrupciones.
*/
#include "pic.h"

#define PIC1_PORT 0x20
#define PIC2_PORT 0xA0

static __inline __attribute__((always_inline)) void outb(uint32_t port,
                                                         uint8_t data) {
  __asm __volatile("outb %0,%w1" : : "a"(data), "d"(port));
}
void pic_finish1(void) { 
  outb(PIC1_PORT, 0x20); 
}

void pic_finish2(void) {
  outb(PIC1_PORT, 0x20);
  outb(PIC2_PORT, 0x20);
}

// COMPLETAR: implementar pic_reset()
void pic_reset() {

  // Inicializamos PIC1 y PIC2
  outb(PIC1_PORT, 0x11);
  outb(PIC2_PORT, 0x11);

  // Remapeamos PIC1 a 0x20 y PIC2 a 0x28
  outb(PIC1_PORT + 1, 0x20);
  outb(PIC2_PORT + 1, 0x28);

  outb(PIC1_PORT + 1, 0x04); // ICW3: PIC1 tiene a PIC2 en IRQ2
  outb(PIC2_PORT + 1, 0x02); // ICW3: PIC2 es esclavo en IRQ2

  outb(PIC1_PORT + 1, 0x01); // ICW4: Modo No Buffered, Fin de Interrupcion Normal. Deshabilitamos las Interrupciones del PIC1
  outb(PIC2_PORT + 1, 0x01); // ICW4: Modo No Buffered, Fin de Interrupcion Normal. Deshabilitamos las Interrupciones del PIC2

  pic_disable();
}

void pic_enable() {
  outb(PIC1_PORT + 1, 0x00);
  outb(PIC2_PORT + 1, 0x00);
}

void pic_disable() {
  outb(PIC1_PORT + 1, 0xFF);
  outb(PIC2_PORT + 1, 0xFF);
}
