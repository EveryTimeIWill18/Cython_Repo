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
        """Load data into the vector."""
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
                    
    cpdef int get_length(self):
        """Get the vector length."""
        if not self.vector_container:
            raise MemoryError('Memory not allocated for vector_container.')
        if self.vector_container._c_vector == NULL:
            raise MemoryError('Memory not allocated for vector_container._c_vector.')

        return self.vector_container.length
   cpdef Vector vector_subtraction(self, Vector other):
        """Vector subtraction."""
        if not other:
            raise MemoryError('Memory not allocated for other.')
        if not other.vector_container._c_vector:
            raise MemoryError('Memory not allocated for other._c_vector.')
        if not self.vector_container:
            raise MemoryError('Memory not allocated for vector_container.')
        if not self.vector_container._c_vector:
            raise MemoryError('Memory not allocated for vector_container._c_vector.')
        if self.vector_container.length != other.vector_container.length:
            raise IndexError("Matrices do not have equal length.")

        cdef int i
        cdef int length = self.vector_container.length
        cdef Vector new_vector = Vector()
        # Allocate memory for the new vector
        new_vector.vector_container._c_vector = <double *> malloc(length * sizeof(double))

        for i in range(length):
            new_vector.vector_container._c_vector[i] = (self.vector_container._c_vector[i] - other.vector_container._c_vector[i])
        i = 0
        for i in range(length):
            print(f'{new_vector.vector_container._c_vector[i]=}')

        return new_vector

    cpdef Vector vector_sum(self, Vector other):
        """Vector sum."""
        if not other:
            raise MemoryError('Memory not allocated for other.')
        if not other.vector_container._c_vector:
            raise MemoryError('Memory not allocated for other._c_vector.')
        if not self.vector_container:
            raise MemoryError('Memory not allocated for vector_container.')
        if not self.vector_container._c_vector:
            raise MemoryError('Memory not allocated for vector_container._c_vector.')
        if self.vector_container.length != other.vector_container.length:
            raise IndexError("Matrices do not have equal length.")

        cdef int i
        cdef int length = self.vector_container.length
        cdef Vector new_vector = Vector()
        # Allocate memory for the new vector
        new_vector.vector_container._c_vector = <double*>malloc(length*sizeof(double))
        if not new_vector.vector_container._c_vector:
            raise MemoryError('Memory not allocated for dot vector._c_vector.')

        for i in range(length):
            new_vector.vector_container._c_vector[i] = (self.vector_container._c_vector[i]+other.vector_container._c_vector[i])
        i = 0
        for i in range(length):
            print(f'{new_vector.vector_container._c_vector[i]=}')

        return new_vector

    cpdef double dot_product(self, Vector other):
        """Dot product."""
        if not other:
            raise MemoryError('Memory not allocated for other.')
        if not other.vector_container._c_vector:
            raise MemoryError('Memory not allocated for other._c_vector.')
        if not self.vector_container:
            raise MemoryError('Memory not allocated for vector_container.')
        if not self.vector_container._c_vector:
            raise MemoryError('Memory not allocated for vector_container._c_vector.')
        if self.vector_container.length != other.vector_container.length:
            raise IndexError("Matrices do not have equal length.")

        cdef double dot = 0.0
        cdef int length = self.vector_container.length
        cdef int i

        for i in range(length):
            dot += self.vector_container._c_vector[i]*other.vector_container._c_vector[i]
        return dot

    cpdef Vector scalar_multiply(self, double scalar):
        """Creates a new Vector via scalar multiplication."""
        if not self.vector_container:
            raise MemoryError('Memory not allocated for vector_container.')
        if not self.vector_container._c_vector:
            raise MemoryError('Memory not allocated for vector_container._c_vector.')

        cdef Vector new_vector = Vector()
        cdef int length = self.vector_container.length
        cdef int i
        new_vector.vector_container._c_vector = <double*>malloc(length * sizeof(double))
        for i in range(length):
            new_vector.vector_container._c_vector[i] = scalar*self.vector_container._c_vector[i]
        i = 0
        for i in range(length):
            print(f'Scalar mult: {i=}| {new_vector.vector_container._c_vector[i]=}')

    cpdef double vector_mean(self):
        """Vector mean."""
        if not self.vector_container:
            raise MemoryError('Memory not allocated for vector_container.')
        if not self.vector_container._c_vector:
            raise MemoryError('Memory not allocated for vector_container._c_vector.')

        cdef double cy_mean = 0.0
        cdef double vec_sum = 0.0
        cdef int length = self.vector_container.length
        cdef int i

        for i in range(length):
            vec_sum += self.vector_container._c_vector[i]

        cy_mean = vec_sum/length
        print(f'{cy_mean=}')
        return cy_mean

    cpdef double sum_of_squares(self):
        """Computes the sum of squares."""
        if not self.vector_container:
            raise MemoryError('Memory not allocated for vector_container.')
        if not self.vector_container._c_vector:
            raise MemoryError('Memory not allocated for vector_container._c_vector.')

        cdef double sum_squares = 0.0
        cdef int length = self.vector_container.length
        cdef int i

        for i in range(length):
            sum_squares +=  (self.vector_container._c_vector[i]*self.vector_container._c_vector[i])
        print(f'{sum_squares=}')
        return sum_squares

    cpdef double magnitude(self):
        """Computes magnitude."""
        if not self.vector_container:
            raise MemoryError('Memory not allocated for vector_container.')
        if not self.vector_container._c_vector:
            raise MemoryError('Memory not allocated for vector_container._c_vector.')
        cdef double mag = 0.0
        cdef int length = self.vector_container.length
        cdef int i

        for i in range(length):
            mag += (self.vector_container._c_vector[i]*self.vector_container._c_vector[i])
        mag = sqrt(mag)
        print(f'MAGNITUDE: {mag=}')
        return mag

    cpdef double distance(self, Vector other):
        """Computes distance."""
        if not other:
            raise MemoryError('Memory not allocated for other.')
        if not other.vector_container._c_vector:
            raise MemoryError('Memory not allocated for other._c_vector.')
        if not self.vector_container:
            raise MemoryError('Memory not allocated for vector_container.')
        if not self.vector_container._c_vector:
            raise MemoryError('Memory not allocated for vector_container._c_vector.')
        if self.vector_container.length != other.vector_container.length:
            raise IndexError("Matrices do not have equal length.")

        cdef double dist = 0.0
        cdef int length = self.vector_container.length
        cdef int i

        for i in range(length):
            dist += exp(self.vector_container._c_vector[i] - other.vector_container._c_vector[i])

        dist = sqrt(dist)
        print(f'{dist=}')
        return dist
    
    def __dealloc__(self):
        """Deallocate memory."""
        if self.vector_container != NULL:
            if self.vector_container._c_vector != NULL:
                free(self.vector_container._c_vector)
            free(self.vector_container)

                    
