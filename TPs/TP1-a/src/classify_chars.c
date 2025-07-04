#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void classify_chars_in_string(char* string, char** vowels_and_cons) {
    uint64_t vowels_index = 0;
    uint64_t consonants_index = 0;
    
    uint64_t i = 0;
    while (string[i]) {
     
        if (string[i] == 'a' || string[i] == 'e' || string[i] == 'i' || string[i] == 'o' || string[i] == 'u') {
            vowels_and_cons[0][vowels_index] = string[i];
            vowels_index++;
        } else {
           vowels_and_cons[1][consonants_index] = string[i];
            consonants_index++;
        }
        i++;
    }
    vowels_and_cons[0][vowels_index] = '\0';
    vowels_and_cons[1][consonants_index] = '\0';

    //printf("String: %ld\n", i);

    //printf("Vowels: %s\n", vowels_and_cons[0]);
    //printf("Consonants: %s\n", vowels_and_cons[1]);
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
 

    for (uint64_t i = 0; i < size_of_array; i++) {
        char* vowels = malloc(sizeof(char) * 64);
        char* consonants = malloc(sizeof(char) * 64);

        array[i].vowels_and_consonants = malloc(sizeof(char*) * 2);
        array[i].vowels_and_consonants[0] = vowels;
        array[i].vowels_and_consonants[1] = consonants;

        classify_chars_in_string(array[i].string, array[i].vowels_and_consonants);

    }
}
