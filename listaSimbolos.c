#include "listaSimbolos.h"
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>

struct PosicionListaRep {
  Simbolo dato;
  struct PosicionListaRep *sig;
};

struct ListaRep {
  PosicionLista cabecera;
  PosicionLista ultimo;
  int n;
};

typedef struct PosicionListaRep *NodoPtr;

Lista creaLS() {
  Lista nueva = malloc(sizeof(struct ListaRep));
  nueva->cabecera = malloc(sizeof(struct PosicionListaRep));
  nueva->cabecera->sig = NULL;
  nueva->ultimo = nueva->cabecera;
  nueva->n = 0;
  return nueva;
}

void liberaLS(Lista lista) {
  while (lista->cabecera != NULL) {
    NodoPtr borrar = lista->cabecera;
    lista->cabecera = borrar->sig;
    free(borrar);
  }
  free(lista);
}

void insertaLS(Lista lista, PosicionLista p, Simbolo s) {
  NodoPtr nuevo = malloc(sizeof(struct PosicionListaRep));
  nuevo->dato = s;
  nuevo->sig = p->sig;
  p->sig = nuevo;
  if (lista->ultimo == p) {
    lista->ultimo = nuevo;
  }
  (lista->n)++;
}

void suprimeLS(Lista lista, PosicionLista p) {
  assert(p != lista->ultimo);
  NodoPtr borrar = p->sig;
  p->sig = borrar->sig;
  if (lista->ultimo == borrar) {
    lista->ultimo = p;
  }
  free(borrar);
  (lista->n)--;
}

Simbolo recuperaLS(Lista lista, PosicionLista p) {
  //assert(p != lista->ultimo);
  return p->dato;
}

PosicionLista buscaLS(Lista lista, char *nombre) {
  NodoPtr aux = lista->cabecera;
  while (aux->sig != NULL && strcmp(aux->sig->dato.nombre,nombre) != 0) { //strcmp devuelve 0 si las cadenas son iguales
    aux = aux->sig;
  }
  return aux->sig;
}

void asignaLS(Lista lista, PosicionLista p, Simbolo s) {
  assert(p != lista->ultimo);
  p->sig->dato = s;
}

int longitudLS(Lista lista) {
  return lista->n;
}

PosicionLista inicioLS(Lista lista) {
  return lista->cabecera;
}

PosicionLista finalLS(Lista lista) {
  return lista->ultimo;
}

PosicionLista siguienteLS(Lista lista, PosicionLista p) {
  assert(p != lista->ultimo);
  return p->sig;
}

Simbolo CrearSimbolo(char *nom, Tipo tip, int valr){
  Simbolo simbo;
  simbo.nombre=nom;
  simbo.tipo=tip;
  simbo.valor=valr;
  return simbo;
}

void mostrarlista(Lista lista){
  printf("%s","    .data\n");	
  NodoPtr aux = lista->cabecera; 
  while (aux->sig != NULL) {
	if(aux->sig->dato.tipo==CADENA){	    
		printf("%s%s\n",concatenacadena(aux->sig->dato.valor),":");	
		printf("%s%s\n","    .asciiz ",aux->sig->dato.nombre);
	}else{
		printf("%s%s\n",concatena("_",aux->sig->dato.nombre),":");
		printf("%s\n","    .word 0");
	     }
	aux = aux->sig;
  }
}

bool esConstante(Lista lista, char *nom){	
	NodoPtr aux = buscaLS(lista, nom);
	Simbolo s = recuperaLS(lista, aux);	
	if(s.tipo==CONSTANTE) return true;
	else return false;
}

char *concatena(char *arg1, char *arg2){
	char *aux = (char*)malloc(strlen(arg1)+strlen(arg2)+1);
	sprintf(aux,"%s%s",arg1,arg2);
	return aux;

}

char *concatenacadena(int arg2){
	char *aux = (char*)malloc(5); //sabemos la longitud esacta puesto que es $str seguido de un numero
	sprintf(aux,"%s%d","$str",arg2);
	//printf("%s", aux);
	return aux;
}




