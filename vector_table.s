.set at
.section .vector_4,code
.set noreorder
.ent _vector_4
_vector_4:
#nop
	nop
	nop
   #la $a1, clock
   #jr $a1       		# unknowing or
   nop
here_04:
	b here_04
	nop
.end _vector_4

.section .vector_24,code
.set noreorder
.ent _vector_24
_vector_24:
   la $a1, uart  		# load address to echo
   jr $a1        		# go there
   #li $a2, 0x12345678	# debug script
   nop
here_024:
	b here_024
	nop
.end _vector_24

.section .vector_32,code
.set noreorder
.ent _vector_32
_vector_32:
   la $a1, uart  		# load address to echo
   jr $a1        		# go there
   #li $a2, 0x12345678	# debug script
   nop
here_032:
	b here_032
	nop
.end _vector_32
