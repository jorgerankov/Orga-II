#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
    lista_t* lista = malloc(sizeof(lista_t));
    lista->head = NULL; // Inicio head = NULL
    return lista;
}

uint32_t longitud(lista_t* lista) {

    // Inicializo contador:
    uint32_t contador = 0;
    nodo_t* nodo_actual = lista->head;

    // Recorro array para ir contando los elementos:
    while (nodo_actual != NULL){
        contador++;
        nodo_actual = nodo_actual->next;
    }

    // Devuelvo el total:
    return contador;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {

    // Creo nuevo nodo:
    nodo_t* nuevo_nodo = malloc(sizeof(nodo_t));

    // Reservo memoria para array y para copiar los datos:
    nuevo_nodo->arreglo = malloc(longitud * sizeof(uint32_t));

    for (uint64_t i = 0; i < longitud; i++) {
            nuevo_nodo->arreglo[i] = arreglo[i];
        }

    nuevo_nodo->longitud = longitud;
    nuevo_nodo->next = NULL;

    // Nuevo nodo es el primero si la lista esta vacia:
    if (lista->head == NULL){
        lista->head = nuevo_nodo;
    }
    else {
        nodo_t* actual = lista->head;

        while (actual->next != NULL)
        {
            actual = actual->next;
        }
    
        actual->next = nuevo_nodo;
    }
    
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {

    nodo_t* nodo_actual = lista->head;

    // Inicio contador:
    uint32_t contador = 0;

    // Recorre la lista hasta llegar al i-esimo nodo:
    while (nodo_actual != NULL && contador < i){
        nodo_actual = nodo_actual->next;
        contador++;
    }

    // Devuelve el nodo en la posicion i:
    return nodo_actual;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {

    // Inicio contador:
    uint64_t contador_total = 0;
    nodo_t* nodo_actual = lista->head;

    // Sumo longitud de cada array
    // y avanzo al siguiente nodo:
    while (nodo_actual != NULL)
    {
        contador_total += nodo_actual->longitud;
        nodo_actual = nodo_actual->next;
    }

    // Devuelve total de elementos:
    return contador_total;
}

void imprimir_lista(lista_t* lista) {
    nodo_t* nodo_actual = lista->head;

    // Recorro array e imprimo longitud de cada nodo:
    while (nodo_actual != NULL)
    {
        printf("| %lu | ->", nodo_actual->longitud);
        nodo_actual = nodo_actual->next;
    }

    // Imprimo final de busqueda (null):
    printf("null\n");
    
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
    
    for (uint64_t i = 0; i < size_of_array; i++)
    {
        if (array[i] == elemento_a_buscar)
        {
            
            return 1; // Si el elemento fue encontrado
        }
    }
    return 0; // Si no lo fue
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
    nodo_t* nodo_actual = lista->head;

    while (nodo_actual != NULL)
    {
        if (array_contiene_elemento(nodo_actual->arreglo, nodo_actual->longitud,elemento_a_buscar))
        {
            return 1; // Si el elemento fue encontrado en un nodo
        }
        nodo_actual = nodo_actual->next;
    }
    return 0; // Si no lo fue

}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
void destruir_lista(lista_t* lista) {
    nodo_t* nodo_actual = lista->head;
    while (nodo_actual != NULL)
    {
        nodo_t* nodo_next = nodo_actual->next;
        free(nodo_actual->arreglo); // Libero array
        free(nodo_actual);  // Libero nodos
        nodo_actual = nodo_next;
    }
    free(lista); // Libero lista
}
