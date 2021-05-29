CFLAGS=-Wall
CPPFLAGS=
CC= g++
SOURCES=parser.cpp main.cpp tokens.cpp Kodea.cpp

all: parser proba

.PHONY: clean

clean:
	rm parser.cpp parser.hpp parser tokens.cpp *~

parser.cpp: parser.y
	bison -d -o $@ $^

parser.hpp: parser.cpp

tokens.cpp: tokens.l parser.hpp
	flex -o $@ $<

parser: $(SOURCES) Kodea.h Lag.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $(SOURCES)

proba:  parser ./probak/proba1.in ./probak/proba2.in ./probak/proba3.in ./probak/proba1txar.in ./probak/proba2txar.in ./probak/proba3txar.in

	./parser <./probak/proba1.in
	./parser <./probak/proba2.in
	./parser <./probak/proba3.in
	./parser <./probak/proba1txar.in
	./parser <./probak/proba2txar.in
	./parser <./probak/proba3txar.in
	
	
