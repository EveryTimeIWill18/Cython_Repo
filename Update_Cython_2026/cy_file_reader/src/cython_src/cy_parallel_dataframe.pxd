"""
cy_parallel_dataframe.pxd
~~~~~~~~~~~~~~~~~~~~~~~~~
"""
from file_reader cimport CSVReader


cdef struct __ParallelDataFrame__:
    double **container
    char **column_names
    int rows
    int cols


cdef class CyParallelDataFrame(CSVReader):
    """This class is used to create a fast and efficient parallel data frame in Cython"""

    cdef:
        __ParallelDataFrame__ *Frame

    cpdef void csv_to_dataframe(self)
    cpdef list get_columns(self)
    cpdef double get_value(self, int row, int col)
