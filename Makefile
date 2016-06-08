HOST    = i686-w64-mingw32-
CC      = $(HOST)gcc
CXX     = $(HOST)g++
AR      = $(HOST)ar
RANLIB  = $(HOST)ranlib
WINDRES = $(HOST)windres

OBJPATH = build/win32

PYX_FILES = example.pyx
PYX_SOURCES := $(addprefix $(OBJPATH)/, $(PYX_FILES:.pyx=.c))
PYX_OBJS    := $(PYX_SOURCES:.c=.obj)

PYTHON_DIR = /windows/python27_win32

default: depend initdir $(PYX_OBJS) lvexample.dll

initdir:
	mkdir -p $(OBJPATH)

CFLAGS= -mthreads -DNDEBUG -MMD -Wall -O2 -march=i686 -mtune=i686 -I.. -g \
	-I$(PYTHON_DIR)/include -I../include -I$(OBJPATH)

CXXFLAGS= $(CFLAGS)

PYTHON_LDFLAGS = -L$(PYTHON_DIR)/libs -lpython27

EXAMPLE_OBJS := $(addprefix $(OBJPATH)/, example.obj example-init.obj)

lvexample.dll: $(EXAMPLE_OBJS)
	$(CC) -shared -Wl,--enable-auto-image-base -Wl,--enable-auto-import \
		-shared -o $@ $^ $(PYTHON_LDFLAGS)

$(PYX_SOURCES): $(OBJPATH)/%.c : %.pyx $(PXDS) $(PXIS)
	cython -I../src -o $@ $<

$(PYX_OBJS): $(OBJPATH)/%.obj: $(OBJPATH)/%.c
	$(CC) $(CFLAGS) -Wno-unused \
	-fno-strict-aliasing -Wstrict-prototypes \
	-DNDEBUG -g -c -o $@ $<

%.res: %.rc
	$(WINDRES) --output-format=coff --input $< --output $@

$(OBJPATH)/%.obj: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJPATH)/%.obj: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.s: %.cpp
	$(CXX) $(CXXFLAGS) -S -o $@ $<

-include $(OBJPATH)/.depend

depend:
	@mkdir -p $(OBJPATH)
	-@cat $(OBJPATH)/*.d > $(OBJPATH)/.depend

clean:
	-rm -f *.dll
	-rm -f $(OBJPATH)/*
