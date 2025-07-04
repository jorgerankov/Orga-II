#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
    
    vector_t* vector = malloc(sizeof(vector_t));
    vector->size = 0;
    vector->capacity = 2;
    vector->array = malloc(sizeof(uint32_t)*2); // no hay razon para siquiera darle un tamaño inicial

    return vector;
}

uint64_t get_size(vector_t* vector) {
    return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {

    if (vector->size == vector->capacity){
        vector->array = realloc(vector->array, (vector->capacity)*2*(sizeof(uint32_t)));
        vector->capacity*=2;
    }
    vector->array[vector->size] = elemento;
    vector->size++;
}

int son_iguales(vector_t* v1, vector_t* v2) {
    uint64_t i;
    if (v1->size == v2->size){
        for (i = 0; i < v1->size; i++){
            if (v1->array[i] != v2->array[i]){
                return 0;
            }
        }
        return 1;
    }
    return 0;
}

uint32_t iesimo(vector_t* vector, size_t index) {
    if (index < vector->capacity){
        return vector->array[index];
    }
    else{
        return 0;
    }
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out)
{
    *out = vector->array[index];
    
}

// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    
    vector_t* vector_mas_grande = array_de_vectores[0];
    for (size_t i = 1; i < longitud_del_array; i++){
        if (array_de_vectores[i]->size > vector_mas_grande->size){
            vector_mas_grande = array_de_vectores[i];
        }
    }
    return vector_mas_grande;

}
