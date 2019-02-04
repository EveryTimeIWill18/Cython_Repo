import os
import sys
cimport cython
from libc.stdlib cimport malloc, free, realloc
from libc.string cimport strcmp
from libc.string cimport memcpy
from libc.string cimport memset
from libc.string cimport strlen
from libc.math cimport sqrt
from cpython.string cimport PyString_AsString
from cython.view cimport array as cvarray
from cymem.cymem cimport Pool # wrapper around calloc function
from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free


# - Create a struct that will hold the file information
cdef struct Container:
    int num_files
    char* file_path
    char* file_name
    char** file_array

cdef class FileSystem:
    """
    FileSystem
    ----------
    Cython class to efficiently calculate 
    file system tasks.
    """
    cdef readonly int num_files        # current number of files
    cdef int fp_size
    cdef int cf_size
    cdef int f_arr_size
    cdef char* file_path               # file path name
    cdef char* current_file   # current file being pointed to
    cdef char** file_array    # array of file names
    
    def __init__(self, size_t fp_size, size_t cf_size, size_t f_arr_size, threads=1):
        self.fp_size = fp_size
        self.cf_size = cf_size
        self.f_arr_size = f_arr_size
        
        self.file_path = <char*>PyMem_Malloc(self.fp_size * sizeof(char))
        self.current_file = <char*>PyMem_Malloc(self.cf_size * sizeof(char))
        self.file_array = <char**>PyMem_Malloc(self.f_arr_size * sizeof(char *))
    
    def realloc_file_path(self, size_t n)-> None:
        """
        Reallocate memory for the file_path variable.
        """
        mem = <char *>PyMem_Realloc(self.file_path, n * sizeof(char))
        self.fp_size = n  # update the value
        if not mem:
            raise MemoryError()
        self.file_path = mem # increase the size
    
        
    def set_file_path(self, str fp) -> None:
        """
        Set the file path.
        """
        if os.path.exists(fp):
            print("Path: {} exists".format(fp))
            
        else:
            print("Could not find path: {}".format(fp))

    
    def copy_char_array(char* char_array, int input_arr_size):
        """
        Copy over the previously stored array
        of characters to a new character array.
        """
        cdef Py_ssize_t str_length = strlen(char_array)
        if str_length < input_arr_size:
            print("There is enough memory to store the string")
        else:
            print("WARNING!! There is not enough memory!!")
        
    
    
    
# - test out the FileSystem cython class
########################################################################
fs = FileSystem(15, 15, 15)
file_path = "Y:\\Shared\\USD\\Business Data and Analytics\\" \
            "Claims_Pipeline_Files\\SA_Claims\\file_extensions\raw_eml_files"

fs.set_file_path(file_path)


from libc.stdlib cimport free, malloc, realloc, calloc
from libc.string cimport strcpy, strlen


cdef enum boolean:
    TRUE = True
    FALSE = False
    
cdef readonly struct Path:
    char* name
    Py_ssize_t length
    boolean is_path

    
    

# - file_path is a character array
cdef char* file_path = "Y:\\Shared\\USD\\Business Data and Analytics\\" \
                       "Claims_Pipeline_Files\\SA_Claims\\file_extensions\raw_eml_files"

# - calculate the size of the character array
cdef Py_ssize_t p_length = strlen(file_path)



cdef class FilePaths:
    cdef readonly char* c_str_fp
    cdef readonly Py_ssize_t c_str_length
    cdef Path* struct_file_path_one
    
    def __init__(self, char* c_str_fp):
        self.c_str_fp = c_str_fp
        self.c_str_length = strlen(self.c_str_fp)
        self.struct_file_path_one = <Path*>malloc(10 * sizeof(Path))
        
        # - set the struct attributes
        self.struct_file_path_one.name = self.c_str_fp
        self.struct_file_path_one.length = self.c_str_length
        


path_one = FilePaths(file_path)
path_ = path_one.c_str_fp
print(unicode(path_))


