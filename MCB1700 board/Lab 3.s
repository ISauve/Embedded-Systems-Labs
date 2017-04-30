;*-------------------------------------------------------------------
;* Name:    	lab_3_program.s 
;* Purpose: 	input/output interfacing
;*-------------------------------------------------------------------
				THUMB 		; Thumb instruction set 
                AREA 		My_code, CODE, READONLY
                EXPORT 		__MAIN
				ENTRY  
__MAIN

; The following lines are similar to Lab-1 but use a defined address to make it easier.
; They just turn off all LEDs 
				LDR			R10, =LED_BASE_ADR		; R10 is a permenant pointer to the base address for the LEDs, offset of 0x20 and 0x40 for the ports

				MOV 		R3, #0xB0000000		; Turn off three LEDs on port 1  
				STR 		R3, [r10, #0x20]
				MOV 		R3, #0x0000007C
				STR 		R3, [R10, #0x40] 	; Turn off five LEDs on port 2 


; to test the delay loop - run 1000000 times - light should turn off after 10s
				;MOV 		R0, #0x86A0
				;MOVT		R0, #0x1
				;BL			DELAY
				;; turn back on
				;MOV 		R3, #0xA0000000 
				;STR 		R3, [R10, #0x20]		; Turn on the three LEDs on port 1
				
; to run the counter subroutine
				;BL 			COUNT

; This line is very important in your main program
; Initializes R11 to a 16-bit non-zero value and NOTHING else can write to R11 !!
				MOV			R11, #0xABCD		; Init the random number generator with a non-zero number
				BL 			RandomNum 		

				; R11 holds our randomly generated number - call delay for this length
				MOV		R0, R11
				BL		DELAY
				
				MOV 	R3, #0x90000000		; Turn on LED P.29
				STR 	R3, [R10, #0x20]
				
				; Initialize P2.10 as an input (INTO button)
				MOV		R6, #0x00
				STRB	R6, [R10, #0x41]
				LDR 	R9, =FIO2PIN
				
				MOV		R4, #0				; set counter to 0
increment		MOV 	R0, #1				; increment once every 0.1ms
				BL		DELAY
				ADD		R4, R4, #1
				
				; check if INTO button is pressed
				LDR		R6, [R9]
				MOV		R7,	#0x3B83
				TEQ		R6, R7				; value if the button is pressed
				BEQ		dispReflex			; if it is pressed, exit loop
				
				B		increment
			
dispReflex			
				MOV 	R3, R4
				
				BL		DISPLAY_NUM			; display bits 0-7
				MOV		R0, #20000			; wait 2 seconds
				BL 		DELAY
				
				LSR		R3, #8				
				BL		DISPLAY_NUM			; display bits 8-15
				MOV		R0, #20000			; wait 2 seconds
				BL 		DELAY
				
				LSR		R3, #8
				BL		DISPLAY_NUM			; display bits 16-23
				MOV		R0, #20000			; wait 2 seconds
				BL 		DELAY
				
				LSR		R3, #8
				BL		DISPLAY_NUM			; display bits 24-31
				MOV		R0, #20000			; wait 2 seconds
				BL 		DELAY
				
				MOV		R0, #50000			; wait 5 seconds
				BL 		DELAY
				B dispReflex


;; SUBROUTINES

; Display the number in R3 onto the 8 LEDs
DISPLAY_NUM		STMFD		R13!,{R1, R2, R14}
		; Send bits 0-4 to Port 2
		AND		R1, R3, #0x1F		; isolate the bits
		RBIT	R1, R1				; flip the contents of the register
		LSR		R1, #25				; shift them into position
		EOR     R1, #0x007c			; flip the bits (because active-low)
		STR 	R1, [R10, #0x40]
		
		; Send bits 5-7 to Port 1
		AND		R2, R3, #0xE0
		RBIT	R2, R2
		LSL		R2, #5				; shift into position
		; shift bits 29 and 30 left 1 (leave 31 where it is)
		LSLS	R2, #1				; left shift once (to get the 31st bit into the carry)
		LSR		R2, #1				; right shift once (to add a 0)
		RRX		R2, R2				; rotate once with carry (to put the 31st bit back)
		EOR		R2, #0xB0000000
		STR 	R2, [R10, #0x20]
	
		LDMFD		R13!,{R1, R2, R15}


; R11 holds a 16-bit random number via a pseudo-random sequence as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R11 holds a non-zero 16-bit number.  If a zero is fed in the pseudo-random sequence will stay stuck at 0
; Take as many bits of R11 as you need.  If you take the lowest 4 bits then you get a number between 1 and 15.
;   If you take bits 5..1 you'll get a number between 0 and 15 (assuming you right shift by 1 bit).
;
; R11 MUST be initialized to a non-zero 16-bit value at the start of the program OR ELSE!
; R11 can be read anywhere in the code but must only be written to by this subroutine
RandomNum		STMFD		R13!,{R1, R2, R3, R14}

				AND			R1, R11, #0x8000
				AND			R2, R11, #0x2000
				LSL			R2, #2
				EOR			R3, R1, R2
				AND			R1, R11, #0x1000
				LSL			R1, #3
				EOR			R3, R3, R1
				AND			R1, R11, #0x0400
				LSL			R1, #5
				EOR			R3, R3, R1		; the new bit to go into the LSB is present
				LSR			R3, #15
				LSL			R11, #1
				ORR			R11, R11, R3
				
				; scale & add an offset to get correct range
				AND 		R11, R11, #0xF	; isolate 4 bits to get a number from 0-15
				LSR			R11, R11, #1	; divide by 2 to get a range of 0 - 7.5
				ADD			R11, R11, #1	; add 2 to get a range of 2 - 9.5
				MOV			R9, #10000		; multiply by 10 000 to convert to from 0.1 ms -> 1s
				MUL			R11, R11, R9	; final range is 2-9.5s
				
				LDMFD		R13!,{R1, R2, R3, R15}



;		Delay 0.1ms (100us) * R0 times (aim for better than 10% accuracy)
DELAY			STMFD		R13!,{R2, R14}
MultipleDelay
		TEQ		R0, #0			; test R0 to see if it's 0 - set Zero flag so you can use BEQ, BNE	
		BEQ 	exitDelay		; if R0 = 0, exit
		MOV		R2, #0x83		; set counter
DelayLoop
		SUBS 	R2, #1 			; Decrement counter and set the N,Z,C status bits
		BNE		DelayLoop		; Loop back if Z=0 (if R0!=0)
		
		SUBS 	R0, #1
		B 		MultipleDelay	; loop back up (in case we have to delay more than once)
exitDelay		LDMFD		R13!, {R2, R15}
			
			
			

;		Counts from 0-255, writes to LEDs w/ 1 delay between numbers
COUNT			STMFD		R13!,{R3, R14}
		MOV		R3, #0x0			; Initialize a counter at 0
DispLoop
		BL		DISPLAY_NUM
		ADD		R3, R3, #1
		MOV		R0, #1000			; run delay once
		BL 		DELAY
		B		DispLoop




LED_BASE_ADR	EQU 	0x2009c000 		; Base address of the memory that controls the LEDs 
PINSEL3			EQU 	0x4002c00c 		; Address of Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002c010 		; Address of Pin Select Register 4 for P2[15:0]
;	Usefull GPIO Registers
;	FIODIR  - register to set individual pins as input or output
;	FIOPIN  - register to read and write pins
;	FIOSET  - register to set I/O pins to 1 by writing a 1
;	FIOCLR  - register to clr I/O pins to 0 by writing a 1
FIO2PIN			EQU		0x2009C054

				ALIGN 

				END 


;; 		LAB REPORT
; Prove time delay meets 2-10s +/- 5% spec

; The random num subroutine puts a random 16 bit number in R11, and as per the
; description given we took the bottom 4 bits to get a number from 0-16. Then we
; scaled it by half and added an offset of 2 to get a range of 2-9.5. Finally we
; multiplied this number by 10 000 to turn this from 0.1 ms to s.
; Using this method we're ensured to be within the 2-10s spec, with a max error of 0.5s
; (because our max is 9.5 instead of 10) which is a max error 5% as required.

	; scale & add an offset to get correct range
		AND 		R11, R11, #0xF	; isolate 4 bits to get a number from 0-15
		LSR			R11, R11, #1	; divide by 2 to get a range of 0 - 7.5
		ADD			R11, R11, #1	; add 2 to get a range of 2 - 9.5
		MOV			R9, #10000		; multiply by 10 000 to convert to from 0.1 ms -> 1s
		MUL			R11, R11, R9	; final range is 2-9.5s


; Questions
; 1. 8 bits: max value is 255 so max amount of time = 255 * 0.1ms = 25.5 ms
;	 16 bits: max = 65 535 -> max time = 65535 * 0.1ms = 6553.5 ms
;	 24 bits: max = 16 777 215 -> max time = 16777215 * 0.1 ms = 1677721.5 ms
;	 32 bits: max = 4 294 967 295 -> max time = 4294967295 * 0.1 ms = 429496729.5 ms
;
; 2. Average reaction time = approx 0.25s (250ms) so 16 bits is best

