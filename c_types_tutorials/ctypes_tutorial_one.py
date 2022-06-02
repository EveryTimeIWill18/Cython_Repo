"""
ctypes_tutorial_one.py
~~~~~~~~~~~~~~~~~~~~~~
 In the first tutorial, we will load in the shared .so file that we created. 
 In case you've not looked at the .c file, to create a shared .so file, please move to the directory where
 your C file lives, and type the following in the command line:
 
      cc -fPIC -shared -o nlp_algorithms.so nlp_algorithms.c

This will create the shared .so file that ctypes will need in order to utilize the code written in your C file.
"""
import os
from typing import List, Set, Dict, Tuple, Any
from pathlib import Path
import ctypes

# The root dir of the project (this may change depending on your folder structure)
SRC_DIR = Path(__file__).resolve().parent

# Create the full path to the .so file
SO_DIR = os.path.join(SRC_DIR, 'c_types_tutorials', 'nlp_algorithms.so')


# Create a class that will be used to store our C struct
class StringDistance(ctypes.Structure):
    # All structs require the _fields_: List[Tuple[Any]] data structure
    _fields_ = [
        ('input_key', ctypes.POINTER(ctypes.c_char)),           # input_key:  a pointer to an array of chars
        ('string_to_match', ctypes.POINTER(ctypes.c_char)),     # string_to_match: a pointer to an array of chars
        ('lev_distance', ctypes.c_ulong),                       # lev_distance:  an unsigned long (int)
        ('ratio', ctypes.c_double)                              # ratio:  a double
    ]

# Create the pointer to the struct
str_distance_pointer = ctypes.POINTER(StringDistance)

# Load in the .so file (our user-created C library)
c_library = ctypes.CDLL(SO_DIR)
    
# Create an object that is mapped to the 'create_str_dist_struct' from our C code
initialize_str_distance = c_library.create_str_dist_struct

# Set the function return type (using: restype)
initialize_str_distance.restype = str_distance_pointer

# Create an object that is mapped to the 'compute_str_distance' from our C code
compute_dist = c_library.compute_str_distance

# Create an object that is mapped to the 'destroy_str_dist_struct' from our C code
free_mem = c_library.destroy_str_dist_struct

# Create the struct instance and then set it to initialize_str_distance function, passing in the required variables
struct_one = str_distance_pointer()
struct_one = initialize_str_distance(ctypes.c_char_p(b'kitten'), ctypes.c_char_p(b'sitting'))

# Compute the string distance
compute_dist(struct_one)
