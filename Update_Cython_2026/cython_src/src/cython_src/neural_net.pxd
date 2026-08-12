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

cdef struct InputMatrix:
    double** matrix
    int rows
    int cols



cdef class NeuralNetwork:
    """This class creates the neural network"""

    cdef:
        Network *neural_net

    cpdef void set_num_layers(self, int num_layers)
    cpdef void set_num_nodes_in_layer(self, int[:] num_nodes_in_layer)
    cpdef void set_layer_ids(self, list layer_ids)
    cpdef void set_node_ids(self, list node_ids)
    cpdef void initialize_weights(self)
    cpdef dict get_network_structure(self)
    cdef void load_x_data(self, double[:, :] X)
    cpdef void forward_propagation(self, double[:, :] x_data)
    cpdef void insert_data_to_input(self, int current_row)
    cpdef void connect_network(self)
    cpdef void view_architecture(self)
