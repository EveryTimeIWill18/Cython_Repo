from array import array
import numpy as np
from cython.view cimport array

# using memory views
# memory views provide access to memory but 
#   they cannot allocate memory themselves

# Using built in python arrays to allocate memory
py_arr = array('i', [0]*100) # array storing 100 ints

# numpy array
np_arr = np.zeros(100, dtype=np.intc)

#cython memory view
cpdef memviewprops(int[:] x): # int[:] x declares a one dimensional mv of ints
    print(x.shape)
    print(x.strides)
    print(x.suboffsets)
    print(x.ndim)
    print(x.size)
    print(x.itemsize)
    print(x.nbytes)
memviewprops(np_arr)  # run the funciton

# using c arrays(NOTE: C arrays are immutable)
# to change the size, we must use the C fucntion realloc from #include<stdlib>
# in cython, from libc.stdlib include realloc

cy_arr = array(shape=(10,), itemsize=sizeof(int), format='i')
print(cy_arr.shape)
print(cy_arr.size)
print(cy_arr.nbytes)

# --- static c array
def c_array():
    cdef int c_arr[100]
    return c_arr
print(c_array())

# more with memory views
# memory views support slicing
cdef f(int[:,:] view, int num):
    view[-2:, -2:] = num

def main():
    import numpy
    x = numpy.zeros(shape=(4,4), dtype=numpy.intc)
    f(x, 1)
    print(x)
    
main()

