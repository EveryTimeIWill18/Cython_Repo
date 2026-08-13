"""
cy_vector.pxd
~~~~~~~~~~~~~
"""

cdef struct IntVector:
    int* _c_vector
    int length

cdef struct FloatVector:
    float* _c_vector
    int length

cdef struct DoubleVector:
    double* _c_vector
    int length




cdef class Vector:
    cdef:
        DoubleVector* vector_container

    cpdef void initialize_vector(self, double[:] data)
    cpdef void insert(self, int index, double value)

    cpdef Vector vector_sum(self, Vector other)
    cpdef Vector vector_subtraction(self, Vector other)
    cpdef double dot_product(self, Vector other)
    cpdef Vector scalar_multiply(self, double scalar)
    cpdef double vector_mean(self)
    cpdef double sum_of_squares(self)
    cpdef double magnitude(self)
    cpdef double distance(self, Vector other)
    cpdef int get_length(self)
