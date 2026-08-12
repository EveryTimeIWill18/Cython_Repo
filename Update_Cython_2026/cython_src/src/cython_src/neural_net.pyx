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
    
    cdef void load_x_data(self, double[:, :] X):
        """Load in X-data"""
        if not self.X_data:
            raise MemoryError('Failed to allocate memory for the X matrix.')
        cdef int m_rows = X.shape[0]
        cdef int n_cols = X.shape[1]
        cdef int i, j
        self.X_data.rows = m_rows
        self.X_data.cols = n_cols
        self.X_data.matrix = <double**> malloc(m_rows * sizeof(double *))
        for i in range(self.X_data.rows):
            self.X_data.matrix[i] = <double*>malloc(n_cols * sizeof(double))

        cdef double* temp
        i, j = 0, 0
        for i in range(m_rows):
            temp = self.X_data.matrix[i]
            for j in range(n_cols):
                temp[j] = X[i, j]
    
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
    
    cpdef void set_layer_ids(self, list layer_ids):
        """Set Layer ids"""
        if self.neural_net.num_layers == 0 or self.neural_net.layers == NULL:
            raise RuntimeError('Num_layers = 0 or neural_net.layers = NULL.')
        cdef int i
        cdef char* layer_id

        for i in range(self.neural_net.num_layers):
            layer_id = layer_ids[i]
            self.neural_net.layers[i].layer_id = <char*>malloc((strlen(layer_id) + 1) * sizeof(char))
            strcpy(self.neural_net.layers[i].layer_id, layer_id)

    cpdef void set_node_ids(self, list node_ids):
        """Set Node ids"""
        if self.neural_net.num_layers == 0 or self.neural_net.layers == NULL:
            raise RuntimeError('Num_layers = 0 or neural_net.layers = NULL.')

        cdef int i, j
        cdef int row
        cdef char* node_id
        row = 0

        for i in range(self.neural_net.num_layers):
            for j in range(self.neural_net.layers[i].num_nodes_in_layer):
                node_id = node_ids[row]
                print(f'{node_id=}')
                self.neural_net.layers[i].layer_nodes[j].id = <char*>malloc((strlen(node_id)+1)* sizeof(char))
                strcpy(self.neural_net.layers[i].layer_nodes[j].id, node_id)
                row += 1

    cpdef void initialize_weights(self):
        """Initialize the weights"""
        if self.neural_net.num_layers == 0 or self.neural_net.layers == NULL:
            raise RuntimeError('Num_layers = 0 or neural_net.layers = NULL.')

        cdef int i, j, k
        cdef Layer* previous_layer
        cdef int num_layers = self.neural_net.num_layers
        cdef Layer* current_layer
        cdef int prev_layer_num_nodes
        cdef int current_layer_num_nodes
        cdef Node* current_node

        for i in range(1, num_layers):
            current_layer = &self.neural_net.layers[i]
            current_layer_num_nodes = current_layer.num_nodes_in_layer
            previous_layer = &self.neural_net.layers[i-1]
            prev_layer_num_nodes = previous_layer.num_nodes_in_layer
            for j in range(current_layer_num_nodes):
                current_node = &current_layer.layer_nodes[j]
                current_node.weights = <double*>malloc(prev_layer_num_nodes * sizeof(double))
                if not current_node.weights:
                    raise MemoryError('Failed to allocate memory for the weights.')
                for k in range(prev_layer_num_nodes):
                    current_node.weights[k] = 0.0
                    print(f'{current_node.weights[k]=}')

    cpdef dict get_network_structure(self):
        """Returns the network structure in a dict"""
        if self.neural_net == NULL or self.neural_net.layers == NULL:
            return {}

        cdef dict network_structure = {}
        cdef int l, n
        cdef Layer current_layer
        cdef list node_ids
        cdef str layer_id, node_id

        for l in range(self.neural_net.num_layers):
            current_layer = self.neural_net.layers[l]

            if current_layer.layer_id != NULL:
                layer_id = current_layer.layer_id.decode('utf-8')
            else:
                layer_id = f'L{l}'
            node_ids = []

            if current_layer.layer_nodes != NULL:
                for n in range(current_layer.num_nodes_in_layer):
                    if current_layer.layer_nodes[n].id != NULL:
                        node_id = current_layer.layer_nodes[n].id.decode('utf-8')
                    else:
                        node_id = f'N{l}_{n}'
                    node_ids.append(node_id)
            network_structure[layer_id] = node_ids
        return network_structure
