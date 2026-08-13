"""
cy_vector.pyx
~~~~~~~~~~~~~
"""
import cython
import numpy as np
cimport numpy as cnp
from libc.stdlib  cimport malloc, realloc, free, atof, calloc
from libc.math cimport exp
from file_reader cimport CSVReader
from libc.string cimport strtok, strcpy, strlen
# Manually add POSIX header declaration to import strtok_r
cdef extern from "string.h":
    char* strtok_r(char* str, char* delim, char** saveptr) nogil


cdef class Vector:
    """Vector class"""

    def __cinit__(self):
        self.vector_container = <DoubleVector*>malloc(sizeof(DoubleVector))
        self.vector_container.length = 0

    def __init__(self):
        ...

    cpdef void initialize_vector(self, double[:] data):
        """Load data into the vector"""
        if not self.vector_container:
            raise MemoryError('Memory not allocated for vector_container.')

        cdef int data_length = data.shape[0]
        cdef int i
        self.vector_container._c_vector = <double*>malloc(data_length * sizeof(double))
        self.vector_container.length = data_length
        if self.vector_container._c_vector != NULL:
            for i in range(data_length):
                self.vector_container._c_vector[i] = data[i]

    cpdef void insert(self, int index, double value):
        """Insert a value at a given index in the vector"""
        if not self.vector_container:
            raise MemoryError('Memory not allocated for vector_container.')
        if self.vector_container._c_vector == NULL:
            raise MemoryError('Memory not allocated for vector_container._c_vector.')
        cdef double * temp
        cdef int temp_length = self.vector_container.length + 1
        cdef double * front
        cdef double * back
        cdef int i, j, k, end
        temp = <double *> realloc(self.vector_container._c_vector,
                    (self.vector_container.length + 1) * sizeof(double))
        if not temp:
            raise MemoryError('Memory not allocated for temp.')

        if index >= self.vector_container.length:
            temp[temp_length - 1] = value
            self.vector_container._c_vector = temp
        elif index < self.vector_container.length and index >= 0:
            end = self.vector_container.length - index
            self.vector_container.length = self.vector_container.length + 1

            front = <double *> malloc((index + 1) * sizeof(double))
            back = <double*>malloc(end*sizeof(double))
            for i in range(index):
                front[i] = temp[i]
            i = index
            front[i] = value

            for j in range(end):
                back[j] = temp[i]
                i += 1
            i = 0
            for k in range(temp_length):
                if k < (index +1):
                    self.vector_container._c_vector[k] = front[k]
                else:
                    self.vector_container._c_vector[k] = back[i]
                    i += 1
    
    def __dealloc__(self):
        """Deallocate memory"""
        if self.vector_container != NULL:
            if self.vector_container._c_vector != NULL:
                free(self.vector_container._c_vector)
            free(self.vector_container)

                    
