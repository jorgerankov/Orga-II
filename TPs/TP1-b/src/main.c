#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "checkpoints.h"
void strPrint(char* a, FILE* pFile);
int main (void){
	/* Acá pueden realizar sus propias pruebas */
	assert(alternate_sum_4(8,2,5,1) == 10);	
	assert(alternate_sum_4_using_c(8,2,5,1) == 10);
	assert(alternate_sum_4_simplified(8,2,5,1) == 10);

	assert(alternate_sum_8(8,2,5,1,8,2,5,1) == 20);

	uint32_t* a = malloc(sizeof(uint32_t*)); 
	product_2_f(a, 32, 0.5);
	assert(*a == 16);

	double* b = malloc(sizeof(double*));
	uint32_t c = 583;
	float d = 521.44;
	uint32_t e = c * d;
	
	uint32_t arreglo1[] = {1, 2, 3};
	uint32_t arreglo2[] = {4, 5, 6};

	nodo_t nodo1;
	nodo_t nodo2;

	nodo1.next = &nodo2;
	nodo1.categoria = 1;
	nodo1.arreglo = arreglo1;
	nodo1.longitud = 3;

	nodo2.next = NULL;
	nodo2.categoria = 2;
	nodo2.arreglo = arreglo2;
	nodo2.longitud = 3;

	lista_t lista;
	lista.head = &nodo1;

	printf("Cantidad total de elementos: %d\n", cantidad_total_de_elementos(&lista));

	assert(cantidad_total_de_elementos(&lista) == 6);
	char* str = "Om3ga $";
	char* ac = strClone(str);
	printf("print a: %ld\n",strlen(str));
	printf("print a: %s\n",str);
	printf("print ac: %s\n",ac);

	//	FILE* file = fopen("test.txt", "w");
//	char* hola = "Hola mundo\n";
//	char* nulo = 0;
//	strPrint(nulo, file);
//	fclose(file);

//	char str[] = "sar";
//	char str2[] = "23";
//	int res = strCmp(str, str2);
//	printf("res: %d\n", res);
//	assert(strCmp(str, str2) == -1);

	FILE* pFile = stdout;  // Vamos a imprimir en la consola (stdout)

    // Pruebas
    printf("Prueba 1: Pasando un string\n");
    strPrint("Hola mundo", pFile);  // Debería imprimir "Hola mundo"

    printf("\nPrueba 2: Pasando NULL\n");
    strPrint(NULL, pFile);  // Debería imprimir "NULL"
	printf("¡Ejecución exitosa!\n");

	return 0;    
}


