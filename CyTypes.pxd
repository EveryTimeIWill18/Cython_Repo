# -*- coding: utf-8 -*-
"""
Created on Thu Jan 24 07:51:07 2019

@author: wmurphy

CyTypes.pyx
==============
This cython module acts as a C header file. It creates the
definitions of the new types that will be used in modules 
relying on this code.

"""
import os
import sys
import cytoolz
cimport cython
from cymem.cymem cimport Pool
from libc.math cimport sqrt
from libc.string cimport strcpy, strlen, memset, memcpy
from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

# - Enums and Structs
###############################################################################
# - enum type: used for true false
cdef public enum boolean:
    TRUE=True
    FALSE=False

# - struct type: used for creation of file paths
cdef public struct __cy_path__:
    char* path_name
    Py_ssize_t length
    boolean is_path
    char** files_array
ctypedef __cy_path__ Path # - typedef for __cy_path__

# - struct type: used for creation of file stores
cdef public struct __cy_file__:
    char* file_name
    Py_ssize_t length
    boolean is_file
ctypedef __cy_file__ File # - typedef for __cy_file__


# - Template Types
###############################################################################
ctypedef fused file_system_utils:
    Path 
    File


# - Methods
###############################################################################
ctypedef Path* (*set_file_path)(char *)
