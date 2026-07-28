"""
cy_data_frame.pxd
~~~~~~~~~~~~~~~~~~
"""
from file_reader cimport CSVReader

# Create a new (fused) type
ctypedef fused numeric:
    int
    float
    double
    long

ctypedef fused any_type:
    numeric
    char

cdef struct __DataFrame__:
    double **container
    char **column_names
    int rows
    int cols


cdef class CyDataFrame(CSVReader):
    """This class is used to create a fast and efficient data frame in Cython"""

    cdef:
        __DataFrame__ *Frame

    cpdef void csv_to_dataframe(self)
    cpdef list get_columns(self)
    cpdef double get_value(self, int row, int col)
    cpdef dict head(self, int n_rows, int m_cols)
    cpdef dict tail(self, int n_rows, int m_cols)
    cpdef dict iloc(self, object rows)

