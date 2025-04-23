#include <stdio.h>
#include <stdlib.h>

#define MEM_SIZE 1024
#define MAX_INSTRUCTIONS 1024

int memory[MEM_SIZE];

typedef struct {
    int opcode;
    int a1;
    int a2;
    int a3;
} Instruction;

Instruction instructions[MAX_INSTRUCTIONS];
int instruction_count = 0;

void load_instructions(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "Erreur : impossible d’ouvrir le fichier %s\n", filename);
        exit(EXIT_FAILURE);
    }

    char line[128];
    while (fgets(line, sizeof(line),file)) {
        Instruction inst = {0};

        int nb = sscanf(line, "%d %d %d %d", &inst.opcode, &inst.a1, &inst.a2, &inst.a3);
        if(nb >= 2) {
            instructions[instruction_count++] = inst;
        } else{
            fprintf(stderr, "Erreur lors de la lecture de la ligne : %s\n", line);
        }
    }

    fclose(file);

    // for (size_t i = 0; i < 20; i++)
    // {
    //     printf("Instruction %ld : %d %d %d %d\n",i,instructions[i].opcode,instructions[i].a1,instructions[i].a2,instructions[i].a3);
    // }
}

void execute() {
    int pc = 0;
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
                pc = inst.a1 - 1; // -1 because pc++ after switch
                break;
            case 8: // JMF
                if (memory[inst.a1] == 0)
                    pc = inst.a2 - 1;
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
            default:
                fprintf(stderr, "Erreur : opcode inconnu %d à la ligne %d\n", inst.opcode, pc);
                exit(EXIT_FAILURE);
        }
        pc++;
    }

    // for (size_t i = 0; i < 20; i++)
    // {
    //     printf("Memory pos %ld have value : %d\n", i, memory[i]);
    // }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage : %s <fichier_code.asm>\n", argv[0]);
        return EXIT_FAILURE;
    }

    load_instructions(argv[1]);
    execute();

    return EXIT_SUCCESS;
}
