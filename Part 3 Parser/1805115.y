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

//vector<string> argumentList;
vector<VariableInfo> var_info;
vector<FunctionInfo> functionArguments;


//this method is used to check the errors in function definition grammar 
void errorCheckingForFunctionDefinition(SymbolInfo *symbolFound, string funcReturnType, string funcName)
{
    //ai null means it was a variable and ai not null and isFunction false means it was an array
    if(symbolFound->ai == NULL || (symbolFound->ai != NULL && symbolFound->ai->isFunction == false))
    {
        errors++;
        writeError(logout, errorFile, line_count, "Variable name function name conflict");

    }
    else if(symbolFound->ai->isFunctionDefined == true)
    {
        errors++;
        writeError(logout, errorFile, line_count, "Multiple definition exists for same function name");
    }
    else if(symbolFound->ai->returnType != funcReturnType)
    {
        errors++;
        string msg = "Return type does not match with previously declared signature for function "+funcName;
        writeError(logout, errorFile, line_count, msg);
    }
    else if(symbolFound->ai->typeSpecifiers.size() != functionArguments.size())
    {
        errors++;
        string msg = "Total number of arguments mismatch in function "+funcName;
        writeError(logout, errorFile, line_count, msg);
    }
    else if(symbolFound->ai->typeSpecifiers.size() == functionArguments.size())
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
    }
}

//this method is used to insert the function definiton or declaration in symbol table 
void insertFunctionDefInTable(string funcName, string returnType, SymbolInfo *symbolFound, bool isDefined)
{
	table->insertInCurrentST(funcName, "function");
	symbolFound = table->lookUp(funcName);
	symbolFound->ai = new AdditionalInfo;
	symbolFound->ai->isFunction = true;
	symbolFound->ai->isFunctionDefined = isDefined;
	symbolFound->ai->returnType = returnType;
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
		//write your code in this block in all the similar blocks below
	}
	;

