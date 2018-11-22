from libc.stdlib cimport malloc, realloc, free
from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free


cdef class AllocateMemory:
    """A class for efficient memory allocation"""

    cdef:
        int BUFFER         # size buffer for auto reallocation
        double* data
        int iterator       # start at the first position of data
        int data_length    # length of the array


    def __cinit__(self, size_t number):
        # allocate some memory
        self.iterator = 0 # init iterator
        self.BUFFER = 10  # init BUFFER
        self.data_length = number
        self.data = <double *> PyMem_Malloc(number * sizeof(double))
        self.data_length = number # set the current length of data
        if not self.data:
            raise MemoryError()

    def resize(self, size_t new_number):
        # Allocate new_number * sizeof(double) bytes
        # preserving the current content and making a best-effort to
        # re-use the original data location

        mem = <double *> PyMem_Realloc(self.data, new_number * sizeof(double))
        self.data_length = new_number # resize the length

        if not mem:
            raise MemoryError()
        # Only overwrite the pointer if the memory was really reallocated.
        # On error (mem is NULL), the originally memory has not been freed.
        self.data = mem

    def __dealloc__(self):
        PyMem_Free(self.data) # no-op if self.data is NULL


    def insert(self, double value, re_size=False, int new_number=-1):
        # insert data into the array
        if self.iterator < self.data_length:
            self.data[self.iterator] = value # set the value
            self.iterator += 1  # increment iterator
        elif self.iterator >= self.data_length:
            if re_size:
                if new_number > 0:
                    self.resize(new_number)
                    self.data[self.iterator] = value
                    self.iterator += 1  # increment iterator
                else:
                    print("The value, {} will not be inserted".format(value))
            else:
                raise TypeError()

    def c_print(self):
        print("iterator currently pointing to {}".format(self.iterator))

    def get_values(self):
        cdef counter = 0
        while counter < self.iterator:
            print(self.data[counter])
            counter += 1


