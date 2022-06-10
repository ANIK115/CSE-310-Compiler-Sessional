%option noyywrap

%x STRING_STATE
%x STRING_STATE_2
%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT

%{
#include<stdio.h>
#include<stdlib.h>
#include<bits/stdc++.h>
using namespace std;

int no_of_buckets = 7;

int line_count=1;
int errors = 0;
int begin_string_line;
int begin_comment_line;
string str = "";
string inStr = "";
string comment = "";

FILE *logout;
FILE *tokenout;


class SymbolInfo
{
    string name;
    string type;
    SymbolInfo *next;

public:

    SymbolInfo()
    {
        next= NULL;
    }

    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        next = NULL;
    }

    string getName()
    {
        return this->name;
    }
    string getType()
    {
        return this->type;
    }
    SymbolInfo* getNext()
    {
        return next;
    }
    void setNext(string symName, string symType)
    {
        next = new SymbolInfo(symName, symType);
    }
    void setNext(SymbolInfo* s)
    {
        next = s;
    }
    void setName(string name)
    {
        this->name = name;
    }
    void setType(string type)
    {
        this->type = type;
    }
    ~SymbolInfo()
    {
        delete next;
    }
};


class ScopeTable //hash table
{
public:

    SymbolInfo **syfo; //pointer for the hash table
    ScopeTable *parentScope;
    int deletedId = 0;
    string scopeId= "";

    ScopeTable(int n)
    {
        syfo = new SymbolInfo*[n];
        for(int i=0; i<n; i++)
        {
            syfo[i] = NULL;
        }
        parentScope = NULL;
    }

    string giveUniqueId()
    {
        if(parentScope != NULL)
        {
            scopeId += parentScope->scopeId+".";
        }
        scopeId += to_string((parentScope->deletedId+1));
        return scopeId;
    }

    uint32_t hashing(string name)
    {
        uint32_t hashVal = 0;
        int c;
        for(int i=0; i<name.size(); i++)
        {
            c = name[i];
            hashVal = c + (hashVal << 6) + (hashVal << 16) - hashVal;
        }
        return (hashVal%no_of_buckets);
    }

    SymbolInfo* lookUp(string symbolName)
    {
        SymbolInfo **ptr = this->syfo;
        int ind = hashing(symbolName);
        int auxInd = 0;
        SymbolInfo *cur = ptr[ind];
        while(cur!= NULL)
        {
            if(cur->getName() == symbolName)
            {
                cout << "Found in ScopeTable# " << scopeId << " at position " << ind << ", " << auxInd << endl;
                return cur;
            }
            cur = cur->getNext();
            auxInd++;
        }
        return cur;
    }

    bool insertIntoSymbolTable(string symbolName, string symbolType)
    {
        SymbolInfo **ptr = this->syfo;
        int ind = hashing(symbolName);
        int pos = 0;

        SymbolInfo *cur = ptr[ind];
        while(true)
        {
            if(cur == NULL)
            {
                ptr[ind] = new SymbolInfo(symbolName, symbolType);
                cout << "Inserted in ScopeTable# " << scopeId << " at position " << ind << ", " << pos << endl;
                return true;
            }
            if(cur->getName()== symbolName)
            {
                cout << "<" << symbolName << "," << symbolType << "> already exists in current ScopeTable" << endl;
                return false;
            }
            if(cur->getNext() == NULL)
            {
                pos++;
                cur->setNext(symbolName, symbolType);
                cout << "Inserted in ScopeTable# " << scopeId << " at position " << ind << ", " << pos << endl;
                return true;
            }
            cur = cur->getNext();
            pos++;
        }
    }

    bool deleteAnEntry(string symbol)
    {
        int location = hashing(symbol);
        SymbolInfo **ptr = this->syfo;
        SymbolInfo *cur = ptr[location];
        int ind = 0;
        if(cur == NULL)
        {
            cout << "Not found\n";
            return false;
        }
        if(cur->getName()==symbol)
        {
            ptr[location] = cur->getNext();
            delete cur;
            cout << "Found in ScopeTable# "<< scopeId << " at position "<< location << ", " <<ind <<endl;
            cout << "Deleted Entry " << location << ", " << ind << " from current ScopeTable" << endl;
            return true;
        }
        SymbolInfo *prev = cur;
        while(cur != NULL)
        {
            if(cur->getName()==symbol)
            {
                prev->setNext(cur->getNext());
                delete cur;
                cout << "Found in ScopeTable# "<< scopeId << " at position "<< location << ", " <<ind <<endl;
                cout << "Deleted Entry " << location << ", " << ind << " from current ScopeTable" << endl;
                return true;
            }
            prev = cur;
            cur = cur->getNext();
            ind++;
        }
        cout << "Not found!" << endl;
        return false;
    }

