/*
 
 Programa:	 Juego  tetris en código ensamblador  AT&T
 Arquitectura:	 Programa binario 16 bits a cargar en el sector MBR (512 bytes) del disco duro
 Modo de ejecución: Al arrancar la computadora de Intel con el sistema en Modo Real
 Emulación: qemu : quick emulator

 ASSEMBLY LANGUAGE 
 https://docs.oracle.com/cd/E26502_01/html/E28388/enmzx.html#scrolltoc : amd64
 https://docs.oracle.com/cd/E19455-01/806-3773/6jct9o0af/index.html : ia-32
 The i386 version as supports both the original Intel 386 architecture in both 16 and 32-bit mode
 file:///home/candido/apuntes/apuntes_asm/asm_gas.html#_programando_en_16_code

 ASSEMBLER TRANSLATE
 https://sourceware.org/binutils/docs/as/index.html#Top
 http://www.nasm.us/xdoc/2.10.07/html/nasmdoci.html
 http://www.nasm.us/xdoc/2.10.07/html/nasmdoc0.html

 CPU INTEL MODE
 https://en.wikipedia.org/wiki/Real_mode
 https://en.wikipedia.org/wiki/BIOS_interrupt_call
 https://osandamalith.com/2015/10/26/writing-a-bootloader/ 

 QEMU
 * Set BIOS to KVM emulation
 * qemu-system-i386 -M accel=kvm:tcg -m 32 -drive "if=ide,file=$workdir/tetros.img,format=raw"
 



 
  TOOLCHAIN
  Cómo el código es para 16 bits compilo para una arquitectura de 32 bits
  as --32 --defsym DEBUG=0  -o tetros.o tetros.s  ->  para depurar
  ld -m elf_i386 tetros.o  -o tetros  -Ttext 0x7c00       -> para depurar
  as --32 --defsym DEBUG=1 -o tetros.o tetros.s         ->  para emular
  ld -m elf_i386 tetros.o --oformat=binary -o tetros.img  -Ttext 0x7c00 ->  para emular
  
  EMULATION
  qemu-system-i386 -drive file=tetros.img,index=0,media=disk,format=raw -> para jugar
  
  DEPURAR CON GDB con 2 terminales
   1º terminal
	qemu-system-i386 -s -S -drive file=tetros.img,index=0,media=disk,format=raw
   2º terminal
	as --32 --defsym DEBUG=1 --gstabs -o tetros.o tetros.s 
	ld -m elf_i386 tetros.o  -o tetros  -Ttext 0x7c00
	gdb tetros
	target remote localhost:1234
	b _start
	c
	n
 TODO
 * Compilar el  módulo nasm con as .intel-syntax
 * Expandir macros .macro  .endm
 * Expandir macros estilo C 	#define  MACRO  mov %ax,%bx \
	                                        mov $3,%cx
 * crash al ejecutar una interrupción BIOS -> http://ternet.fr/gdb_real_mode.html -> stepo

 * https://stackoverflow.com/questions/28811811/using-gdb-in-16-bit-mode
	qemu-system-i386 -hda main.img -S -s &
    gdb tetros -ex 'target remote localhost:1234' \
        -ex 'set architecture i8086' \
        -ex 'break *0x7c00' \
        -ex 'continue'
 * scripts para GDB: https://github.com/dholm/dotgdb -> ya lo he instalado
Complementos:	
  * bios : https://github.com/01org/KVMGT-seabios
  * http://zoo.cs.yale.edu/classes/cs422/2013/lec/l3-hw	
	
*/


	
	.code16			#Código para architecture 16 bits
### Tetris

	## 	.org 0x7c00 : en nasm es origen pero en at&t es desplazamiento. Fijo el origen al linkar

### ============================================================================
### DEBUGGING MACROS
### ============================================================================

	.ifeq	 DEBUG         ## si al ensamblar pongo as --defsym DEBUG=0 ensambla
	.include "debug_macros.s"
	.endif

### ============================================================================
				# MACROS
### ============================================================================

### Sleeps for the given number of microseconds.
	.macro sleep p1
	pusha			# push all registers
	xor %cx, %cx
	mov $\p1,%dx
	mov $0x86,%ah
	int $0x15
	popa
	.endm

### Choose a brick at random.
	.macro select_brick 
	mov $2, %ah                    # get current time
	int $0x1a
	movb seed_value,%al
	xor %dx,%ax
	mov $31,%bl
	mul %bx
	inc %ax
	movb %al, seed_value
	xor %dx, %dx
	mov  $7,%bx
	div %bx
	shl $3,%dl
	xchg %dx,%ax                  # mov al, dl
	.endm

