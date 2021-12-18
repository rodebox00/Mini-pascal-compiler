%{
#include "sintactico.tab.h"
void identificador();
void numero();
int linea;
%}
digito              [0-9]
letra               [a-zA-Z]
entero              {digito}+

%x panico comentario
%option yylineno


%%
"(*"				    {BEGIN(comentario);yymore();linea=yylineno;} //le estoy diciendo que no machaque yytext() sino que lo concatene. yytext() guarda la ultima cadena reconocida por una expresión regular.
<comentario>[^*]*		    yymore();
<comentario>[*]+[^)*]*		    yymore();
<comentario><<EOF>>		    {printf("Comentario no cerrado iniciado en linea: %d\n", linea);}
<comentario>[*]+[)]		    {BEGIN(0);} //termina el comentario
[\n \t\s]+                          ;
"//"(.*)[\n]                        ;		
(?i:program)			    return PROGRAM;
(?i:function)			    return FUNCTION;
(?i:const)			    return CONST; 
(?i:var)			    return VAR; 
(?i:integer)			    return INTEGER; 
(?i:if)			            return IF; 
(?i:then)			    return THEN;
(?i:else)			    return ELSE;
(?i:while)			    return WHILE;
(?i:do)			    	    return DO; 
(?i:for)			    return FOR;
(?i:to)			    	    return TO; 
(?i:begin)                          return BEGINN;
(?i:end)                            return END;
(?i:read)                           return READ;
(?i:write)                          return WRITE;
({letra}|_)({letra}|{digito}|_)*    identificador();return ID;
{entero}                            numero();return INTLITERAL;
\"(\\.|[^"\n])*\"		    yylval.lexema=strdup(yytext);return STRING;
"("                                 return LPAREN;		
")"                                 return RPAREN;
";"                                 return SEMICOLON;
","                                 return COMMA;
":="                                return ASSIGNOP;
"+"                                 return PLUSOP;
"-"                                 return MINUSOP;
":"                                 return DOSPUNTOS;
"*"                                 return MULTIPLICA;
"/"                                 return DIVIDE;
"."                                 return PUNTO;
[^a-zA-Z_0-9();+\-:.,*/"]	    {BEGIN(panico);yymore();}  
<panico>[^a-zA-Z_0-9();:+\-.,*/"]+ {yymore();}
<panico>[a-zA-Z_0-9();:+\-.,*/"]   {BEGIN(0);yyless(yyleng-1);printf("Caracteres no validos en linea %d: %s\n", yylineno, yytext);}
%%





void identificador()
{
  if(yyleng>16) printf("ERROR, numero máximo de carácteres para un identificador sobrepasado %s\n",yytext);
  else yylval.lexema=strdup(yytext);
}


void numero()
{
  if(atoll(yytext)>2147483650) printf("ERROR, numero máximo sobrepasado %s\n",yytext);
  else yylval.lexema=strdup(yytext);
}