    void print()
    {
        SymbolInfo **ptr = this->syfo;
        for(int i=0; i<no_of_buckets; i++)
        {
            if(ptr == NULL)
            {
                cout << i << " -->" << endl;
            }
            else
            {
                SymbolInfo *auxPtr = *ptr;
                cout << i << " --> ";
                while(auxPtr != NULL)
                {
                    cout << "<" << auxPtr->getName() <<" : " << auxPtr->getType() << ">\t";
                    auxPtr = auxPtr->getNext();
                }
                cout << endl;
            }
            ptr++;
        }
    }

    void printInLogFile()
    {
        FILE *fptr = logout;
        SymbolInfo **ptr = this->syfo;
        bool flag = true;
        for(int i=0; i<no_of_buckets; i++)
        {
            if(*ptr != NULL)
            {
            	if(flag)
        	{
        		fprintf(fptr, "\nScopeTable # %s\n", this->scopeId.c_str());
        		flag = false;
        	}
        	
                SymbolInfo *auxPtr = *ptr;
                fprintf(fptr, "%d--> ",i);
                while(auxPtr != NULL)
                {
                    fprintf(fptr, "<%s : %s> ", auxPtr->getName().c_str(), auxPtr->getType().c_str());
                    auxPtr = auxPtr->getNext();
                }
                fprintf(fptr, "\n");
            }
            ptr++;
        }
    }

    ~ScopeTable()
    {
        for(int i=0; i<no_of_buckets; i++)
        {
            delete syfo[i];
        }
        delete[] syfo;
    }
};


class SymbolTable
{
public:

    ScopeTable *currentScopeTable;

    SymbolTable(int n)
    {
        currentScopeTable = new ScopeTable(n);
        currentScopeTable->scopeId = "1";
    }

    void enterScope(int n)
    {
        if(this->currentScopeTable == NULL)
        {
            currentScopeTable = new ScopeTable(no_of_buckets);
            currentScopeTable->scopeId = "1";
            return;
        }
        ScopeTable *st = new ScopeTable(n);
        st->parentScope = this->currentScopeTable;
        this->currentScopeTable = st;
        cout <<"New ScopeTable with id " << this->currentScopeTable->giveUniqueId() <<" created\n";
    }

    void exitScope()
    {
        if(this->currentScopeTable==NULL)
        {
            cout << "NO CURRENT SCOPE" << endl;
            return;
        }
        ScopeTable *temp = this->currentScopeTable;
        cout << "ScopeTable with id " << temp->scopeId << " removed" << endl;
        this->currentScopeTable = this->currentScopeTable->parentScope;
        if(this->currentScopeTable != NULL)
        {
            this->currentScopeTable->deletedId++;
        }
        delete temp;
    }

    bool insertInCurrentST(string name, string type)
    {
        if(this->currentScopeTable == NULL)
        {
            currentScopeTable = new ScopeTable(no_of_buckets);
            currentScopeTable->scopeId = "1";
        }
        bool flag = this->currentScopeTable->insertIntoSymbolTable(name, type);
        return flag;
    }

    bool removeFromCurrentST(string name)
    {
        if(this->currentScopeTable==NULL)
        {
            cout << "NO CURRENT SCOPE" << endl;
            return false;
        }
        bool flag = this->currentScopeTable->deleteAnEntry(name);
        return flag;
    }

    SymbolInfo* lookUp(string name)
    {
        if(this->currentScopeTable==NULL)
        {
            cout << "NO CURRENT SCOPE" << endl;
            return NULL;
        }
        ScopeTable *ptr = currentScopeTable;
        SymbolInfo *location = ptr->lookUp(name);
        if(location != NULL)
        {
            return location;
        }
        while(ptr->parentScope != NULL)
        {
            ptr = ptr->parentScope;
            location = ptr->lookUp(name);
            if(location != NULL)
            {
                cout << "Found!!!!!!!!!!" << endl;
                return location;
            }
        }
        cout << "Not found " << endl;
        return location;
    }

    void printCurrentScopeTable()
    {
        if(this->currentScopeTable==NULL)
        {
            cout << "NO CURRENT SCOPE" << endl;
            return;
        }
        cout << "ScopeTable # " << this->currentScopeTable->scopeId << endl;
        this->currentScopeTable->print();
    }

