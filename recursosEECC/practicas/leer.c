/*
  Programa fuente: leer.c
  Al finalizar la ejecución ejecutar en el terminal: echo $? y comprobar que visualizamos el valor de retorno.
*/

#define   SYS_EXIT  1
#define   SUCCESS   0
#define   FD_OUT    1
#define   FD_IN     0    
#define   COUNT_OUT 22
#define   COUNT_IN  40

#include <stdlib.h>
#include <unistd.h>

int main (void)
{
  char * formulario="\n Nombre y Apellidos:\t";
  char buffer[COUNT_IN], longitud;
  write(FD_OUT,formulario,COUNT_OUT);
  longitud=read (FD_IN,buffer,COUNT_IN);
  write(FD_OUT,buffer,longitud);
  exit(SUCCESS);
}
