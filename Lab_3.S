.section .text
.align 2
.globl _start


// -------------------------------------------------------------------------------------
// Name:        Lab_3.S
// Purpose:     This code has 2 parts: the first part is to create a simple counter
//              subroutine that increments from 0x00 to 0xFF, wraps to 0 and continues
//              counting.  There is a 100ms delay between the display of the count. 
//		The second part is a reflex meter that will measure how fast
//              a user responds to an event accurate to a 10th of a millisecond.
//              Initially, all LED's are off and after a random amount of time
//              (between 2 and 10 seconds), one LED turns on (LED_6) and then the user
//		presses pushbutton S1.  The press of the button will be monitored by
//		using "polling".
//
// Author:      Julius Olajos
// -------------------------------------------------------------------------------------


_start:

// -------------------------------------------------------------------------------------
// GPIO Control Registers Memory Mapping

    .equ GPIO_BASE_CTRL_ADDR, 0x10012000    // Base address for the GPIO control registers
    .equ GPIO_OUTPUT_EN,      0x08          // address offset for enabling GPIO outputs
    .equ GPIO_OUTPUT_VAL,     0x0C          // Address offset for writing to GPIO outputs
    .equ GPIO_OUTPUT_XOR,     0x40          // Address offset for GPIO Outputs XOR
    .equ GPIO_INPUT_VAL,      0x00          // Address offset for reading GPIO inputs
    .equ GPIO_INPUT_EN,       0x04          // address offset for enabling GPIO inputs
    .equ GPIO_PUE,            0x10          // address offset for internal GPIO pull-up resistor

// -------------------------------------------------------------------------------------
// 8 LEDS, 7 Segment LED Display Pins Register Address Mapping

    .equ GPIO_7SEGLED_PINS,   0x0000023F      // Seven Segment LED Display Pins (7)
    .equ GPIO_LEDBAR_PINS,    0x00FC0C00      // LED Bar Pins (8)
    .equ GPIO_ALL_LED_PINS,   0x00FC0E3F      // All LED Pins (15)
    .equ GPIO_LEDBAR_LED_1,   0x00000800      // LEDBAR LED1

// -------------------------------------------------------------------------------------
// Pushbuttons SW(x) Register Address Mapping

    .equ GPIO_SW_1,           0x00001000      // SW1 pushbutton (bit 12)
    .equ GPIO_SW_2,           0x00002000      // SW2 Pushbutton (bit 13)
    .equ GPIO_ALL_PBS,        0x00003000      // All Pushbutton Pins (bits 12, 13)

// Initialize the GPIO control registers
// -------------------------------------------------------------------------------------

    li t0, GPIO_BASE_CTRL_ADDR          // Load Base Address for GPIO Control Registers
    li t1, GPIO_ALL_LED_PINS            // Load GPIO Register to set GPIO_OUTPUT_EN and GPIO_OUTPUT_XOR registers for all GPIO LED Pins
    sw t1, GPIO_OUTPUT_EN(t0)           // Enable outputs on all GPIO LED Pins
    li t2, 0xFF03F1C0
    sw t2, GPIO_OUTPUT_VAL(t0)          // Set all LED pins to zero to turn off all LEDS.
    li t1, GPIO_SW_1                    // Load GPIO Register to set GPIO_INPUT_EN for input pins
    sw t1, GPIO_INPUT_EN(t0)            // Enable inputs on all Pushbutton pins

// -------------------------------------------------------------------------------------


INITIAL:

// Initialize random number generator
 	li a7, 0xABCD                   // Initializes register a7 to a 16-bit non-zero value and NOTHING else can write to a7 !!!!

    // Counter
    li s0, 1000 // 100 ms
    li s1, 0xFF // max num
    li s3, 0 // counter
    jal ra, COUNTER
    beq x0, x0, INITIAL

COUNTER:


//   --------------- Place your code here for the 00 - FF counter here ---------------
    addi sp, sp, -8
    sw ra, 4(sp)

    li a0, 0 // count
    jal ra, COUNTER_HELPER

    lw ra, 4(sp)
    addi sp, sp, 8
    ret

COUNTER_HELPER:
    addi sp, sp, -8
    sw ra, 4(sp)

    sw a0, 0(sp)
    bnez s3, COUNTER_DISPLAY_SKIP
    jal ra, DISPLAY_NUM // display a0

COUNTER_DISPLAY_SKIP:
    jal ra, DELAY
    lw a0, 0(sp)
    addi a0, a0, 1
    ble a0, s1, COUNTER_HELPER

    lw ra, 4(sp)
    addi sp, sp, 8
    ret




// -------------------------------------------------------------------------------------

loop:
//  Generate random number
    jal ra, RandomNum

