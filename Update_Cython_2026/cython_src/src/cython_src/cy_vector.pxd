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
