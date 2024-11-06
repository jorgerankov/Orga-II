/* ** por compatibilidad se omiten tildes **
==============================================================================
TALLER System Programming - Arquitectura y Organizacion de Computadoras - FCEN
==============================================================================

  Definicion de la tabla de descriptores globales
*/
#include "gdt.h"
#include "defines.h"

/* Aca se inicializa un arreglo de forma estatica
GDT_COUNT es la cantidad de líneas de la GDT y esta definido en defines.h */

/* Completar la GDT: 
      Es conveniente completar antes las constantes definidas en defines.h y valerse
      de las mismas para definir los descriptores acá. Traten en lo posible de usar las 
      macros allí definidas.
*/

gdt_entry_t gdt[GDT_COUNT] = {
    /* Descriptor nulo*/
    /* Offset = 0x00 */
    [GDT_IDX_NULL_DESC] =
        {
            // El descriptor nulo es el primero que debemos definir siempre
            // Cada campo del struct se matchea con el formato que figura en el manual de intel
            // Es una entrada en la GDT.
            .limit_15_0 = 0x0000,
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = 0x0,
            .s = 0x00,
            .dpl = 0x00,
            .p = 0x00,
            .limit_19_16 = 0x00,
            .avl = 0x0,
            .l = 0x0,
            .db = 0x0,
            .g = 0x00,
            .base_31_24 = 0x00,
        },
    [GDT_IDX_CODE_0] = 
        {
            .limit_15_0 = GDT_LIMIT_LOW(0x33100),
            .base_15_0 = GDT_BASE_LOW(0x00000000),
            .base_23_16 = GDT_BASE_MID(0x00000000),
            .type = DESC_TYPE_EXECUTE_READ,
            .s = DESC_CODE_DATA,
            .dpl = DESC_DPL_0,
            .p = DESC_PRESENT,
            .limit_19_16 = GDT_LIMIT_HIGH(0x33100),
            .avl = DESC_AVL_0,
            .l = DESC_NOT_LONG_MODE,
            .db = DESC_DB_32,
            .g = DESC_GRANULARITY_KB,
            .base_31_24 = GDT_BASE_HIGH(0x00000000),
        },

    [GDT_IDX_CODE_3] = 
        {
            .limit_15_0 = GDT_LIMIT_LOW(0x33100),
            .base_15_0 = GDT_BASE_LOW(0x00000000),
            .base_23_16 = GDT_BASE_MID(0x00000000),
            .type = DESC_TYPE_EXECUTE_READ,
            .s = DESC_CODE_DATA,
            .dpl = DESC_DPL_3,
            .p = DESC_PRESENT,
            .limit_19_16 = GDT_LIMIT_HIGH(0x33100),
            .avl = DESC_AVL_0,
            .l = DESC_NOT_LONG_MODE,
            .db = DESC_DB_32,
            .g = DESC_GRANULARITY_KB,
            .base_31_24 = GDT_BASE_HIGH(0x00000000),
        },

      [GDT_IDX_DATA_0] = 
        {
            .limit_15_0 = GDT_LIMIT_LOW(0x33100),
            .base_15_0 = GDT_BASE_LOW(0x00000000),
            .base_23_16 = GDT_BASE_MID(0x00000000),
            .type = DESC_TYPE_READ_WRITE,
            .s = DESC_CODE_DATA,
            .dpl = DESC_DPL_0,
            .p = DESC_PRESENT,
            .limit_19_16 = GDT_LIMIT_HIGH(0x33100),
            .avl = DESC_AVL_0,
            .l = DESC_NOT_LONG_MODE,
            .db = DESC_DB_32,
            .g = DESC_GRANULARITY_KB,
            .base_31_24 = GDT_BASE_HIGH(0x00000000),
        },

      [GDT_IDX_DATA_3] = 
        {
            .limit_15_0 = GDT_LIMIT_LOW(0x33100),
            .base_15_0 = GDT_BASE_LOW(0x00000000),
            .base_23_16 = GDT_BASE_MID(0x00000000),
            .type = DESC_TYPE_READ_WRITE,
            .s = DESC_CODE_DATA,
            .dpl = DESC_DPL_3,
            .p = DESC_PRESENT,
            .limit_19_16 = GDT_LIMIT_HIGH(0x33100),
            .avl = DESC_AVL_0,
            .l = DESC_NOT_LONG_MODE,
            .db = DESC_DB_32,
            .g = DESC_GRANULARITY_KB,
            .base_31_24 = GDT_BASE_HIGH(0x00000000),
        },

      [GDT_IDX_VIDEO] = 
        // 0xB800 es el comienzo de la memoria de video
        // 50×80×2=8000 bytes=0x1F40 bytes tamaño maximo, luego el limite
        // de la memoria de video es 0x1F40-1=0x1F3F=8000-1=0x1F3F
        {
            .limit_15_0 = GDT_LIMIT_LOW(0x1F3F),
            .base_15_0 = GDT_BASE_LOW(0xB8000),
            .base_23_16 = GDT_BASE_MID(0xB8000),
            .type = DESC_TYPE_READ_WRITE,
            .s = DESC_CODE_DATA,
            .dpl = DESC_DPL_0,
            .p = DESC_PRESENT,
            .limit_19_16 = GDT_LIMIT_HIGH(0x1F3F),
            .avl = DESC_AVL_0,
            .l = DESC_NOT_LONG_MODE,
            .db = DESC_DB_32,
            .g = DESC_GRANULARITY_KB,
            .base_31_24 = GDT_BASE_HIGH(0xB8000),
        }
    /* Completar la GDT: 
      Es conveniente completar antes las constantes definidas en defines.h y valerse
      de las mismas para definir los descriptores acá. Traten en lo posible de usar las 
      macros allí definidas.
     */
    
};

// Aca hay una inicializacion estatica de una structura que tiene su primer componente el tamano 
// y en la segunda, la direccion de memoria de la GDT. Observen la notacion que usa. 
gdt_descriptor_t GDT_DESC = {sizeof(gdt) - 1, (uint32_t)&gdt};
