#include<bits/stdc++.h>
using namespace std;

void writeMatchedRuleInLogFile(FILE *logout, int lineCount, string text)
    {
        cout << "Line no: " << lineCount << " " << text << endl;
        fprintf(logout, "Line no: %d %s\n\n",lineCount, text.c_str());
    }

void writeMatchedSymbolInLogFile(FILE *logout, string name)
    {
    	cout << name << endl;
        fprintf(logout, "%s\n\n",name.c_str());
    }

void writeError(FILE *logout, FILE *errorFile, int line_count, string errorMsg)
{
    fprintf(logout, "Error at line %d: %s\n\n",line_count, errorMsg.c_str());
	fprintf(errorFile, "Error at line %d: %s\n\n",line_count, errorMsg.c_str());
}


void writeWarning(FILE *logout, FILE *errorFile, int line_count, string errorMsg)
{
    fprintf(logout, "Warning at line %d: %s\n\n",line_count, errorMsg.c_str());
	fprintf(errorFile, "Warning at line %d: %s\n\n",line_count, errorMsg.c_str());
}
