/*
 * Author: 2016 Jani J. Hakala <jjhakala@gmail.com> (Finland)
 */
#include <windows.h>
#include <Python.h>

#include "example.h"

int __declspec(dllexport) example_init(void)
{
    PyGILState_STATE gilstate_save = PyGILState_Ensure();
    int rc = 0;

#if PY_MAJOR_VERSION < 3
    initexample();
#else
    PyInit_example();
#endif
    if (PyErr_Occurred()) {
        rc = -1;
    }
    PyGILState_Release(gilstate_save);
    return rc;
}

/*
 * Based on
 *
 *   https://wiki.blender.org/index.php/Dev:2.4/Source/Python/API/Threads
 */
void __declspec(dllexport) python_init(void)
{
    PyThreadState * py_tstate = NULL;
    Py_Initialize();
    PyEval_InitThreads();
    py_tstate = PyGILState_GetThisThreadState();
    PyEval_ReleaseThread(py_tstate);
}

void __declspec(dllexport) python_fini(void)
{
    PyGILState_Ensure();
    Py_Finalize();
}
