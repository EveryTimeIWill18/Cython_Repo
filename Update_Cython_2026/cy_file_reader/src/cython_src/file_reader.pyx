"""
file_reader.pyx
~~~~~~~~~~~~~~~
"""
from libc.stdlib cimport malloc, realloc, free
from libc.stdio cimport fopen, fclose, FILE, EOF, fseek, SEEK_END, SEEK_SET
from libc.stdio cimport ftell, fgetc, fgets, getc, gets, feof, fread, getline
from libc.string cimport strlen, memcpy, strcpy, strtok, strchr, strncpy



cdef readonly struct FileContents:
    char *file_contents


cdef class CSVReader:
    """Read the contents of a csv file"""

    def __init__(self, char *delimiter, str filename):
        self.File = <FileContents*>malloc(sizeof(FileContents))
        if not self.File:
            raise MemoryError("Failed to allocate FileContents struct.")
        self.delimiter = delimiter

        # self._filename_holder = <bytes>filename
        self.filename = filename.encode('utf-8')
        self.File.file_contents = NULL
        self.EO_STR = 0
        self.file_size = 0
        self.fp = NULL

    cpdef void open_file(self):
        """Open the file for reading"""
        self.fp = fopen(<char*>self.filename, <char*>"r")
        if self.fp == NULL:
            raise FileNotFoundError(2, "No such file or directory: '%s'" % self.filename)
        else:
            self.is_open = 1

    cpdef void close_file(self):
        """Close the file"""
        if self.is_open == 1:
            fclose(self.fp)
            self.is_open = 0

    cpdef void read_file(self):
        """Read the file"""
        if self.is_open == 1:
            fseek(self.fp, 0, SEEK_END)
            self.file_size = ftell(self.fp)

            # Go back to the beginning of the file
            fseek(self.fp, 0 , SEEK_SET)

            self.File.file_contents = <char*>malloc((self.file_size + 1) * sizeof(char))
            if not self.File.file_contents:
                raise MemoryError("Failed to allocate memory for file_contents.")

            fread(self.File.file_contents, 1, self.file_size, self.fp)
            self.File.file_contents[self.file_size] = b'\0' # End of file char

    cpdef str get_contents(self):
        """Return the file contents"""
        if self.File != NULL and self.File.file_contents != NULL:
            return self.File.file_contents.decode('utf-8')
        return ""

    def __dealloc__(self):
        """Free memory"""
        if self.is_open == 1:
            self.close_file()
        if self.File != NULL:
            if self.File.file_contents != NULL:
                free(self.File.file_contents)
            free(self.File)