    void printAllScopeTable()
    {
        if(this->currentScopeTable==NULL)
        {
            cout << "NO CURRENT SCOPE" << endl;
            return;
        }
        ScopeTable *ptr = this->currentScopeTable;
        while(ptr!= NULL)
        {
            cout << "\nScopeTable # " << ptr->scopeId << endl;
            ptr->print();
            ptr->printInLogFile();
            ptr = ptr->parentScope;
        }
        delete ptr;
    }
    ~SymbolTable()
    {
        delete currentScopeTable;
    }
};


SymbolTable st(no_of_buckets);




%}



WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n|\r\n
ID [a-zA-Z_][a-zA-Z0-9_]*
ANYTHING .
IC '
METACHARS [nta'\\frbv0"]
SINGLECOMMENT [/][/]
MULTILINECOMMENT [/][\*]

%%

{NEWLINE} {line_count++;}

"if"	{
			fprintf(tokenout,"<IF> ");
			fprintf(logout,"\nLine no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}
		
"else"	{
			fprintf(tokenout,"<ELSE> ");
			fprintf(logout,"\nLine no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
		}
		
"for"	{	
			fprintf(tokenout, "<FOR> ");
			fprintf(logout, "\nLine no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
		}	

"do" 	{		
			fprintf(tokenout, "<DO> ");
			fprintf(logout, "\nLine no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
		}

"int"	{
			fprintf(tokenout, "<INT> ");
			fprintf(logout, "\nLine no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
		}

"float"	{
			fprintf(tokenout, "<FLOAT> ");
			fprintf(logout, "\nLine no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
		}

"void"	{
			fprintf(tokenout, "<VOID> ");
			fprintf(logout, "\nLine no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
		}
		
"switch"	{
			fprintf(tokenout, "<SWITCH> ");
			fprintf(logout, "\nLine no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
		}

"default"	{
			fprintf(tokenout, "<DEFAULT> ");
			fprintf(logout, "\nLine no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
		}
		
"while"	{
			fprintf(tokenout, "<WHILE> ");
			fprintf(logout, "\nLine no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
		}
		
"break"	{
			fprintf(tokenout, "<BREAK> ");
			fprintf(logout, "\nLine no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
		}
		
"char"	{
			fprintf(tokenout, "<CHAR> ");
			fprintf(logout, "\nLine no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
		}
		
"double"	{
			fprintf(tokenout,"<DOUBLE> ");
			fprintf(logout,"\nLine no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
		}
		
"return"	{
			fprintf(tokenout,"<RETURN> ");
			fprintf(logout,"\nLine no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
		}
	
"case"	{
			fprintf(tokenout,"<CASE> ");
			fprintf(logout,"\nLine no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
		}
		
"continue"	{
			fprintf(tokenout,"<CONTINUE> ");
			fprintf(logout,"\nLine no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
		}
		
		
		

"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}
		
"*"|"/"|"%"	{
		
			fprintf(tokenout,"<MULOP,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
		}
		
"++"|"--"	{
		
			fprintf(tokenout,"<INCOP,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
		}
		
"<"|"<="|">"|">="|"=="|"!="
		{
		
			fprintf(tokenout,"<RELOP,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
		}
		
"="		{
		
			fprintf(tokenout,"<ASSIGNOP,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
		}
		
"&&"|"||"	{
		
			fprintf(tokenout,"<LOGICOP,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
		}
		
"!"		{
		
			fprintf(tokenout,"<NOT,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <NOT> Lexeme %s found\n",line_count,yytext);
		}
		
"("		{
		
			fprintf(tokenout,"<LPAREN,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
		}
		
")"		{
		
			fprintf(tokenout,"<RPAREN,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
		}
		

"{"		{
		
			fprintf(tokenout,"<LCURL,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
			st.enterScope(no_of_buckets);
		}
		
"}"		{
		
			fprintf(tokenout,"<MULOP,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			st.exitScope();
		}
		
"["		{
		
			fprintf(tokenout,"<LTHIRD,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
		}
		
"]"		{
		
			fprintf(tokenout,"<RTHIRD,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_count,yytext);
		}
		
","		{
		
			fprintf(tokenout,"<COMMA,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
		}
		
";"		{
		
			fprintf(tokenout,"<SEMICOLON,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
		}
		
{DIGIT}+ 	{
			fprintf(tokenout,"<CONST_INT,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
			//insert in symbol table and print symbol table content(only non empty buckets)
			bool flag = st.insertInCurrentST(yytext, "CONST_INT");
			if(flag) st.printAllScopeTable();
			else fprintf(logout, "\n%s already exists in current ScopeTable\n", yytext);
				
				
		}
		

{DIGIT}*\.?{DIGIT}+E?[+-]?({DIGIT}|{DIGIT}*)	{
			fprintf(tokenout,"<CONST_FLOAT,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
			//insert in symbol table and print symbol table content(only non empty buckets)
			bool flag = st.insertInCurrentST(yytext, "CONST_FLOAT");
			if(flag) st.printAllScopeTable();
			else fprintf(logout, "\n%s already exixsts in current ScopeTable\n", yytext);
				
		}
		
((\.)*{DIGIT}*)*	{
			fprintf(logout,"\nError at line no %d: Too many decimal points %s\n",line_count,yytext);
			errors++;

		}

{DIGIT}*\.?{DIGIT}+E?[+-]?({DIGIT}|{DIGIT}*)(\.{DIGIT}+)+ {
			fprintf(logout,"\nError at line no %d: Ill formed number %s\n",line_count,yytext);
			errors++;
		
		}
		
({DIGIT}+{ID}+)+	{
			fprintf(logout,"\nError at line no %d: Invalid prefix on ID or invalid suffix on Number %s\n",line_count,yytext);
			errors++;

		}		

		
{ID}		{
			fprintf(tokenout,"<ID,%s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
			//insert in symbol table and print symbol table content(only non empty buckets)
			bool flag = st.insertInCurrentST(yytext, "ID");
			if(flag) st.printAllScopeTable();
			else fprintf(logout, "\n%s already exixsts in current ScopeTable\n", yytext);

		}
		
{IC}{IC}	{
			fprintf(logout,"\nError at line no %d: Empty character constant error %s\n",line_count,yytext);
			errors++;
		}
		
{IC}[\\]{ANYTHING}{IC} {
			//printf("catching metachars in character literals.................\n\n");
			char a = yytext[1];
			char b = yytext[2];
			string name;
			string tokenName= "";
			if(b=='n') {
				name = "'\\n'"; tokenName += "\n"; }
			if(b=='t') {
				name = "'\\t'"; tokenName += "\t"; }
			else if(b=='a') {
				name = "'\\a'"; tokenName += "\a"; }
			else if(b=='f') {
				name = "'\\f'"; tokenName += "\f"; }
			else if(b=='r') {
				name = "'\\r'"; tokenName += "\r"; }
			else if(b=='b') {
				name = "'\\b'"; tokenName += "\b"; }
			else if(b=='v') {
				name = "'\\v'"; tokenName += "\v"; }
			else if(b=='\\') {
				name ="'\\\\'"; tokenName += "\\"; }
			else if(b=='\'') {
				name = "'\''"; tokenName += "'"; }
			else if(b=='\0') {
				name = "'\\0'"; tokenName += "\0"; }
			else
			{
				name = "'\\";
				name += b;
				name += "'";
				tokenName = "";
				tokenName += b;
			}
			
			fprintf(tokenout, "<CONST_CHAR,%s> ", tokenName.c_str());
			fprintf(logout, "\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,%s >\n",line_count,name.c_str(), tokenName.c_str());
			
			bool flag = st.insertInCurrentST(name, "CONST_CHAR");
			if(flag) st.printAllScopeTable();
			else fprintf(logout, "\n%s already exixsts in current ScopeTable\n", name.c_str());

		}

		
{IC}[^\\]{IC}	{
			char cl = yytext[1];
			fprintf(tokenout,"<CONST_CHAR,%c> ",cl);
			string name = "'";
			name += cl;
			name += "'";
			fprintf(logout, "\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,%c >\n",line_count,name.c_str(),cl);
			//insert in symbol table and print symbol table content(only non empty buckets)
			bool flag = st.insertInCurrentST(name, "CONST_CHAR");
			if(flag) st.printAllScopeTable();
			else fprintf(logout, "\n%s already exixsts in current ScopeTable\n", name.c_str());

		}
		
		
{IC}[^'\n]*|{IC}[\\]{IC}	{
			
			fprintf(logout,"\nError at line no %d: Unterminated character %s\n",line_count,yytext);
			errors++;
			}
			
{IC}{ANYTHING}*{IC}		{
			
			fprintf(logout,"\nError at line no %d: Multi character constant error %s\n",line_count,yytext);
			errors++;
			}
			
["]		{
			begin_string_line = line_count;
			str ="\"";
			inStr = "\"";
			BEGIN STRING_STATE;
		
		}
		
<STRING_STATE>["]	{
			str += "\"";
			inStr += "\"";
			fprintf(tokenout,"<STRING,%s> ",str.c_str());
			fprintf(logout,"\nLine no %d: TOKEN <STRING> Lexeme %s found --> <STRING, %s>\n",begin_string_line,inStr.c_str(), str.c_str());
			BEGIN INITIAL;

		}
		
<STRING_STATE>[^\n\\"]* {
			str += yytext;
			inStr += yytext;
		}
		
<STRING_STATE>[\n] {
			fprintf(logout,"\nError at line no %d: Unfinished string \"%s\n",begin_string_line, str.c_str());
			line_count++;
			errors++;
			BEGIN INITIAL;
		}
		
<STRING_STATE>[\\]	{
			inStr += "\\";
			BEGIN STRING_STATE_2;
		}
		
		
<STRING_STATE_2>{WHITESPACE}*{NEWLINE}	{
			line_count++;
			inStr += "\n";
			BEGIN STRING_STATE;

		}
		
<STRING_STATE>[\\]{METACHARS} {
			printf("Got a meta char in string.............\n\n");
			char b = yytext[1];
			if(b=='n') {
				str+= "\n"; inStr += "\\n"; }
			if(b=='t') {
				str+= "\t"; inStr += "\\t"; }
			if(b=='a') {
				str+= "\a"; inStr += "\\a"; }
			if(b=='f') {
				str+= "\f"; inStr += "\\f"; }
			if(b=='r') {
				str+= "\r"; inStr += "\\r"; }
			if(b=='b') {
				str+= "\b"; inStr += "\\b"; }
			if(b=='v') {
				str+= "\v"; inStr += "\\v"; }
			if(b=='\\') {
				str+="\\"; inStr += "\\\\"; }
			if(b=='\'') {
				str+= "'"; inStr += "\\'"; }
			if(b=='\0') {
				str+= "\0"; inStr += "\\0"; }
			if(b=='\"') {
				str+= "\""; inStr += "\\\""; }
			
			//fprintf(logout, "...............now string is %s ...............\n\n\n\n", str.c_str());
		}
		
<STRING_STATE>[\\]. {
			printf("Executing other character after slash...%c\n", yytext[1]);
			str+= yytext[1];
			inStr+= "\\";
			inStr+= yytext[1];
			
		}
		
{SINGLECOMMENT} 	{
			begin_comment_line = line_count;
			comment ="//";
			BEGIN SINGLE_LINE_COMMENT;

		}
		
<SINGLE_LINE_COMMENT>{NEWLINE}|[\\][^\n]* {
			fprintf(logout, "\nLine no %d: Token <COMMENT> Lexeme %s found\n",begin_comment_line, comment.c_str());
			line_count++;
			BEGIN INITIAL;

		}
		
<SINGLE_LINE_COMMENT>[\\]{NEWLINE}	{
			line_count++;

		}
		
<SINGLE_LINE_COMMENT>[^\n]* {
			comment += yytext;

		}
		
{MULTILINECOMMENT}		{
			begin_comment_line = line_count;
			comment = "/*";
			BEGIN MULTI_LINE_COMMENT;
		}
		
<MULTI_LINE_COMMENT>[\*][/]	{
			comment += "*/";
			fprintf(logout, "\nLine no %d: Token <COMMENT> Lexeme %s found\n",begin_comment_line, comment.c_str());
			BEGIN INITIAL;
		}
		
<MULTI_LINE_COMMENT>{NEWLINE}   {
			line_count++;
			comment += "\n";
		}
		
<MULTI_LINE_COMMENT><<EOF>> {
			fprintf(logout,"\nLine no %d: Unfinished comment %s\n",begin_comment_line, comment.c_str());
			errors++;
			BEGIN INITIAL;
		}
		
<MULTI_LINE_COMMENT>{ANYTHING}  {
			comment += yytext;

		}

				

{WHITESPACE}	{
		
		}
			
{ANYTHING}	{
		
			fprintf(logout,"\nLine no %d: Unrecognized character %s found\n",line_count,yytext);
		}
		
<<EOF>>		{
			line_count--;
			st.printAllScopeTable();
			fprintf(logout, "\nTotal lines: %d\n",line_count);
			fprintf(logout, "Total errors: %d\n",errors);
			
			return 0;

		}

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
