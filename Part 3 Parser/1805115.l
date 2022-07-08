%option noyywrap

%x STRING_STATE
%x STRING_STATE_2
%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT

%{
#include<bits/stdc++.h>
using namespace std;


#include "1805115.cpp"
#include "y.tab.h"


int begin_string_line;
int begin_comment_line;
string str = "";
string inStr = "";
string comment = "";


extern int line_count;
extern int errors;
extern SymbolTable *st;

extern YYSTYPE yylval;





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
			// fprintf(tokenout,"<IF> ");
			// fprintf(logout,"\nLine no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return IF;
		}
		
"else"	{
			// fprintf(tokenout,"<ELSE> ");
			// fprintf(logout,"\nLine no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return ELSE;
		}
		
"for"	{	
			// fprintf(tokenout, "<FOR> ");
			// fprintf(logout, "\nLine no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return FOR;
		}	

"do" 	{		
			// fprintf(tokenout, "<DO> ");
			// fprintf(logout, "\nLine no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return DO;
		}

"int"	{
			// fprintf(tokenout, "<INT> ");
			// fprintf(logout, "\nLine no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return INT;
		}

"float"	{
			// fprintf(tokenout, "<FLOAT> ");
			// fprintf(logout, "\nLine no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return FLOAT;
		}

"void"	{
			// fprintf(tokenout, "<VOID> ");
			// fprintf(logout, "\nLine no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return VOID;
		}
		
"switch"	{
			// fprintf(tokenout, "<SWITCH> ");
			// fprintf(logout, "\nLine no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return SWITCH;
		}

"default"	{
			// fprintf(tokenout, "<DEFAULT> ");
			// fprintf(logout, "\nLine no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return DEFAULT;
		}
		
"while"	{
			// fprintf(tokenout, "<WHILE> ");
			// fprintf(logout, "\nLine no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return WHILE;
		}
		
"break"	{
			// fprintf(tokenout, "<BREAK> ");
			// fprintf(logout, "\nLine no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return BREAK;
		}
		
"char"	{
			// fprintf(tokenout, "<CHAR> ");
			// fprintf(logout, "\nLine no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return CHAR;
		}
		
"double"	{
			// fprintf(tokenout,"<DOUBLE> ");
			// fprintf(logout,"\nLine no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return DOUBLE;
		}
		
"return"	{
			// fprintf(tokenout,"<RETURN> ");
			// fprintf(logout,"\nLine no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return RETURN;
		}
	
"case"	{
			// fprintf(tokenout,"<CASE> ");
			// fprintf(logout,"\nLine no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return CASE;
		}
		
"continue"	{
			// fprintf(tokenout,"<CONTINUE> ");
			// fprintf(logout,"\nLine no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "keyword";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return CONTINUE;
		}
		
		
		

"+"		|

"-"		{
			// fprintf(tokenout,"<ADDOP,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "ADDOP";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return ADDOP;
		}
		
"*"|"/"|"%"	{
		
			// fprintf(tokenout,"<MULOP,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "MULOP";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return MULOP;
		}
		
"++"	{
		
			// fprintf(tokenout,"<INCOP,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "INCOP";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return INCOP;
		}
"--"	{
			string name = yytext;
			string type = "INCOP";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return DECOP;

		}
		
"<"|"<="|">"|">="|"=="|"!="	{
		
			// fprintf(tokenout,"<RELOP,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "RELOP";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return RELOP;
		}
		
"="		{
		
			// fprintf(tokenout,"<ASSIGNOP,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "ASSIGNOP";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return ASSIGNOP;
		}
		
"&&"|"||"	{
		
			// fprintf(tokenout,"<LOGICOP,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "LOGICOP";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return LOGICOP;
		}
		
"!"		{
		
			// fprintf(tokenout,"<NOT,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <NOT> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "NOT";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return NOT;
		}
		
"("		{
		
			// fprintf(tokenout,"<LPAREN,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "LPAREN";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return LPAREN;
		}
		
")"		{
		
			// fprintf(tokenout,"<RPAREN,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "RPAREN";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return RPAREN;
		}
		

"{"		{
		
			// fprintf(tokenout,"<LCURL,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
			// st.enterScope(no_of_buckets);
			string name = yytext;
			string type = "LCURL";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return LCURL;
		}
		
"}"		{
		
			// fprintf(tokenout,"<MULOP,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
			// st.exitScope();
			string name = yytext;
			string type = "RCURL";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return RCURL;
		}
		
"["		{
		
			// fprintf(tokenout,"<LTHIRD,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "LTHIRD";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return LTHIRD;
		}
		
"]"		{
		
			// fprintf(tokenout,"<RTHIRD,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "RTHIRD";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return RTHIRD;
		}
		
","		{
		
			// fprintf(tokenout,"<COMMA,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "COMMA";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return COMMA;
		}
		