### Sets video mode and hides cursor.
	.macro clear_screen 
	xor %ax, %ax                   # clear screen (40x25)
	int $0x10
	mov $1,%ah                    # hide cursor
	mov $0x2607,%cx
	int $0x10
	.endm

	.equ field_left_col,	13
	.equ field_width,     	14
	.equ inner_width,    	12
	.equ inner_first_col, 	14
	.equ start_row_col, 	0x0412

	.macro init_screen 
	clear_screen
	mov $3, %dh                        # row
	mov  $18, %cx                       # number of rows
ia: 	push %cx
	inc %dh                           # increment row
	mov  $field_left_col,%dl           # set column
	mov  $field_width, %cx              # width of box
	mov  $0x78, %bx                     # color
	call set_and_write
	cmp  $21, %dh                       # don't remove last line
	je ib                            # if last line jump
	inc %dx                           # increase column
	mov $inner_width, %cx              # width of box
	xor %bx, %bx                       # color
	call set_and_write
ib: 	pop %cx
	loop ia
	.endm
### ============================================================================

	.equ delay, 0x7f00
	.equ seed_value, 0x7f02

	.section .text
	.global _start

_start:
	xor %ax, %ax
	mov %ax,%ds
	init_screen
new_brick:
	movb $100,  delay            # 3 * 100 = 300ms
	select_brick                     # returns the selected brick in AL
	mov  $start_row_col,%dx            # start at row 4 and col 38
lp:
	call check_collision
	jne .                            # collision -> game over
	call print_brick

wait_or_keyboard:
	xor %cx, %cx
	movb  delay,%cl
wait_a:
	push %cx
	sleep 3000                       # wait 3ms

	push %ax
	mov  $1, %ah                    # check for keystroke# AX modified
	int $0x16                     # http://www.ctyme.com/intr/rb-1755.htm
	mov %ax, %cx
	pop %ax
	jz no_key                    # no keystroke
	call clear_brick
	## 4b left, 48 up, 4d right, 50 down
	cmp $0x4b, %ch                # left arrow
	je left_arrow                # http://stackoverflow.com/questions/16939449/how-to-detect-arrow-keys-in-assembly
	cmp  $0x48,%ch                 # up arrow
	je up_arrow
	cmp  $0x4d, %ch
	je right_arrow

	movb  $10, delay         # every other key is fast down
	jmp clear_keys
left_arrow:
	dec %dx
	call check_collision
	je clear_keys                 # no collision
	inc %dx
	jmp clear_keys
right_arrow:
	inc %dx
	call check_collision
	je clear_keys                # no collision
	dec %dx
	jmp clear_keys
up_arrow:
	mov  %al, %bl
	inc %ax
	inc %ax
	test  $0b00000111, %al           # check for overflow
	jnz nf                       # no overflow
	sub  $8,%al
nf: call check_collision
	je clear_keys                # no collision
	mov  %bl,%al
clear_keys:
	call print_brick
	push %ax
	xor %ah, %ah                   # remove key from buffer
	int $0x16
	pop %ax
no_key:
	pop %cx
	loop wait_a

	call clear_brick
	inc %dh                       # increase row
	call check_collision
	je lp                        # no collision
	dec %dh
	call print_brick
	call check_filled
	jmp new_brick
	
salida:
	mov $1,%ax
	int $0x80

### ------------------------------------------------------------------------------

set_and_write:
	mov  $2 , %ah                   # set cursor
	int $0x10
	mov  $0x0920, %ax               # write boxes
	int $0x10
	ret



set_and_read:
	mov  $2,  %ah                    # set cursor position
	int $0x10
	mov  $8, %ah                   # read character and attribute, BH = 0
	int $0x10                     # result in AX
	ret

### ------------------------------------------------------------------------------

### DH = current row
	.macro replace_current_row 
	pusha                           # replace current row with row above
	mov  $inner_first_col, %dl
	mov  $inner_width, %cx
cf_aa:
	push %cx
	dec %dh                          # decrement row
	call set_and_read
	inc %dh                          # increment row
	mov  %ah, %bl                      # color from AH to BL
	mov  $1, %cl
	call set_and_write
	inc %dx                          # next column
	pop %cx
	loop cf_aa
	popa
	.endm

check_filled:
	pusha
	mov  $21, %dh                       # start at row 21
next_row:
	dec %dh                           # decrement row
	jz cf_done                       # at row 0 we are done
	xor  %bx, %bx
	mov $inner_width,  %cx
	mov  $inner_first_col, %dl          # start at first inner column