program : program unit	{
	
	string type = "program";
	string name = $1->getName()+$2->getName();
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
	string name = $1->getName()+" "+$2->getName()+" "+$3->getName()+" "+$4->getName()+" "+$5->getName()+""+$6->getName();
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
        	writeError(logout, errorFile, line_count, "Variable name function name conflict");
    	}else if(symbolFound->ai->isFunction == true)
		{
			errors++;
			string msg = "Multiple declaration of function "+$2->getName();
			writeError(logout, errorFile, line_count, msg);
		}
	}else 
	{
		bool flag = false;
		table->insertInCurrentST($2->getName(), "function");
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
			table->removeFromCurrentST($2->getName());
		}

	}
	functionArguments.clear();
}
		| type_specifier ID LPAREN RPAREN SEMICOLON	{

			string type = "func_declaration";
			string name = $1->getName()+" "+$2->getName()+" "+$3->getName()+" "+$4->getName()+""+$5->getName();
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
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement	{
			string type = "func_definition";
			string name = $1->getName()+" "+$2->getName()+" "+$3->getName()+" "+$4->getName()+" "+$5->getName()+" "+$6->getName();
			$$ = new SymbolInfo(name, type);
			string rule = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);

			SymbolInfo *symbolFound = table->lookUp($2->getName());
			if(symbolFound != NULL)
			{
				string funcName = $2->getName();
				string funcReturnType = $1->getName();
				errorCheckingForFunctionDefinition(symbolFound, funcReturnType, funcName);
			}else 
			{

				bool flag = false;
				table->insertInCurrentST($2->getName(), "function");
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
					symbolFound->ai->isFunctionDefined = true;
					symbolFound->ai->returnType = $1->getName();
					//cout << "insertion part complete in function declaration\n\n";
				}else
				{
					table->removeFromCurrentST($2->getName());
				}

				

			}
			functionArguments.clear();

}
		| type_specifier ID LPAREN RPAREN compound_statement	{

			string type = "func_definition";
			string name = $1->getName()+" "+$2->getName()+" "+$3->getName()+" "+$4->getName()+" "+$5->getName();
			$$ = new SymbolInfo(name, type);
			string rule = "func_definition : type_specifier ID LPAREN RPAREN compound_statement";
			writeMatchedRuleInLogFile(logout, line_count, rule);
			writeMatchedSymbolInLogFile(logout, name);

			SymbolInfo *symbolFound = table->lookUp($2->getName());
			if(symbolFound != NULL)
			{
				string funcName = $2->getName();
				string funcReturnType = $1->getName();
				errorCheckingForFunctionDefinition(symbolFound, funcReturnType, funcName);
			}else 
			{
				
				insertFunctionDefInTable($2->getName(), $1->getName(), symbolFound, true);
			}

			functionArguments.clear();
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID	{

	string type = "parameter_list";
	string name = $1->getName()+" "+$2->getName()+""+$3->getName()+" "+$4->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "parameter_list  : parameter_list COMMA type_specifier ID";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);

	FunctionInfo fi($3->getName(), $4->getName());
	functionArguments.push_back(fi);
}
		| parameter_list COMMA type_specifier	{

			string type = "parameter_list";
			string name = $1->getName()+" "+$2->getName()+""+$3->getName();
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

 		
compound_statement : LCURL statements RCURL
 		    | LCURL RCURL
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON	{

	string type = "var_declaration";
	string name = $1->getName()+" "+$2->getName()+" "+$3->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "var_declaration : type_specifier declaration_list SEMICOLON";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);


	string varType = $1->getName();

	if(varType=="void")
	{
		errors++;
		fprintf(logout, "ERROR at line no %d : cannot declare variable of void type\n\n",line_count, name.c_str());
		fprintf(errorFile, "ERROR at line no %d : cannot declare variable of void type\n\n",line_count, name.c_str());
	}

	

	for(int i=0; i<var_info.size(); i++)
	{
		string symbolName = var_info[i].varName;
		SymbolInfo *symbolFound = table->lookUp(symbolName);
		if(symbolFound != NULL)
		{
			errors++;
			fprintf(logout, "ERROR at line %d : %s name already exists\n\n",line_count, symbolName.c_str());
			fprintf(errorFile, "ERROR at line %d : %s name already exists\n\n",line_count, symbolName.c_str());
			continue;
		}

		table->insertInCurrentST(symbolName, varType);
		SymbolInfo *newSymbol =  table->lookUp(symbolName);
		newSymbol->ai = new AdditionalInfo;
		newSymbol->ai->returnType = varType;
		if(var_info[i].varSize!=0)
		{
			newSymbol->ai->isArray = true;
			newSymbol->ai->arraySize = var_info[i].varSize;
		}
	}

	var_info.clear();

}
 		 
type_specifier	: 
INT	{
	string type = "type_specifier";
	string name = $1->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "type_specifier : INT";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);
}
| FLOAT	{
	string type = "type_specifier";
	string name = $1->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "type_specifier : FLOAT";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);
}
| VOID	{
	string type = "type_specifier";
	string name = $1->getName();
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
			    string name = $1->getName()+""+$2->getName()+""+$3->getName()+" "+$4->getName()+" "+$5->getName()+" "+$6->getName();
			    $$ = new SymbolInfo(name, type);
			    string rule = "declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD";
			    writeMatchedRuleInLogFile(logout, line_count, rule);
			    writeMatchedSymbolInLogFile(logout, name);

			    VariableInfo v($<symbol>3->getName(), stoi($<symbol>5->getName()));
			    var_info.push_back(v);

		   }
 		  | ID	{

			   string type = "declaration_list";
			   string name = $1->getName();
			   $$ = new SymbolInfo(name, type);
			   string rule = "declaration_list : ID";
			   writeMatchedRuleInLogFile(logout, line_count, rule);
			   writeMatchedSymbolInLogFile(logout, name);

			   VariableInfo v(name, 0);
			   var_info.push_back(v);
		   }
 		  | ID LTHIRD CONST_INT RTHIRD	{
			   string type = "declaration_list";
			   string name = $1->getName()+" "+$2->getName()+" "+$3->getName()+" "+$4->getName();
			   $$ = new SymbolInfo(name, type);
			   string rule = "declaration_list : ID LTHIRD CONST_INT RTHIRD";
			   writeMatchedRuleInLogFile(logout, line_count, rule);
			   writeMatchedSymbolInLogFile(logout, name);

				VariableInfo v($<symbol>1->getName(), stoi($<symbol>3->getName()));
				var_info.push_back(v);
		   }
 		  
