%{
#include "bits/stdc++.h"
#include "utility.h"
#include "AssemblyUtil.h"
#include "1805115.cpp"




int line_count = 1;
int errors = 0;
int warning_count = 0;
int no_of_buckets = 7;
SymbolTable *table = new SymbolTable(7);

FILE *input;
FILE *logout;
FILE *errorFile;

#define ERROR "error";


//Necessary class
class VariableInfo
{
	public:
	string varName;
	int varSize;

	VariableInfo(string name, int size)
	{
		varName = name;
		varSize = size;
	}

};

class FunctionInfo
{
	public:
	string typeSpecifier;
	string arg_name;

	FunctionInfo(string typeSpecifier)
	{
		this->typeSpecifier = typeSpecifier;
		arg_name = "";
	}
	FunctionInfo(string typeSpecifier, string arg_name)
	{
		this->typeSpecifier = typeSpecifier;
		this->arg_name = arg_name;
	}
};

vector<string> argumentList;
vector<VariableInfo> var_info;
vector<FunctionInfo> functionArguments;
string functionReturnType;
string currentFunctionName;
vector<string>argAsmList;



//this method is used to check the errors in function definition grammar 
void errorCheckingForFunctionDefinition(SymbolInfo *symbolFound, string funcReturnType, string funcName)
{
    //ai null means it was a variable and ai not null and isFunction false means it was a variable
    if(symbolFound->ai == NULL || (symbolFound->ai != NULL && symbolFound->ai->isFunction == false))
    {
        errors++;
        writeError(logout, errorFile, line_count, "Multiple declaration of "+symbolFound->getName());

    }else if(symbolFound->ai->isFunctionDefined == true)
    {
        errors++;
        writeError(logout, errorFile, line_count, "Multiple declaration of function "+symbolFound->getName());
    }else if(symbolFound->ai->returnType != funcReturnType)
    {
        errors++;
        string msg = "Return type mismatch with function declaration in function "+funcName;
        writeError(logout, errorFile, line_count, msg);
    }else if(symbolFound->ai->typeSpecifiers.size() != functionArguments.size())
    {
        errors++;
        string msg = "Total number of arguments mismatch with declaration in function "+funcName;
        writeError(logout, errorFile, line_count, msg);
    }else if(symbolFound->ai->typeSpecifiers.size() == functionArguments.size())
    {
        for(int i=0; i<functionArguments.size(); i++)
        {
            if(symbolFound->ai->typeSpecifiers[i] != functionArguments[i].typeSpecifier)
            {
				errors++;
                string msg = i+"th argument mismatch in function "+funcName;
                writeError(logout, errorFile, line_count, msg);
				break;
            }
        }
		symbolFound->ai->isFunctionDefined = true;
    }
}

//this method is used to insert the function definiton or declaration in symbol table 
void insertFunctionDefInTable(string funcName, string returnType, SymbolInfo *symbolFound, bool isDefined)
{
	table->insertInCurrentST(funcName, "ID");
	symbolFound = table->lookUp(funcName);
	// if(symbolFound)
	// {
	// 	cout << funcName << " Function is stored-------------------------\n\n\n\n\n\n";
	// }
	symbolFound->ai = new AdditionalInfo;
	symbolFound->ai->isFunction = true;
	symbolFound->ai->isFunctionDefined = isDefined;
	symbolFound->ai->returnType = returnType;
}



void routineWorkForLCURL()
{
	//Entering new scope 
	//table->enterScope();
	//storing all the function argument variables in the new scope table
	for(int i=0; i<functionArguments.size();i++)
	{	
		SymbolInfo *symbolFound = table->lookUpInAllScope(functionArguments[i].arg_name);
		if(symbolFound!= NULL)
		{
			// errors++;
			// string msg = "Multiple argument with same name "+functionArguments[i].arg_name;
			// writeError(logout, errorFile, line_count, msg);
		}else
		{
			table->insertInCurrentST(functionArguments[i].arg_name, "ID");
			SymbolInfo *symbol = table->lookUp(functionArguments[i].arg_name);
			symbol->ai = new AdditionalInfo;
			symbol->ai->returnType = functionArguments[i].typeSpecifier;
		}
	}
}

//added for offline 4
int labelCount = 1;
int tempCount = 0;
vector<pair<string, int>> varList;
string label1= "";
string label2= "";
string label3= "";
string label4= "";
string forLabel1, forLabel2, forLabel3, forLabel4;

string conditionLabel;
string conditionVar;


string newLabel()
{
	string label = "Label"+to_string(labelCount++);
	return label;
}

string newTemp()
{
	string temp = "temp"+to_string(tempCount++);
	varList.push_back({temp, 0});
	return temp;
}

FILE *asmFile;
FILE *optimizedAsmFile;

//adding done

extern FILE *yyin;
int yylex();


void yyerror(const char *s)
{
	cout << "error occurred at " << line_count << ": " << s;
}


%}

%union {
	SymbolInfo *symbol;
}

%token<symbol> BREAK CASE CONTINUE DEFAULT RETURN SWITCH VOID CHAR DOUBLE FLOAT INT DO WHILE FOR IF ELSE
%token<symbol> INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD
%token<symbol> COMMA SEMICOLON PRINTLN

%token <symbol> ID
%token <symbol> CONST_INT
%token <symbol> CONST_FLOAT
%token <symbol> CONST_CHAR STRING

%token <symbol> ADDOP MULOP RELOP LOGICOP

%type <symbol> start program unit var_declaration variable type_specifier declaration_list
%type <symbol> expression_statement func_declaration parameter_list func_definition
%type <symbol> compound_statement statements unary_expression factor statement arguments
%type <symbol> expression logic_expression simple_expression rel_expression term argument_list
%type<symbol> if_else_pera


%left LOGICOP
%left RELOP 
%left ADDOP
%left MULOP
%left BITOP
%right ASSIGNOP
%right INCOP DECOP NOT 


%nonassoc NO_ELSE
%nonassoc ELSE 

%error-verbose 




%%

start : program
	{
		$$ = new SymbolInfo($1->getName(), "start");
		writeMatchedRuleInLogFile(logout, line_count, "start : program");
		//writeMatchedSymbolInLogFile(logout,$1->getName());

		//added for offline 4
		writeAssembly(asmFile, ".DATA");
		for(int i=0; i<varList.size(); i++)
		{
			if(varList[i].second == 0)
			{
				writeAssembly(asmFile, varList[i].first+" DW ?");
			}else
			{
				writeAssembly(asmFile, varList[i].first+" DW "+to_string(varList[i].second)+" DUP(?)");
			}
		}
		string code = "NEWLINE DB 0DH, 0AH, \'$\'\n";
		code += "NUMBER_STRING DB \'00000$\'\n";
		code += "END MAIN\n";
		writeAssembly(asmFile, code);
	}
	;

program : program unit	{
	
	string type = "program";
	string name = $1->getName()+"\n"+$2->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "program : program unit";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout,name);
}
	| unit	{

		string type = "program";
		string name = $1->getName();
		$$ = new SymbolInfo(name, type);
		string rule = "program : unit";
		writeMatchedRuleInLogFile(logout, line_count, rule);
		writeMatchedSymbolInLogFile(logout, name);
	}
	;
	
