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
        
    cpdef CySeries mul(self, CySeries other, char* new_name):
        """Multiplies the values of two CySeries containers"""
        if self.Series.container == NULL or other.Series.container == NULL:
            raise  ValueError("Containers are NULL.")

        if self.Series.length != other.Series.length:
            raise IndexError("Lengths of the containers do not match.")

        cdef int length = self.Series.length
        cdef char* series_name = <char*>malloc(strlen(new_name) * sizeof(char))
        strcpy(series_name, new_name)

        cdef CySeries output_series = CySeries(name=series_name)
        output_series.Series.container = <double*>malloc(length * sizeof(double))
        output_series.Series.length = length

        cdef double* container1 = self.Series.container
        cdef double* container2 = other.Series.container
        cdef double* result_container = output_series.Series.container
        cdef int i

        for i in range(length):
            result_container[i] = (container1[i]*container2[i])
        return output_series
    
    cpdef double pop(self, int index_):
        """Get the value at a given index"""
        if self.Series == NULL or self.Series.container == NULL:
            raise ValueError("Series or Series container is empty.")
        if index_ < 0 or index_ > self.Series.length:
            raise IndexError("Index is out of bounds.")

        cdef double value = self.Series.container[index_]
        cdef int i
        cdef int updated_length = self.Series.length - 1
        cdef double* temp_container = NULL
        temp_container = <double*>malloc(updated_length * sizeof(double))
        
        if temp_container == NULL:
            raise ValueError("Temp container is empty.")

        for i in range(self.Series.length):
            if i < index_:
                temp_container[i] = self.Series.container[i]
            elif i >= index_:
                temp_container[i] = self.Series.container[i + 1]

        self.Series.container = temp_container
        self.Series.length = updated_length
        temp_container = NULL
        return value

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
