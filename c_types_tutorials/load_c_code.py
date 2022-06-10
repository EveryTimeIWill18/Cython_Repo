"""
load_c_code.py
~~~~~~~~~~~~~~
This module is sued for wrapping and loading in our
C code so it can used inside our Python applications

This is a nice way to Pythonify our C code. Remember, your team will likely not be very good at C and by designing class
wrappers around our C code, we abstract away the difficulties of havign to work with C.

For an additional upgrade, you could create a parent class for our Python class C wrappers as you will see,
some of the methods within each Python class are repeated, breaking the cardinal rule of, "Don't Repeat Yourself",
but that's not really important for this lesson


"""
import os
import ctypes
from pathlib import Path
from typing import List, Set, Dict, NewType, Tuple


# Python implementations of C-structs
class LevDistance(ctypes.Structure):
    _fields_ = [
        ('input_key', ctypes.POINTER(ctypes.c_char)),
        ('string_to_match', ctypes.POINTER(ctypes.c_char)),
        ('lev_distance', ctypes.c_ulong),
        ('ratio', ctypes.c_double)
    ]

class LCSStruct(ctypes.Structure):
    _fields_ = [
        ('str_one', ctypes.POINTER(ctypes.c_char)),
        ('str_two', ctypes.POINTER(ctypes.c_char)),
        ('str_one_len', ctypes.c_int),
        ('str_two_len', ctypes.c_int),
        ('lcs_matrix', ctypes.POINTER(ctypes.POINTER(ctypes.c_int))),
        ('result', ctypes.c_int),
        ('lcs_ratio', ctypes.c_double)
    ]



class C_CodeWrapper:
    """A Parent class for wrapping defining methods that
    will be used in all children classes
    """
    def __init__(self, f_path: str, f_name: str):
        self.f_path = f_path
        self.f_name = f_name
        # ctypes attributes
        self.c_library = ctypes.CDLL(os.path.join(self.f_path, self.f_name))

    def c_setup(self):
        """This method is used to setup the required items
        needed for use of the C library
        """
        pass




class LevenshteinDistance:
    """A class that loads in the C implementation
    of the Levenshtein distance algorithm
    """

    def __init__(self, f_path: str, f_name: str):
        self.f_path = f_path
        self.f_name = f_name
        # ctypes attributes
        self.c_library = ctypes.CDLL(os.path.join(self.f_path, self.f_name))


    def c_setup(self):
        """This method is used to setup the required items
        needed for use of the C library
        """
        self.lev_distance_struct = ctypes.POINTER(LevDistance)

        # Initialize and allocate memory for the lev distance struct
        self.create_str_dist_struct = self.c_library.create_str_dist_struct
        self.create_str_dist_struct.restype = self.lev_distance_struct

        # Setup the C function that computes lev distance
        self.compute_str_distance = self.c_library.compute_str_distance

        # Setup the C function that returns the lev distance
        self.get_lev_distance = self.c_library.get_lev_distance
        self.get_lev_distance.restype = ctypes.c_ulong

        # Setup the C function that returns the lev distance ratio
        self.get_lev_ratio = self.c_library.get_lev_ratio
        self.get_lev_ratio.restype = ctypes.c_double

        # Setup the C function that free allocated memory
        self.destroy_str_dist_struct = self.c_library.destroy_str_dist_struct

    def compute_lev_distance(self, str_1: bytes, str_2: bytes):
        """A wrapper around the lev distance C function"""

        # Remove spaces from the bytes names
        b1 = str_1.split(b' ')
        b2 = str_2.split(b' ')

        bytes_str_1 = b''.join(b for b in b1)
        bytes_str_2 = b''.join(b for b in b2)

        print(f"{bytes_str_1=}\n{bytes_str_2=}")

        # Create an instance of the struct
        self.lev_dist_struct_instance = self.lev_distance_struct()
        self.lev_dist_struct_instance = self.create_str_dist_struct(
            ctypes.c_char_p(bytes_str_1), ctypes.c_char_p(bytes_str_2)
        )

        # Execute Lev distance computation
        self.compute_str_distance(self.lev_dist_struct_instance)

    def get_distance(self) -> int:
        """Returns the Lev distance"""
        return self.get_lev_distance(self.lev_dist_struct_instance)

    def get_ratio(self) -> float:
        """Returns the Lev ratio"""
        return self.get_lev_ratio(self.lev_dist_struct_instance)

    def free(self) -> None:
        """Free the allocated memory"""
        self.destroy_str_dist_struct(self.lev_dist_struct_instance)



class LongestCommonSubstring:
    """A class that loads in the C implementation
        of the Longest Common Substring
    """
    def __init__(self, f_path: str, f_name: str):
        self.f_path = f_path
        self.f_name = f_name
        # ctypes attributes
        self.c_library = ctypes.CDLL(os.path.join(self.f_path, self.f_name))

    def c_setup(self):
        """This method is used to setup the required items
        needed for use of the C library
        """

        self.lcs_struct = ctypes.POINTER(LCSStruct)

        # Map init_lcs C function
        self.init_lcs = self.c_library.init_lcs
        self.init_lcs.restype = self.lcs_struct

        # Map lcs_algorithm C function
        self.lcs_algorithm = self.c_library.lcs_algorithm

        # Map get_lcs_result C function
        self.get_lcs_result = self.c_library.get_lcs_result
        self.get_lcs_result.restype = ctypes.c_int

        # Map get_lcs_ratio C function
        self.get_lcs_ratio = self.c_library.get_lcs_ratio
        self.get_lcs_ratio.restype = ctypes.c_double

        # Free the memory
        self.destroy_lcs = self.c_library.destroy_lcs

    def compute_lcs(self, str_1: bytes, str_2: bytes):
        """A wrapper aroundLongest Common Substring algorithm"""

        # Create an instance of the struct
        self.lcs_struct_instance = self.lcs_struct()
        self.lcs_struct_instance = self.init_lcs(
            ctypes.c_char_p(str_1), ctypes.c_char_p(str_2)
        )
        # Execute LCS computation
        self.lcs_algorithm(self.lcs_struct_instance)

    def get_result(self) -> int:
        """Returns an integer of the LCS"""
        return self.get_lcs_result(self.lcs_struct_instance)

    def get_ratio(self) -> float:
        """Returns the LCS ratio"""
        return self.get_lcs_ratio(self.lcs_struct_instance)

    def free(self) -> None:
        """Free the allocated memory"""
        self.destroy_lcs(self.lcs_struct_instance)










def main():
    f_path = os.path.join(Path(__file__).parent, 'c_algorithms')
    c_lev_file = 'nlp_algorithms.so'
    c_lcs_file = 'lcs.so'

    lev_distance = LevenshteinDistance(f_path=f_path, f_name=c_lev_file)
    lev_distance.c_setup()
    # lev_distance.compute_lev_distance(str_1='JAMES', str_2='JAMES BOBY')
    lev_distance.compute_lev_distance(str_1=b'WILLIAM MURPHY', str_2=b'WILLIAM  R  MURPHY   ')

    lev_dist = lev_distance.get_distance()
    print(f"{lev_dist=}")
    lev_ratio = lev_distance.get_ratio()
    print(f"{lev_ratio=}")

    lev_distance.free()


    lcs = LongestCommonSubstring(f_path=f_path, f_name=c_lcs_file)
    lcs.c_setup()
    lcs.compute_lcs(str_1=b"ABDAG", str_2=b"ABDAG")
    lcs_result = lcs.get_result()
    print(f"{lcs_result=}")
    lcs_ratio = lcs.get_ratio()
    print(f"{lcs_ratio=}")









if __name__ == '__main__':
    main()