unit : var_declaration	{

	string type = "unit";
	string name = $1->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "unit : var_declaration";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);
}
     | func_declaration	{

		string type = "unit";
		string name = $1->getName();
		$$ = new SymbolInfo(name, type);
		string rule = "unit : func_declaration";
		writeMatchedRuleInLogFile(logout, line_count, rule);
		writeMatchedSymbolInLogFile(logout, name);
	 }
     | func_definition	{

		string type = "unit";
		string name = $1->getName();
		$$ = new SymbolInfo(name, type);
		string rule = "unit : func_definition";
		writeMatchedRuleInLogFile(logout, line_count, rule);
		writeMatchedSymbolInLogFile(logout, name);
	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON	{

	string type = "func_declaration";
	string name = $1->getName()+" "+$2->getName()+""+$3->getName()+""+$4->getName()+""+$5->getName()+""+$6->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);

	//cout << rule << endl;

	SymbolInfo *symbolFound = table->lookUp($2->getName());
	if(symbolFound != NULL)
	{
		if(symbolFound->ai == NULL || (symbolFound->ai != NULL && symbolFound->ai->isFunction == false))
    	{
        	errors++;
        	writeError(logout, errorFile, line_count, "Multiple declaration of "+$2->getName());
    	}else if(symbolFound->ai->isFunction == true)
		{
			errors++;
			string msg = "Multiple declaration of function "+$2->getName();
			writeError(logout, errorFile, line_count, msg);
		}
	}else 
	{
		bool flag = false;
		table->insertInCurrentST($2->getName(), "ID");
		SymbolInfo *symbolFound = table->lookUp($2->getName());
		symbolFound->ai = new AdditionalInfo;
		for(int i=0; i<functionArguments.size(); i++)
		{
			if(functionArguments[i].typeSpecifier == "void")
			{
				errors++;
				fprintf(logout, "Error at line %d: for %dth argument, void cannot be parameter datatype\n\n",line_count, i+1);
				fprintf(errorFile, "Error at line %d: for %dth argument, void cannot be parameter datatype\n\n",line_count, i+1);
				flag = true;
				break;
			}
			symbolFound->ai->typeSpecifiers.push_back(functionArguments[i].typeSpecifier);
			symbolFound->ai->argumentNames.push_back(functionArguments[i].arg_name);

		}

		if(flag == false)
		{
			symbolFound->ai->isFunction = true;
			symbolFound->ai->isFunctionDefined = false;
			symbolFound->ai->returnType = $1->getName();
			// cout << "insertion part complete in function declaration\n\n";
		}else
		{
			//if there is an error, then the function declaration is not stored in symbol table. So previously stored one is being deleted
			table->removeFromCurrentST($2->getName());
		}

	}
	functionArguments.clear();
}
		| type_specifier ID LPAREN RPAREN SEMICOLON	{

			string type = "func_declaration";
			string name = $1->getName()+" "+$2->getName()+""+$3->getName()+""+$4->getName()+""+$5->getName();
			$$ = new SymbolInfo(name, type);
			string rule = "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);

			SymbolInfo *symbolFound = table->lookUp($2->getName());
			if(symbolFound != NULL)
			{
				if(symbolFound->ai == NULL || (symbolFound->ai != NULL && symbolFound->ai->isFunction == false))
    			{
        			errors++;
        			writeError(logout, errorFile, line_count, "Variable name function name conflict");
    			}else if(symbolFound->ai->isFunction == true)
				{
					errors++;
					string msg = "Multiple declaration of function "+$2->getName();
					writeError(logout, errorFile, line_count, msg);
				}
			}else 
			{
				insertFunctionDefInTable($2->getName(), $1->getName(), symbolFound, false);
				
			}
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN  {
			string paramCode = "";
			currentFunctionName = $2->getName();
			functionReturnType = $1->getName();
			SymbolInfo *symbolFound = table->lookUpInAllScope($2->getName());
			if(symbolFound != NULL)
			{
				symbolFound->ai = new AdditionalInfo;
				symbolFound->ai->returnType = functionReturnType;
				string funcName = $2->getName();
				string funcReturnType = $1->getName();
				errorCheckingForFunctionDefinition(symbolFound, funcReturnType, funcName);
				//added for offline 4
				table->enterScope();
				string scopeId = table->giveCurrentScopeId();
				for(int i=0; i<functionArguments.size(); i++)
				{
					string varName = functionArguments[i].arg_name+scopeId;
					varList.push_back({varName,0});
					table->insertInCurrentST(functionArguments[i].arg_name, "ID");
					SymbolInfo *si = table->lookUp(functionArguments[i].arg_name);
					si->ai = new AdditionalInfo;
					si->ai->returnType = functionArguments[i].typeSpecifier;
					si->asmVar = varName;
					paramCode += "\tPOP "+varName;
				}
			}else 
			{

				bool flag = false;
				table->insertInCurrentST($2->getName(), "ID");
				SymbolInfo *symbolFound = table->lookUp($2->getName());
				
				//added for offline 4
				table->enterScope();
				string scopeId = table->giveCurrentScopeId();
				symbolFound->ai = new AdditionalInfo;
				
				for(int i=0; i<functionArguments.size(); i++)
				{
					if(functionArguments[i].typeSpecifier == "void")
					{
						errors++;
						fprintf(logout, "Error at line %d: for %dth argument, void cannot be parameter datatype\n\n",line_count, i+1);
						fprintf(errorFile, "Error at line %d: for %dth argument, void cannot be parameter datatype\n\n",line_count, i+1);
						flag = true;
						break;
					}
					symbolFound->ai->typeSpecifiers.push_back(functionArguments[i].typeSpecifier);
					symbolFound->ai->argumentNames.push_back(functionArguments[i].arg_name);

					//added for offline 4
					string varName = functionArguments[i].arg_name+scopeId;
					varList.push_back({varName,0});
					table->insertInCurrentST(functionArguments[i].arg_name, "ID");
					SymbolInfo *si = new SymbolInfo();
					si = table->lookUp(functionArguments[i].arg_name);
					si->ai = new AdditionalInfo;
					si->ai->returnType = functionArguments[i].typeSpecifier;
					si->asmVar = varName;
					// cout << "No Problem here. got " + si->asmVar+" ---------------------------------------- \n\n";
					paramCode += "\tPOP "+varName+"\n";
					
				}
				SymbolInfo *s = table->lookUpInAllScope("a");
				// cout << s->asmVar << "----------------------------------------------\n\n\n\n\n\n\n\n";
				if(flag == false)
				{
					symbolFound->ai->isFunction = true;
					symbolFound->ai->isFunctionDefined = true;
					symbolFound->ai->returnType = $1->getName();
					//cout << "insertion part complete in function declaration\n\n";
				}else
				{
					table->removeFromCurrentST($2->getName());
				}
			}
			

			//added for offline 4
			string code = "";
			if(currentFunctionName == "main")
			{
				code += "MAIN PROC\n";
				code += "\tMOV AX, @DATA\n";
				code += "\tMOV DS, AX\n";
			}else
			{
				code += currentFunctionName+" PROC\n";
				code += "\tPOP BP\n";
				code += paramCode;
				code += "\tPUSH BP\n";
			}
			writeAssembly(asmFile, code);

			

}	compound_statement	 {
		string type = "func_definition";
		string name = $1->getName()+" "+$2->getName()+""+$3->getName()+""+$4->getName()+""+$5->getName()+""+$7->getName();
		$$ = new SymbolInfo(name, type);
		string rule = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
		writeMatchedRuleInLogFile(logout, line_count, rule);
		writeMatchedSymbolInLogFile(logout, name);
		functionArguments.clear();

		string code ="";
		if(currentFunctionName == "main")
		{
			code += "\tMOV AX, 4CH\n";
			code += "\tINT 21H\n";
			code += "MAIN ENDP\n";
			// code += "END MAIN\n";
		}else
		{
			code += "\tRET\n";
			code += currentFunctionName+" ENDP\n";
		}

		writeAssembly(asmFile, code);

}

		| type_specifier ID LPAREN RPAREN 	{
			currentFunctionName = $2->getName();
			functionReturnType = $1->getName();
			SymbolInfo *symbolFound = table->lookUpInAllScope($2->getName());
			if(symbolFound != NULL)
			{
				string funcName = $2->getName();
				string funcReturnType = $1->getName();
				errorCheckingForFunctionDefinition(symbolFound, funcReturnType, funcName);
			}else 
			{
				insertFunctionDefInTable($2->getName(), $1->getName(), symbolFound, true);
			}

			//added for offline 4
			table->enterScope();

			string code = "";
			if(currentFunctionName == "main")
			{
				code += "MAIN PROC\n";
				code += "\tMOV AX, @DATA\n";
				code += "\tMOV DS, AX\n";
			}else
			{
				code += currentFunctionName+" PROC\n";
				// code += "\tPOP BP\n";
			}
			writeAssembly(asmFile, code);
			functionArguments.clear();
		} compound_statement	{
			string type = "func_definition";
			string name = $1->getName()+" "+$2->getName()+""+$3->getName()+""+$4->getName()+""+$6->getName();
			$$ = new SymbolInfo(name, type);
			string rule = "func_definition : type_specifier ID LPAREN RPAREN compound_statement";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);

			string code ="";
			if(currentFunctionName == "main")
			{
				code += "\tMOV AX, 4CH\n";
				code += "\tINT 21H\n";
				code += "MAIN ENDP\n";
				// code += "END MAIN\n";
			}else
			{
				code += "\tRET\n";
				code += currentFunctionName+" ENDP\n";
			}

			writeAssembly(asmFile, code);
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID	{

	string type = "parameter_list";
	string name = $1->getName()+""+$2->getName()+""+$3->getName()+" "+$4->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "parameter_list : parameter_list COMMA type_specifier ID";
	

	for(int i=0; i<functionArguments.size(); i++)
	{
		if(functionArguments[i].arg_name == $4->getName())
		{
			errors++;
			string msg = "Multiple declaration of "+$4->getName()+" in parameter";
			writeError(logout, errorFile, line_count, msg);
		}
	}

	FunctionInfo fi($3->getName(), $4->getName());
	functionArguments.push_back(fi);

	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);
}
		| parameter_list COMMA type_specifier	{

			string type = "parameter_list";
			string name = $1->getName()+""+$2->getName()+""+$3->getName();
			$$ = new SymbolInfo(name, type);
			string rule = "parameter_list  : parameter_list COMMA type_specifier";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);

			FunctionInfo fi($3->getName());
			functionArguments.push_back(fi);
		}
 		| type_specifier ID	{

			 string type = "parameter_list";
			 string name = $1->getName()+" "+$2->getName();
			 $$ = new SymbolInfo(name, type);
			 string rule = "parameter_list : type_specifier ID";
			 writeMatchedRuleInLogFile(logout, line_count, rule);
			 writeMatchedSymbolInLogFile(logout, name);
			 FunctionInfo fi($1->getName(), $2->getName());
			 functionArguments.push_back(fi);
			 //added this line to debug function definition error : undeclared variable
			//table->insertInCurrentST($2->getName(), "ID");
		 }
		| type_specifier	{

			string type = "parameter_list";
			string name = $1->getName();
			$$ = new SymbolInfo(name, type);
			string rule = "parameter_list : type_specifier";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);
			FunctionInfo fi(name);
			functionArguments.push_back(fi);
		}
 		;

 		
