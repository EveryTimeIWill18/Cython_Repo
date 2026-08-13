"""
cy_matrix.pyx
~~~~~~~~~~~~~~
"""
from cy_vector cimport Vector, DoubleVector
import cython
import numpy as np
cimport numpy as cnp
from libc.stdlib  cimport malloc, realloc, free, atof, calloc
from libc.math cimport sqrt, exp
from file_reader cimport CSVReader
from libc.string cimport strtok, strcpy, strlen
# Manually add POSIX header declaration to import strtok_r
cdef extern from "string.h":
    char* strtok_r(char* str, char* delim, char** saveptr) nogil


cdef class Matrix:
    def __cinit__(self):
        self.matrix_container = <CyMatrix*>malloc(sizeof(CyMatrix))

    def __init__(self):
        ...

    cpdef void initialize_matrix(self, double[:, :] init_matrix):
        """Initialize the matrix."""
        if not self.matrix_container:
            raise MemoryError('Memory not allocated for matrix_container.')

        cdef int n_rows = init_matrix.shape[0]
        cdef int m_cols = init_matrix.shape[1]
        self.matrix_container.num_rows = n_rows
        self.matrix_container.num_cols = m_cols

        cdef int i, row, col
        self.matrix_container._c_matrix = <double**>malloc(n_rows*sizeof(double*))

        if self.matrix_container._c_matrix == NULL:
            raise MemoryError('Memory not allocated for matrix_container._c_matrix.')

        for i in range(n_rows):
            self.matrix_container._c_matrix[i] = <double*>malloc(m_cols*sizeof(double))
            if self.matrix_container._c_matrix[i] == NULL:
                raise MemoryError(f'Memory not allocated for matrix_container._c_matrix[{i}].')

    def __dealloc__(self):
        """Deallocate memory."""
        if self.matrix_container != NULL:
            if self.matrix_container._c_matrix != NULL:
                for i in range(self.matrix_container.num_rows):
                    free(self.matrix_container._c_matrix[i])
                free(self.matrix_container._c_matrix)
            free(self.matrix_container)
