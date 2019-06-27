# -*- coding: utf-8 -*-
"""
data_mining.pyx
~~~~~~~~~~~~~~~
This module is a cython pyx file that is used to mine text efficiently
from the various support file formats.
"""
# -- python imports
import os
import sys
import time
# -- cython c imports
from libc.stdlib cimport malloc, realloc, free
from libc.stdio cimport fopen, fclose, FILE, EOF, fseek, SEEK_END, SEEK_SET
from libc.stdio cimport ftell, fgetc, fgets, getc, gets, feof, fread, getline
from libc.string cimport strlen, memcpy, strcpy, strtok, strchr, strncpy
from cython.parallel import prange, parallel, threadid

# preprocessor directive
DEF BUFFER = 100

# template for numeric types
ctypedef fused numeric_var:
    int
    long
    long long
    float
    double

cdef readonly struct Token:
    char **token_array
    int *token_size_array
    
cdef readonly struct Columns:
    char **column_array
    
cdef readonly struct Rows:
    Columns *Col
    
cdef readonly struct DataContainer:
    char ***data_frame
    char *columns
    char **data_array
    
cdef class Tokenize:
    """Tokenize the input file/string"""
    cdef Token *Tok
    cdef FILE *fp
    cdef readonly:
        char *filename
        char *column_header
        char *delimiter
        char newline
        char *file_contents
        char current_char
        int iterator
        int c
        int num_columns
        long file_size
        int num_tokens
        bint is_open
        bint EO_STR
    
    def __init__(self, char *delimiter, char *filename):
        self.Tok = <Token*>malloc(sizeof(Token))
        self.delimiter = delimiter
        self.newline = b"\n"
        self.fp = NULL
        self.filename = filename
        self.column_header = NULL
        self.file_contents = NULL
        self.file_size = 0
        self.num_tokens = 0
        self.iterator = 0
        self.current_char = b" "
        self.c = 0
        self.EO_STR = 0
        self.num_columns = 0
       
    def open_file(self):
        """Open the file for reading."""
        self.fp = fopen(self.filename, "r")
        if self.fp == NULL:
            raise FileNotFoundError(2, "No such file or directory: '%s'" % self.filename)
        else:
            # the file is now open
            self.is_open = 1
    
    def close_file(self):
        """Close the opened file."""
        if self.is_open == 1:
            if self.fp != NULL:
                fclose(self.fp)
                self.is_open = 0
            else:
                raise Exception(2, "An error occurred trying to close the file: '%s'" % self.filename)
    
    def read_in_file(self):
        """Read the file contents."""
        if self.is_open == 1:
            fseek(self.fp, 0, SEEK_END)
            self.file_size = ftell(self.fp)
            fseek(self.fp, 0, SEEK_SET)
            self.file_contents = <char*>malloc(self.file_size*sizeof(char))
            fread(self.file_contents, 1, self.file_size, self.fp)
            #fclose(self.fp)
            self.is_open = 0
    
    def get_columns(self):
        """Set up the column names."""
        if self.file_contents != NULL:
            tmp = 0
            while True:
                print(<str>chr(self.file_contents[self.iterator]))
                if <str>chr(self.file_contents[self.iterator]) == "\n":
                    self.num_columns += 1
                    tmp = self.iterator
            
                    break
                if <str>chr(self.file_contents[self.iterator]) == "\0":
                    self.EO_STR = 0 # enf of string reached
                    break
                if <str>chr(self.file_contents[self.iterator]) == ",":
                    self.num_columns += 1
                    tmp = self.iterator
                    
                self.iterator += 1
                self.column_header = <char*>malloc(self.iterator*sizeof(char))
                strncpy(self.column_header, self.file_contents, self.iterator)
               
                
               

# Test the functionality #
###############################################################################
emlFile = b"Y:\\Shared\\USD\\Business Data and Analytics\\Claims_Pipeline_Files\\Mapping_Files\\EmlMappingFile.csv"
tokenizer = Tokenize(b',', emlFile)
tokenizer.open_file()
tokenizer.read_in_file()
tokenizer.get_columns()
print(tokenizer.file_size)
print(tokenizer.is_open)
print(tokenizer.column_header)
tokenizer.close_file()
print(tokenizer.is_open)
        
         
