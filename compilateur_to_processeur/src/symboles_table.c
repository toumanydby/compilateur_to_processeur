#include "symboles_table.h"

static int next_address = 0;  // Global address counter
static int cmpt_addr = 0;     // Counter of freed addresses
static int *address_freed = NULL;

int get_addr_freed() {
    for (size_t i = 0; i < cmpt_addr; i++) {
        if (address_freed[i] != -1) {
            int addr = address_freed[i];
            address_freed[i] = -1; // Mark as reused
            return addr;
        }
    }
    return -1;
}

void init_symbol_table(SymbolTable *symbols_table) {
    int default_val = -1;
    address_freed = malloc(sizeof(int) * INIT_NUMBER_SYMBOLES);
    for (int i = 0; i < INIT_NUMBER_SYMBOLES; i++) {
        address_freed[i] = default_val;
    }

    symbols_table->nb_symboles = 0;
    symbols_table->capacity = INIT_NUMBER_SYMBOLES;
    symbols_table->symbols = malloc(symbols_table->capacity * sizeof(Symbol));
    if (!symbols_table->symbols) {
        fprintf(stderr, "Erreur: allocation mémoire échouée\n");
        exit(EXIT_FAILURE);
    }

    next_address = 0;
    cmpt_addr = 0;
}

void free_symbol_table(SymbolTable *symbols_table) {
    free(symbols_table->symbols);
    symbols_table->symbols = NULL;

    free(address_freed);               // ✅ Prevent memory leak
    address_freed = NULL;
    cmpt_addr = 0;

    symbols_table->nb_symboles = 0;
    symbols_table->capacity = 0;
}

// Add a symbol (temporary or regular)
int add_symbol(SymbolTable *symbols_table, const char *name, int depth, int is_temp) {
    if (!is_temp) {
        for (int i = 0; i < symbols_table->nb_symboles; i++) {
            if (strcmp(symbols_table->symbols[i].name, name) == 0 && 
                symbols_table->symbols[i].depth == depth) {
                return symbols_table->symbols[i].address;
            }
        }
    }

    int addr = get_addr_freed();
    Symbol *sym;

    if (addr != -1) {
        sym = &symbols_table->symbols[addr];
        strcpy(sym->name, name);
        sym->depth = depth;
        sym->is_temp = is_temp;
        sym->address = addr;
        symbols_table->nb_symboles++;  // ✅ Ensure reused slots are counted
        return sym->address;
    } else {
        if (symbols_table->nb_symboles == symbols_table->capacity) {
            symbols_table->capacity *= SIZE_FACTOR;
            symbols_table->symbols = realloc(symbols_table->symbols, symbols_table->capacity * sizeof(Symbol));
            if (!symbols_table->symbols) {
                fprintf(stderr, "Erreur: réallocation mémoire échouée\n");
                exit(EXIT_FAILURE);
            }
        }

        sym = &symbols_table->symbols[symbols_table->nb_symboles];
        strcpy(sym->name, name);
        sym->depth = depth;
        sym->is_temp = is_temp;
        sym->address = next_address++;
        int final_addr = sym->address;
        symbols_table->nb_symboles++;  // ✅ Increment here too
        return final_addr;    
    }
}

int get_symbol_address(SymbolTable *symbols_table, const char *name, int depth) {
    for (int i = symbols_table->nb_symboles - 1; i >= 0; i--) {
        if (strcmp(symbols_table->symbols[i].name, name) == 0) {
            return symbols_table->symbols[i].address;
        }
    }
    fprintf(stderr, "Erreur: variable '%s' non trouvée\n", name);
    return -1;
}

void remove_symbol_at_depth(SymbolTable *symbols_table, int depth) {
    for (int i = symbols_table->nb_symboles - 1; i >= 0; i--) {
        if (symbols_table->symbols[i].address != -1 &&
            symbols_table->symbols[i].depth == depth) {
            symbols_table->symbols[i].address = -1;
            if (cmpt_addr < INIT_NUMBER_SYMBOLES) {
                address_freed[cmpt_addr++] = i;
            }
        }
    }
}

void remove_temp_variable(SymbolTable *symbols_table, int depth) {
    // printf("HEEEEELLLOOOO IT'S MEEEEEEEEE\n");
    for (int i = symbols_table->nb_symboles - 1; i >= 0; i--) {
        if (symbols_table->symbols[i].is_temp &&
            symbols_table->symbols[i].address != -1 &&
            symbols_table->symbols[i].depth == depth) {
            symbols_table->symbols[i].address = -1;
            if (cmpt_addr < INIT_NUMBER_SYMBOLES) {
                address_freed[cmpt_addr++] = i;
            }
        }
    }
}

void print_symboles_table(const SymbolTable *symbols_table) {
    printf("Table des symboles:\n");
    for (int i = 0; i < symbols_table->nb_symboles; i++) {
        
        // Skip invalid or freed symbols
        if (symbols_table->symbols[i].address == -1 || strlen(symbols_table->symbols[i].name) == 0) {
            continue;
        }
        printf("%s -> Adresse %d (profondeur %d) %s\n",
               symbols_table->symbols[i].name,
               symbols_table->symbols[i].address,
               symbols_table->symbols[i].depth,
               symbols_table->symbols[i].is_temp ? "[Temporaire]" : "");
    }

    printf("Table of addr freed symboles: %d\n", cmpt_addr);
    for (int i = 0; i < cmpt_addr; i++) {
        printf("Addresse freed num %d\n", address_freed[i]);

        // if(address_freed[i] != -1){
        // }
    }
}