//  Once your number has been generated, it will be stored in register a7. Do not overwrite this!
//  You will now need to set up delays, subroutines to turn the LED ON and OFF, and for polling whether the Pushbutton S1 has been pressed.
//  Keep in mind that you will get a 32-bit number back from the random number generator.  You will need to display this 8 bits at a time,
//  starting with the lowest 8 bits.
//  You will probably want to rotate 8 bits at a time for display.



//   --------------- Place your code here ----------------------------------------



DISPLAY:    

// Display the 32-bit number on the 8-LED Bar

// Register t1 holds the value of the number to be displayed
// Map each bit of the number to the corresponding LED Bar bit
// MSB to LSB: bits 23, 22, 21, 20, 19, 18, 11, 10
//

DISPLAY_HELPER_1:
    slli a1, a0, 16 // shift bits left until bit 2 - 7 are aligned to 18 - 23
    andi a2, a1, 0x0FC00000 // sets bits 18-23 according to 3-8

    slli a1, a0, 10 // shifts bits 0-1  to align to 10-11
    andi a1, a1, 0xC00
    or a0, a1, a2 // sets a0 to be the joining of a1 and a2
    ret

DISPLAY_HELPER_2:
    slli a1, a0, 16 // shift bits left until bit 2 - 7 are aligned to 18 - 23
    andi a2, a1, 0x0FC00000 // sets bits 18-23 according to 3-8

    slli a1, a0, 10 // shifts bits 0-1  to align to 10-11
    andi a1, a1, 0xC00
    or a0, a1, a2 // sets a0 to be the joining of a1 and a2
    ret

DISPLAY_HELPER_3:
    slli a1, a0, 16 // shift bits left until bit 2 - 7 are aligned to 18 - 23
    andi a2, a1, 0x0FC00000 // sets bits 18-23 according to 3-8

    slli a1, a0, 10 // shifts bits 0-1  to align to 10-11
    andi a1, a1, 0xC00
    or a0, a1, a2 // sets a0 to be the joining of a1 and a2
    ret

DISPLAY_HELPER_4:
    slli a1, a0, 16 // shift bits left until bit 2 - 7 are aligned to 18 - 23
    andi a2, a1, 0x0FC00000 // sets bits 18-23 according to 3-8

    slli a1, a0, 10 // shifts bits 0-1  to align to 10-11
    andi a1, a1, 0xC00
    or a0, a1, a2 // sets a0 to be the joining of a1 and a2
    ret

DISPLAY_NUM:
      addi sp, sp, -16
      sw ra, 12(sp)


// Remember, the 8 LEDS are mapped to the GPIO as bits MSB to LSB: bits 23, 22, 21, 20, 19, 18, 11, 10



//   --------------- Place your code here for displaying the 8-bit values --------------- 
      jal ra, DISPLAY_HELPER_1 // maps a0 into GPIO bits stored in a0
      sw a0, GPIO_OUTPUT_VAL(t0) // display num

      lw ra, 12(sp)
      addi sp, sp, 16
      ret

// Random Number generator
// Register a7 holds the random number.
// You can read this value anywhere in the code, but this register can only be written to by this subroutine
// Or Else!

RandomNum:
     addi sp, sp, -16
     sw ra, 12(sp)


     li s4, 0x8000		     // Load upper 20 bits
     and t1, a7, s4  		     // Mask to lower 16 bits
     li s4, 0x2000  		     // Load upper 20 bits
     and t3, a7, s4  		     // Mask to lower 16 bits


     slli t3, t3, 2
     xor t3, t1, t3
     li s4, 0x1000  		     // Load upper 20 bits
     and t1, a7, t0		     // Mask to lower 16 bits

     slli t1, t1, 3
     xor t3, t3, t1
     andi t1, a7, 0x0400
     slli t1, t1, 5
     xor t3, t3, t1
     srli t3, t3, 15
     slli a7, a7, 1
     or a7, a7, t3		     // Register a7 holds the random number

     lw ra, 12(sp)
     addi sp, sp, 16
     ret

RandomNumScale:
    // idea is to map 65535 into 8 seconds
    // 1 second = 8192 nums
    // 1 ms = 8 nums
    // for each 8 nums do .1ms 
    // add 2 seconds to it

DELAY:
    addi sp, sp, -16
    sw ra, 12(sp)
	

//   --------------- Place your code here for the various delays and timers --------------- 
    // s0 is delay time in 0.1ms
    // 0.1ms = 800 cycles
    mv a0, s0
    li a1, 800
    mul a0, a0, a1

    jal ra, DELAY_HELPER
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

DELAY_HELPER:
    addi a0, a0, -1
    bnez a0, DELAY_HELPER

    ret