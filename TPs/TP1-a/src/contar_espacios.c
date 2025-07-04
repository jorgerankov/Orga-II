#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
    uint32_t i = 0;
    while ((void*)string != NULL && string[i]) {
        i++;
    }
    return i;
}

uint32_t contar_espacios(char* string) {
    uint32_t i = 0;
    uint32_t contador = 0;
    uint32_t longitud = longitud_de_string(string);
    while (i < longitud) {
        if (string[i] == ' ') {
            contador++;
        }
        i++;
    }
    return contador;
}

//Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
int main() {
    printf("0. %d\n", longitud_de_string("hola como andas"));
    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));
}
*/
