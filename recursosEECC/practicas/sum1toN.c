/*
  Programa:       sum1toN.c
  Descripción:    realiza la suma de la serie 1,2,3,...N
                  Es el programa en lenguaje C equivalente a sum1toN.ias de la máquina IAS de von Neumann
  Lenguaje:       C99
  Descripción:    Suma de los primeros 5 números naturales
  Entrada:        Definida en una variable
  Salida:         Sin salida
  Compilación:    gcc -m32 -g -o sum1toN sum1toN.c
  S.O:            GNU/linux 4.10 ubuntu 17.04 x86-64
  Librería:       /usr/lib/x86_64-linux-gnu/libc.so
  CPU:            Intel(R) Core(TM) i5-6300U CPU @ 3.0GHz
  Compilador:     gcc version 6.3 
  Ensamblador:    GNU assembler version 2.28
  Linker/Loader:  GNU ld (GNU Binutils for Ubuntu) 2.28
  Asignatura:     Estructura de Computadores
  Fecha:          20/09/2017
  Autor:          Cándido Aramburu
*/

void  main (void)
{
  char sum=0;
  char n=0b101;	//Declaración de variables locales
  while(n>0){
    sum-=n;
    n--;
  }
}