import os
import sys
from libc.stdlib cimport free, malloc, realloc, calloc
from libc.string cimport strcpy, strlen


cdef enum boolean:
    TRUE = True
    FALSE = False
    
cdef readonly struct Path:
    char* name
    Py_ssize_t length
    boolean is_path

cdef class FilePaths:
    cdef readonly char* c_str_fp
    cdef readonly Py_ssize_t c_str_length
    cdef Path* struct_file_path_one
    
    def __init__(self, char* c_str_fp):
        self.c_str_fp = c_str_fp
        self.c_str_length = strlen(self.c_str_fp)
        self.struct_file_path_one = <Path*>malloc(10 * sizeof(Path))
        
    
# - Setup
###############################################################################
# - file_path is a character array
cdef char* file_path = "C:\\"   # 67 58 92
path_one = FilePaths(file_path)

cdef char* fPtr
cdef str py_str_fp = <str> path_one.c_str_fp

cdef int i = 0
cdef str py_str = "".join(<str>chr(path_one.c_str_fp[i]) for i in range(path_one.c_str_length))

path_ = "C://"

# cython: embedsignature=True

cdef double invert(int x) except *:   # - raise exception, use * to get information
    cdef double a
    a = 1/x
    return a

def pyinvert(x):
    """
    Python implementation 
    of the invert function.
    """
    return invert(x)
    
    
    
 # cython: embedsignature=True
# cython: language_level=3

from libc.string cimport strcat


# NOTE: must use bytes!
# python strings may be faster than c-strings

# - example
def f1(a, b):
    cdef char* ca
    cdef char* cb
    pa = a.encode('utf-8')
    pb = a
    
    
# - syntax for memoryviews
def h(double[:,:,:] x):
    cdef int n, m, p  # Range dimensions
    # - Access shape attribute for sizes
    n = x.shape[0]
    m = x.shape[1]
    p = x.shape[2]
    
    cdef int i, j, k  # Loop  variables
    for i in range(n):
        for j in range(m):
            for k in range(p):
                # <do something with x[i,j,k]>
                pass
                
import threading

# - TO RELEASE THE GIL, USE NOGIL
cdef f(int x) nogil:
    # - safe to call from a nogil lock
    cdef int y
    y = x + 1
    return x + 1

cdef h(int x):
    # - releases the GIL
    cdef int y
    with nogil:
        y = x + 1
    return x + 1
    
    
# cython: boundscheck = False
# distutils: extra_compile_args = -fopenmp
# distutils: extra_link_args = -fopenmp

# - parallel version
# - must add the above for bypassing the GIL

from cython.parallel cimport prange
from libc.math cimport log

def fastlog(double[:] x, double[:] out):
    cdef int i, n = x.shape[0]
    for i in prange(n, nogil=True):
        out[i] = log(x[i])
    return out
    
    
 from cython.parallel cimport prange
from libc.math cimport log

def single_thread_fastlog(double[:] x, double[:] out):
    cdef int i, n = x.shape[0]
    for i in range(n):
        out[i] = log(x[i])
    return out
    
    
# cython: boundscheck = False
# cuthon: wraparound = False
from cpython.datetime cimport(
    import_datetime, datetime_new, dattime, timedelta,
    timedelta_seconds, timedelta_days)

import_datetime() # <--- important!

cpdef convert_arraysdt(long[:] year, long[: month, long[:] day,
                                          long long[:] out):
    """long goes into out"""
    cdef int i, n = year.shape[0]
    cdef datetime dt, epoch = datetime_new(1970, 1, 1, 0, 0, 0, None)
    cdef timedelta
    cdef long seconds 
    for i in range(n):
    dt = <timedelta>datetime_new(
        year[i], month[i], day[i], 1, 1, 0, 0, 0, 0, None)
    td = <timedelta>(dt-epoch)
    seconds = timedelta.keys(td) * 86400
    out[i] = timedelta_days(td)*86400
