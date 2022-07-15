%{
#include "bits/stdc++.h"
#include "lib/utility.h"

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
	table->enterScope();
	//storing all the function argument variables in the new scope table
	for(int i=0; i<functionArguments.size();i++)
	{	
		SymbolInfo *symbolFound = table->lookUp(functionArguments[i].arg_name);
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
			cout << "insertion part complete in function declaration\n\n";
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
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN 
{
			currentFunctionName = $2->getName();
			functionReturnType = $1->getName();
			cout << "I was here in func_definition------------------------\n\n\n";
			SymbolInfo *symbolFound = table->lookUpInAllScope($2->getName());
			if(symbolFound != NULL)
			{
				string funcName = $2->getName();
				string funcReturnType = $1->getName();
				errorCheckingForFunctionDefinition(symbolFound, funcReturnType, funcName);
			}else 
			{

				bool flag = false;
				table->insertInCurrentST($2->getName(), "ID");
				SymbolInfo *symbolFound = table->lookUp($2->getName());
				//table->enterScope();
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
					symbolFound->ai->isFunctionDefined = true;
					symbolFound->ai->returnType = $1->getName();
					//cout << "insertion part complete in function declaration\n\n";
				}else
				{
					table->removeFromCurrentST($2->getName());
				}
			}

			

}	compound_statement	 {
		string type = "func_definition";
		string name = $1->getName()+" "+$2->getName()+""+$3->getName()+""+$4->getName()+""+$5->getName()+""+$7->getName();
		$$ = new SymbolInfo(name, type);
		string rule = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
		writeMatchedRuleInLogFile(logout, line_count, rule);
		writeMatchedSymbolInLogFile(logout, name);
		functionArguments.clear();

}

		| type_specifier ID LPAREN RPAREN 	{

			SymbolInfo *symbolFound = table->lookUpInAllScope($2->getName());
			if(symbolFound != NULL)
			{
				string funcName = $2->getName();
				string funcReturnType = $1->getName();
				errorCheckingForFunctionDefinition(symbolFound, funcReturnType, funcName);
			}else 
			{
				//table->enterScope();
				insertFunctionDefInTable($2->getName(), $1->getName(), symbolFound, true);
			}

			functionArguments.clear();
		} compound_statement	{
			string type = "func_definition";
			string name = $1->getName()+" "+$2->getName()+""+$3->getName()+""+$4->getName()+""+$6->getName();
			$$ = new SymbolInfo(name, type);
			string rule = "func_definition : type_specifier ID LPAREN RPAREN compound_statement";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);
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
	routineWorkForLCURL();

} statements RCURL	{
	string name = $1->getName()+"\n"+$3->getName()+"\n"+$4->getName()+"\n";
	$$ = new SymbolInfo(name, "compound_statement");
	writeMatchedRuleInLogFile(logout, line_count, "compound_statement : LCURL statements RCURL");
	writeMatchedSymbolInLogFile(logout, name);
	table->printAllScopeTable(logout);
	table->exitScope();
}
 	| LCURL	{
		 routineWorkForLCURL();

	} RCURL	{
		string name = $1->getName()+"\n\n"+$3->getName()+"\n";
		$$ = new SymbolInfo(name, "compound_statement");
		writeMatchedRuleInLogFile(logout, line_count, "compound_statement : LCURL RCURL");
		writeMatchedSymbolInLogFile(logout, name);
		// table->printAllScopeTable(logout);
		// table->exitScope();
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

				VariableInfo v($<symbol>1->getName(), stoi($<symbol>3->getName()));
				var_info.push_back(v);
		   }
 		  
statements : statement	{

	string type = "statements";
	string name = $1->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "statements : statement";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);
}
	| statements statement	{
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
	  | compound_statement	{
		  	string type = "statement";
			string name = $1->getName();
			$$ = new SymbolInfo(name, type);
			string rule = "statement : compound_statement";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);	
		  
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement	{

		  string type = "statement";
		  string name = $1->getName()+""+$2->getName()+""+$3->getName()+""+$4->getName()+""+$5->getName()+""+$6->getName()+""+$7->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);	
	  }
	  | IF LPAREN expression RPAREN statement %prec NO_ELSE	{
		  //Here we're telling Bison to use the precedence for NO_ELSE which was defined at the beginning
		  string type = "statement";
		  string name = $1->getName()+""+$2->getName()+""+$3->getName()+""+$4->getName()+""+$5->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : IF LPAREN expression RPAREN statement";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);	
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement	{
		  string type = "statement";
		  string name = $1->getName()+""+$2->getName()+""+$3->getName()+""+$4->getName()+""+$5->getName()+""+$6->getName()+""+$7->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : IF LPAREN expression RPAREN statement ELSE statement";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);
	  }
	  | WHILE LPAREN expression RPAREN statement	{
		  string type = "statement";
		  string name = $1->getName()+""+$2->getName()+""+$3->getName()+""+$4->getName()+""+$5->getName();
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
		  if(symbolFound!= NULL)
		  {
			  if(symbolFound->ai->isFunction == true)
			  {
				  errors++;
				  string msg = "Function cannot be inside printf";
				  writeError(logout, errorFile, line_count, msg);
			  }
		  }else
			{
				errors++;
				string msg = "Undeclared variable "+$3->getName();
				writeError(logout, errorFile, line_count, msg);
			}
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);

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
			  string msg = "Return type mismatch for current function";
			  writeError(logout, errorFile, line_count, msg);
		  }
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);
	  }
	  ;
	  
