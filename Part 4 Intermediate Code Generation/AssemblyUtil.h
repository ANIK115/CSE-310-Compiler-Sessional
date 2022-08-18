#include<bits/stdc++.h>
using namespace std;


void writeAssembly(FILE *asmFile, string code)
{
    fprintf(asmFile, "%s\n", code.c_str());
}

void initializeAssembly(FILE *asmFile)
{
    string code = ".MODEL SMALL\n";
    code += ".STACK 100H\n";
    code += ".CODE\n";
    fprintf(asmFile, "%s\n", code.c_str());
}

void printFunction(FILE *asmFile)
{
	string code = "DISPLAY PROC\n";
    code += "\tCMP AX, 0\n";
    code += "\tJGE PRINT\n";
    code += "\tMOV DL, \'-\'\n";
    code += "\tPUSH AX\n";
    code += "\tMOV AH, 2\n";
    code += "\tINT 21H\n";
    code += "\tPOP AX\n";
    code += "\tNEG AX\n";
    code += "PRINT:\n";
    code += "\tLEA SI, NUMBER_STRING\n";
    code += "\tADD SI, 5\n\n";
    code += "\tPRINT_LOOP:\n";
    code += "\tDEC SI\n";
    code += "\tMOV DX, 0\n";
    code += "\t;DX:AX = 0000:AX\n";
    code += "\tPUSH CX\n";
    code += "\tMOV CX, 10\n";
    code += "\tDIV CX\n";
    code += "\tPOP CX\n";
    code += "\tADD DL, 48\n";
    code += "\t MOV [SI], DL\n";
    code += "\tCMP AX, 0\n";
    code += "JNE PRINT_LOOP\n";
    code += "MOV DX, SI\n";
    code += "\tMOV AH, 9\n";
    code += "\tINT 21H\n";
    code += "\tLEA DX, NEWLINE\n";
    code += "\tMOV AH, 9\n";
    code += "\tINT 21H\n";
    code += "\tXOR AX, AX\n";
    code += "\tRET\n";
	fprintf(asmFile, "%s\n", code.c_str());
}