";"		{
		
			// fprintf(tokenout,"<SEMICOLON,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			string name = yytext;
			string type = "SEMICOLON";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return SEMICOLON;
		}
		
{DIGIT}+ 	{
			// fprintf(tokenout,"<CONST_INT,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
			// //insert in symbol table and print symbol table content(only non empty buckets)
			// bool flag = st.insertInCurrentST(yytext, "CONST_INT");
			// if(flag) st.printAllScopeTable(logout);
			// else fprintf(logout, "\n%s already exists in current ScopeTable\n", yytext);

			string name = yytext;
			string type = "CONST_INT";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return CONST_INT;
				
				
		}
		

{DIGIT}*\.?{DIGIT}+E?[+-]?({DIGIT}|{DIGIT}*)	{
			// fprintf(tokenout,"<CONST_FLOAT,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
			// //insert in symbol table and print symbol table content(only non empty buckets)
			// bool flag = st.insertInCurrentST(yytext, "CONST_FLOAT");
			// if(flag) st.printAllScopeTable(logout);
			// else fprintf(logout, "\n%s already exixsts in current ScopeTable\n", yytext);

			string name = yytext;
			string type = "CONST_FLOAT";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return CONST_FLOAT;
				
		}
		
((\.)*{DIGIT}*)*	{
			// fprintf(logout,"\nError at line no %d: Too many decimal points %s\n",line_count,yytext);
			errors++;

		}

{DIGIT}*\.?{DIGIT}+E?[+-]?({DIGIT}|{DIGIT}*)(\.{DIGIT}+)+ {
			// fprintf(logout,"\nError at line no %d: Ill formed number %s\n",line_count,yytext);
			errors++;
		
		}
		
({DIGIT}+{ID}+)+	{
			// fprintf(logout,"\nError at line no %d: Invalid prefix on ID or invalid suffix on Number %s\n",line_count,yytext);
			errors++;

		}		

		
{ID}		{
			// fprintf(tokenout,"<ID,%s> ",yytext);
			// fprintf(logout,"\nLine no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
			// //insert in symbol table and print symbol table content(only non empty buckets)
			// bool flag = st.insertInCurrentST(yytext, "ID");
			// if(flag) st.printAllScopeTable(logout);
			// else fprintf(logout, "\n%s already exixsts in current ScopeTable\n", yytext);

			string name = yytext;
			string type = "ID";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return ID;

		}
		
{IC}{IC}	{
			// fprintf(logout,"\nError at line no %d: Empty character constant error %s\n",line_count,yytext);
			errors++;
		}
		
{IC}[\\]{ANYTHING}{IC} {
			//fprintf(logout, "catching metachars in character literals %s.................\n\n", yytext);
			//char a = yytext[0];
			char b = yytext[2];
			//char c = yytext[2];
			//fprintf(logout,"0: %c, 1: %c, 2: %c\n\n",a,b,c);
			string name;
			char tokenName;
			if(b=='n') {
				name = "'\\n'"; tokenName = '\n'; }
			else if(b=='t') {
				name = "'\\t'"; tokenName = '\t'; }
			else if(b=='a') {
				name = "'\\a'"; tokenName = '\a'; }
			else if(b=='f') {
				name = "'\\f'"; tokenName = '\f'; }
			else if(b=='r') {
				name = "'\\r'"; tokenName = '\r'; }
			else if(b=='b') {
				name = "'\\b'"; tokenName = '\b'; }
			else if(b=='v') {
				name = "'\\v'"; tokenName = '\v'; }
			else if(b=='\\') {
				name ="'\\\\'"; tokenName = '\\'; }
			else if(b=='\'') {
				name = "'\''"; tokenName = '\''; }
			else if(b=='\0') {
				name = "'\\0'"; tokenName = '\0'; }
			else
			{
				name = "'\\";
				name += b;
				name += "'";
				tokenName = b;
			}
			
			// fprintf(tokenout, "<CONST_CHAR,%c> ", tokenName);
			// fprintf(logout, "\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found -->  <CHAR_CONST,%c > \n",line_count,name.c_str(),tokenName);
			
			// bool flag = st.insertInCurrentST(name, "CONST_CHAR");
			// if(flag) st.printAllScopeTable(logout);
			// else fprintf(logout, "\n%s already exixsts in current ScopeTable\n", name.c_str());

			string type = "CONST_CHAR";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return CONST_CHAR;

		}

		
{IC}[^\\\n]{IC}	{
			//fprintf(logout,"executing line 709-----\n");
			char cl = yytext[1];
			//fprintf(tokenout,"<CONST_CHAR,%c> ",cl);
			string name = "'";
			name += cl;
			name += "'";
			// fprintf(logout, "\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,%c >\n",line_count,name.c_str(),cl);
			// //insert in symbol table and print symbol table content(only non empty buckets)
			// bool flag = st.insertInCurrentST(name, "CONST_CHAR");
			// if(flag) st.printAllScopeTable(logout);
			// else fprintf(logout, "\n%s already exixsts in current ScopeTable\n", name.c_str());

			string type = "CONST_CHAR";
			SymbolInfo *syfo = new SymbolInfo(name, type);
			yylval.symbol = syfo;
			return CONST_CHAR;

		}
		
		
{IC}[^'\n]*|{IC}[\\]{IC}	{
			//fprintf(logout,"executing line 725-----\n");
			// fprintf(logout,"\nError at line no %d: Unterminated character %s\n",line_count,yytext);
			errors++;
			}
			
