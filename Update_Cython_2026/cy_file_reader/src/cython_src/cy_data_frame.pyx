"""
cy_data_frame.pyx
~~~~~~~~~~~~~~~~~~~
"""
from libc.stdlib  cimport malloc, realloc, free, atof
from file_reader cimport CSVReader
from libc.string cimport strtok, strcpy, strlen

# Manually add POSIX header declaration to import strtok_r
cdef extern from "string.h":
    char* strtok_r(char* str, char* delim, char** saveptr) nogil



cdef class CyDataFrame(CSVReader):
    """This class is used to create a fast and efficient data frame in Cython"""

    def __init__(self, char* delimiter, str filename, int initial_size=10):
        # Initialize the DataFrame
        super().__init__(delimiter, filename)
        self.Frame = <__DataFrame__*> malloc(sizeof(__DataFrame__))
        if not self.Frame:
            raise MemoryError("Failed to allocate memory for Frame")
        self.Frame.rows = 0
        self.Frame.cols = 0
        self.Frame.container = NULL
        self.Frame.column_names = NULL
        # self.Frame.container = <any_type**>malloc(initial_size * sizeof(any_type))

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
            char* row_ptr = NULL
            char* col_ptr = NULL
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
        self.Frame.container =<double**>malloc(self.Frame.rows * sizeof(double*))

        for i in range(self.Frame.rows):
            self.Frame.container[i] = <double*>malloc(col_count * sizeof(double))

        # Fill in column names
        cdef char* buffer_parser = <char*>malloc((f_size + 1) * sizeof(char))
        if not buffer_parser:
            raise MemoryError("Failed memory allocation for buffer_parser.")
        strcpy(buffer_parser, self.File.file_contents)

        # Redefine row reference
        row_ptr = NULL
        token = strtok_r(buffer_parser, <char*>"\n", &row_ptr)

        cdef:
            int current_row = 0
            int current_col = 0
            int index = 0

        while token != NULL:
            current_col = 0
            col_ptr = NULL
            if index == 0:
                # Read in the columns
                col_token = strtok_r(token, self.delimiter, &col_ptr)
                while col_token != NULL and current_col < col_count:
                    self.Frame.column_names[current_col] = <char*>malloc((strlen(col_token)+ 1) * sizeof(char))
                    strcpy(self.Frame.column_names[current_col], col_token)
                    current_col += 1
                    col_token = strtok_r(NULL, self.delimiter, &col_ptr)
            else:
                # Read in the actual data now
                col_token = strtok_r(token, self.delimiter, &col_ptr)
                while col_token != NULL and current_col < col_count:
                    if current_row < self.Frame.rows:
                        self.Frame.container[current_row][current_col] = atof(col_token)
                    current_col += 1
                    col_token = strtok_r(NULL, self.delimiter, &col_ptr)
                current_row += 1
            index += 1
            token = strtok_r(NULL, <char*>'\n', &row_ptr)
        free(buffer_parser)

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