cf_loop:
	call set_and_read
	shr $4, %ah                        # rotate to get background color in AH
	jz cf_is_zero                    # jmp if background color is 0
	inc %bx                           # increment counter
	inc %dx                           # go to next column
cf_is_zero:
	loop cf_loop
	cmp  $inner_width, %bl             # if counter is 12 full we found a full row
	jne next_row
replace_next_row:                    # replace current row with rows above
	replace_current_row
	dec %dh                           # replace row above ... and so on
	jnz replace_next_row
	call check_filled                # check for other full rows
cf_done:
	popa
	ret

clear_brick:
	xor  %bx, %bx
	jmp print_brick_no_color
print_brick:  # al = 0AAAARR0
	mov %al ,  %bl                  # select the right color
	shr  $3, %bl
	inc %bx
	shl  $4, %bl
print_brick_no_color:
	inc %bx                       # set least significant bit
	mov  %bx, %di
	jmp check_collision_main
	## BL = color of brick
	## DX = position (DH = row), AL = brick offset
	## return: flag
check_collision:
	mov $0,  %di
check_collision_main:            # DI = 1 -> check, 0 -> print
	pusha
	xor %bx, %bx                   # load the brick into AX
	mov %al,  %bl
	movw bricks(%bx),  %ax

	xor %bx, %bx                   # BH = page number, BL = collision counter
	mov $4,  %cx
cc:
	push %cx
	mov  $4, %cl
zz:
	test $0b10000000,  %ah
	jz is_zero

	push %ax
	or %di, %di
	jz ee                        # we just want to check for collisions
	pusha                        # print space with color stored in DI
	mov %di ,  %bx                  # at position in DX
	xor %al, %al
	mov $1,  %cx
	call set_and_write
	popa
	jmp is_zero_a
ee:
	call set_and_read
	shr  $4 , %ah                   # rotate to get background color in AH
	jz is_zero_a                 # jmp if background color is 0
	inc %bx
is_zero_a:
	pop %ax

is_zero:
	shl  $1 , %ax                   # move to next bit in brick mask
	inc %dx                       # move to next column
	loop zz
	sub  $4 , %dl                   # reset column
	inc %dh                       # move to next row
	pop %cx
	loop cc
	or %bl, %bl                    # bl != 0 -> collision
	popa
	ret

	

### ==============================================================================

bricks:
	## 	  in AL      in AH
	## 	  3rd + 4th  1st + 2nd row
	.byte 0b01000100, 0b01000100, 0b00000000, 0b11110000
	.byte 0b01000100, 0b01000100, 0b00000000, 0b11110000
	.byte 0b01100000, 0b00100010, 0b00000000, 0b11100010
	.byte 0b01000000, 0b01100100, 0b00000000, 0b10001110
	.byte 0b01100000, 0b01000100, 0b00000000, 0b00101110
	.byte 0b00100000, 0b01100010, 0b00000000, 0b11101000
	.byte 0b00000000, 0b01100110, 0b00000000, 0b01100110
	.byte 0b00000000, 0b01100110, 0b00000000, 0b01100110
	.byte 0b00000000, 0b11000110, 0b01000000, 0b00100110
	.byte 0b00000000, 0b11000110, 0b01000000, 0b00100110
	.byte 0b00000000, 0b01001110, 0b01000000, 0b01001100
	.byte 0b00000000, 0b11100100, 0b10000000, 0b10001100
	.byte 0b00000000, 0b01101100, 0b01000000, 0b10001100
	.byte 0b00000000, 0b01101100, 0b01000000, 0b10001100

	.ifgt DEBUG  ## ensambla si DEBUG es mayor que cero. pej en as --defsym DEBUG=1
###  It seems that I need a dummy partition table entry for my notebook.
	## 	times 446-($-$$) db 0
 	.fill  494 - (. - _start) ,1,0 #fill repeat, size bytes, value
	.byte 0x80                   # bootable
	.byte 0x00, 0x01, 0x00       # start CHS address
	.byte 0x17                   # partition type
	.byte 0x00, 0x02, 0x00       # end CHS address
	.byte 0x00, 0x00, 0x00, 0x00 # LBA
	.byte 0x02, 0x00, 0x00, 0x00 # number of sectors

### ; At the end we need the boot sector signature.
	## 	times 510-($-$$) db 0
	 	.fill 0x1fe - (. - _start) ,1,0
	.byte 0x55
	.byte 0xaa
	.endif

		.end
