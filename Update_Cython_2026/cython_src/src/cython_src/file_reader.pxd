"""
file_reader.pxd
~~~~~~~~~~~~~~~
The .pxd file acts as a C-style header file.
"""
from libc.stdio cimport FILE

cdef readonly struct FileContents:
    char *file_contents



cdef class CSVReader:
    """Read the contents of a csv file"""
    cdef:
        FileContents *File
        FILE *fp
        # bytes _filename_holder  # Keep underlying c-string alive in memory
        bytes filename
        char *delimiter
        long file_size
        bint is_open
        bint EO_STR

    cpdef void open_file(self)
    cpdef void read_file(self)
    cpdef void close_file(self)
    cpdef str get_contents(self)
