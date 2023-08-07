/*
  Programa fuente: imprimir.c
  Al finalizar la ejecución ejecutar en el terminal: echo $? y comprobar que visualizamos el valor de retorno.
*/

#define   SYS_EXIT  1
#define   SUCCESS   0
#define   FD        1
#define   COUNT     10

#include <stdlib.h>
#include <unistd.h>

int main (void)
{
  char * saludo="Hola Mundo";
  write(FD,saludo,COUNT);
  exit(SUCCESS);
}
