.PHONY: all clean test

LDFLAGS=-O2 -Wall -fPIC 
CFLAGS=-O2 -Wall -fPIC --std=gnu11 -I. -Wno-unused-function
OBJS=capn-malloc.o capn-stream.o capn.o
prefix = /usr

all: capn.a capn.so capnpc-c test

clean:
	rm -f *.o *.so capnpc-c compiler/*.o *.a gtest/src/*.o

%.o: %.c *.h *.inc compiler/*.h
	$(CC) $(CFLAGS) -c $< -o $@
	
capn.so: $(OBJS)
	$(CC) -shared $(LDFLAGS) $^ -o $@

capn.a: $(OBJS)
	$(AR) rcs $@ $^

capnpc-c: compiler/capnpc-c.o compiler/schema.capnp.o compiler/str.o capn.a
	$(CC) $(LDFLAGS) $^ -o $@

test: capn-test
	./capn-test

%-test.o: %-test.cpp *.h *.c *.inc
	$(CXX) --std=c++11 -g -I. -Igtest -o $@ -c $<
	
gtest-all.o: gtest/src/gtest-all.cc gtest/src/*.h gtest/src/*.cc
	$(CXX) --std=c++11 -g -I. -Igtest -o $@ -c $<

capn-test: capn-test.o capn-stream-test.o compiler/test.capnp.o compiler/schema-test.o compiler/schema.capnp.o capn.a gtest-all.o -lpthread
	$(CXX) -std=c++11 -g -I. -o $@ $^
	
install:
	install -c capnpc-c $(prefix)/bin/capnpc-c
	install -c capn.so $(prefix)/lib/capn.so
	install -c capn.a $(prefix)/lib/capn.a
