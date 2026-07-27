"""
cy_parallel_dataframe.pyx
~~~~~~~~~~~~~~~~~~~~~~~~~
"""
import sys
from Cython.Shadow import CythonDotParallel
from markdown_it.rules_core.normalize import NULL_RE

sys.modules['cython.parallel'] = CythonDotParallel()
from cython.parallel cimport prange
from libc.stdlib cimport malloc, free, atof
from libc.string cimport strcpy, strlen

cdef extern from "string.h":
    char* strtok_r(char* str, const char* delim, char** saveptr) nogil


cdef inline void parse_row(char* row_str, char* delimiter, int target_cols, double* row_container) nogil:
    """Parse a single row of data"""
    cdef char* local_col_ptr = NULL
    cdef int local_c = 0
    cdef char* local_col_token = strtok_r(row_str, delimiter, &local_col_ptr)

    while local_col_token != NULL and local_c < target_cols:
        row_container[local_c] = atof(local_col_token)
        local_c += 1
        local_col_token = strtok_r(NULL, delimiter, &local_col_ptr)


cdef class CyParallelDataFrame(CSVReader):
    """Parallel Cython DataFrame"""
    def __init__(self, char * delimiter, str filename):
        super().__init__(delimiter, filename)
        self.Frame = <__ParallelDataFrame__*>malloc(sizeof(__ParallelDataFrame__))
        if not self.Frame:
            raise MemoryError("Failed to allocate memory for Frame")
        self.Frame.rows = 0
        self.Frame.cols = 0
        self.Frame.container = NULL
        self.Frame.column_names = NULL

    cpdef void csv_to_dataframe(self):
        """
        Load in the csv file and parse it by delimiter.
        """
        # open the file, read the contents, then close the file
        self.open_file()
        self.read_file()
        self.close_file()

        if self.File == NULL or self.File.file_contents == NULL:
            raise ValueError("No data to parse.")
        cdef long f_size = self.file_size
        cdef char *buffer_count = <char *> malloc((f_size + 1) * sizeof(char))
        strcpy(buffer_count, self.File.file_contents)

        # Get data shape
        cdef:
            char * row_ptr = NULL
            char * col_ptr = NULL
            char * token = strtok_r(buffer_count, <char *> "\n", &row_ptr)

        cdef int line_count = 0
        cdef int col_count = 0
        cdef char* col_token

        while token != NULL:
            if line_count == 0:
                col_token = strtok_r(token, self.delimiter, &col_ptr)
                while col_token != NULL:
                    col_count += 1
                    col_token = strtok_r(NULL, self.delimiter, &col_ptr)
            line_count += 1
            token = strtok_r(NULL, <char*>'\n', &row_ptr)
        free(buffer_count)

        self.Frame.rows = line_count - 1
        self.Frame.cols = col_count
        # Allocate memory
        self.Frame.column_names = <char**>malloc(col_count * sizeof(char*))
        self.Frame.container = <double**> malloc(self.Frame.rows * sizeof(double*))

        for j in range(self.Frame.rows):
            self.Frame.container[j] = <double*> malloc(col_count * sizeof(double))


        # Parse the data via parallelism
        cdef char** row_starts = <char**>malloc(line_count * sizeof(char*))
        row_ptr = NULL
        row_starts[0] = strtok_r(self.File.file_contents, <char*>"\n", &row_ptr)

        cdef int i
        for i in range(1, line_count):
            row_starts[i] = strtok_r(NULL, <char*>"\n", &row_ptr)

        # Get column_names
        col_ptr = NULL
        col_token = strtok_r(row_starts[0], self.delimiter, &col_ptr)
        cdef int c = 0
        while col_token != NULL and c < col_count:
            self.Frame.column_names[c] = <char*>malloc((strlen(col_token)+ 1) * sizeof(char))
            strcpy(self.Frame.column_names[c], col_token)
            c += 1
            col_token = strtok_r(NULL, self.delimiter, &col_ptr)

        cdef:
            int r
            int total_rows = self.Frame.rows
            int target_cols = col_count

        cdef double** container = self.Frame.container
        cdef char* delimiter = self.delimiter

        cdef char * local_col_ptr
        cdef int local_c
        cdef char * local_col_token

        with nogil:
            for r in prange(0, total_rows, schedule='static', num_threads=4):
                parse_row(row_starts[r + 1], delimiter, target_cols, container[r])
        free(row_starts)


    cpdef list get_columns(self):
        """Returns the column names in a list"""
        cdef list col_list = []
        if self.Frame != NULL and self.Frame.column_names != NULL:
            for i in range(self.Frame.cols):
                if self.Frame.column_names[i] != NULL:
                    col_list.append(self.Frame.column_names[i].decode('utf-8'))
        return col_list

    cpdef double get_value(self, int row, int col):
        """Get the value of the given index"""
        if 0 <= row < self.Frame.rows and 0 <= col < self.Frame.cols:
            return self.Frame.container[row][col]
        raise IndexError("Index out of range of the DataFrame")

    def shape(self):
        """Get the shape of the dataframe"""
        if self.Frame != NULL:
            return (self.Frame.rows, self.Frame.cols)

    def __dealloc__(self):
        """Deallocate memory"""
        if self.Frame != NULL:
            if self.Frame.column_names != NULL:
                for i in range(self.Frame.cols):
                    if self.Frame.column_names[i] != NULL:
                        free(self.Frame.column_names[i])
                free(self.Frame.column_names)
            if self.Frame.container != NULL:
                for i in range(self.Frame.rows):
                    free(self.Frame.container[i])
                free(self.Frame.container)
            free(self.Frame)
