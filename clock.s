.global clock
.text
.set noreorder

.set INTBASE, 0xBF800000
.set IFS0CLR, 0x00081034
.set TMR1, 0x00000610

.ent clock

clock:
	li $t6, 0xBF800600		#
	li $t9, 0x8000			#
	sw $t9, 0x0C($t6)		#
	li $t6, INTBASE			#
	li $t9, 0x10			#
	sw $t9, IFS0CLR($t6)	#
	li $t9, 0x401			#
	mtc0 $t9, $12, 0		#
	li $t9, 0x8000			#
	sw $t9, 0x0604($t6)		#
	lw $zero, TMR1($t6)		#
	nop
	#lw $t9, 0xC($t3)		#
	#addi $t9, $t9, 1		# increment time +1
	#sw $t9, 0xC($t3)		#
	nop
	li $a1, 0x39
	li $a2, 0x35
	lw $t9, 0xC($t3)		# seconds
	slti $t9, $t9, 0x30		#
	addi $t9, $t9, -1		#
	bgezal $t9, XXXS		#
	nop
	lw $t9, 0x8($t3)		# ten seconds
	slti $t9, $t9, 0x30		#
	addi $t9, $t9, -1		#
	bgezal $t9, XXSX		#
	nop
	lw $t9, 0x4($t3)		# minutes
	slti $t9, $t9, 0x30		#
	addi $t9, $t9, -1		#
	bgezal $t9, XMXX		#
	nop
	lw $t9, 0x0($t3)		# ten minutes
	slti $t9, $t9, 0x30		#
	addi $t9, $t9, -1		#
	bgezal $t9, MXXX		#
	nop
	b return
	nop



MXXX:
	li $t9, 0x35
	sw $t9, 0x0($t3)
	jr $ra
	nop

XMXX:
	li $t9, 0x39
	sw $t9, 0x4($t3)
	lw $t9, 0x0($t3)
	addi $t9, $t9, -1
	sw $t9, 0x0($t3)
	jr $ra
	nop
XXSX:
	li $t9, 0x35
	sw $t9, 0x8($t3)
	lw $t9, 0x4($t3)
	addi $t9, $t9, -1
	sw $t9, 0x4($t3)
	jr $ra
	nop

XXXS:	
	li $t9, 0x39
	sw $t9, 0xC($t3)
	lw $t9, 0x8($t3)
	addi $t9, $t9, -1
	sw $t9, 0x8($t3)
	jr $ra
	nop
	
return:
	#mfc0 $a1, $14			# move EPC to $a1
	#addi $a1, $a1, 4
	#jr $a1					#
	lw $t9, 0x0($t8)
	beq $t9, 0x30303030, alarm
	nop
	lw $t9, 0x86010($t1)
	andi $t9, $t9, 0x80
	bgtz $t9, prompt
	nop
	li $t9, 0x8000
	la $a1, draw
	jr $a1
	sw $t9, 0x0608($t6)		#

.end clock

/*
stop:
	b alarm
	nop	*/
	