expression_statement : SEMICOLON	{

	cout << "I was here in expression_statement : SEMICOLON\n\n\n";
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

	SymbolInfo *symbolFound = table->lookUpInAllScope($1->getName());
	if(symbolFound == NULL)
	{
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
		//cout << "variable : ID rule, symbolFound is not null before--------------\n\n\n";
		$$->ai->returnType = symbolFound->ai->returnType;
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

		cout << "return type:----------------------------" << $3->ai->returnType << "\n\n\n\n\n\n\n\n\n\n";
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


		 
	 }
	 ;
	 
 expression : logic_expression	{

	 $$ = new SymbolInfo($1->getName(), "expression");
	 string rule = "expression : logic_expression";
	 writeMatchedRuleInLogFile(logout, line_count, rule);
	 writeMatchedSymbolInLogFile(logout, $1->getName());
	 $$->ai = new AdditionalInfo;
	 $$->ai->returnType = $1->ai->returnType;

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
	$$->ai->returnType = $1->ai->returnType;

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

	} 	
		 ;
			
rel_expression	: simple_expression	{

	$$ = new SymbolInfo($1->getName(), "rel_expression");
	string rule = "rel_expression : simple_expression";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, $1->getName());
	$$->ai = new AdditionalInfo;
	$$->ai->returnType = $1->ai->returnType;
}
		| simple_expression RELOP simple_expression	{
			string name = $1->getName()+""+$2->getName()+""+$3->getName();
			$$ = new SymbolInfo(name, "rel_expression");
			string rule = "rel_expression : simple_expression RELOP simple_expression";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);
			$$->ai = new AdditionalInfo;
			$$->ai->returnType = "int";
		}
		;
				
simple_expression : term	{
	$$ = new SymbolInfo($1->getName(), "simple_expression");
	writeMatchedRuleInLogFile(logout, line_count, "simple_expression : term");
	writeMatchedSymbolInLogFile(logout, $1->getName());

	$$->ai = new AdditionalInfo;
	$$->ai->returnType = $1->ai->returnType;
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

	} 
	;
					
