"""
neural_net.pxd
~~~~~~~~~~~~~~
"""


cdef struct Node:
    char* id
    double data
    Node** successor_nodes
    int num_successors
    double* weights


cdef struct Layer:
    int layer_id
    int num_nodes_in_layer
    Node* layer_nodes

cdef struct Network:
    int num_layers
    Layer* layers



cdef class NeuralNetwork:
    """This class creates the neural network"""

    cdef:
        Network *neural_net

    cpdef void set_num_layers(self, int num_layers)
    cpdef void set_num_nodes_in_layer(self, int[:] num_nodes_in_layer)
