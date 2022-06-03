"""
longest_common_substring.py
~~~~~~~~~~~~~~~~~~~~~~~~~~~
TO BE REMOVED:
  This script will be converted to C with a Python wrapper, just using GitHua as a glorified folder
  
  The code base contains a string combinatorial algorithm that I created from scratch (will be moved to C)
"""
import os
from typing import List, Set, Dict, NewType, Tuple



class LongestCommonSubstring:
    """This class is used to get the longest common substrings
    between the two strings
    """

    def __init__(self):
        self.longest_common_substring: List[Dict[str, Tuple[str]]] = []
        self.string_one: str = ''
        self.string_two: str= ''
        self.string_one_combinations: List[str] = []
        self.string_two_combinations: List[str] = []

    def __call__(self, str_one: str, str_two: str):
        # Call string_combinations function twice
        self.string_one = str_one
        self.string_two = str_two
        self.string_combinations(input_string=self.string_one, str_combinations_list=self.string_one_combinations)
        self.string_combinations(input_string=self.string_two, str_combinations_list=self.string_two_combinations)
        pprint(f"{self.string_one_combinations=}")
        pprint(f"{self.string_two_combinations=}")


    def string_combinations(self, input_string: str, str_combinations_list: List[str]) -> List[str]:
        """Generate all possible string combinations (w/o replacement)
        for the given input string
        """
        str_size = 2
        pointer_ = 0
        combinations_list = []
        while True:
            if str_size == 2:
                if pointer_ == len(input_string) - 1:
                    str_size += 1
                temp_str = input_string[pointer_]
                other_ = input_string[pointer_ + 1:]
                while len(other_) > 0:
                    if len(temp_str) == str_size:
                        combinations_list.append(temp_str)
                        str_combinations_list.append(temp_str)
                        temp_str = input_string[pointer_]
                    else:
                        temp_str += other_[0]
                        other_ = other_[1:]
                        if len(other_) == 0:
                            combinations_list.append(temp_str)
                            str_combinations_list.append(temp_str)
                pointer_ += 1
            elif str_size > 2 and str_size < len(input_string):
                temp_combinations_list = []
                for s in combinations_list:
                    if len(s) == str_size - 1:
                        substr_pos = input_string.find(s[-1])
                        substring = input_string[substr_pos + 1:]
                        for c in substring:
                            new_substring = s + c
                            temp_combinations_list.append(new_substring)
                            str_combinations_list.append(new_substring)
                if len(temp_combinations_list) > 0:
                    combinations_list = [*combinations_list, *temp_combinations_list]
                    str_combinations_list = [*str_combinations_list, *temp_combinations_list]
                    str_size += 1
            else:
                print(f"IN FINAL ELSE!!!!!!!!!")
                combinations_list.append(input_string)
                str_combinations_list.append(input_string)
                pprint(f"FINAL LIST: {str_combinations_list=}")
                break
        return str_combinations_list

lcs_one = LongestCommonSubstring()
lcs_one(str_one='ABCD', str_two='ACBAD')
