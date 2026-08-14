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
        i = 0
        for i in range(n_rows):
            for j in range(m_cols):
                self.matrix_container._c_matrix[i][j] = init_matrix[i][j]
    
    cpdef Matrix multiply(self, Matrix other):
        """Matrix multiplication"""
        if self.matrix_container._c_matrix == NULL:
            raise MemoryError('Memory not allocated for matrix_container._c_matrix.')
        if not other:
            raise MemoryError('Memory not allocated for other._c_matrix.')
        cdef int i, j, k
        cdef double current_value
        cdef int current_mat_n_rows = self.matrix_container.num_rows
        cdef Matrix new_matrix = Matrix()

        cdef bool dims_match = self.check_dimensions(A=self, B=other)
        if dims_match == True:
            # Allocate memory for the matrix
            new_matrix.matrix_container._c_matrix = <double**> malloc(current_mat_n_rows * sizeof(double *))
            if new_matrix.matrix_container._c_matrix == NULL:
                raise MemoryError('Memory not allocated for new_matrix.matrix_container._c_matrix.')
            # Allocate memory for each row of the matrix
            for i in range(other.matrix_container.num_cols):
                new_matrix.matrix_container._c_matrix[i] = <double *> malloc(
                    other.matrix_container.num_cols * sizeof(double))
                if new_matrix.matrix_container._c_matrix[i] == NULL:
                    raise MemoryError(f'Memory not allocated for new_matrix.matrix_container._c_matrix[{i}]')

            new_matrix.matrix_container.num_rows = current_mat_n_rows
            new_matrix.matrix_container.num_cols = other.matrix_container.num_cols

            i = 0
            for i in range(current_mat_n_rows):
                for j in range(other.matrix_container.num_cols):
                    for k in range(self.matrix_container.num_cols):
                        new_matrix.matrix_container._c_matrix[i][j] += (self.matrix_container._c_matrix[i][k]*other.matrix_container._c_matrix[k][j])
            return new_matrix
        elif dims_match == False and self.transpose_needed == True:
            ...
        else:
            raise IndexError('Matrices cannot be multiplied.')

    cpdef void print_matrix(self):
        """Print out the matrix"""
        if self.matrix_container._c_matrix == NULL:
            raise MemoryError('Memory not allocated for _c_matrix.')

        cdef int i, j
        cdef int n_rows = self.matrix_container.num_rows
        cdef int m_cols = self.matrix_container.num_cols

        for i in range(n_rows):
            for j in range(m_cols):
                print(f'{self.matrix_container._c_matrix[i][j]=}')

    cpdef Matrix transpose(self):
        """Transpose the matrix."""
        if self.matrix_container == NULL:
            raise MemoryError('Memory not allocated for matrix_container.')
        cdef int i, j

        cdef Matrix new_matrix = Matrix()
        new_matrix.matrix_container.num_rows = self.matrix_container.num_cols
        new_matrix.matrix_container.num_cols = self.matrix_container.num_rows

        cdef int new_rows = new_matrix.matrix_container.num_rows
        cdef int new_cols = new_matrix.matrix_container.num_cols

        if new_matrix.matrix_container == NULL:
            raise MemoryError('Memory not allocated for new_matrix.matrix_container.')

        # Allocate _c_matrix memory
        new_matrix.matrix_container._c_matrix = <double**>malloc(new_rows * sizeof(double*))
        if new_matrix.matrix_container._c_matrix == NULL:
            raise MemoryError('Memory not allocated for new_matrix.matrix_container._c_matrix.')

        for i in range(new_rows):
            new_matrix.matrix_container._c_matrix[i] = <double*>malloc(new_cols * sizeof(double))
            if new_matrix.matrix_container._c_matrix[i] == NULL:
                raise MemoryError(f'Memory not allocated for new_matrix.matrix_container._c_matrix[{i}]')

        i = 0
        for i in range(self.matrix_container.num_cols):
            for j in range(self.matrix_container.num_rows):
                new_matrix.matrix_container._c_matrix[i][j] = self.matrix_container._c_matrix[j][i]

        return new_matrix

    cpdef int[:] shape(self):
        """Returns the shape of the data."""
        if self.matrix_container == NULL:
            raise MemoryError('Memory not allocated for matrix_container.')

        cdef cnp.ndarray[cnp.int32_t, ndim=1] _shape = np.empty(2, dtype=np.int32)
        _shape[0] = self.matrix_container.num_rows
        _shape[1] = self.matrix_container.num_cols
        return _shape
    
    def __dealloc__(self):
        """Deallocate memory."""
        if self.matrix_container != NULL:
            if self.matrix_container._c_matrix != NULL:
                for i in range(self.matrix_container.num_rows):
                    free(self.matrix_container._c_matrix[i])
                free(self.matrix_container._c_matrix)
            free(self.matrix_container)
