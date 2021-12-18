%{
#include <stdio.h>
#include "listaSimbolos.h"
#include "assert.h"
#include <string.h>
#include <stdlib.h>
Lista tablaSimb;
int contCadenas=1;
char registros[10]={0};
int contador_etiq=1;
int error=0;	//Variable para identificar si ha habido un error en el codigo
void yyerror();
char *obtenerReg();
void liberarReg(char *reg);
char *nuevaEtiqueta();
void main(); extern int yylex(); extern int yylineno;
%}

%code requires{
#include "listaCodigo.h"
}

%union{
char *lexema;
ListaC codigo;
}

%type <codigo> expression statement print_item print_list read_list compound_statement optional_statements statements declarations constants
%token <lexema> STRING ID INTLITERAL
%token  BEGINN END READ WRITE LPAREN RPAREN SEMICOLON COMMA ASSIGNOP PLUSOP MINUSOP DOSPUNTOS MULTIPLICA DIVIDE PUNTO PROGRAM CONST VAR IF THEN ELSE WHILE DO FOR TO INTEGER FUNCTION

//Preferencia de operadores
%left PLUSOP MINUSOP
%left MULTIPLICA DIVIDE
%left UMINUSOP


%expect 1
%%

program : {tablaSimb=creaLS();} PROGRAM ID LPAREN RPAREN SEMICOLON functions declarations compound_statement PUNTO {if(error==0){;mostrarlista(tablaSimb);imprimirCodigo($8);imprimirCodigo($9);};liberaLS(tablaSimb);liberaLC($8);liberaLC($9);}	//Imprimimos al final la lista de simbolos y de código si no hay errores
	;

functions 	: functions function SEMICOLON
		| 
		;

function 	: FUNCTION ID LPAREN CONST identifiers DOSPUNTOS type RPAREN DOSPUNTOS type
declarations compound_statement
		;

declarations 	: declarations VAR identifiers DOSPUNTOS type SEMICOLON	 {$$=$1;}
		| declarations CONST constants SEMICOLON   {$$=$1;concatenaLC($$,$3);liberaLC($3);}
		| 	{$$=creaLC();}
		;

identifiers 	: ID {if (buscaLS(tablaSimb, $1)==NULL) insertaLS(tablaSimb, finalLS(tablaSimb), CrearSimbolo($1 , VARIABLE, 0)); else{;error++;printf("Error: Variable %s ya declarada \n",$1);};}
		| identifiers COMMA ID {if (buscaLS(tablaSimb, $3)==NULL) insertaLS(tablaSimb, finalLS(tablaSimb), CrearSimbolo($3 , VARIABLE, 0)); else{;error++;printf("Error: Variable %s ya declarada \n",$3);};}
		;

type 	: INTEGER
	;

constants 	: ID ASSIGNOP expression {if (buscaLS(tablaSimb, $1)==NULL){;insertaLS(tablaSimb, finalLS(tablaSimb), CrearSimbolo($1 , CONSTANTE, 0));$$=$3;Operacion oper; oper.op="sw"; oper.res=recuperaResLC($$); oper.arg1=concatena("_",$1); oper.arg2=NULL;insertaLC($$,finalLC($$),oper);liberarReg(oper.res);}else{;$$=creaLC();error++;printf("Error: Constante %s ya declarada \n",$1);};}
		| constants COMMA ID ASSIGNOP expression {if (buscaLS(tablaSimb, $3)==NULL){;insertaLS(tablaSimb, finalLS(tablaSimb), CrearSimbolo($3 , CONSTANTE, 0));$$=$1;concatenaLC($$,$5);Operacion oper; oper.op="sw"; oper.res=recuperaResLC($5); oper.arg1=concatena("_",$3); oper.arg2=NULL;insertaLC($$,finalLC($$),oper);liberarReg(recuperaResLC($5));liberaLC($5);}else{;$$=creaLC();error++;printf("Error: Constante %s ya declarada \n",$3);};}
		;

compound_statement 	: BEGINN optional_statements END  {$$=$2;}
			;

optional_statements 	: statements	{$$=$1;}
			| 	{$$=creaLC();}
			;

statements 	: statement	{$$=$1;}
		| statements SEMICOLON statement	{$$=$1;concatenaLC($$,$3);liberaLC($3);} 
		;

