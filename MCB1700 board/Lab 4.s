	THUMB 					; Declare THUMB instruction set 
	AREA 		My_code, CODE, READONLY ;
	EXPORT 		__MAIN 			; Label __MAIN is used externally 
	EXPORT 		EINT3_IRQHandler 	; without this the interupt routine will not be found

	ENTRY 

__MAIN
	; The following lines are similar to previous labs.
	; They just turn off all LEDs 
	LDR	R10, =LED_BASE_ADR	; R10 is a  pointer to the base address for the LEDs
	MOV 	R3, #0xB0000000		; Turn off three LEDs on port 1  
	STR 	R3, [r10, #0x20]
	MOV 	R3, #0x0000007C
	STR 	R3, [R10, #0x40] 	; Turn off five LEDs on port 2 

	; enable interrupts
	LDR 	R7, =IO2INTCLR
		
	LDR 	R8, =ISER0		; Interrupt set-enable		
	MOV  	R3, #0x200000		; 21st bit is 1
	STR	R3, [R8]
		
	LDR	R9, =IO2IntEnf		; Interrupt falling edge		
	MOV 	R3, #0x400		; 10th bit is 1
	STR 	R3, [R9]		
			
	; generate a random number			
	MOV	R11, #0xF283		; Init the random number generator with a non-zero number
	BL 	RANDOM_NUM
		
DISP_LOOP
	; display on the LEDs
	BL	DISPLAY_NUM
		
	; delay 1 sec
	MOV	R0, #10000
	BL	DELAY
		
	; decrement value in R6 by 10 (aka 1s)
	SUBS	R6, #10
		
	; exits when R6 <= 0
	BEQ	FLASH_LOOP
	BMI	FLASH_LOOP
		
	; if R6 > 0, branch back to DISP LOOP
	B	DISP_LOOP
		
FLASH_LOOP
	; flash LEDs on & off at a 10Hz rate
		
	; ISR -> generates new random num, scales it & saves it in R6
	;	  -> if in FLASH LOOP, go to DISP LOOP
	CMP 	R6, #0
	BPL	DISP_LOOP		; exits if R6 > 0 (if ISR was called)
		
	; Turn off all LEDs
	MOV 	R3, #0xB0000000		 
	STR 	R3, [r10, #0x20]
	MOV 	R3, #0x0000007C
	STR 	R3, [R10, #0x40] 	
		
	; delay
	MOV	R0, #500
	BL 	DELAY
		
	; Turn on all LEDs
	MOV 	R3, #0x00000000	
	STR 	R3, [R10, #0x20]		
	MOV 	R3, #0x00000000
	STR 	R3, [R10, #0x40] 
		
	; delay
	MOV	R0, #500
	BL 	DELAY

	B 	FLASH_LOOP





;*------------------------------------------------------------------- 
; Subroutine RANDOM_NUM ... Calls RNG & saves new random num in R6
;*------------------------------------------------------------------- 

RANDOM_NUM
	STMFD	R13!, {R14}
	BL 	RNG			; Generates a random number from 50-250
	MOV	R6, R11			; Copy R11 to R6
	LDMFD	R13!, {R15}
	


;*------------------------------------------------------------------- 
; Subroutine RNG ... Generates a pseudo-Random Number in R11 
;*------------------------------------------------------------------- 

; R11 holds a random number as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R11 MUST be initialized to a non-zero 16-bit value at the start of the program
; R11 can be read anywhere in the code but must only be written to by this subroutine
RNG 	STMFD	R13!,{R1-R3, R14} 	; Random Number Generator 
	AND	R1, R11, #0x8000
	AND	R2, R11, #0x2000
	LSL	R2, #2
	EOR	R3, R1, R2
	AND	R1, R11, #0x1000
	LSL	R1, #3
	EOR	R3, R3, R1
	AND	R1, R11, #0x0400
	LSL	R1, #5
	EOR	R3, R3, R1		; The new bit to go into the LSB is present
	LSR	R3, #15
	LSL	R11, #1
	ORR	R11, R11, R3
		
	; scale & add an offset to get correct range (50 - 250)
	AND 	R11, R11, #0xFF		; isolate bottom 8 bits to get a number from 0-255
	MOV	R3, #4
	MUL	R11, R11, R3		; *4 -> 0 - 1000
	MOV	R3, #5
	SDIV	R11, R11, R3		; %5 -> 0-200
	ADD	R11, R11, #50		; +50 -> final range 50 - 250

	LDMFD	R13!, {R1-R3, R15}



;*------------------------------------------------------------------- 
; Subroutine DELAY ... Causes a delay of 0.1s * R0 times
;*------------------------------------------------------------------- 

;	Delay 100ms * R0 times (aim for better than 10% accuracy)
DELAY	
	STMFD	R13!,{R2, R14}

MultipleDelay
	TEQ	R0, #0			; test R0 to see if it's 0
	BEQ 	exitDelay		; if R0 = 0, exit
	MOV	R2, #0x83		; set counter
	
DelayLoop
	SUBS 	R2, #1 			; Decrement counter and set the N,Z,C status bits
	BNE	DelayLoop		; Loop back if Z=0 (if R0!=0)
		
	SUBS 	R0, #1
	B 	MultipleDelay		; loop back up (in case we have to delay more than once)
exitDelay	
	LDMFD	R13!, {R2, R15}
		


;*------------------------------------------------------------------- 
; Subroutine DISPLAY_NUM ... Dsplays number in of R6 on LEDs
;*------------------------------------------------------------------- 

; Display the number in R6 onto the 8 LEDs
DISPLAY_NUM	
	STMFD	R13!,{R1, R2, R14}
	; Send bits 0-4 to Port 2
	AND	R1, R6, #0x1F		; isolate the bits
	RBIT	R1, R1			; flip the contents of the register
	LSR	R1, #25			; shift them into position
	EOR     R1, #0x007c		; flip the bits (because active-low)
	STR 	R1, [R10, #0x40]
		
	; Send bits 5-7 to Port 1
	AND	R2, R6, #0xE0
	RBIT	R2, R2
	LSL	R2, #5			; shift into position
	; shift bits 29 and 30 left 1 (leave 31 where it is)
	LSLS	R2, #1			; left shift once (to get the 31st bit into the carry)
	LSR	R2, #1			; right shift once (to add a 0)
	RRX	R2, R2			; rotate once with carry (to put the 31st bit back)
	EOR	R2, #0xB0000000
	STR 	R2, [R10, #0x20]
	
	LDMFD	R13!,{R1, R2, R15}



; The Interrupt Service Routine MUST be in the startup file for simulation to work correctly
;*------------------------------------------------------------------- 
; Interrupt Service Routine (ISR) for EINT3_IRQHandler 
;*------------------------------------------------------------------- 
; This ISR handles the interrupt triggered when the INT0 push-button is pressed 
; with the assumption that the interrupt activation is done in the main program
EINT3_IRQHandler 	
	STMFD 	R13!, {R14}	 
		
	; clear the cause of the interrupt using IO2IntClr (IO 2INTerrupt CLearR)
	; do NOT disable the interrupt input
	MOV 	R12, #0
	LDR 	R7, =IO2INTCLR 		; Clear Interrupt
	MOV 	R5, #0x400		; 10th bit is 1
	STR	R5, [R7]
		
	; generate a new random number, scale it, store it in R6
	BL 	RANDOM_NUM
		
	LDMFD 	R13!, {R15}  


;*-------------------------------------------------------------------
; Below is a list of useful registers with their respective memory addresses.
;*------------------------------------------------------------------- 
LED_BASE_ADR	EQU 	0x2009c000 				; Base address of the memory that controls the LEDs 
PINSEL3			EQU 	0x4002C00C 			; Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002C010 			; Pin Select Register 4 for P2[15:0]
FIO1DIR			EQU		0x2009C020 		; Fast Input Output Direction Register for Port 1 
FIO2DIR			EQU		0x2009C040 		; Fast Input Output Direction Register for Port 2 
FIO1SET			EQU		0x2009C038 		; Fast Input Output Set Register for Port 1 
FIO2SET			EQU		0x2009C058 		; Fast Input Output Set Register for Port 2 
FIO1CLR			EQU		0x2009C03C 		; Fast Input Output Clear Register for Port 1 
FIO2CLR			EQU		0x2009C05C 		; Fast Input Output Clear Register for Port 2 
IO2IntEnf		EQU		0x400280B4		; GPIO Interrupt Enable for port 2 Falling Edge 
ISER0			EQU		0xE000E100		; Interrupt Set-Enable Register 0 
IO2INTCLR		EQU		0x400280AC		; Interrupt Port 2 Clear Register

				ALIGN 

				END
