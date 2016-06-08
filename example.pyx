# from libc cimport uint16_t, uint32_t, uint64_t, strncpy
# cimport c_python as cp

cdef public int example_test() with gil:
    return 42
