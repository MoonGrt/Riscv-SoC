# make clean && make

PROJ_NAME = test
DEBUG = yes
BENCH = no
MULDIV = no

SRCS = $(wildcard libs/*.c) \
       $(wildcard libs/*.cpp) \
       $(wildcard libs/*.S) \
       $(wildcard src/*.c) \
       $(wildcard src/*.cpp) \
       $(wildcard src/*.S)

INC += -I libs
LDSCRIPT = linker.ld

include ../../resources/gcc.mk
include ../../resources/subproject.mk
