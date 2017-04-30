# Keil MCB1700 Board with LPC1768 MCU (by NXP)

### Lab 1
*Objective*  
The objective of this lab is to complete, assemble and download a simple assembly language program. Here is a short list of what you will do in this session:
  - Write some THUMB assembly language instructions
  - Use different memory addressing modes
  - Test and debug the code on the Keilboard
  - The on-board RAM is used instead of Flash memory You will flash an LED (Light Emitting Diode) at an approximate 1 Hz frequenqy


### Lab 2
*Objective*  
In structured programming, big tasks are broken into small routines. A short program is written for each routine. The main program calls these short subroutines. In most cases when a subroutine is called, some information, parameters, must be communicated between the main program and the subroutine. This is called parameter passing. In this lab, you will use subroutines and parameter passing by implementing a Morse code system.

*What you do*  
In this lab you will turn one LED into a Morse code transmitter. You will cause one LED to blink in Morse code for a five character word. The LED mustbe turned on and off with specifiedtime delaysuntil all characters are communicated.

### Lab 3
*Objective*  
The objective of this lab is to learn how to use peripherals (LEDs, switch) connected to a microprocessor. 
The ARM CPU is connected to the outside world using Ports and in this lab you will setup, and use,
Input and Output ports.

*What you do*  
In this lab you will measure how fast a user responds (reflex-meter) to an 
event accurate to a 10thof a millisecond. Initially all LEDs are off and after a random amount of time (between 2 to 10 seconds),
one LED turns on and then the user presses the push button. Between the two events of ‘Turning the LED on’ and 
‘Pressing the push button’, a 32 bit counter is incremented every 10thof a millisecond in a loop. 
The final value of this 32 bit number willbe sent to the 8 LEDs in separate bytes with a 2 second delay between them.


### Lab 4
*Objective*  
The objective of this lab is to learn about interrupts. You will enable an interrupt source in the LPC1768 microprocessor, 
and write an interrupt service routine (ISR) that is triggered when pressing the INT0 button.  The ISR returnsto the main 
program after handling the interrupt.

*What you do*  
The random number generator from lab-3 will be reconfigured to generate a number which gives a time delay of 5.0 to 25.0 
seconds with a resolution of 0.1s. Once the program is started a random integer is generated and stored in R6. The main 
program then displays this (without a decimal so that 5.6 seconds displays as 56 in binary) on the 8 LEDs. The program 
delays one second.  Then the count in R6 is decrement by the equivalent of 1 second (10) and the new count (time left) 
displayed.  This continues. When the count would go to 0 or less, all decrementing should stop and all LEDs flash on and 
off (at 1 second rate is fine but 10Hz is better). The interrupt service routine, triggered by INT0 being pressed, generates 
a new random number, scales it and stores it in R6. The main program exits the flashing loop if necessary and counts the new 
random number down.
