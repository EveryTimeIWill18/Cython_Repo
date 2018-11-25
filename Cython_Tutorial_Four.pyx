import numpy

cpdef long f1(long x, long y):
    return x % y

cdef long f2(long x, long y):
    return x % y

def pyf1(long[:] x, long[:] y):
    cdef long result = 0
    for i in range(x.shape[0]):
        result += f1(x[i], y[i])
    return result

def pyf2(long[:] x, long[:] y):
    cdef long result = 0
    for i in range(x.shape[0]):
        result += f2(x[i], y[i])
    return result
    
x = numpy.random.randint(1, 100, 2**20)
y = numpy.random.randint(1, 100, 2**20)
print(x[:5])

# cython inheritence and polymorphism

# class inheritence using cython classes
cdef class A:
    """Cython parent class A"""
    cdef int x
    def __init__(self, x):
        self.x = x
        
cdef class B(A):
    """Cython subclass B"""
    cdef int y
    def __init__(self, x, y):
        super().__init__(x)
        self.v = y
        
class C(B):
    """Python subclass of Cython class B"""
    def __init__(self, x, y, z):
        super().__init__(x, y)
        self.z = z
   
   
from libc.stdlib cimport malloc, realloc, free

# remember, __cinit__ is only called once.
# super() will not call __cinit__
# __cinit__ useful for allocating memory
cdef class AA:
    cdef char* x  # x is a pointer to a char
    def __cinit__(self, int size):
        self.x = <char *>malloc(size * sizeof(char))
     
cdef class BB(AA):
    def __init__(self, size):
        # does not call A.__cinit__
        super().__init__(size)

cdef class AAA:
    def f(self):
        return 'A'
    
cdef class BBB(AAA):
    def f(self):
        return 'B'
    
# test out polymorphism
bbb = BBB()
print(dir(bbb))

# cython oop
cdef class Bird:
    """Cython class, Bird"""
    cdef public:
        double weight # ounces
    def __init__(self, weight):
        self.weight = weight
    def weight_ratio(self, carry_weight):
        return carry_weight/self.weight
    
cdef class Swallow(Bird):
    """Cython subclass, Swallow"""
    cdef public:
        bint migratory # True/False
    def __init__(self, weight, migratory):
        super().__init__(weight)
        self.migratory = migratory
        
        
## example
bird1 = Bird(5)
bird2 = Bird(7)
bird3 = Bird(100)

swallow = Swallow(5, True)
print(swallow.weight_ratio(16))

cdef class Parent:
    cdef str dancing_style(self):
        return "Waltz"

cdef class Child(Parent):
    cdef str dancing_style(self):
        return "Break dancing"
    
cdef Parent obj   # declare a var called obj, type: Parent
cdef Parent obj2  # create another instance of Parent
obj = Child()     # create an instance of Child, subclass


print(obj.dancing_style())
print(obj2.dancing_style())

