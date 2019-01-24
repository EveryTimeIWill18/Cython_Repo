# -*- coding: utf-8 -*-
"""
Created on Thu Jan 24 07:51:07 2019

@author: wmurphy

Optimizers.pyx
==============
This cython module is used to speed up portions of 
the python that are slowed from the large overhead
that using pure python creates.
"""
import os
import sys
import time
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
# - convert to python string
cdef str py_str = "".join(<str>chr(path_one.c_str_fp[i]) for i in range(path_one.c_str_length))