compound_statement : LCURL	{
	//routineWorkForLCURL();

} statements RCURL	{
	string name = $1->getName()+"\n"+$3->getName()+"\n"+$4->getName()+"\n";
	$$ = new SymbolInfo(name, "compound_statement");
	writeMatchedRuleInLogFile(logout, line_count, "compound_statement : LCURL statements RCURL");
	writeMatchedSymbolInLogFile(logout, name);
	table->printAllScopeTable(logout);
	table->exitScope();
}
 	| LCURL	{
		 //routineWorkForLCURL();

	} RCURL	{
		string name = $1->getName()+"\n\n"+$3->getName()+"\n";
		$$ = new SymbolInfo(name, "compound_statement");
		writeMatchedRuleInLogFile(logout, line_count, "compound_statement : LCURL RCURL");
		writeMatchedSymbolInLogFile(logout, name);
		// table->printAllScopeTable(logout);
		table->exitScope();
	 }
 	;
 		    
var_declaration : type_specifier declaration_list SEMICOLON	{

	string type = "var_declaration";
	string name = $1->getName()+" "+$2->getName()+""+$3->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "var_declaration : type_specifier declaration_list SEMICOLON";
	

	string varType = $1->getName();

	if(varType=="void")
	{
		errors++;
		string msg = "Variable type cannot be void";
		writeError(logout, errorFile, line_count, msg);
	}

	//added for offline 4
	string scopeId = table->giveCurrentScopeId();
	for(int i=0; i<var_info.size(); i++)
	{
		string symbolName = var_info[i].varName;
		SymbolInfo *symbolFound = table->lookUp(symbolName);
		if(symbolFound != NULL)
		{
			errors++;
			string msg = "Multiple declaration of "+symbolName;
			writeError(logout, errorFile, line_count, msg);
			continue;
		}

		table->insertInCurrentST(symbolName, "ID");
		SymbolInfo *newSymbol =  table->lookUp(symbolName);
		newSymbol->ai = new AdditionalInfo;
		newSymbol->ai->returnType = varType;
		if(var_info[i].varSize!=0)
		{
			newSymbol->ai->isArray = true;
			newSymbol->ai->arraySize = var_info[i].varSize;
		}

		//added for offline 4
		string varName = symbolName+scopeId;
		int len = var_info[i].varSize;
		varList.push_back({varName, len});
		newSymbol->asmVar = varName;
	}

	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);

	var_info.clear();

}
 		 
type_specifier	: 
INT	{
	string type = "type_specifier";
	string name = $1->getName()+"";
	$$ = new SymbolInfo(name, type);
	string rule = "type_specifier : INT";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);
}
| FLOAT	{
	string type = "type_specifier";
	string name = $1->getName()+"";
	$$ = new SymbolInfo(name, type);
	string rule = "type_specifier : FLOAT";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);
}
| VOID	{
	string type = "type_specifier";
	string name = $1->getName()+"";
	$$ = new SymbolInfo(name, type);
	string rule = "type_specifier : VOID";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);
}
 		
