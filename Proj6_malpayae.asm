TITLE Project 6 - String Primitives and Macros      (Proj6_malpayae.asm)

; Author:	Eva Malpaya
; Last Modified:	3/14/2021
; OSU email address: malpayae@oregonstate.edu
; Course number/section:   CS271 Section 401
; Project Number:	6                Due Date:	3/14/2021
; Description: This program prompts the user to enter numbers to be
; entered into an array, validates the input, then displays the array.
;
; Note: 'array' and 'list' may be used interchangeably in my comments

INCLUDE Irvine32.inc

;--------------------------------------
; 
; preconditions:	
; postconditions:	
; receives:			prompt (ref), count (val)
; returns:			userInput (ref), bytesRead (ref)
;--------------------------------------
mGetString MACRO prompt, count

	; Display a prompt

	; Get user's keyboard input into a memory location

	;

ENDM


;--------------------------------------
; 
; preconditions:	
; postconditions:	
; receives:			string (ref)
; returns:			
;--------------------------------------
mDisplayString MACRO string

	; Display a prompt

	; Get user's keyboard input into a memory location

	;

ENDM

; Required constants
LO = 10			; 7 to 12		; 10 default
HI = 29			; 27 to 32		; 29 default
ARRAYSIZE = 200 ; 180 to 220	; 200 default

.data

prog_title			BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures ",13,10,0
author				BYTE	"Written by: Eva Malpaya ",13,10,0
;ec_1				BYTE	"**EC: Program aligns the output columns.",13,10,0	; ec = extra credit
prompt_intro		BYTE	13,10,"Please provide 10 signed decimal integers. ",13,10
					BYTE	"Each number needs to be small enough to fit inside a 32 bit register. ",13,10
					BYTE	"After you have finished inputting the raw numbers I will display ",13,10
					BYTE	"a list of the integers, their sum, and their average value. ",13,10,13,10,0
prompt				BYTE	"Please enter a signed number:  ",13,10
prompt_again		BYTE	"Please try again: ",13,10
display				BYTE	"You entered the following numbers: ",13,10
display_sum			BYTE	"The sum of these numbers is: ",13,10
display_avg			BYTE	"The rounded average is: ",13,10
goodbye				BYTE	13,10,"Thanks for playing!  ",0
count				DWORD	?

.code
main PROC
	; Introduce the program
	PUSH	OFFSET prog_title
	PUSH	OFFSET author
	CALL	introduction

	; Get 10 valid integers from the user
	mGetString	prompt, count


	; Store these numeric values in an array


	; Calculate the sum


	; Calculate the average


	; Display the integers, their sum, and their average
	mDisplayString, string


	; Say goodbye
	PUSH	OFFSET goodbye
	CALL	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;--------------------------------------
; Introduces the program title and programmer's name, introduces
; the program itself, and displays the extra credit print statements 
; (if necessary).
; preconditions:	intro1, intro2 are strings
; postconditions:	EDX changed changed but restored
; receives:			intro1, intro2
; returns:			none
;--------------------------------------
introduction PROC
	PUSH	EBP
	MOV		EBP, ESP
	; preserve registers
	PUSH	EDX		

	; Introduce the program title and programmer's name
	MOV		EDX, [EBP+12]
	CALL	WriteString

	; Introduce the program
	MOV		EDX, [EBP+8]
	CALL	WriteString

	; Display the extra credit print statements 
	; N/A this project

	; restore registers
	POP		EDX		
	POP		EBP
	RET		8
introduction ENDP


;--------------------------------------
; 
;
; preconditions:	
; postconditions:	
; receives:			userInput (ref)
; returns:			
;--------------------------------------
ReadVal PROC

	; Invoke mGetString to get user input in form of string of digits


	; Convert string of ascii digits to numeric value rep (SDWORD),
	; validating user input as valid (no letters, symbols, etc)


	; Store value in memory variable 

	RET
ReadVal ENDP


;--------------------------------------
; 
;
; preconditions:	
; postconditions:	userInput (val)
; receives:			
; returns:			
;--------------------------------------
WriteVal PROC

	; Convert numeric SDWORD value to string of ascii digits


	; Invoke mDisplayString macro to print ascii rep of SDWORD value to output

	RET
WriteVal ENDP



;--------------------------------------
; Displays a parting message
;
; preconditions:	goodbye is a string that contains a farewell message
; postconditions:	EDX changed changed but restored
; receives:			goodbye
; returns:			none; prints to terminal only
;--------------------------------------
farewell PROC
	PUSH	EBP
	MOV		EBP, ESP
	; preserve registers
	PUSH	EDX

	MOV		EDX, [EBP+8]
	CALL	WriteString

	; restore registers
	POP		EDX
	POP		EBP
	RET
farewell ENDP


END main
