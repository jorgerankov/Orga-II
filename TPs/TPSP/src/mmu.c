/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"
#include "kassert.h"

static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_end = 0x003FFFFF;
static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
*/
static inline void* kmemset(void* s, int c, size_t n) {
  uint8_t* dst = (uint8_t*)s;
  for (size_t i = 0; i < n; i++) {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
*/
static inline void zero_page(paddr_t addr) {
  kmemset((void*)addr, 0x00, PAGE_SIZE);
}


void mmu_init(void) {}


/**
 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible. 
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void) {
  next_free_kernel_page += PAGE_SIZE;
  return next_free_kernel_page;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void) {
  next_free_user_page += PAGE_SIZE;
  return next_free_user_page;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void) {
  uint32_t pd_index = 0;
  kpd[pd_index] = (pd_entry_t) {
    .pt = (uint32_t)kpt >> 12,
    .attrs = 0x03,
  };
  // Mapeamos las primeras 4MB con identity mapping
  for (paddr_t addr = 0; addr < identity_mapping_end; addr += PAGE_SIZE) {
    uint32_t pt_index = addr >> 12 & 0x3FF;
    kpt[pt_index] = (pt_entry_t) {
      .attrs = 0x03,
      .page =  addr >> 12
    };
  }

  return (paddr_t)kpd;
}


/**
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginación de modo de que
 * la dirección virtual virt se traduzca en la dirección física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traducción
 * @param virt la dirección virtual que se ha de traducir en phy
 * @param phy la dirección física que debe ser accedida (dirección de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */
void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) {
  // Indices de la page table y page directory
  uint32_t pd_index = VIRT_PAGE_DIR(virt);
  uint32_t pt_index = VIRT_PAGE_TABLE(virt);

  // Punteros a las regiones de memoria correspondientes
  pd_entry_t* pd = (pd_entry_t*)(CR3_TO_PAGE_DIR(cr3));

  if (!(pd[pd_index].attrs & 0x1)) { 
    paddr_t new_pt = mmu_next_free_kernel_page();
    zero_page(new_pt);
    pd[pd_index] = (pd_entry_t) {
      .attrs = MMU_W | attrs,
      .pt = new_pt >> 12
    };
  }

  pt_entry_t* pt = (pt_entry_t*)(pd[pd_index].pt << 12);

  // Seteo la page table para mapear
  pt[pt_index] = (pt_entry_t) {
    .attrs = attrs,
    .page = phy >> 12
  };

  tlbflush();
}

/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {

  uint32_t pd_index = VIRT_PAGE_DIR(virt);
  uint32_t pt_index = VIRT_PAGE_TABLE(virt);

  pd_entry_t* pd = (pd_entry_t*)(CR3_TO_PAGE_DIR(cr3));
  pt_entry_t* pt = (pt_entry_t*)(pd[pd_index].pt << 12);

  paddr_t phy = pt[pt_index].page << 12;
  zero_page(phy);

  pt[pt_index] = (pt_entry_t) {
    .attrs = 0,
    .page = 0
   };

  tlbflush();
  return phy;
}

#define DST_VIRT_PAGE 0xA00000
#define SRC_VIRT_PAGE 0xB00000

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr) {
  uint32_t cr3 = rcr3();

  mmu_map_page(cr3, SRC_VIRT_PAGE, src_addr, 0x03);
  mmu_map_page(cr3, DST_VIRT_PAGE, dst_addr, 0x03);

  uint32_t* src = (uint32_t*)SRC_VIRT_PAGE;
  uint32_t* dst = (uint32_t*)DST_VIRT_PAGE;

  for (size_t i = 0; i < PAGE_SIZE / sizeof(uint32_t); i++) {
    dst[i] = src[i];
  }

  mmu_unmap_page(cr3, SRC_VIRT_PAGE);
  mmu_unmap_page(cr3, DST_VIRT_PAGE);
}

 /**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @pararm phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */
paddr_t mmu_init_task_dir(paddr_t phy_start) {
 
  uint32_t pd_task = mmu_next_free_kernel_page();

  paddr_t cr3 = (paddr_t)(pd_task); // pd_task siempre tiene los 12 bits menos significativos en 0, coincide con los atributos necesarios

  // Mapeo el kernel en los primeros 4 MB
  for (paddr_t addr = 0; addr < identity_mapping_end; addr += PAGE_SIZE) {
    mmu_map_page(cr3, addr, addr, MMU_P | MMU_W | MMU_SU); // Read-Write, kernel
  }

  // Mapeo las páginas de código en 0x08000000 y 0x08001000 (solo lectura)
  vaddr_t code_virt_addr = 0x08000000;
  mmu_map_page(cr3, code_virt_addr, phy_start, MMU_P | MMU_R | MMU_U);       // Read-Only, usuario
  mmu_map_page(cr3, code_virt_addr + PAGE_SIZE, phy_start + PAGE_SIZE, MMU_P | MMU_R | MMU_U); // Read-Only, usuario

  // Mapeo la página de stack en 0x08002000 (lectura-escritura)
  vaddr_t stack_virt_addr = 0x08002000;
  paddr_t stack_phy_addr = mmu_next_free_user_page();
  mmu_map_page(cr3, stack_virt_addr, stack_phy_addr, MMU_P | MMU_W | MMU_U); // Read-Write, usuario

  // Mapeo la página de memoria compartida en 0x08003000 (lectura-escritura)
  mmu_map_page(cr3, TASK_SHARED_PAGE, SHARED, MMU_P | MMU_R | MMU_U); // Read-Only, usuario

  return cr3; 

}


// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
  // chequear si la direccion esta en la seccion de memoria compartida
  if (virt >= ON_DEMAND_MEM_START_VIRTUAL && virt <= ON_DEMAND_MEM_END_VIRTUAL){
    // mapear la pagina en la direccion virtual
    uint32_t cr3 = rcr3();
    mmu_map_page(cr3, virt, ON_DEMAND_MEM_START_PHYSICAL, MMU_P | MMU_W | MMU_U); // Read-Write, usuario
    return true;
  }
  return false;
}
