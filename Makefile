# all:compilo

# compilo: lex.yy.c
# 	gcc -o compilo 

# lex.yy.c: compilo.l
# 	lex compilo.l

# test: compilo
# 	./compilo < test.c

# GRM=calc.y
# LEX=compilo.l
# BIN=compilo
# TEST_FILE=test.c

# CC=gcc
# CFLAGS=-Wall -g

# OBJ= lex.yy.o
# all: $(BIN)

# %.o: %.c
# 	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

# lex.yy.c: $(LEX)
# 	flex $<

# $(BIN): $(OBJ)
# 	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -o $@

# test: $(BIN)
# 	./$(BIN) < $(TEST_FILE)

# clean:
# 	rm $(OBJ) lex.yy.c


# Compiler and flags
CC = gcc
CFLAGS = -Wall -g

# Directories
SRC_DIR = src
TEST_DIR = tests
BIN_DIR = bin
OBJ_DIR = obj

# Files
LEX_FILE = $(SRC_DIR)/compilo.l
YACC_FILE = $(SRC_DIR)/compilo.y
TEST_FILE = $(TEST_DIR)/test.c

# Binaries
COMPILO_BIN = $(BIN_DIR)/compilator
PROCESSOR_BIN = $(BIN_DIR)/processor

# Objects
COMPILO_OBJ = $(OBJ_DIR)/lex.yy.o 
# $(OBJ_DIR)/calc.tab.o
PROCESSOR_OBJ = $(OBJ_DIR)/processor.o

# Targets
all: compilo processor

compilo: $(COMPILO_BIN)

processor: $(PROCESSOR_BIN)

test: $(COMPILO_BIN)
	./$(COMPILO_BIN) < $(TEST_FILE)

# Rules for compilo
$(OBJ_DIR)/lex.yy.c: $(LEX_FILE)
	flex -o $@ $<

# $(OBJ_DIR)/calc.tab.c: $(YACC_FILE)
# 	bison -d -o $@ $<

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) -c $(CFLAGS) $< -o $@

$(COMPILO_BIN): $(COMPILO_OBJ)
	$(CC) $(CFLAGS) $^ -o $@

# Rules for processor
$(PROCESSOR_BIN): $(PROCESSOR_OBJ)
	$(CC) $(CFLAGS) $^ -o $@

# Create directories if they don't exist
$(OBJ_DIR) $(BIN_DIR):
	mkdir -p $@
# Clean
clean:
	rm -rf $(OBJ_DIR)/* $(BIN_DIR)/*