declaration_list : declaration_list COMMA ID	{
			    string type = "declaration_list";
			    string name = $1->getName()+""+$2->getName()+""+$3->getName();
			    $$ = new SymbolInfo(name, type);
				string rule = "declaration_list : declaration_list COMMA ID";
				writeMatchedRuleInLogFile(logout, line_count, rule);
			    writeMatchedSymbolInLogFile(logout, name);

				VariableInfo v($<symbol>3->getName(), 0);
				var_info.push_back(v);

			}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD	{

			    string type = "declaration_list";
			    string name = $1->getName()+""+$2->getName()+""+$3->getName()+""+$4->getName()+""+$5->getName()+""+$6->getName();
			    $$ = new SymbolInfo(name, type);
			    string rule = "declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD";
				SymbolInfo *symbolFound = table->lookUp($3->getName());
				if(symbolFound==NULL)
				{
					VariableInfo v($3->getName(), stoi($5->getName()));
			    	var_info.push_back(v);
				}else
				{
					errors++;
					string msg = "Multiple declaration of "+$3->getName();
					writeError(logout, errorFile, line_count, msg);
				}
				writeMatchedRuleInLogFile(logout, line_count, rule);
			    writeMatchedSymbolInLogFile(logout, name);
			    

		   }
 		  | ID	{

			   string type = "declaration_list";
			   string name = $1->getName()+"";
			   $$ = new SymbolInfo(name, type);
			   string rule = "declaration_list : ID";
			   SymbolInfo *symbolFound = table->lookUp($1->getName());
				if(symbolFound==NULL)
				{
					VariableInfo v($1->getName(), 0);
			    	var_info.push_back(v);
				}else
				{
					errors++;
					string msg = "Multiple declaration of "+$1->getName();
					writeError(logout, errorFile, line_count, msg);
				}
			   writeMatchedRuleInLogFile(logout, line_count, rule);
			   writeMatchedSymbolInLogFile(logout, name);
		   }
 		  | ID LTHIRD CONST_INT RTHIRD	{
			   string type = "declaration_list";
			   string name = $1->getName()+""+$2->getName()+""+$3->getName()+""+$4->getName();
			   $$ = new SymbolInfo(name, type);
			   string rule = "declaration_list : ID LTHIRD CONST_INT RTHIRD";
			   writeMatchedRuleInLogFile(logout, line_count, rule);
			   writeMatchedSymbolInLogFile(logout, name);

			   SymbolInfo *symbolFound = table->lookUp($1->getName());
				if(symbolFound==NULL)
				{
					VariableInfo v($<symbol>1->getName(), stoi($<symbol>3->getName()));
					var_info.push_back(v);
				}else
				{
					errors++;
					string msg = "Multiple declaration of "+$1->getName();
					writeError(logout, errorFile, line_count, msg);
				}

				//added for offline 4
				
		   }
 		  
statements : statement	{
	// cout << "came here before crash\n\n";
	string type = "statements";
	string name = $1->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "statements : statement";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);
}
	| statements statement	{
		// cout << "Came here before crash\n\n";
		string type = "statements";
		string name = $1->getName()+"\n"+$2->getName();
		$$ = new SymbolInfo(name, type);
		writeMatchedRuleInLogFile(logout, line_count, "statements : statements statement");
		writeMatchedSymbolInLogFile(logout, name);

	   }
	   ;
	   
statement : var_declaration	{

	string type = "statement";
	string name = $1->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "statement : var_declaration";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);

}
	  | expression_statement	{

			string type = "statement";
			string name = $1->getName();
			$$ = new SymbolInfo(name, type);
			string rule = "statement : expression_statement";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);
	  }
	  | {table->enterScope();} compound_statement	{
		  	string type = "statement";
			string name = $2->getName();
			$$ = new SymbolInfo(name, type);
			string rule = "statement : compound_statement";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);	
		  
	  }
	  | FOR LPAREN {
		  string code = "; Code segment for For loop rule\n";
		  writeAssembly(asmFile, code);
	  } expression_statement {
		  string exp_label = newLabel();
		  string code = exp_label + ":\n";
		  writeAssembly(asmFile, code);
		  $4->labels.clear();
		  $4->labels.push_back(exp_label);
	  }
	  expression_statement {
		  string conditionVar = $6->asmVar;
		  string label2 = newLabel();
		  string label3 = newLabel();
		  string label4 = newLabel();

		  string code = "";
		  code += "\tMOV AX, "+conditionVar+ "\n";
		  code += "\tCMP AX, 1\n";
		  code += "\tJE "+label3+"\n";
		  code += "\tJNE "+label4+"\n";
		  code += label2 +":\n";
		  writeAssembly(asmFile, code);
		  $6->labels.clear();
		  $6->labels.push_back(label2);
		  $6->labels.push_back(label3);
		  $6->labels.push_back(label4);
	  }
	   expression	{
		   string exp_label = $4->labels[0];
		   string code = "\tJMP "+exp_label+"\n";
		   string label3 = $6->labels[1];
		   code += label3+":\n";
		   writeAssembly(asmFile, code);

	   }
	    RPAREN statement	{
		  string label2 = $6->labels[0];
		  string label4 = $6->labels[2];
		  string code = "\tJMP "+label2+"\n";
		  code += label4+":\n";
		  writeAssembly(asmFile, code);
		  string type = "statement";
		  string name = $1->getName()+""+$2->getName()+""+$4->getName()+""+$6->getName()+""+$8->getName()+""+$10->getName()+""+$11->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);	
	  }
	  | IF LPAREN expression if_else_pera RPAREN statement %prec NO_ELSE	{
		  //Here we're telling Bison to use the precedence for NO_ELSE which was defined at the beginning
		  string type = "statement";
		  string name = $1->getName()+""+$2->getName()+""+$3->getName()+""+$5->getName()+""+$6->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : IF LPAREN expression RPAREN statement and boom";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);

		  string code = "";
		//   cout << "Before boom-------------------\n\n";
		  string falseLabel = $4->labels[0];
		//   cout << "After boom.................\n\n";
		  code += falseLabel + ":\n";
		  writeAssembly(asmFile, code);
		//   cout << "Okay till now in if lparen....no else\n\n";

	  }
	  | IF LPAREN expression if_else_pera RPAREN statement ELSE {
		  string code = "";
		  string falseLabel = $4->labels[0];
		  string nextLabel = newLabel();
		  code += "\tJMP "+nextLabel+"\n";
		  code += falseLabel+":\n";
		  writeAssembly(asmFile, code);
		//   cout << "Okay till now!\n\n\n\n\n";
		  //$6->labels.clear();
		  $6->labels.push_back(nextLabel);
	  }
	  statement	{
		  string type = "statement";
		  string name = $1->getName()+""+$2->getName()+""+$3->getName()+""+$5->getName()+""+$6->getName()+""+$7->getName()+""+$9->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : IF LPAREN expression RPAREN statement ELSE statement";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);

		  //added for offline 4
		  string nextLabel = $6->labels[0];
		  string code = nextLabel+":\n";
		  writeAssembly(asmFile, code);
		  
	  }
	  | WHILE LPAREN {
		  string code = "; Code segment for WHILE rule\n";
		  string label1 = newLabel();
		  code += label1+":\n";
		  writeAssembly(asmFile, code);
		  $1->labels.push_back(label1);
	  }
	  expression	{
		  string conditionVar = $4->asmVar;
		  string label2 = newLabel();
		  string code = "\tMOV AX, "+conditionVar+"\n";
		  code += "\tCMP AX, 0\n";
		  code += "\tJE "+label2+"\n";
		  writeAssembly(asmFile, code);
		  $4->labels.clear();
		  $4->labels.push_back(label2);

	  }
	   RPAREN statement	{
		   string label1 = $1->labels[0];
		   string label2 = $4->labels[0];
		   string code = "\tJMP "+label1+"\n";
		   code += label2+":\n";
		   writeAssembly(asmFile, code);
		  string type = "statement";
		  string name = $1->getName()+""+$2->getName()+""+$4->getName()+""+$6->getName()+""+$7->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : WHILE LPAREN expression RPAREN statement";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);	
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON	{
		  string type = "statement";
		  string name = $1->getName()+""+$2->getName()+""+$3->getName()+""+$4->getName()+""+$5->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : PRINTLN LPAREN ID RPAREN SEMICOLON";
		  SymbolInfo *symbolFound = table->lookUpInAllScope($3->getName());
		  string code = "";
		  bool flag = true;
		  if(symbolFound!= NULL)
		  {
			  if(symbolFound->ai->isFunction == true)
			  {
				  errors++;
				  string msg = "Function cannot be inside println";
				  writeError(logout, errorFile, line_count, msg);
				  flag = false;
			  }
		  }else
			{
				errors++;
				string msg = "Undeclared variable "+$3->getName();
				writeError(logout, errorFile, line_count, msg);
				flag = false;
			}

		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);

		  //added for offline 4

		  if(flag)
		  {
			  string varName = symbolFound->asmVar;
			  code += "\tXOR AX, AX\n";
			  code += "\tMOV AX, "+varName+"\n";
			  code += "\tCALL DISPLAY\n";
			  writeAssembly(asmFile, code);
		  }

	  }
	  | RETURN expression SEMICOLON	{
		  string type = "statement";
		  string name = $1->getName()+" "+$2->getName()+""+$3->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : RETURN expression SEMICOLON";
		  //cout << "I was here in return expression SEMICOLON rule-----------------\n\n\n";
		  if(functionReturnType == "void")
		  {
			  errors++;
			  string msg = "Function type void cannot have a return statement";
			  writeError(logout, errorFile, line_count, msg);
		  }else if($2->ai->returnType != functionReturnType)
		  {
			  errors++;
			  string msg = "Return type mismatch for current function with return type "+$2->ai->returnType +" and "+functionReturnType;
			  writeError(logout, errorFile, line_count, msg);
		  }
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);

		  string code = "\tPOP BP\n";
		  code += "\tPUSH "+ $2->asmVar + "\n";
		  code += "\tPUSH BP\n";
		  writeAssembly(asmFile, code);
	  }
	  ;

