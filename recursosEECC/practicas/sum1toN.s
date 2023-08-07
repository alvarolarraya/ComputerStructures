### Programa: sum1toN.s
### Descripción: realiza la suma de la serie 1,2,3,...N
### Es el programa en lenguaje AT&T i386 equivalente a sum1toN.ias de la máquina IAS de von Neumann
### gcc -m32 -g -nostartfiles -o sum1toN sum1toN.s
### Ensamblaje as --32 --gstabs sum1toN.s -o sum1toN.o
### linker -> ld -melf_i386    -o sum1toN sum1toN.o 

        ##  Declaración de variables
        .section .data

n:	.int 5
       
        .global _start

        ##  Comienzo del código
        .section .text
_start:
        mov $0,%ecx # ECX implementa la variable suma
        mov n,%edx  # EDX implementa es un alias de la variable n
bucle:
        add %edx,%ecx
        sub $1,%edx
        jnz bucle
       
        mov %ecx, %ebx # el argumento de salida al S.O. a través de EBX según convenio
                
        ## salida
        mov $1, %eax  # código de la llamada al sistema operativo: subrutina exit
        int $0x80     # llamada al sistema operativo

        
        .end

        
