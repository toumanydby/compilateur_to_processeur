#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MEM_SIZE 1024
#define MAX_INSTRUCTIONS 1024
#define MAX_LABELS 1024

int memory[MEM_SIZE];

typedef struct {
    int opcode;
    int a1;
    int a2;
    int a3;
} Instruction;

Instruction instructions[MAX_INSTRUCTIONS];
int instruction_count = 0;

int labels_table[MAX_LABELS]; // index = label number , value = instruction to go for that label

void load_instructions(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "Erreur : impossible d’ouvrir le fichier %s\n", filename);
        exit(EXIT_FAILURE);
    }

    // On lit toutes les lignes une par une 
    char line[128];
    while (fgets(line, sizeof(line), file)) {
        // Fill the label table 
        if(strncmp(line, "LABEL", 5) == 0){
            int label;
            if(sscanf(line, "LABEL%d:", &label) == 1){
                labels_table[label] = instruction_count;
            } else{
                fprintf(stderr, "Erreur lecture label : %s", line);
            }
            continue;
        }

        // Fill the instructions table 
        Instruction inst = {0};
        int nb = sscanf(line, "%d %d %d %d", &inst.opcode, &inst.a1, &inst.a2, &inst.a3);
        if(nb >= 2) {
            instructions[instruction_count++] = inst;
        } else{
            fprintf(stderr, "Erreur lors de la lecture de la ligne : %s\n", line);
        }
    }

    fclose(file);

    for (size_t i = 0; i < instruction_count; i++)
    {
        printf("Instruction %ld : %d %d %d %d\n",i,instructions[i].opcode,instructions[i].a1,instructions[i].a2,instructions[i].a3);
    }
}

void execute() {
    int pc = 0; // program counter 
    while (pc < instruction_count) {
        Instruction inst = instructions[pc];

        switch (inst.opcode) {
            case 1: // ADD
                memory[inst.a1] = memory[inst.a2] + memory[inst.a3];
                break;
            case 2: // MUL
                memory[inst.a1] = memory[inst.a2] * memory[inst.a3];
                break;
            case 3: // SOU
                memory[inst.a1] = memory[inst.a2] - memory[inst.a3];
                break;
            case 4: // DIV
                if (memory[inst.a3] == 0) {
                    fprintf(stderr, "Erreur : division par zéro à l’instruction %d\n", pc);
                    exit(EXIT_FAILURE);
                }
                memory[inst.a1] = memory[inst.a2] / memory[inst.a3];
                break;
            case 5: // COP
                memory[inst.a1] = memory[inst.a2];
                break;
            case 6: // AFC
                memory[inst.a1] = inst.a2;
                break;
            case 7: // JMP
                pc = labels_table[inst.a1]; 
                continue;
            case 8: // JMF
                if (memory[inst.a1] == 0){
                    pc = labels_table[inst.a2]; 
                    continue;                    
                }
                break;
            case 9: // INF
                memory[inst.a1] = (memory[inst.a2] < memory[inst.a3]) ? 1 : 0;
                break;
            case 10: // SUP
                memory[inst.a1] = (memory[inst.a2] > memory[inst.a3]) ? 1 : 0;
                break;
            case 11: // EQU
                memory[inst.a1] = (memory[inst.a2] == memory[inst.a3]) ? 1 : 0;
                break;
            case 12: // NEQU
                memory[inst.a1] = (memory[inst.a2] != memory[inst.a3]) ? 1 : 0;
                break;
            case 13: // PRI
                printf("%d\n", memory[inst.a1]);
                break;
            case 14: // LOAD 
                inst.a1 = memory[inst.a2];
                break;
            case 15: // STORE
                memory[inst.a1] = inst.a2;
                break;
            default:
                fprintf(stderr, "Erreur : opcode inconnu %d à la ligne %d\n", inst.opcode, pc);
                exit(EXIT_FAILURE);
        }
        pc++;
    }

    // for (size_t i = 0; i < instruction_count; i++)
    // {
    //     printf("Memory pos %ld have value : %d\n", i, memory[i]);
    // }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage : %s <fichier_code.asm>\n", argv[0]);
        return EXIT_FAILURE;
    }

    for (int i = 0; i < MAX_LABELS; i++) labels_table[i] = -1;


    load_instructions(argv[1]);
    execute();

    return EXIT_SUCCESS;
}
