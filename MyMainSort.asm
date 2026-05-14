asect 0xf0
dc ISR
dc sleep

asect 0xf8
data:

asect 0xf9
ready:

asect 0x00

start:
	setsp 0xef
	ei
	br sleep
	
sleep:
	ldi r0, ready
	ldi r1, 1
	st r0, r1
	wait
	br sleep
	
ISR:
	ldi r0, ready
	ldi r1, 0
	st r0, r1
	ld r0, r0
	
	ldi r0, data
	ldi r2, 0
	ldi r3, lb
	ldc r3, r3
	while
		ldi r1, 54	
		cmp r2, r1
	stays ne
		ld r0, r1
		st r3, r1
		inc r2
		inc r3
	wend
	# r3 pointer to current value in lb
	# r2 pointer to a new record
	ldi r3, lb
	ldc r3, r3
	ldi r2, new 
	ldc r2, r2

	ldi r1, res
	ldc r1, r1
	
	push r2
	push r1
	push r3
	ldi r0, 0
	ld r2, r2	
	while
		# r0 counter
		
		ldi r1, 8
		cmp r1, r0		
		stays ne
			# write down current in res 
			# and look the next lb value
				
				ld r3, r3
				cmp r2, r3
			# if new is lower that the current in lb
			# if new is higher that in lb
			if 
			is hs
				pop r3 
				pop r1
				pop r2
				st r1, r2
				inc r1
				inc r0
				jsr update_lb
			else
					pop r3
					pop r1
					st r1, r3
					inc r1
					push r1
					ldi r1, 6
					add r1, r3
					push r3
					inc r0
			fi	
		wend
		jsr write_few

		jsr write_in_output_device
	
	addsp 3
	rti
	
update_lb:
	
	while 
		ldi r2, 8
		cmp r0, r2
		stays ne
			st r1, r3
			ldi r2, 6
			add r2, r3
			inc r1
			inc r0
	wend
	rts
# write updated lb in 0x00
# r1 records counter
# r0 pointers to final lb
# r3 counter of values in records
# r2 addr to write new lb to
write_one:

	ld r0, r0

	ldi r1, 0
	while 
		ldi r2, 6
		cmp r1, r2
		stays ne
			ld r0, r2
			st r3, r2
			inc r3
			inc r1
			inc r0	
		wend
	rts

write_few:
	ldi r0, res
	ldc r0, r0
	ldi r1, 0	
	ldi r3, 0
	push r0
	push r1
	
	while 
		ldi r2, 8
		cmp r1, r2
		stays ne
			jsr write_one
			pop r1
			inc r1
			pop r0
			inc r0
			push r0
			push r1
	wend	
	pop r1
	pop r0	
	rts

write_in_output_device:
	ldi r0, data
	ldi r2, 0
		
	while
		ldi r1, 54
		cmp r2, r1			
	stays ne
		ld r2, r3
		st r0, r3
		inc r2
	wend
	rts

lb: dc 48
new: dc 0x60
res: dc 0x70

end