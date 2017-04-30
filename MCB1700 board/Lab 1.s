	THUMB		; Declare THUMB instruction set 
	AREA		My_code, CODE, READONLY 	; 
	EXPORT		__MAIN 		; Label __MAIN is used externally q
	ENTRY 
__MAIN

; The following operations can be done in simpler methods. They are done in this way to practice different memory addressing methods
; MOV moves into the lower word (16 bits) and clears the upper word
; MOVT moves into the upper word
; show several ways to create an address using a fixed offset and register as offset and several examples are used below
; NOTE MOV can move ANY 16-bit, and only SOME >16-bit, constants into a register
; BNE and BEQ can be used to branch on the last operation being Not Equal or EQual to zero

	MOV 	R2, #0xC000		; move 0xC000 into R2
	MOV 	R4, #0x0		; init R4 register to 0 to build address
	MOVT 	R4, #0x2009		; assign 0x20090000 into R4
	ADD 	R4, R4, R2 		; add 0xC000 to R4 to get 0x2009C000 

	MOV 	R3, #0x0000007C		; move initial value for port P2 into R3 
	STR 	R3, [R4, #0x40] 	; Turn off five LEDs on port 2 

	MOV 	R3, #0xB0000000		; move initial value for port P1 into R3
	STR 	R3, [R4, #0x20]		; Turn off three LEDs on Port 1 using an offset

	MOV 	R2, #0x20		; put Port 1 offset into R2 for user later

	MOV 	R0, #0xFFFF 		; Initialize R0 lower word for countdown
	MOVT 	R0, #0xA
	
loop
	SUBS 	R0, #1 			; Decrement r0 and set the N,Z,C status bits
	BNE	loop			; Loop back if Z=0 (if R0!=0)
	MOV 	R0, #0xFFFF 		; Initialize R0 least significant word for countdown
	MOVT 	R0, #0xA		; Initialize R0 most significant word for countdown
	EOR 	R3, #0x10000000		; If R3=1, set it to #0xA0000000, else set it to #0xB0000000 (through an exclusive or on bit 28)
	STR 	R3, [R4, R2]		; Toggle the LED in Port 1
	B 	loop			; Branch back to loop


; 'Long flowchart' implementation:
;loop
;loop1
;	SUBS 	R0, #1 			; Decrement r0 and set the N,Z,C status bits
;	BNE	loop1			; loop back if Z=0 (if R0!=0)
;	MOV 	R3, #0xA0000000 	; toggle bit 28
;	STR 	R3, [R4, R2] 		; write the contents of R3 to port 1, turns on LED P1.28
;	MOV 	R0, #0xFFFF 
;	MOVT 	R0, #0xA
;
;loop2
;	SUBS 	R0, #1 			; Decrement r0 and set the N,Z,C status bits
;	BNE	loop2			; loop back if Z=0 (if R0!=0)
;	MOV 	R3, #0xB0000000 	; toggle bit 28
;	STR 	R3, [R4, R2] 		; write the contents of R3 to port 1, turns on LED P1.28
;	MOV 	R0, #0xFFFF 
;	MOVT 	R0, #0xA
;	
;	B 	loop			; branch back to loop


 	END
