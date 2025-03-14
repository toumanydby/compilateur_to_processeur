#ifndef SYMBOLES_TABLE_H
#define SYMBOLES_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INIT_NUMBER_SYMBOLES 100
#define BUFFER_SIZE 256
#define SIZE_FACTOR 2 

typedef struct {
    char name[BUFFER_SIZE];
    int value;
    int depth; // profondeur du symbole
} Symbol;

typedef struct {
    Symbol *symbols;
    int nb_symboles;
    int capacity;
} SymbolTable;

void init_symbol_table(SymbolTable *symbols_table);
void free_symbol_table(SymbolTable *symbols_table);
void add_symbol(SymbolTable *symbols_table, char *name, int value, int depth);
int get_symbol_value(SymbolTable *symbols_table, char *name);
int get_symbol_depth(SymbolTable *symbols_table, char *name);
void set_symbol_value(SymbolTable *symbols_table, char *name, int value);
void remove_symbol_at_depth(SymbolTable *symbols_table, int depth);
void print_symboles_table(SymbolTable *symbols_table);

#endif