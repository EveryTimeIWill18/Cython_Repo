import numpy as np
import array
import os
import sys
import psutil

# import malloc, free, and dealloc from C standard library
from libc.stdlib cimport malloc, realloc, free

cdef class A:
    cdef list items # Python list
    cdef int* vec  # C-level dynamic array
    
    def __cinit__(self, num_list, num_vec):
        """will be called exactly once"""
        self.vec = <int*> malloc(num_vec * sizeof(int))
    
    def __init__(self, num_list, num_vec):
        """will be called from 0 to many times"""
        self.items = [0] * num_list
        
    def __dealloc__(self):
        """called only once during object destruction"""
        free(self.vec)
    

cdef class Vector:
    cdef:
        double *vec          # pointer to double. i.e an array of doubles
        long length          # length of the vector
        public double[:] mv  # memory view. Can be utilized in pure python
        
    def __cinit__(self, long length):
        """cinit: called exactly once"""
        self.change_length(length)
    
    cpdef change_length(self, long newlength):
        """re-allocate memory to change the size of the vector"""
        self.vec = <double*>realloc(self.vec, newlength * sizeof(double))
        self.mv = <double[:newlength]>self.vec
        self.length = newlength
    
    def __dealloc__(self):
        """de-allocate sequestered memory"""
        free(self.vec)  # must free memory or memory leaks can occur!
        pass
        
def memory():
    """testing the memroy usage"""
    pid = os.getpid()
    proc = psutil.Process(pid)
    mem = proc.memory_info()
    mem_used = mem.vms/1024/1024
    print(mem)
    print('Memory used: {:.2f} MB'.format(mem.vms/1024/1024))
    
# check memory usage
baseline = memory()
a = Vector(2)
mem_a = memory()
print(mem_a - baseline)
    return mem_used
