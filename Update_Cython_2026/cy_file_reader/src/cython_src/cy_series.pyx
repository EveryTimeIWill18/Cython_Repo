"""
cy_series.pyx
~~~~~~~~~~~~
"""
import numpy as np
from libc.stdlib cimport malloc, free, atof
from file_reader cimport CSVReader
from libc.string cimport strcpy, strlen

# Manually add POSIX header declaration to import strtok_r
cdef extern from "string.h":
    char* strtok_r(char* str, char* delim, char** saveptr) nogil


cdef class CySeries:
    """Cython Series implementation"""
    def __init__(self, char* name):
        # Initialize the DataFrame
        self.Series = <__Series__*>malloc(sizeof(__Series__))
        if not self.Series:
            raise MemoryError("Failed to allocate memory for the Series.")
        self.Series.name = <char*>malloc((strlen(name) + 1)*sizeof(char))
        if not self.Series.name:
            free(self.Series)
            raise MemoryError("Failed to allocate memory for the Series.name.")
        strcpy(self.Series.name, name)
        self.Series.index = NULL
        self.Series.container = NULL
        self.Series.length = 0

    cpdef void load_data(self, object dataset):
        """Load in the dataset"""
        cdef double[:] numpy_dataset = np.array(dataset, dtype=np.float64)
        cdef int data_length = numpy_dataset.shape[0]
        cdef int i

        self.Series.container = <double*>malloc(data_length * sizeof(double))
        self.Series.index = <int*>malloc(data_length * sizeof(int))
        if not self.Series.container and not self.Series.index:
            raise MemoryError("Failed to allocate memory for the Series container.")

        for i in range(data_length):
            self.Series.container[i] = numpy_dataset[i]
            self.Series.index[i] = i
        self.Series.length = data_length

    cpdef dict get_data(self):
        """Return the data"""
        cdef int data_length = self.Series.length
        cdef str data_name = self.Series.name.decode('utf-8')
        cdef dict data_set = {}
        cdef list data = []
        cdef int i
        if data_length > 0:
            for i in range(data_length):
                data.append((self.Series.index[i], self.Series.container[i]))
            data_set[data_name] = data
        return data_set

    def __dealloc__(self):
        """Deallocate memory"""
        if self.Series != NULL:
            if self.Series.name != NULL:
                free(self.Series.name)
            if self.Series.container != NULL:
                free(self.Series.container)
            free(self.Series)