{IC}{ANYTHING}*{IC}		{
			//fprintf(logout,"executing line 731-----\n");
			// fprintf(logout,"\nError at line no %d: Multi character constant error %s\n",line_count,yytext);
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
			// fprintf(tokenout,"<STRING,%s> ",str.c_str());
			// fprintf(logout,"\nLine no %d: TOKEN <STRING> Lexeme %s found --> <STRING, %s>\n",begin_string_line,inStr.c_str(), str.c_str());
			BEGIN INITIAL;
			yylval.symbol = new SymbolInfo(inStr, "STRING");
			return STRING;

		}
		
		
<STRING_STATE>[^"\n\\]* {
			//fprintf(logout, "At this time: %s\n",yytext);
			str += yytext;
			inStr += yytext;
		}
		
<STRING_STATE>[\n] {
			// fprintf(logout,"\nError at line no %d: Unterminated string %s\n",begin_string_line, inStr.c_str());
			line_count++;
			errors++;
			BEGIN INITIAL;
		}
		
<STRING_STATE>[\\]	{
			//fprintf(logout, "Going to String state 2...........\n\n\n\n");
			inStr += "\\";
			BEGIN STRING_STATE_2;
		}
		
		
<STRING_STATE_2>{WHITESPACE}*{NEWLINE}	{
			line_count++;
			inStr += "\n";
			//fprintf(logout,"\n\nin string state 2!......\n\n");
			BEGIN STRING_STATE;

		}
		
<STRING_STATE>[\\]{METACHARS} {
			//printf("Got a meta char in string.............\n\n");
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
		
<STRING_STATE_2>{ANYTHING} {
			
			str+= yytext[0];
			inStr+= yytext[0];
			BEGIN STRING_STATE;
			
		}
		
{SINGLECOMMENT} 	{
			begin_comment_line = line_count;
			comment ="//";
			BEGIN SINGLE_LINE_COMMENT;

		}
		
<SINGLE_LINE_COMMENT>{NEWLINE} {
			// fprintf(logout, "\nLine no %d: Token <COMMENT> Lexeme %s found\n",begin_comment_line, comment.c_str());
			line_count++;
			BEGIN INITIAL;

		}
		
<SINGLE_LINE_COMMENT>[\\]{NEWLINE}	{
			line_count++;
			comment += "\\\n";

		}
		
<SINGLE_LINE_COMMENT>[^\\\n]* {
			comment += yytext;

		}
		
{MULTILINECOMMENT}		{
			begin_comment_line = line_count;
			comment = "/*";
			BEGIN MULTI_LINE_COMMENT;
		}
		
<MULTI_LINE_COMMENT>[\*][/]	{
			comment += "*/";
			// fprintf(logout, "\nLine no %d: Token <COMMENT> Lexeme %s found\n",begin_comment_line, comment.c_str());
			BEGIN INITIAL;
		}
		
<MULTI_LINE_COMMENT>{NEWLINE}   {
			line_count++;
			comment += "\n";
		}
		
<MULTI_LINE_COMMENT><<EOF>> {
			// fprintf(logout,"\nLine no %d: Unterminated comment %s\n",begin_comment_line, comment.c_str());
			errors++;
			BEGIN INITIAL;
		}
		
<MULTI_LINE_COMMENT>{ANYTHING}  {
			comment += yytext;

		}

				

{WHITESPACE}	{
		
		}
			
{ANYTHING}	{
		
			// fprintf(logout,"\nError at line no %d: Unrecognized character %s found\n",line_count,yytext);
			errors++;
		}
		
<<EOF>>		{
			// st.printAllScopeTable(logout);
			// fprintf(logout, "\nTotal lines: %d\n",line_count);
			// fprintf(logout, "Total errors: %d\n",errors);
			
			return 0;

		}

%%

// int main(int argc,char *argv[]){
	
// 	if(argc!=2){
// 		printf("Please provide input file name and try again\n");
// 		return 0;
// 	}
	
// 	FILE *fin=fopen(argv[1],"r");
// 	if(fin==NULL){
// 		printf("Cannot open specified file\n");
// 		return 0;
// 	}
	
// 	logout= fopen("1805115_log.txt","w");
// 	tokenout= fopen("1805115_token.txt","w");

// 	yyin= fin;
// 	yylex();
// 	fclose(yyin);
// 	fclose(tokenout);
// 	fclose(logout);
// 	return 0;
// }