if_else_pera : {
		  string code = "";
		  //string trueLabel = newLabel();
		  string falseLabel = newLabel();
		  string var = conditionVar;
		  code += "\tMOV AX, "+var+"\n";
		  code += "\tCMP AX, 0\n";
		  code += "\tJE "+falseLabel+"\n";
		  writeAssembly(asmFile, code);
		  cout << "Okay till now in if else pera!\n\n\n";
		  $$ = new SymbolInfo();
		  $$->labels.push_back(falseLabel);
	  } 
	  
expression_statement : SEMICOLON	{

	string type = "expression_statement";
	string name = $1->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "expression_statement : SEMICOLON";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);
}		
	| expression SEMICOLON 	{
		string type = "expression_statement";
		string name = $1->getName()+""+$2->getName();
		$$ = new SymbolInfo(name, type);
		$$->asmVar = $1->asmVar;

		string rule = "expression_statement : expression SEMICOLON";
		writeMatchedRuleInLogFile(logout, line_count, rule);
		writeMatchedSymbolInLogFile(logout, name);
	}
	;
	  
variable : ID	{
	string type = "variable";
	string name = $1->getName()+"";
	$$ = new SymbolInfo(name, type);
	string rule = "variable : ID";
	//cout << "Entered this rule:- " << rule << "---------------\n\n" << endl;
	$$->ai = new AdditionalInfo;

	cout << "before lookUp in variable : ID rule=======================\n\n";
	SymbolInfo *symbolFound = table->lookUpInAllScope($1->getName());
	if(symbolFound == NULL)
	{
		// cout << "Got null in variable : ID--------------------------\n\n\n";
		errors++;
		string msg = "Undeclared variable "+$1->getName();
		writeError(logout, errorFile, line_count, msg);
		$$->ai->returnType = ERROR;	//to keep the code running
	}else
	{
		
		if(symbolFound->ai != NULL)
		{
		if(symbolFound->ai->isFunction == true)
		{
			errors++;
			string msg = "Variable name conflicts with function name";
			writeError(logout, errorFile, line_count, msg);

		}else if(symbolFound->ai->isArray == true)
		{
			errors++;
			string msg = "Type mismatch, "+$1->getName()+" is an array";
			writeError(logout, errorFile, line_count, msg);
		}
		}
		// cout << "variable : ID rule, symbolFound is not null before--------- "+symbolFound->getName() +"-----\n\n\n";
		$$->ai->returnType = symbolFound->ai->returnType;
		//added this for offline 4
		$$->asmVar = symbolFound->asmVar;
		// cout << "Got "+$$->asmVar +" in Variable : ID rule-----------------\n";
		//cout << "variable : ID rule, symbolFound is not null after " << symbolFound->ai->returnType << "--------------\n\n\n";
	}
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);

}		
	 | ID LTHIRD expression RTHIRD	{

		 string type = "variable";
		 string name = $1->getName()+""+$2->getName()+""+$3->getName()+""+$4->getName();
		 $$ = new SymbolInfo(name, type);
		 string rule = "variable : ID LTHIRD expression RTHIRD";
		 $$->ai = new AdditionalInfo;

		 SymbolInfo *symbolFound = table->lookUpInAllScope($1->getName());

		// cout << "return type:----------------------------" << $3->ai->returnType << "\n\n\n\n\n\n\n\n\n\n";
		 if($3->ai->returnType != "int")
		 {
			 errors++;
			 string msg = "Expression inside third brackets not an integer";
			 writeError(logout, errorFile, line_count, msg);
		 }

		 if(symbolFound != NULL)
		 {
			 if(symbolFound->ai->isFunction == true)
			 {
				 errors++;
				 string msg = "Variable name conflicts with function name";
				 writeError(logout, errorFile, line_count, msg);
			 }else if(symbolFound->ai->isArray == false)
			 {
				 errors++;
				 string msg =$1->getName()+" not an array";
				 writeError(logout, errorFile, line_count, msg);
			 }
			 $$->ai->returnType = symbolFound->ai->returnType;
		 }else 
		 {
			 errors++;
			 string msg = "Undeclared variable "+$1->getName();
			 writeError(logout, errorFile, line_count, msg);
			 $$->ai->returnType = ERROR; //to keep code running 
		 }
		 writeMatchedRuleInLogFile(logout, line_count, rule);
		 writeMatchedSymbolInLogFile(logout, name);

		//added for offline 4;
		string varName = $3->asmVar;
		string code = "\tMOV BX, "+varName+"\n";
		code += "\tADD BX, BX\n";
		string ind = newTemp();		
		$$->ai->array_index = ind;
		$$->ai->isArray = true;
		$$->asmVar = symbolFound->asmVar;

		writeAssembly(asmFile, code);

		 
	 }
	 ;
	 
 expression : logic_expression	{

	 $$ = new SymbolInfo($1->getName(), "expression");
	 string rule = "expression : logic_expression";
	 writeMatchedRuleInLogFile(logout, line_count, rule);
	 writeMatchedSymbolInLogFile(logout, $1->getName());
	 $$->ai = new AdditionalInfo;
	 $$->ai->returnType = $1->ai->returnType;
	 //added for offline 4
	 $$->asmVar = $1->asmVar;
	 conditionVar = $1->asmVar;	//added for if else condition

 }
	   | variable ASSIGNOP logic_expression 	{

		   	cout << "pera pera......................\n\n\n";
		    string type = "expression";
		    string name = $1->getName() + "" + $2->getName()+""+$3->getName();
		    $$ = new SymbolInfo(name, type);
		    string rule = "expression : variable ASSIGNOP logic_expression";

			cout << "Got this rule: ------- " << rule << "\n\n\n";
			$$->ai = new AdditionalInfo;
		    SymbolInfo *left = $1;	//left refers to variable 
		    SymbolInfo *right = $3;	//right refers to logic_expression
		    if(left->ai->returnType == right->ai->returnType)
		    {
			    $$->ai->returnType = left->ai->returnType; 
		   	}else
			{
				if(left->ai->returnType == "float" && right->ai->returnType == "int")
				{
					warning_count++;
					string msg = "Auto type conversion from float to int for logic_expression "+$3->getName();
					writeWarning(logout, errorFile, line_count, msg);
					$$->ai->returnType = "float";
				}else if(left->ai->returnType == "int" && right->ai->returnType == "float")
				{
					errors++;
					string msg = "Type Mismatch";
					writeError(logout, errorFile, line_count, msg);
					$$->ai->returnType = left->ai->returnType;
				}else
				{
					if(right->ai->returnType == "void")
					{
						errors++;
						string msg = "Void function used in expression";
						writeError(logout, errorFile, line_count, msg);
					}
					$$->ai->returnType = left->ai->returnType;
				}	   
			}

			//added for offline 4
			cout << "Generating assembly code for variable ASSIGNOP logical_expression====================================\n\n\n\n\n\n\n\n\n";
			string code = "\tMOV AX, "+$3->asmVar+"\n";
			if($1->ai == NULL)
			{
				cout << "no array rule-----------------------------------------------\n\n\n";
				code += "\tMOV "+$1->asmVar+" , AX\n";
			}else
			{
				if($1->ai->isArray == true)
				{
					cout << "Came in array rule-------------------------------------------------------\n\n\n\n\n";
					code += "\tMOV BX, "+$1->ai->array_index+"\n";
					code += "\tADD BX, BX\n";
					code += "\tMOV "+$1->asmVar+"[BX] , AX\n";
				}else
				{
					cout << "Is array variable is false!!!!!!!!!\n\n\n\n\n\n";
					code += "\tMOV "+$1->asmVar+" , AX\n";
				}
			}
			
			code += "\tMOV "+$1->asmVar+", AX\n";
			$$->asmVar = $1->asmVar;
			writeAssembly(asmFile, code);
			cout << "After Generating assembly code for variable ASSIGNOP logical_expression====================================\n\n\n\n\n\n\n\n\n";
			writeMatchedRuleInLogFile(logout, line_count, rule);
	 	    writeMatchedSymbolInLogFile(logout, name);
	   }
	   ;
			
