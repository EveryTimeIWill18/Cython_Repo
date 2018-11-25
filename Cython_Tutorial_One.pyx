from pprint import pprint
# creating cython extension types
cdef class Noddy:
    pass

noddy = Noddy()
dir(noddy)

# cython class extension with one method
cdef class MyType:
    def my_method(self, name):
        """prints name"""
        print("Hello, ", name)
t = MyType()
t.my_method('William')

class PyBook:
    def __init__(self, title):
        self.title = title

cdef class CyBook:
    # fields only accessable in cython code
    # must provide an access level
    # python can read but cannot change the value
    # readonly must be defined so native
    # python can print out the value
    cdef readonly str title  # must define title
    def __init__(self, title):
        self.title = title

# CyBook will compile but attribute error occurs
# extension types are c structs. must be declaired at
# compile time
   
py_book = PyBook("Learning Python")
book = CyBook("Learning Cython")
print(book.title)

# cython extension types
# must define data fields at the class level

cdef class Swallow:
    pass


cdef class Parrot:
    cdef Swallow friend
    cdef public bint alive
    cdef readonly str status
    
    def __init__(self, Swallow friend):
        self.alive = False
        self.status = "busy"
        self.friend = friend
    
class pyEvent:
    def from_dict(self, d):
        """self loading from an event dict"""
        self.host = d['host']
        self.year = int(d['year'])
        self.attendance = int(d['average attendance'])
        
def find_max_py1(events: list):
    return max(events, key=lambda e: e.attendance)

def find_max_py2(events: list):
    for e in events:
        if e.attendance > largest.attendance:
            largest = e
    return largest
cdef class cyEvent:
    cdef public:
        str host
        int attendance, matches, teams, goals, year
        
    def from_dict(self, d):
        self.host = d['host']
        self.year = int(d['year'])
        self.attendance = int(d['average attendance'])
    
cdef int keyfunc(cyEvent e):
    return e.attendance

def find_max_cy1(list events):
    # python max function slows things down
    # *NOTE:*
    #  manual loop in cython will be the fastest option 
    return max(events, key=keyfunc)

def find_max_cy2(list events):
    cdef cyEvent e, largest = events[0]
    for e in events:
        if e.attendance > largest.attendance:
            largest = e
    return largest
