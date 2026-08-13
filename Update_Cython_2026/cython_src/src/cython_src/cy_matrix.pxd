"""
cy_matrix.pxd
~~~~~~~~~~~~~~
"""
from cy_vector cimport Vector, DoubleVector




cdef struct CyMatrix:
    double ** _c_matrix
    int num_rows
    int num_cols


cdef class Matrix:
    cdef:
        CyMatrix* matrix_container

    cdef void initialize_matrix(self, double[:, :] init_matrix)