logic_expression : rel_expression	{

	$$ = new SymbolInfo($1->getName(), "logic_expression");
	string rule = "logic_expression : rel_expression";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, $1->getName());

	$$->ai = new AdditionalInfo;
	$$->ai= $1->ai;
	//added for offline 4
	$$->asmVar = $1->asmVar;

}	
	| rel_expression LOGICOP rel_expression	{

		string name = $1->getName()+""+$2->getName()+""+$3->getName();
		$$ = new SymbolInfo(name, "logic_expression");
		string rule = "logic_expression : rel_expression LOGICOP rel_expression";
		
		$$->ai = new AdditionalInfo;
		if($1->ai->returnType != "int" || $3->ai->returnType != "int")
		{
			errors++;
			string msg = "Both operands of "+$2->getName()+" should be of int type";
			writeError(logout, errorFile, line_count, msg);
			$$->ai->returnType = ERROR;
		}else
		{
			$$->ai->returnType = "int";
		}

		writeMatchedRuleInLogFile(logout, line_count, rule);
		writeMatchedSymbolInLogFile(logout, name);

		//added for offline 4
		label1 = newLabel();
		label2 = newLabel();
		label3 = newLabel();
		string temp = newTemp();

		string code = "";
		code += "XOR AX, AX \n";
		if($2->getName() == "||")
		{
			code += "\tMOV AX, "+$1->asmVar+"\n";
			code += "\tCMP AX, 1\n";
			code += "\tJE "+label1+"\n";
			code += "\tMOV AX, "+$3->asmVar+"\n";
			code += "\tCMP AX, 1\n";
			code += "\tJE "+label1+"\n";
			code += "\tMOV "+temp+" , 0\n";
			code += "\JMP "+label2+"\n";
			code += label1+":\n";
			code += "\tMOV "+temp+" , 1\n";
			code += label2 +":\n";
		}else if($2->getName()=="&&")
		{
			code += "\tMOV AX, "+$1->asmVar+"\n";
			code += "\tCMP AX, 0\n";
			code += "\tJE "+label1+"\n";
			code += "\tMOV AX, "+$3->asmVar+"\n";
			code += "\tCMP AX, 0\n";
			code += "\tJE "+label1+"\n";
			code += "\tMOV "+temp +" , 1\n";
			code += "\tJMP "+label2+"\n";
			code += label1+":\n";
			code += "\MOV "+temp +" , 0\n";
			code += label2+":\n"; 
		}

		writeAssembly(asmFile, code);
		$$->asmVar = temp;
		


	} 	
		 ;
			
rel_expression	: simple_expression	{

	$$ = new SymbolInfo($1->getName(), "rel_expression");
	string rule = "rel_expression : simple_expression";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, $1->getName());
	$$->ai = new AdditionalInfo;
	$$->ai = $1->ai;
	//added for offline 4
	$$->asmVar = $1->asmVar;
}
		| simple_expression RELOP simple_expression	{
			string name = $1->getName()+""+$2->getName()+""+$3->getName();
			$$ = new SymbolInfo(name, "rel_expression");
			string rule = "rel_expression : simple_expression RELOP simple_expression";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);
			$$->ai = new AdditionalInfo;
			$$->ai->returnType = "int";
			//added for offline 4
			string lab1 = newLabel();
			string lab2 = newLabel();
			string op = $2->getName();

			string code = "";
			code += "\tMOV AX, "+$1->asmVar+"\n";
			code += "\tCMP AX, "+$3->asmVar+"\n";

			if(op == "==")
			{
				code += "\tJE "+lab1+"\n";
			}else if(op == "!=")
			{
				code += "\tJNE "+lab1+"\n";
			}else if(op == ">=")
			{
				code += "\tJGE "+lab1+"\n";
			}else if(op == ">")
			{
				code += "\tJG "+lab1+"\n";
			}else if(op== "<=")
			{
				code += "\tJLE "+lab1+"\n";
			}else if(op== "<")
			{
				code += "\tJL "+lab1+"\n";
			}
			string temp = newTemp();
			code += "\tMOV "+temp+" , 0\n";
			code += "\tJMP "+lab2+"\n";
			code += lab1+":\n";
			code += "\tMOV "+temp+" , 1\n";
			code += lab2+":\n";
			$$->asmVar = temp;
			writeAssembly(asmFile, code);
		}
		;
				
