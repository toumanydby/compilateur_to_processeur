#include "symboles_table.h"

void init_symbol_table(SymbolTable *symbols_table){
    symbols_table->nb_symboles = 0;
    symbols_table->capacity = INIT_NUMBER_SYMBOLES;
    symbols_table->symbols = (Symbol *) malloc(symbols_table->capacity * sizeof(Symbol));
    if (!symbols_table->symbols) {
        fprintf(stderr, "Erreur: malloc de la table des symboles echouee\n");
        exit(EXIT_FAILURE);
    } 
}

void free_symbol_table(SymbolTable *symbols_table){
    free(symbols_table->symbols);
    symbols_table->symbols = NULL;
    symbols_table->nb_symboles = 0;
    symbols_table->capacity = 0;
}


void add_symbol(SymbolTable *symbols_table, char *name, int value, int depth) {
    // On verifie si le symbole existe deja a la meme profondeur dans la table des symboles
    for (int i = 0; i < symbols_table->nb_symboles; i++)
    {
        if(strcmp(symbols_table->symbols[i].name, name) == 0 && symbols_table->symbols[i].depth == depth){
            printf("Symbole déjà inscrit dans la table à cette profondeur\n");
            return;
        } 
    }
    
    // On augmente la capacite de la table si on a pas assez d'espace
    if(symbols_table->nb_symboles == symbols_table->capacity){
        symbols_table->capacity *= SIZE_FACTOR;
        symbols_table->symbols = (Symbol *) realloc(symbols_table->symbols, symbols_table->capacity * sizeof(Symbol));
        if(!symbols_table->symbols){
            fprintf(stderr, "Erreur: Échec du réallouage mémoire\n");
            exit(EXIT_FAILURE);
        }
    }

    // On rajoute notre nouveau symbole avec les informations dans le tableau
    strcpy(symbols_table->symbols[symbols_table->nb_symboles].name,name);
    symbols_table->symbols[symbols_table->nb_symboles].value = value;
    symbols_table->symbols[symbols_table->nb_symboles].depth = depth;
    symbols_table->nb_symboles++;
}

int get_symbol_value(SymbolTable *symbols_table, char *name) {
    for (int i = 0; i < symbols_table->nb_symboles; i++) {
        if (strcmp(symbols_table->symbols[i].name, name) == 0) {
            return symbols_table->symbols[i].value;
        }
    }
    fprintf(stderr, "Erreur: Variable %s non trouvée\n", name);
    return -1;
}

int get_symbol_depth(SymbolTable *symbols_table, char *name) {
    for (int i = 0; i < symbols_table->nb_symboles; i++) {
        if (strcmp(symbols_table->symbols[i].name, name) == 0) {
            return symbols_table->symbols[i].depth;
        }
    }
    fprintf(stderr, "Erreur: Variable %s non trouvée\n", name);
    return -1; 
}

void set_symbol_value(SymbolTable *symbols_table, char *name, int value) {
    for (int i = 0; i < symbols_table->nb_symboles; i++) {
        if (strcmp(symbols_table->symbols[i].name, name) == 0) {
            symbols_table->symbols[i].value = value;
            return;
        }
    }
    fprintf(stderr, "Erreur: Variable %s non trouvée\n", name);
}

void remove_symbol_at_depth(SymbolTable *symbols_table, int depth)
{
    for (int i = symbols_table->nb_symboles - 1; i >= 0; i--) {
        if (symbols_table->symbols[i].depth == depth) {
            printf("Removing variable %s (depth %d)\n", symbols_table->symbols[i].name, depth);
            symbols_table->nb_symboles--;
        } else {
            break;
        }
    }
    
    // int i = 0;
    // while (i < symbols_table->nb_symboles) {
    //     if (symbols_table->symbols[i].depth == depth) {
    //         for (int j = i; j < symbols_table->nb_symboles - 1; j++) {
    //             symbols_table->symbols[j] = symbols_table->symbols[j + 1];
    //         }
    //         symbols_table->nb_symboles--;
    //     } else {
    //         i++;
    //     }
    // }
}

void print_symboles_table(SymbolTable *symbols_table) {
    printf("Nombre de symboles: %d\n", symbols_table->nb_symboles);
    for(int i = 0; i < symbols_table->nb_symboles; i++) {
        printf("%s = %d (profondeur %d)\n", symbols_table->symbols[i].name, symbols_table->symbols[i].value, symbols_table->symbols[i].depth);
    }
}
