CC?=cc
MPICC?=mpicc
MPICXX?=mpicxx
PREFIX=/usr
CFLAGS?=-g -Wall -fopenmp

all: libradixsort.a libmpsort-mpi.a

install: libradixsort.a libmpsort-mpi.a
	install -d $(PREFIX)/lib
	install -d $(PREFIX)/include
	install libradixsort.a $(PREFIX)/lib/libradixsort.a
	install libmpsort-mpi.a $(PREFIX)/lib/libmpsort-mpi.a
	install mpsort.h $(PREFIX)/include/mpsort.h

clean:
	rm -f *.o *.a
tests: main main-mpi bench-mpi

main: main.c libmpsort-omp.a libradixsort.a
	$(CC) $(CFLAGS) -o main $^
main-mpi: main-mpi.cpp libmpsort-mpi.a libradixsort.a
	$(MPICXX) $(CFLAGS) -o main-mpi $^
bench-mpi: bench-mpi.cpp libmpsort-mpi.a libradixsort.a mp-mpiu.h
	$(MPICXX) $(CFLAGS) -o bench-mpi $^
test-issue7: test-issue7.cpp libmpsort-mpi.a libradixsort.a
	$(MPICXX) $(CFLAGS) -o test-issue7 $^

libradixsort.a: mpsort.h radixsort.c internal.h
	$(CC) $(CFLAGS) -c -o radixsort.o radixsort.c
	ar r libradixsort.a radixsort.o
	ranlib libradixsort.a

libmpsort-omp.a: mpsort.h mpsort-omp.c
	$(CC) $(CFLAGS) -c -o mpsort-omp.o mpsort-omp.c
	ar r libmpsort-omp.a mpsort-omp.o
	ranlib libmpsort-omp.a

libmpsort-mpi.a: mpsort.h mpsort-mpi.cpp internal-parallel.h internal.h mp-mpiu.cpp mp-mpiu.h
	$(MPICXX) $(CFLAGS) -c -o mpsort-mpi.o mpsort-mpi.cpp
	$(MPICXX) $(CFLAGS) -c -o mp-mpiu.o mp-mpiu.cpp
	ar r libmpsort-mpi.a mpsort-mpi.o mp-mpiu.o
	ranlib libmpsort-mpi.a