simple_expression : term	{
	$$ = new SymbolInfo($1->getName(), "simple_expression");
	writeMatchedRuleInLogFile(logout, line_count, "simple_expression : term");
	writeMatchedSymbolInLogFile(logout, $1->getName());

	$$->ai = new AdditionalInfo;
	$$->ai= $1->ai;
	//added for offline 4
	$$->asmVar = $1->asmVar;
} 
	| simple_expression ADDOP term	{

		string name = $1->getName()+""+$2->getName()+""+$3->getName();
		$$ = new SymbolInfo(name, "simple_expression");
		string rule = "simple_expression : simple_expression ADDOP term";
		writeMatchedRuleInLogFile(logout, line_count, rule);
		writeMatchedSymbolInLogFile(logout, name);

		string retType = "int";
		if($1->ai->returnType == "float" || $3->ai->returnType == "float")
		{
			warning_count++;
			string msg = "Auto type conversion from int to float";
			writeWarning(logout, errorFile, line_count, msg);
			retType = "float";
		}
		if($3->ai->returnType == "void")
		{
			errors++;
			string msg = "Void function used in expression";
			writeError(logout, errorFile, line_count, msg);
			retType = ERROR;
		}
		$$->ai = new AdditionalInfo;
		$$->ai->returnType = retType;

		//added for offline 4
		string temp = newTemp();
		string code = "";
		code += "\tMOV AX, "+$1->asmVar+"\n";
		
		if($2->getName()== "+")
		{
			code += "\tADD AX, "+$3->asmVar+"\n";
			code += "\tMOV "+temp+" , AX\n";
		}else if($2->getName()=="-")
		{
			code += "\tSUB AX, "+$3->asmVar+"\n";
			code += "\tMOV "+temp+" , AX\n";
		}

		$$->asmVar = temp;
		writeAssembly(asmFile, code);
	} 
	;
					
term :	unary_expression	{
	$$ = new SymbolInfo($1->getName(), "term");
	writeMatchedRuleInLogFile(logout, line_count, "term : unary_expression");
	writeMatchedSymbolInLogFile(logout, $1->getName());
	$$->ai = new AdditionalInfo;
	$$->ai= $1->ai;
	//added for offline 4
	$$->asmVar = $1->asmVar;

}
    |  term MULOP unary_expression	{
		string name = $1->getName()+""+$2->getName()+""+$3->getName();
		$$ = new SymbolInfo(name, "term");
		string rule = "term : term MULOP unary_expression";
		writeMatchedRuleInLogFile(logout, line_count, rule);
		
		string retType = "int";
		if($1->ai->returnType == "float" ||  $3->ai->returnType == "float")
		{
			// cout << "1st operand : "+$1->getName()+"---------\n\n\n";
			// cout << "2nd operand : "+$3->getName()+"---------\n\n\n";
			// cout << "operand : "+$2->getName()+ "------------\n\n\n";
			if($2->getName()=="\%")
			{
				errors++;
				string msg = "Non-Integer operand on modulus operator";
				writeError(logout, errorFile, line_count, msg);
				retType = ERROR;
			}else
			{
				warning_count++;
				string msg = "Auto type conversion from float to int";
				writeWarning(logout, errorFile, line_count, msg);
				retType = "float";
			}
		}else if($1->ai->returnType == "int" && $3->ai->returnType=="int")
		{
			//All okay
		}else if($3->ai->returnType == "void")
		{
			errors++;
			string msg = "Void function used in expression";
			writeError(logout, errorFile, line_count, msg);
			retType = ERROR;
		}
		else
		{
			retType = ERROR;
		}
		writeMatchedSymbolInLogFile(logout, name);
		$$->ai = new AdditionalInfo;
		$$->ai->returnType = retType;

		//added for offline 4
		string temp = newTemp();
		string code = "";
		string op = $2->getName();

		//The First operand will be in AX, and the 2nd one will be in BX. Then MUL BX or DIV BX
		code += "\tMOV AX, "+$1->asmVar+"\n";
		code += "\tMOV BX, "+$3->asmVar+"\n";

		if(op== "*")
		{
			code += "\tMUL BX\n";
			code += "\tMOV "+temp +" , AX\n";
		}else if(op == "/")
		{
			code += "\tDIV BX\n";
			code += "\tMOV "+temp +" , AX\n";
		}else if(op == "%")
		{
			code += "\tXOR DX, DX\n";
			code += "\tDIV BX\n";
			code += "\tMOV "+temp+" , DX\n";
		}

		$$->asmVar = temp;
		writeAssembly(asmFile, code);
	}
    ;

unary_expression : ADDOP unary_expression	{
	string name = $1->getName()+""+$2->getName();
	$$ = new SymbolInfo(name, "unary_expression");
	writeMatchedRuleInLogFile(logout, line_count, "unary_expression : ADDOP unary_expression");
	writeMatchedSymbolInLogFile(logout, name);
	$$->ai= new AdditionalInfo;
	$$->ai->returnType = $2->ai->returnType;

	//added for offline 4
	string code = "";
	if($1->getName() == "-")
	{
		code += "\tMOV AX, "+$2->asmVar+"\n";
		code += "\tNEG AX\n";
		code += "\tMOV "+$2->asmVar+" , AX\n";
	}

	$$->asmVar = $2->asmVar;
	writeAssembly(asmFile, code);


}
	| NOT unary_expression	{
		string name = $1->getName()+""+$2->getName();
		$$ = new SymbolInfo(name, "unary_expression");
		writeMatchedRuleInLogFile(logout, line_count, "unary_expression : NOT unary_expression");
		writeMatchedSymbolInLogFile(logout, name);
		$$->ai= new AdditionalInfo;
		$$->ai->returnType = $2->ai->returnType;

		//added for offline 4
		string code = "";
		code += "\tMOV AX, "+$2->asmVar+"\n";
		code += "\tNOT AX\n";
		code += "\tMOV "+$2->asmVar+" , AX\n";
		$$->asmVar = $2->asmVar;
		writeAssembly(asmFile, code);
	} 
	| factor	{
		//cout << "I was here in unary_expression : factor :3--------------------------------\n\n\n";
		$$ = new SymbolInfo($1->getName(), "unary_expression");
		writeMatchedRuleInLogFile(logout, line_count, "unary_expression : factor");
		writeMatchedSymbolInLogFile(logout, $1->getName());
		$$->ai= new AdditionalInfo;
		$$->ai = $1->ai;
		//cout << $1->ai->returnType << " in unary_expression : factor\n\n\n\n\n\n\n";

		//added for offline 4
		$$->asmVar = $1->asmVar;
	} 
	;
	
