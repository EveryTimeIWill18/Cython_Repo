def open_file(str fileName):
    """Efficiently open a file"""
    cdef FILE *fp
    cdef char *s = <char*>malloc(6000*sizeof(char))
    fp = fopen(fileName, "r")
    fgets(s, 6000, fp)
    cdef int i = 0
    for i in range(6000):
        print(<str>chr(s[i])
