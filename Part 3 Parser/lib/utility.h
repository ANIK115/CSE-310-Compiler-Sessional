#include<bits/stdc++.h>
using namespace std;

void writeMatchedRuleInLogFile(FILE *logout, int lineCount, string text)
    {
        fprintf(logout, "Line no: %d %s\n\n",lineCount, text.c_str());
    }

void writeMatchedSymbolInLogFile(FILE *logout, string name)
    {
        fprintf(logout, "%s\n\n",name.c_str());
    }

void writeError(FILE *logout, FILE *errorFile, int line_count, string errorMsg)
{
    fprintf(logout, "Error at line %d: %s\n\n",line_count, errorMsg.c_str());
	fprintf(errorFile, "Error at line %d: %s\n\n",line_count, errorMsg.c_str());
}