statement 	: ID ASSIGNOP expression {if (buscaLS(tablaSimb, $1)==NULL){;$$=creaLC();error++;printf("Error: Variable %s no declarada \n",$1);}else if(esConstante(tablaSimb, $1)){;$$=creaLC();error++;printf("Error: Asignacion a constante \n");}else{;$$=$3;Operacion oper; oper.op="sw"; oper.res=recuperaResLC($3); oper.arg1=concatena("_",$1); oper.arg2=NULL;insertaLC($$,finalLC($$),oper);liberarReg(oper.res);};}
		| IF expression THEN statement	{$$=$2;char *etiq=nuevaEtiqueta();Operacion oper;oper.op="beqz";oper.res=recuperaResLC($$);oper.arg1=etiq;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);concatenaLC($$,$4);liberarReg(oper.res);liberaLC($4);oper.op="etiq";oper.res=etiq;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);}
		| IF expression THEN statement ELSE statement {$$=$2;char *etiq=nuevaEtiqueta();char *etiq2=nuevaEtiqueta();Operacion oper;oper.op="beqz";oper.res=recuperaResLC($$);oper.arg1=etiq;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);concatenaLC($$,$4);liberarReg(oper.res);liberaLC($4);oper.op="b";oper.res=etiq2;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);oper.op="etiq";oper.res=etiq;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);concatenaLC($$,$6);liberaLC($6);oper.op="etiq";oper.res=etiq2;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);}
		| WHILE expression DO statement	{$$=$2;char *etiq=nuevaEtiqueta();char *etiq2=nuevaEtiqueta();Operacion oper;oper.op="etiq";oper.res=etiq;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,inicioLC($$),oper);oper.op="beqz";oper.res=recuperaResLC($$);oper.arg1=etiq2;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);concatenaLC($$,$4);liberarReg(oper.res);liberaLC($4);oper.op="b";oper.res=etiq;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);oper.op="etiq";oper.res=etiq2;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);}
		| FOR ID ASSIGNOP expression TO expression DO statement {if (buscaLS(tablaSimb, $2)==NULL){;$$=creaLC();error++;printf("Error: Variable %s no declarada \n",$2);}else if(esConstante(tablaSimb, $2)){;$$=creaLC();error++;printf("Error: Asignacion a constante \n");}else{;$$=$4;concatenaLC($$,$6);char *etiq=nuevaEtiqueta();char *etiq2=nuevaEtiqueta();Operacion oper;oper.op="sw";oper.res=recuperaResLC($$);oper.arg1=concatena("_",$2);oper.arg2=NULL;insertaLC($$,finalLC($$),oper);oper.op="etiq";oper.res=etiq;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);oper.op="beq";oper.res=recuperaResLC($$);oper.arg1=recuperaResLC($6);oper.arg2=etiq2;insertaLC($$,finalLC($$),oper);liberaLC($6);liberarReg(oper.arg1);concatenaLC($$,$8);liberaLC($8);oper.op="addi";oper.res=recuperaResLC($$);oper.arg1=recuperaResLC($$);oper.arg2="1";insertaLC($$,finalLC($$),oper);oper.op="sw";oper.res=recuperaResLC($$);oper.arg1=concatena("_",$2);oper.arg2=NULL;insertaLC($$,finalLC($$),oper);oper.op="b";oper.res=etiq;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);oper.op="etiq";oper.res=etiq2;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,finalLC($$),oper);};}
		| WRITE LPAREN print_list RPAREN  {$$=$3;}
		| READ LPAREN read_list RPAREN	{$$=$3;}
		| compound_statement	{$$=$1;}
		;

print_list 	: print_item {$$=$1;}
		| print_list COMMA print_item	{$$=$1;concatenaLC($$,$3);liberaLC($3);}
		;

print_item 	: expression	{$$=$1;Operacion oper; oper.op="li"; oper.res="$v0"; oper.arg1="1"; oper.arg2=NULL;insertaLC($$,finalLC($$),oper); oper.op="move"; oper.res="$a0"; oper.arg1=recuperaResLC($$); oper.arg2=NULL;insertaLC($$,finalLC($$),oper);oper.op="syscall"; oper.res=NULL; oper.arg1=NULL; oper.arg2=NULL;insertaLC($$,finalLC($$),oper);liberarReg(recuperaResLC($$));}
		| STRING	{insertaLS(tablaSimb, inicioLS(tablaSimb), CrearSimbolo($1 , CADENA, contCadenas));contCadenas++;$$=creaLC();Operacion oper; oper.op="la"; oper.res="$a0"; oper.arg1=concatenacadena(contCadenas-1); oper.arg2=NULL;insertaLC($$,finalLC($$),oper);oper.op="li"; oper.res="$v0"; oper.arg1="4"; oper.arg2=NULL;insertaLC($$,finalLC($$),oper);oper.op="syscall"; oper.res=NULL; oper.arg1=NULL; oper.arg2=NULL;insertaLC($$,finalLC($$),oper);}
		;

