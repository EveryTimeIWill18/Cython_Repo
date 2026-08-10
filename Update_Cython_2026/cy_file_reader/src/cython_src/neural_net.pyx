"""
neural_net.pyx
~~~~~~~~~~~~~~
"""
from logging import NullHandler

import numpy as np
cimport numpy as cnp
from libc.stdlib  cimport malloc, realloc, free, atof, calloc
from file_reader cimport CSVReader
from libc.string cimport strtok, strcpy, strlen
# Manually add POSIX header declaration to import strtok_r
cdef extern from "string.h":
    char* strtok_r(char* str, char* delim, char** saveptr) nogil



cdef class NeuralNetwork:

    def __cinit__(self):
        self.neural_net =<Network*>malloc(sizeof(Network))
        if not self.neural_net:
            raise MemoryError('Failed to allocate memory for the network.')
        self.neural_net.layers = NULL
        self.neural_net.num_layers = 0

    def __init__(self):
      ...

    cpdef void set_num_layers(self, int num_layers):
        """Set the number of layers"""
        if num_layers <= 0:
            raise ValueError('Number of layers must be greater than 0.')
        self.neural_net.num_layers = num_layers
        self.neural_net.layers = <Layer*>calloc(num_layers, sizeof(Layer))

        if not self.neural_net.layers:
            raise MemoryError('Failed memory allocation for network layers')

    cpdef void set_num_nodes_in_layer(self, int[:] num_nodes_in_layer):
        """Set the number of nodes in layers"""
        if self.neural_net.num_layers == 0 or self.neural_net.layers == NULL:
            raise RuntimeError('Num_layers = 0 or neural_net.layers = NULL.')

        cdef int i, j, num_nodes
        for i in range(self.neural_net.num_layers):
            num_nodes = num_nodes_in_layer[i]
            if num_nodes <= 0:
                raise ValueError(f'Layer: {i} must have at least 1 node in it.')
            self.neural_net.layers[i].num_nodes_in_layer = num_nodes
            self.neural_net.layers[i].layer_nodes = <Node*>calloc(num_nodes, sizeof(Node))
            if not self.neural_net.layers[i].layer_nodes:
                raise MemoryError(f'Failed memory allocation for Layer[{i}] nodes.')
            for j in range(num_nodes):
                self.neural_net.layers[i].layer_nodes[j].id = NULL
                self.neural_net.layers[i].layer_nodes[j].data = 0.0
                self.neural_net.layers[i].layer_nodes[j].successor_nodes = NULL
                self.neural_net.layers[i].layer_nodes[j].weights = NULL
                self.neural_net.layers[i].layer_nodes[j].num_successors = 0
