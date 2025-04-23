# Compilateur et options
CC = gcc
CFLAGS = -Wall -I$(SRC_DIR)
DEBUG_CFLAGS = -Wall -g -I$(SRC_DIR)

# Répertoires
BIN_DIR = bin
OBJ_DIR = obj
SRC_DIR = src

# Fichiers source
LEX_FILE = $(SRC_DIR)/compilo.l
YACC_FILE = $(SRC_DIR)/compilo.y
SYMBOL_TABLE_FILE = $(SRC_DIR)/symboles_table.c
ASSEMBLY_FILE = $(SRC_DIR)/interpreteur.c

# Cible par défaut
all: $(BIN_DIR)/compilateur $(BIN_DIR)/interpreteur

# Cible de débogage
debug: $(BIN_DIR)/compilateur_debug

# Création des répertoires si nécessaire
$(BIN_DIR) $(OBJ_DIR):
	mkdir -p $@

# Génération du parseur avec Bison (sans débogage)
$(OBJ_DIR)/compilo.tab.c $(OBJ_DIR)/compilo.tab.h: $(YACC_FILE) | $(OBJ_DIR)
	bison -d $(YACC_FILE) -o $(OBJ_DIR)/compilo.tab.c

# Génération du parseur avec Bison (avec débogage)
$(OBJ_DIR)/compilo_debug.tab.c $(OBJ_DIR)/compilo_debug.tab.h: $(YACC_FILE) | $(OBJ_DIR)
	bison -v -d $(YACC_FILE) -o $(OBJ_DIR)/compilo_debug.tab.c

# Génération de l'analyseur lexical avec Flex (sans débogage)
$(OBJ_DIR)/lex.yy.c: $(LEX_FILE) $(OBJ_DIR)/compilo.tab.h | $(OBJ_DIR)
	flex -o $(OBJ_DIR)/lex.yy.c $(LEX_FILE)

# Génération de l'analyseur lexical avec Flex (avec débogage)
$(OBJ_DIR)/lex_debug.yy.c: $(LEX_FILE) $(OBJ_DIR)/compilo_debug.tab.h | $(OBJ_DIR)
	flex -d -o $(OBJ_DIR)/lex_debug.yy.c $(LEX_FILE)

# Compilation des objets (version standard)
$(OBJ_DIR)/lex.yy.o: $(OBJ_DIR)/lex.yy.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/compilo.tab.o: $(OBJ_DIR)/compilo.tab.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/symboles_table.o: $(SYMBOL_TABLE_FILE) $(SRC_DIR)/symboles_table.h | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Compilation des objets (version débogage)
$(OBJ_DIR)/lex_debug.yy.o: $(OBJ_DIR)/lex_debug.yy.c | $(OBJ_DIR)
	$(CC) $(DEBUG_CFLAGS) -c $< -o $@

$(OBJ_DIR)/compilo_debug.tab.o: $(OBJ_DIR)/compilo_debug.tab.c | $(OBJ_DIR)
	$(CC) $(DEBUG_CFLAGS) -c $< -o $@

$(OBJ_DIR)/symboles_table_debug.o: $(SYMBOL_TABLE_FILE) $(SRC_DIR)/symboles_table.h | $(OBJ_DIR)
	$(CC) $(DEBUG_CFLAGS) -c $< -o $@

# Compilation de l'exécutable standard
$(BIN_DIR)/compilateur: $(OBJ_DIR)/lex.yy.o $(OBJ_DIR)/compilo.tab.o $(OBJ_DIR)/symboles_table.o | $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $^

# Compilation de l'exécutable avec débogage
$(BIN_DIR)/compilateur_debug: $(OBJ_DIR)/lex_debug.yy.o $(OBJ_DIR)/compilo_debug.tab.o $(OBJ_DIR)/symboles_table_debug.o | $(BIN_DIR)
	$(CC) $(DEBUG_CFLAGS) -o $@ $^

# Compilation de l'interpréteur
$(BIN_DIR)/interpreteur: $(ASSEMBLY_FILE) | $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $<

# Exécution avec un fichier de test (version standard)
test: $(BIN_DIR)/compilateur
	$(BIN_DIR)/compilateur < tests/test.c

# Exécution avec un fichier de test (version débogage)
test_debug: $(BIN_DIR)/compilateur_debug
	$(BIN_DIR)/compilateur_debug < tests/test.c 2>&1 | tee debug.log

# Exécution de l'interpréteur sur le fichier asm généré
run_interpreteur: $(BIN_DIR)/interpreteur
	$(BIN_DIR)/interpreteur $(BIN_DIR)/output_bin.asm

# Nettoyage des fichiers générés
clean:
	rm -f $(BIN_DIR)/compilateur $(BIN_DIR)/compilateur_debug $(BIN_DIR)/interpreteur
	rm -f $(OBJ_DIR)/*.o $(OBJ_DIR)/*.c $(OBJ_DIR)/*.h
	rm -f $(OBJ_DIR)/compilo.output $(OBJ_DIR)/compilo_debug.output

# Nettoyage complet
mrproper: clean
	rm -f *~ *.log

.PHONY: all debug test test_debug run_interpreteur clean mrproper
