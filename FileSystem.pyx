# -*- coding: utf-8 -*-
"""
Created on Thu Jan 24 07:51:07 2019

@author: wmurphy

FileSystem.pyx
==============
This cython module is used to speed up portions of 
the python that are slowed from the large overhead
that using pure python creates.
"""
import os
import sys
import cytoolz
cimport cython
from cymem.cymem cimport Pool
from libc.math cimport sqrt
from libc.string cimport strcpy, strlen, memset, memcpy
from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free


cdef enum boolean:
    TRUE = True
    FALSE = False

cdef public struct Path:
    char* path_name
    int num_files
    char** files_array
    boolean is_path

ctypedef Path __cy_path__
    
cdef struct File:
    char* file_name
    char* file_extension  
    boolean is_file

ctypedef File __cy_file__


cdef __cy_path__* set_path(char* cy_str):
    cdef int i = 0
    cdef str py_str
    cdef Py_ssize_t cy_str_len
    
    # - allocate memory for the struct
    temp = <__cy_path__*>PyMem_Malloc(sizeof(__cy_path__))
    if cy_str is not NULL:
        cy_str_len = strlen(cy_str)     # - get the length of the c string
        
        # - allocate memory for the c-string in the Path struct
        temp.path_name = <char*>PyMem_Malloc(cy_str_len * sizeof(char))
        
        # - copy over the c string into python string
        py_str = "".join(
                <str>chr(cy_str[i])
                for i in range(cy_str_len)  
        )  
        
        # - check to make sure the path exists
        if os.path.exists(py_str):
            print("Path: {} exists\n".format(py_str))
            temp.is_path = TRUE
            print("IS PATH = {}".format(temp.is_path))
        else:
            temp.is_path = FALSE
        
        i = 0    # - reset the value of i
        for i in range(cy_str_len):
            # - copy each character into the struct
            temp.path_name[i] = py_str[i]
        return temp
    else:
        print("py_str is null")
  
ctypedef Path* (*__struct_init__)(char *) 
    
    

# - Setup
cdef char* file_path = "Y:\\Shared\\USD\\Business Data and Analytics\\" \
                       "Claims_Pipeline_Files\\SA_Claims\\" \
                       "file_extensions\\raw_eml_files"


cpdef void create_path(char* pth):
    cdef __cy_path__ p
    
    
                       
                      
# - set the file path
set_path(file_path)
