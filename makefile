ejecutable : lex.yy.c sintactico.tab.c sintactico.tab.h 
	gcc lex.yy.c  sintactico.tab.c listaSimbolos.c listaCodigo.c main.c -lfl -o ejecutable

sintactico.tab.c   sintactico.tab.h : sintactico.y
	 bison -v -d sintactico.y

lex.yy.c: Analizadorlexico.l
	flex Analizadorlexico.l

limpiar:
	rm lex.yy.c ejecutable sintactico.tab.c sintactico.tab.h