read_list	: ID {$$=creaLC();if (buscaLS(tablaSimb, $1)==NULL){;error++;printf("Error: Variable %s no declarada \n",$1);}else if(esConstante(tablaSimb, $1)){error++;printf("Error: Asignacion a constante \n");}else{;Operacion oper;oper.op="li";oper.res="$v0";oper.arg1="5";oper.arg2=NULL;insertaLC($$,finalLC($$),oper);oper.op="syscall";oper.res=NULL;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,finalLC($$),oper); oper.op="sw"; oper.res="$v0"; oper.arg1=concatena("_",$1); oper.arg2=NULL;insertaLC($$,finalLC($$),oper);};}	
		| read_list COMMA ID {if (buscaLS(tablaSimb, $3)==NULL){;$$=creaLC();error++;printf("Error: Variable %s no declarada \n",$3);}else if(esConstante(tablaSimb, $3)){;$$=creaLC();error++;printf("Error: Asignacion a constante \n");}else{;$$=$1;Operacion oper;oper.op="li";oper.res="$v0";oper.arg1="5";oper.arg2=NULL;insertaLC($$,finalLC($$),oper);oper.op="syscall";oper.res=NULL;oper.arg1=NULL;oper.arg2=NULL;insertaLC($$,finalLC($$),oper); oper.op="sw"; oper.res="$v0"; oper.arg1=concatena("_",$3); oper.arg2=NULL;insertaLC($$,finalLC($$),oper);};}
		;

expression 	: expression PLUSOP expression	{$$=$1;concatenaLC($$,$3);Operacion oper;oper.op="add";oper.res=recuperaResLC($1);oper.arg1=recuperaResLC($1);oper.arg2=recuperaResLC($3);insertaLC($$,finalLC($$),oper);liberaLC($3);liberarReg(oper.arg2);}
		| expression MINUSOP expression	{$$=$1;concatenaLC($$,$3);Operacion oper;oper.op="sub";oper.res=recuperaResLC($1);oper.arg1=recuperaResLC($1);oper.arg2=recuperaResLC($3);insertaLC($$,finalLC($$),oper);liberaLC($3);liberarReg(oper.arg2);}
		| expression MULTIPLICA expression {$$=$1;concatenaLC($$,$3);Operacion oper;oper.op="mul";oper.res=recuperaResLC($1);oper.arg1=recuperaResLC($1);oper.arg2=recuperaResLC($3);insertaLC($$,finalLC($$),oper);liberaLC($3);liberarReg(oper.arg2);}
		| expression DIVIDE expression	{$$=$1;concatenaLC($$,$3);Operacion oper;oper.op="div";oper.res=recuperaResLC($1);oper.arg1=recuperaResLC($1);oper.arg2=recuperaResLC($3);insertaLC($$,finalLC($$),oper);liberaLC($3);liberarReg(oper.arg2);}
		| MINUSOP expression	%prec UMINUSOP {$$=$2;Operacion oper;oper.op="neg";oper.res=recuperaResLC($2);oper.arg1=recuperaResLC($2);oper.arg2=NULL;insertaLC($$,finalLC($$),oper);}
		| LPAREN expression RPAREN	{$$=$2;}
		| ID	{$$=creaLC();if (buscaLS(tablaSimb, $1)==NULL){;guardaResLC($$,obtenerReg());error++;printf("Error: Variable %s no declarada \n",$1);}else{;Operacion oper; oper.op="lw"; oper.res=obtenerReg(); oper.arg1=concatena("_",$1); oper.arg2=NULL;insertaLC($$,finalLC($$),oper);guardaResLC($$,oper.res);};}
		| INTLITERAL	{$$=creaLC();Operacion oper; oper.op="li"; oper.res=obtenerReg(); oper.arg1=$1; oper.arg2=NULL;insertaLC($$,finalLC($$),oper);guardaResLC($$,oper.res);}
		//| ID LPAREN arguments RPAREN	
		;

/*arguments 	: expressions
		| 
		;

expressions 	: expression
		| expressions COMMA expression
		;*/

%%

void yyerror() {

	printf(" Error sintáctico\n");

}


char *obtenerReg(){
	for(int i=0;i<10;i++){
		if(registros[i]==0){
			registros[i]=1;
			char aux[16];
			sprintf(aux, "$t%d",i);
			return strdup(aux);
		}
	}
	printf("Error: registros agotados\n");
	exit(1);
}

void liberarReg(char *reg){
	if(reg[0]=='$' && reg[1]=='t'){
		int aux= reg[2]-'0';
		assert(aux>=0);
		assert(aux<10);
		registros[aux]=0;
	}
}


char *nuevaEtiqueta(){
	char aux[16];
	sprintf(aux,"$l%d",contador_etiq);
	contador_etiq++;
	return strdup(aux);
}

