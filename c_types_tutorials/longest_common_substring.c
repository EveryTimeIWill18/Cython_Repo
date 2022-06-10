#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#define MAX(a,b) (((a)>(b))? (a):(b))

typedef struct {
    const char * str_one;
    const char * str_two;
    int str_one_len;
    int str_two_len;

    int ** lcs_matrix;
    int result;
    double lcs_ratio;

} LCS;

LCS * init_lcs(const char *str_one, const char * str_two) {
    /*  This function creates an instance of the LCS structure
     and allocates memory to the required data structures.

        returns: Pointer to the newly created LCS structure
     */

    LCS * lcs;
    // Allocate memory for the struct
    lcs = (LCS*) malloc(sizeof(LCS));

    // set the strings
    lcs->str_one = str_one;
    lcs->str_two = str_two;
    // Get the lengths of the input strings
    lcs->str_one_len = (int) strlen(str_one);
    lcs->str_two_len = (int) strlen(str_two);
    printf("lcs->str_one_len := %d\n", lcs->str_one_len);
    printf("lcs->str_two_len := %d\n", lcs->str_two_len);

    // Allocate memory for the matrix
    lcs->lcs_matrix = (int **) malloc((lcs->str_one_len+1) * sizeof(int *));

    for (int i=0; i <= lcs->str_one_len; i++) {
        *(lcs->lcs_matrix + i) = (int *) malloc((lcs->str_two_len +1) * sizeof(int));
    }
    // Initialize result to 0
    lcs->result = 0;
    // Initialize lcs ratio to 0.10000
    lcs->lcs_ratio = 0.0;

    return lcs;
}

void lcs_algorithm(LCS *lcs_struct) {
    /* This function calculates the longest
      common substring, using the two strings that
      that were given as input in the LCM init function

      returns void
     */
    printf("RUNNING ...\n");
    printf("lcs_str_one_len := %d\n", lcs_struct->str_one_len);
    printf("lcs_str_two_len := %d\n", lcs_struct->str_two_len);

    for (int i=0; i <= lcs_struct->str_one_len; i++) {
        for (int j = 0; j <= lcs_struct->str_two_len; j++) {
            if (i == 0 || j == 0) {
                *(*(lcs_struct->lcs_matrix + i) + j) = 0;
            }
            else if (lcs_struct->str_one[i-1] == lcs_struct->str_two[j-1]) {
                lcs_struct->lcs_matrix[i][j] = lcs_struct->lcs_matrix[i-1][j-1] + 1;
                lcs_struct->result = MAX(lcs_struct->result, lcs_struct->lcs_matrix[i][j]);
            } else {
                lcs_struct->lcs_matrix[i][j] = 0;
            }
        }
    }
    printf("finished computing LCS!\n");
}

int get_lcs_result(LCS * lcs_struct) {
    /* This function returns the LCS result
     i.e. the count of the longest common substring
    */
    if (lcs_struct) {
        return lcs_struct->result;
    }else {
        fprintf(stderr, "Error: Memory already deallocated\nerrno: %d\n", errno);
        return -1;
    }

}

double get_lcs_ratio(LCS *lcs_struct) {
    /* This function returns the LCS ratio
      that will be used in assessing how identical
      two strings are
     */
    if (lcs_struct) {

        int longest_str = MAX(lcs_struct->str_one_len, lcs_struct->str_two_len);
        lcs_struct->lcs_ratio = ((double)lcs_struct->result / longest_str);
        return lcs_struct->lcs_ratio;
    }else {
        fprintf(stderr, "Error: Memory already deallocated\nerrno: %d\n", errno);
        return -1.0;
    }

}

void destroy_lcs(LCS *lcs_struct) {
    /* This function frees up all allocated memory
     that was used in the creation of the matrix
     and the memory used to create the LCS structure

        returns void
     */
    if (lcs_struct) {
        for (int i=0; i <= lcs_struct->str_one_len; i++) {
            // free the nested array's allocated memory
            free(lcs_struct->lcs_matrix[i]);
        }
        // free the outside array's allocated memory
        free(lcs_struct->lcs_matrix);
        // free the allocated memory for the lcs_struct
        free(lcs_struct);
    } else {
        fprintf(stderr, "Error: Memory already deallocated\nerrno: %d\n", errno);
    }
}
