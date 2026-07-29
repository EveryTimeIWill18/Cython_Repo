"""
cy_series.pxd
~~~~~~~~~~~~~
"""
from file_reader cimport CSVReader


ctypedef fused numeric:
    int
    float
    double
    long

ctypedef fused any_type:
    numeric
    char


cdef struct __Series__:
    double *container
    char* name
    int length
    int* index



cdef class CySeries:
    """Cython Series implementation"""
    cdef:
        __Series__* Series

    # cpdef void csv_to_series(self)
    cpdef void load_data(self, object dataset)
    cpdef dict get_data(self)
    cpdef double pop(self, int index_)
    # cpdef str get_name(self)
    # cpdef double get_value(self, int index)