term :	unary_expression	{
	$$ = new SymbolInfo($1->getName(), "term");
	writeMatchedRuleInLogFile(logout, line_count, "term : unary_expression");
	writeMatchedSymbolInLogFile(logout, $1->getName());
	$$->ai = new AdditionalInfo;
	$$->ai->returnType = $1->ai->returnType;
}
    |  term MULOP unary_expression	{
		string name = $1->getName()+""+$2->getName()+""+$3->getName();
		$$ = new SymbolInfo(name, "term");
		string rule = "term : term MULOP unary_expression";
		writeMatchedRuleInLogFile(logout, line_count, rule);
		
		string retType = "int";
		if($1->ai->returnType == "float" ||  $3->ai->returnType == "float")
		{
			cout << "1st operand : "+$1->getName()+"---------\n\n\n";
			cout << "2nd operand : "+$3->getName()+"---------\n\n\n";
			cout << "operand : "+$2->getName()+ "------------\n\n\n";
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
	}
    ;

unary_expression : ADDOP unary_expression	{
	string name = $1->getName()+""+$2->getName();
	$$ = new SymbolInfo(name, "unary_expression");
	writeMatchedRuleInLogFile(logout, line_count, "unary_expression : ADDOP unary_expression");
	writeMatchedSymbolInLogFile(logout, name);
	$$->ai= new AdditionalInfo;
	$$->ai->returnType = $2->ai->returnType;
}
	| NOT unary_expression	{
		string name = $1->getName()+""+$2->getName();
		$$ = new SymbolInfo(name, "unary_expression");
		writeMatchedRuleInLogFile(logout, line_count, "unary_expression : NOT unary_expression");
		writeMatchedSymbolInLogFile(logout, name);
		$$->ai= new AdditionalInfo;
		$$->ai->returnType = $2->ai->returnType;
	} 
	| factor	{
		//cout << "I was here in unary_expression : factor :3--------------------------------\n\n\n";
		$$ = new SymbolInfo($1->getName(), "unary_expression");
		writeMatchedRuleInLogFile(logout, line_count, "unary_expression : factor");
		writeMatchedSymbolInLogFile(logout, $1->getName());
		$$->ai= new AdditionalInfo;
		$$->ai->returnType = $1->ai->returnType;
		cout << $1->ai->returnType << " in unary_expression : factor\n\n\n\n\n\n\n";
	} 
	;
	
factor	: variable	{
	$$ = new SymbolInfo($1->getName(), "factor");
	writeMatchedRuleInLogFile(logout, line_count, "factor : variable");
	writeMatchedSymbolInLogFile(logout, $1->getName());
	$$->ai= new AdditionalInfo;
	$$->ai->returnType = $1->ai->returnType;
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
				}
			}
		}
		writeMatchedRuleInLogFile(logout, line_count, "factor : ID LPAREN argument_list RPAREN");
		writeMatchedSymbolInLogFile(logout, name);
		$$->ai = new AdditionalInfo;
		$$->ai->returnType = retType;
		argumentList.clear();

	}
	| LPAREN expression RPAREN	{
		cout << "Till this works fine.......................................";
		string name = $1->getName()+""+$2->getName()+""+$3->getName();
		$$ = new SymbolInfo(name, "factor");
		writeMatchedRuleInLogFile(logout, line_count, "factor : LPAREN expression RPAREN");
		writeMatchedSymbolInLogFile(logout, name);
		$$->ai= new AdditionalInfo;
		cout << "Till this works fine.......................................";
		if($2->ai)
		{
			$$->ai->returnType = $2->ai->returnType;
		}else
		{
			$$->ai->returnType = "int";
		}
		
	}
	| CONST_INT	{
		$$ = new SymbolInfo($1->getName(), "factor");
		writeMatchedRuleInLogFile(logout, line_count, "factor : CONST_INT");
		writeMatchedSymbolInLogFile(logout, $1->getName());
		$$->ai= new AdditionalInfo;
		$$->ai->returnType = "int";
	}
	| CONST_FLOAT	{
		$$ = new SymbolInfo($1->getName(), "factor");
		writeMatchedRuleInLogFile(logout, line_count, "factor : CONST_FLOAT");
		writeMatchedSymbolInLogFile(logout, $1->getName());
		$$->ai= new AdditionalInfo;
		$$->ai->returnType = "float";
	}
	| variable INCOP	{
		string name = $1->getName()+""+$2->getName();
		$$ = new SymbolInfo(name, "factor");
		writeMatchedRuleInLogFile(logout, line_count, "factor : variable INCOP");
		writeMatchedSymbolInLogFile(logout, name);
		$$->ai= new AdditionalInfo;
		$$->ai->returnType = $1->ai->returnType;
	}
	| variable DECOP	{
		string name = $1->getName()+""+$2->getName();
		$$ = new SymbolInfo(name, "factor");
		writeMatchedRuleInLogFile(logout, line_count, "factor : variable DECCOP");
		writeMatchedSymbolInLogFile(logout, name);
		$$->ai= new AdditionalInfo;
		$$->ai->returnType = $1->ai->returnType;
	}
	;
	
argument_list : arguments	{
	$$ = new SymbolInfo($1->getName(), "argument_list");
	writeMatchedRuleInLogFile(logout, line_count, "argument_list : arguments");
	writeMatchedSymbolInLogFile(logout, $1->getName());
}
	|	{
		$$ = new SymbolInfo("", "argument_list");
		writeMatchedRuleInLogFile(logout, line_count, "argument_list : ");
		writeMatchedSymbolInLogFile(logout, "");
	}
	;
	
arguments : arguments COMMA logic_expression	{

	argumentList.push_back($3->ai->returnType);
	string name = $1->getName()+""+$2->getName()+""+$3->getName();
	$$ = new SymbolInfo(name, "arguments");
	writeMatchedRuleInLogFile(logout, line_count, "arguments : arguments COMMA logic_expression");
	writeMatchedSymbolInLogFile(logout, name);
	
}
| logic_expression	{
	argumentList.push_back($1->ai->returnType);
	$$ = new SymbolInfo($1->getName(), "arguments");
	writeMatchedRuleInLogFile(logout, line_count, "arguments : logic_expression");
	writeMatchedSymbolInLogFile(logout, $1->getName());
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
	
	return 0;
}