factor	: variable	{
	$$ = new SymbolInfo($1->getName(), "factor");
	writeMatchedRuleInLogFile(logout, line_count, "factor : variable");
	writeMatchedSymbolInLogFile(logout, $1->getName());
	$$->ai= new AdditionalInfo;
	$$->ai->returnType = $1->ai->returnType;
	//added for offline 4
	$$->asmVar = $1->asmVar;	//Have to recheck this later
} 
	| ID LPAREN argument_list RPAREN	{
		//this grammar is for a= fun(4,5);
		//check if the function exists or not in the symbol table
		//check return type of function: cannot be void
		//check parameter list size and serial
		//check if it is a function or a variable 

		string name = $1->getName()+""+$2->getName()+""+$3->getName()+""+$4->getName();
		$$ = new SymbolInfo(name, "factor");
		

		string retType = "undeclared";
		SymbolInfo *symbolFound = table->lookUpInAllScope($1->getName());

		if(symbolFound == NULL)
		{
			errors++;
			string msg = "Undeclared function "+$1->getName();
			writeError(logout, errorFile, line_count, msg);
		}else
		{
			if(symbolFound->ai->isFunction==false)
			{
				errors++;
				string msg = "Non function identifier "+$1->getName();
				writeError(logout, errorFile, line_count, msg);
			}else
			{
				retType = symbolFound->ai->returnType;
				// if(symbolFound->ai->returnType == "void")
				// {
				// 	errors++;
				// 	string msg = "Void function used in expression";
				// 	writeError(logout, errorFile, line_count, msg);
				// }
				if(symbolFound->ai->typeSpecifiers.size()!=argumentList.size())
				{
					errors++;
					string msg = "Total number of arguments mismatch in function "+$1->getName();
					writeError(logout, errorFile, line_count, msg);
				}else
				{
					for(int i=0; i<argumentList.size(); i++)
					{
						if(argumentList[i] != symbolFound->ai->typeSpecifiers[i])
						{
							if((argumentList[i] == "float" && symbolFound->ai->typeSpecifiers[i] == "int") || (argumentList[i] == "int" && symbolFound->ai->typeSpecifiers[i] == "float"))
							{
								errors++;
								string msg = to_string(i+1)+"th argument mismatch in function " + $1->getName();
								writeError(logout, errorFile, line_count, msg);
							}else
							{
								errors++;
								string num = ""+(i+1);
								string msg = to_string(i+1)+"th argument mismatch in function " + $1->getName();
								writeError(logout, errorFile, line_count, msg);
							}
						}
					}

					//added for offline 4
					string code = "";
					//saving the general purpose registers;
					code += "\tPUSH DX\n";
					code += "\tPUSH CX\n";
					code += "\tPUSH BX\n";
					code += "\tPUSH AX\n";
					
					//here can add an error checking: argument list and parameterlists matches or not
					int size = $3->asmArgs.size();
					for(int i=size-1; i>=0; i--)
					{
						code += "\tPUSH "+$3->asmArgs[i] + "\n";
					}
					$3->asmArgs.clear();
					string function_name = $1->getName();
					code += "\tCALL "+function_name+" \n";
					string temp = newTemp();
					if(retType != "void")
					{
						
						code += "\tPOP "+temp+"\n";
					}
					
					code += "\tPOP AX\n";
					code += "\tPOP BX\n";
					code += "\tPOP CX\n";
					code += "\tPOP DX\n";
					writeAssembly(asmFile, code);
					$$->asmVar = temp;
				}
			}
		}
		writeMatchedRuleInLogFile(logout, line_count, "factor : ID LPAREN argument_list RPAREN");
		writeMatchedSymbolInLogFile(logout, name);
		$$->ai = new AdditionalInfo;
		$$->ai->returnType = retType;

		//need to add codes for offline 4 after completing function definition
		argumentList.clear();

	}
	| LPAREN expression RPAREN	{
		// cout << "Till this works fine.......................................";
		string name = $1->getName()+""+$2->getName()+""+$3->getName();
		$$ = new SymbolInfo(name, "factor");
		writeMatchedRuleInLogFile(logout, line_count, "factor : LPAREN expression RPAREN");
		writeMatchedSymbolInLogFile(logout, name);
		$$->ai= new AdditionalInfo;
		// cout << "Till this works fine.......................................";
		if($2->ai)
		{
			$$->ai->returnType = $2->ai->returnType;
		}else
		{
			$$->ai->returnType = "int";
		}

		//added for offline 4
		$$->asmVar = $2->asmVar;
		
	}
	| CONST_INT	{
		$$ = new SymbolInfo($1->getName(), "factor");
		writeMatchedRuleInLogFile(logout, line_count, "factor : CONST_INT");
		writeMatchedSymbolInLogFile(logout, $1->getName());
		$$->ai= new AdditionalInfo;
		$$->ai->returnType = "int";

		//added for offline 4
		$$->asmVar = $1->getName();
	}
	| CONST_FLOAT	{
		$$ = new SymbolInfo($1->getName(), "factor");
		writeMatchedRuleInLogFile(logout, line_count, "factor : CONST_FLOAT");
		writeMatchedSymbolInLogFile(logout, $1->getName());
		$$->ai= new AdditionalInfo;
		$$->ai->returnType = "float";

		//added for offline 4
		$$->asmVar = $1->getName();
	}
	| variable INCOP	{
		string name = $1->getName()+""+$2->getName();
		$$ = new SymbolInfo(name, "factor");
		writeMatchedRuleInLogFile(logout, line_count, "factor : variable INCOP");
		writeMatchedSymbolInLogFile(logout, name);
		$$->ai= new AdditionalInfo;
		$$->ai->returnType = $1->ai->returnType;

		//added code for offline 4
		string temp = newTemp();
		
		string code = "\tMOV AX, "+$1->asmVar+"\n";
		code += "\tMOV "+temp+" , AX\n";
		code += "\tINC "+$1->asmVar+"\n";

		$$->asmVar = temp;
		writeAssembly(asmFile, code);

	}
	| variable DECOP	{
		string name = $1->getName()+""+$2->getName();
		$$ = new SymbolInfo(name, "factor");
		writeMatchedRuleInLogFile(logout, line_count, "factor : variable DECCOP");
		writeMatchedSymbolInLogFile(logout, name);
		$$->ai= new AdditionalInfo;
		$$->ai->returnType = $1->ai->returnType;


		//added code for offline 4
		string temp = newTemp();
		string code = "\tMOV AX, "+$1->asmVar+"\n";
		code += "\tMOV "+temp+" , AX\n";
		code += "\tDEC "+$1->asmVar+"\n";

		$$->asmVar = temp;
		writeAssembly(asmFile, code);
	}
	;
	
argument_list : arguments	{
	$$ = new SymbolInfo($1->getName(), "argument_list");
	writeMatchedRuleInLogFile(logout, line_count, "argument_list : arguments");
	writeMatchedSymbolInLogFile(logout, $1->getName());
	$$->asmArgs = $1->asmArgs;
	//no change
}
	|	{
		$$ = new SymbolInfo("", "argument_list");
		writeMatchedRuleInLogFile(logout, line_count, "argument_list : ");
		writeMatchedSymbolInLogFile(logout, "");
		//no change
	}
	;
	
arguments : arguments COMMA logic_expression	{

	argumentList.push_back($3->ai->returnType);
	string name = $1->getName()+""+$2->getName()+""+$3->getName();
	$$ = new SymbolInfo(name, "arguments");
	writeMatchedRuleInLogFile(logout, line_count, "arguments : arguments COMMA logic_expression");
	writeMatchedSymbolInLogFile(logout, name);

	//added for offline 4
	$1->asmArgs.push_back($3->asmVar);
	$$->asmArgs = $1->asmArgs;
	
}
| logic_expression	{
	argumentList.push_back($1->ai->returnType);
	$$ = new SymbolInfo($1->getName(), "arguments");
	writeMatchedRuleInLogFile(logout, line_count, "arguments : logic_expression");
	writeMatchedSymbolInLogFile(logout, $1->getName());

	//added for offline 4
	$$->asmArgs.push_back($1->asmVar);

}
;
 

%%
int main(int argc,char *argv[])
{

	input = fopen(argv[1],"r");
	if(!input)
	{
		cout << "Cannot open input file" << endl;
		return 0;
	}

	errorFile = fopen("1805115_error.txt", "w");
	logout = fopen("1805115_log.txt", "w");

	//added for offline 4
	asmFile = fopen("code.asm", "w");
	initializeAssembly(asmFile);
	printFunction(asmFile);

	if(!logout)
	{
		cout << "Cannot open logout file!\n\n";
	}

	//cout << "opened files" << endl;

	yyin = input;
	yyparse();

	table->printAllScopeTable(logout);
	fprintf(logout, "\nTotal lines %d\n\n",line_count);
	fprintf(logout, "Total warnings %d\n\n",warning_count);
	fprintf(logout, "Total errors %d\n\n",errors);

	fclose(input);
	fclose(logout);
	fclose(errorFile);
	fclose(asmFile);
	
	return 0;
}

