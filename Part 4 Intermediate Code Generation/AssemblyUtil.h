#include<bits/stdc++.h>
using namespace std;


void writeAssembly(FILE *asmFile, string code)
{
    fprintf(asmFile, "%s", code.c_str());
}

void initializeAssembly(FILE *asmFile)
{
    string code = ".MODEL SMALL\n";
    code += ".STACK 100H\n";
    code += ".CODE\n";
    fprintf(asmFile, "%s", code.c_str());
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
	fprintf(asmFile, "%s", code.c_str());
}

void optimizeCode(FILE *asmFile)
{
    asmFile = fopen("optimize.asm", "w");

    vector<string> codes;

    ifstream file_in("code.asm");
    string line;

    while (getline(file_in, line))
    {
        codes.push_back(line);
    }
    
    for(int i=0; i<=codes.size()-1; i++)
    {
        if(codes[i].size() < 4 || codes[i+1].size() < 4)
        {
            fprintf(asmFile, "%s\n", codes[i].c_str());
        }
        else if(codes[i].substr(1,3) == "MOV" && codes[i+1].substr(1,3) == "MOV")
        {
            
            
                stringstream ss1(codes[i]);
                stringstream ss2(codes[i+1]);
                vector<string>vars1, vars2;
                while(getline(ss1, line, ' '))
                    vars1.push_back(line);
                while(getline(ss2, line , ' '))
                    vars2.push_back(line);
                
                int a,b,c,d;
                a = vars1[1].size()-1;
                b = vars1[2].size()-1;
                c = vars2[1].size()-1;
                d = vars2[2].size()-1;
                if(vars1[1].substr(0, a) == vars2[1].substr(0,c) && vars1[2].substr(0,b) == vars2[2].substr(0,d))
                {
                    fprintf(asmFile, "%s\n", codes[i++].c_str());
                    cout << "Got a change in first one\n\n";
                }else if(vars1[1].substr(0,a) == vars2[2] && vars2[1].substr(0, c) == vars1[2])
                {
                    fprintf(asmFile, "%s\n", codes[i++].c_str());
                    cout << "Got a change in second one\n\n";
                }else
                {
                    fprintf(asmFile, "%s\n", codes[i].c_str());

                }
            
        }else
        {
            fprintf(asmFile, "%s\n", codes[i].c_str());

        }
    }
    fclose(asmFile);
}
