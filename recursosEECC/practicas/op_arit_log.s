### Programa:     op_arit_log.s
### Descripción: Emplear estructuras de datos con diferentes operaciones lógicas y aritméticas.
### Compilación: gcc -m32 -g -o op_arit_log op_arit_log.s
	
	## MACROS
	.equ SYS_EXIT,	1
	.equ SUCCESS,	0
	.equ N,		5

	## VARIABLES LOCALES
	
	
	## INSTRUCCIONES
	.global main
	.text
main:

	## RESET	

	xor  %eax,%eax
	xor  %ebx,%ebx
	xor  %ecx,%ecx
	xor  %edx,%edx
	xor  %esi,%esi
        xor  %edi,%edi
	

	## OPERACIONES ARITMETICAS con NUMEROS ENTEROS
	
	## add: suma
	mov $5,%eax
	mov $10,%ebx
	add %ebx,%eax

	## sub: resta
	mov $5,%eax
	mov $10,%ebx
	sub %ebx,%eax
	

	## imul: multiplicación entera "con signo": AX<- BL*AL
        movb $-3,%bl
	movb $5,%al
	imulb %bl

        ## idiv: división "con signo" .   (AL=Cociente, AH=Resto) <- AX/(byte en registro o memoria)	    
	movw $5,%ax		#dividendo
	movb $3,%bl		#divisor
	idivb %bl	    # 5/3 = 1*3 + 2

        ## complemento a 2: equivalente a cambiar de signo negación
	negb %bl	    


	## Expresión N*(N+1)/2
	movw $N,%bx
	movw $(N+1),%ax
	imulw %bx		#imulw Op ; Op=word ; DX:AX<- AX*Op
	movw $2,%bx
	## El resultado queda en AX y el resto DX=0
	idivw %bx		#idivw Op ; Op=word ; AX<-(DX:AX)/Op ; DX:=Resto
	

	## OPERACIONES LOGICAS

	mov $0xFFFF1F, %eax
        mov $0x0000F1, %ebx
	not %eax	# inversión
	and %ebx,%eax	# producto lógico
	or  %ebx,%eax	# suma lógica

        ## Complemento a 2 mediante operación lógica not()+1
	mov %ebx,%eax		
	not %eax
	inc %eax

	## Desplazamiento de bits
        shr $4,%eax		#desplazamiento lógico: bits a introduccir -> 0..
	sar $4,%eax		#desplazamiento aritmético: bits a introducir -> extensión del signo

	## SALIDA
	
	mov $SYS_EXIT, %eax	
	mov $SUCCESS,  %ebx
	int $0x80
	
	.end