statements : statement
	   | statements statement
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
		  string name = $1->getName()+" "+$2->getName()+" "+$3->getName()+" "+$4->getName()+" "+$5->getName()+" "+$6->getName()+" "+$7->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);	
	  }
	  | IF LPAREN expression RPAREN statement %prec NO_ELSE	{
		  string type = "statement";
		  string name = $1->getName()+" "+$2->getName()+" "+$3->getName()+" "+$4->getName()+" "+$5->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : IF LPAREN expression RPAREN statement";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);	
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement	{
		  string type = "statement";
		  string name = $1->getName()+" "+$2->getName()+" "+$3->getName()+" "+$4->getName()+" "+$5->getName()+" "+$6->getName()+" "+$7->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : IF LPAREN expression RPAREN statement ELSE statement";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);
	  }
	  | WHILE LPAREN expression RPAREN statement	{
		  string type = "statement";
		  string name = $1->getName()+" "+$2->getName()+" "+$3->getName()+" "+$4->getName()+" "+$5->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : WHILE LPAREN expression RPAREN statement";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);	
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON	{
		  string type = "statement";
		  string name = $1->getName()+" "+$2->getName()+" "+$3->getName()+" "+$4->getName()+" "+$5->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : PRINTLN LPAREN ID RPAREN SEMICOLON";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);
	  }
	  | RETURN expression SEMICOLON	{
		  string type = "statement";
		  string name = $1->getName()+" "+$2->getName()+" "+$3->getName();
		  $$ = new SymbolInfo(name, type);
		  string rule = "statement : RETURN expression SEMICOLON";
		  writeMatchedRuleInLogFile(logout, line_count, rule);
		  writeMatchedSymbolInLogFile(logout, name);
	  }
	  ;
	  
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
		string name = $1->getName()+" "+$2->getName();
		$$ = new SymbolInfo(name, type);
		string rule = "expression_statement : expression SEMICOLON";
		writeMatchedRuleInLogFile(logout, line_count, rule);
		writeMatchedSymbolInLogFile(logout, name);
	}
	;
	  
variable : ID	{

	//Will complete this later!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	string type = "variable";
	string name = $1->getName();
	$$ = new SymbolInfo(name, type);
	string rule = "variable : ID";
	writeMatchedRuleInLogFile(logout, line_count, rule);
	writeMatchedSymbolInLogFile(logout, name);

	SymbolInfo *symbolFound = table->lookUp($1->getName());
	if(symbolFound == NULL)
	{
		errors++;
		string msg = "Undeclared variable "+$1->getName();
		writeError(logout, errorFile, line_count, msg);
	}
}		
	 | ID LTHIRD expression RTHIRD 
	 ;
	 
 expression : logic_expression	
	   | variable ASSIGNOP logic_expression 	
	   ;
			
logic_expression : rel_expression 	
		 | rel_expression LOGICOP rel_expression 	
		 ;
			
rel_expression	: simple_expression 
		| simple_expression RELOP simple_expression	
		;
				
simple_expression : term 
		  | simple_expression ADDOP term 
		  ;
					
term :	unary_expression
     |  term MULOP unary_expression
     ;

unary_expression : ADDOP unary_expression  
		 | NOT unary_expression 
		 | factor 
		 ;
	
factor	: variable 
	| ID LPAREN argument_list RPAREN
	| LPAREN expression RPAREN
	| CONST_INT 
	| CONST_FLOAT
	| variable INCOP 
	| variable DECOP
	;
	
argument_list : arguments
			  |
			  ;
	
arguments : arguments COMMA logic_expression
	      | logic_expression
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

	//table->printAllScopeTable(logout);
	fprintf(logout, "Total lines %d\n\n",line_count);
	fprintf(logout, "Total warnings %d\n\n",warning_count);
	fprintf(logout, "Total errors %d\n\n",errors);

	fclose(input);
	fclose(logout);
	fclose(errorFile);
	
	return 0;
}

