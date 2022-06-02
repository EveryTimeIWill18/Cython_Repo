/*
*  nlp_algorithms.c
*  ~~~~~~~~~~~~~~~~
*  This code serves as the base for creating a set string processing algorithms that will be used 
*  with the my tutorials on using the 'ctypes' module in Python.
*
*  Many of the tutorials online use relatively simple C code; this tutorial will go in great depth.
*
*  Developer: William Robert Murphy
*
* STEPS TO GETTING THIS C FILE WORKING IN PYTHON
* -----------------------------------------------
* In the command line, move to the dir (or write the full path name) to this file (nlp_algorithms.c) and execute the following
*     
*     cc -fPIC -shared -o nlp_algorithms.so nlp_algorithms.c
*
* This will create a shared .so file that Python will read in using ctypes.
*
* Please go to the nlp_algorithms.py for a continuation of this tutorial.
*/


#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>


struct string_distance {
    const char * input_key;
    const char * string_to_match;
    unsigned long lev_distance;
    double ratio;
};


struct string_distance * create_str_dist_struct(const char * str_key, const char * str_to_match) {

    // Create and allocate memory for the struct
    struct string_distance * new_str_dist;
    new_str_dist = (struct string_distance *)malloc(sizeof(struct string_distance));

    // set the strings
    new_str_dist->input_key = str_key;
    new_str_dist->string_to_match = str_to_match;

    // set default values of lev distance and ratio
    new_str_dist->lev_distance = 0;
    new_str_dist->ratio = 0.0;

    return new_str_dist;
}

// struct string_distance* str_diff
void compute_str_distance(struct string_distance* str_diff) {
    /* Computes the Levenshtein distance between 2 strings
     * and calculates the ratio of 'sameness'
     * */
    // Check to make sure strings have been set
    if (strlen(str_diff->input_key) <= 0 || strlen(str_diff->string_to_match) <= 0) {
        fprintf(stderr, "Error: No string input\nerrno: %d\n", errno);
    } else {
        // Set the string lengths
        size_t input_key_len = strlen(str_diff->input_key);
        size_t str_to_match_len = strlen(str_diff->string_to_match);

        if (input_key_len > str_to_match_len) {
            printf("in IF");
            // If input_key is longer than str_to_match
            str_diff->lev_distance = (input_key_len - str_to_match_len);
            printf("lev_distance == %d\n", (int)str_diff->lev_distance);
            for (int i=0; i < str_to_match_len; i++) {
                if (*(str_diff->string_to_match + i) != *(str_diff->input_key + i)) {
                    str_diff->lev_distance++;
                    printf("UPDATED: lev_distance == %d\n", (int)str_diff->lev_distance);
                }
            }

        } else if (str_to_match_len > input_key_len) {
            printf("in ELSE IF\n");
            // If string to match is longer than input_key
            str_diff->lev_distance = (str_to_match_len - input_key_len );
            printf("lev_distance == %d\n", (int)str_diff->lev_distance);
            for (int i=0; i < input_key_len; i++) {
                if (*(str_diff->input_key + i) != *(str_diff->string_to_match + i)) {
                    str_diff->lev_distance++;
                    printf("UPDATED: lev_distance == %d\n", (int)str_diff->lev_distance);
                }
            }
        } else {
            // If lengths are equal
            printf("in ELSE");
            for (int i=0; i < input_key_len; i++) {
                if (*(str_diff->input_key + i) != *(str_diff->string_to_match + i)) {
                    str_diff->lev_distance++;
                    printf("UPDATED: lev_distance == %d\n", (int)str_diff->lev_distance);
                }
            }
        }
        // Update the struct ratio
        str_diff->ratio = ((double)(str_to_match_len - str_diff->lev_distance))/ input_key_len;
        printf("str_diff->lev_distance = %d\n", (int)str_diff->lev_distance);
        printf("str_diff->ratio = %f\n", str_diff->ratio);
    }
}


void destroy_str_dist_struct(struct string_distance * str_dist) {
    if (str_dist != NULL) {
        free(str_dist);
        str_dist = NULL;
        printf("Memory successfully freed!\n");
    } else {
        fprintf(stderr, "Error: Memory already deallocated\nerrno: %d\n", errno);
    }
}
