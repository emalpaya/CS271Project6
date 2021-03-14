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
; receives:			prompt, userInput, count, bytesRead
; returns:			userInput, bytesRead updated
;--------------------------------------
mGetString MACRO prompt, userInput, count, bytesRead
	; Display a prompt
	mDisplayString prompt

	; Get user's keyboard input into a memory location
	MOV		EDX, userInput
	MOV		ECX, count
	CALL	ReadString
	MOV		userInput, EDX
	MOV		bytesRead, EAX

ENDM


;--------------------------------------
; 
; preconditions:	
; postconditions:	
; receives:			string (ref)
; returns:			
;--------------------------------------
mDisplayString MACRO string
	PUSH	EDX
	MOV		EDX, string
	CALL	WriteString
	POP		EDX

ENDM

; Required constants
COUNT =		31		; length of input string can accomodate
ARRAYSIZE = 10		; Number of valid integers to get from user

.data
prog_title			BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures ",13,10,0
author				BYTE	"Written by: Eva Malpaya ",13,10,0
;ec_1				BYTE	"**EC: Program aligns the output columns.",13,10,0	; ec = extra credit
prompt_intro		BYTE	13,10,"Please provide 10 signed decimal integers. ",13,10
					BYTE	"Each number needs to be small enough to fit inside a 32 bit register. ",13,10
					BYTE	"After you have finished inputting the raw numbers I will display ",13,10
					BYTE	"a list of the integers, their sum, and their average value. ",13,10,13,10,0
prompt				BYTE	"Please enter a signed number:  ",0
error				BYTE	"ERROR: You did not enter an signed number or your number was too big. ",13,10,0
prompt_again		BYTE	"Please try again: ",0
display				BYTE	13,10,"You entered the following numbers: ",13,10,0
display_sum			BYTE	"The sum of these numbers is: ",13,10,0
display_avg			BYTE	"The rounded average is: ",13,10,0
goodbye				BYTE	13,10,"Thanks for playing!  ",0
array				DWORD	ARRAYSIZE DUP(?)
userInput			BYTE	?
bytesRead			DWORD	0

.code
main PROC
	; Introduce the program
	PUSH	OFFSET prog_title
	PUSH	OFFSET author
	CALL	introduction

	; Get 10 valid integers from the user
	PUSH	OFFSET error		;40
	PUSH	array				;36
	PUSH	OFFSET userInput	;32
	PUSH	bytesRead			;28
	PUSH	COUNT				;24
	PUSH	ARRAYSIZE			;20
	PUSH	OFFSET prompt_intro	;16
	PUSH	OFFSET prompt		;12
	PUSH	OFFSET prompt_again	;8
	CALL	getNumbers


	; Store these numeric values in an array


	; Calculate the sum


	; Calculate the average


	; Display the integers, their sum, and their average
	;mDisplayString display


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
; postconditions:	
; receives:			intro1, intro2
; returns:			none
;--------------------------------------
introduction PROC
	PUSH	EBP
	MOV		EBP, ESP
	; preserve registers	

	; Introduce the program title
	mDisplayString [EBP+12]

	; Introduce the programmer's name
	mDisplayString [EBP+8]

	; Display the extra credit print statements 

	; restore registers
	POP		EBP
	RET		8
introduction ENDP

;--------------------------------------
; 
; (if necessary).
; preconditions:	
; postconditions:	
; receives:			
; returns:			
;--------------------------------------
getNumbers PROC
	PUSH	EBP
	MOV		EBP, ESP
	; preserve registers	
	PUSH	ECX

	; Display the prompt intro
	mDisplayString [EBP+16]	;prompt_intro

	; Get 10 valid integers from the user.
	MOV		ECX, [EBP+20]	;ARRAYSIZE
_fillLoop:
	PUSH	ECX
	PUSH	[EBP+8]			;28	;prompt_again
	PUSH	[EBP+40]		;24	;error
	PUSH	[EBP+12]		;20	;prompt
	PUSH	[EBP+24]		;16	;COUNT
	PUSH	[EBP+32]		;12	;userInput
	PUSH	[EBP+28]		;8	;bytesRead
	CALL	ReadVal
	POP		ECX
	LOOP	_fillLoop
	

	; restore registers
	POP		ECX
	POP		EBP
	RET		40
getNumbers ENDP

;--------------------------------------
; 
; (if necessary).
; preconditions:	
; postconditions:	
; receives:			
; returns:			
;--------------------------------------
ReadVal PROC
	; Create local variables
	LOCAL	isValid:	DWORD	; bool for character validation

	; Handled by LOCAL dir
	;PUSH	EBP
	;MOV		EBP, ESP
	
	; preserve registers	
	PUSH	EAX		
	PUSH	EBX		
	PUSH	ECX
	PUSH	EDX

	; initialize local variables
	MOV		isValid, 1

_startLoop:
	; Invoke myGetString macro to get user input in form of string of digits
	;prompt, userInput, count, bytesRead

	MOV		EAX, isValid
	CMP		EAX, 0
	JE		_getStringAgain
	JMP		_getString

_getStringAgain:
	mGetString [EBP+28], [EBP+12], [EBP+16], [EBP+8]
	JMP		_continueStartLoop
_getString:
	mGetString [EBP+20], [EBP+12], [EBP+16], [EBP+8]

	; if string is too large, automatically set as invalid
	MOV		EAX, [EBP+8]
	CMP		EAX, 4
	JG		_sizeInvalid

_continueStartLoop:
	;PUSH	[isValid]				;16	
	LEA		EDI, isValid
	PUSH	EDI						;16
	PUSH	[EBP+8]					;12	;bytesRead
	PUSH	[EBP+12]				;8	;userInput
	CALL	validate

	; if input is invalid, display error message
	MOV		EAX, isValid
	CMP		EAX, 0
	JE		_notifyInvalid

	; if this point is reached, string is valid; jump to end
	JMP		_stringIsValid

_sizeInvalid:
	MOV		isValid, 0
_notifyInvalid:
	mDisplayString [EBP+24]			;error
	;MOV		isValid, 1				;reset checker
	JMP		_startLoop

_stringIsValid:

	; restore registers
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	;POP		EBP					; Handled by LOCAL dir
	RET		24
ReadVal ENDP


;--------------------------------------
; 
; (if necessary).
; preconditions:	
; postconditions:	
; receives:			
; returns:			
;--------------------------------------
validate PROC
	; Create local variables
	LOCAL	index:	DWORD	; placeholder in string

	; Handled by LOCAL dir
	;PUSH	EBP
	;MOV		EBP, ESP

	; preserve registers
	PUSH	EAX		
	PUSH	EBX		
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI

	; initialize local variables
	MOV		index, 0

	MOV		ECX, [EBP+12]	; String length into ECX
	INC		ECX				; Account for null-terminator
	MOV		ESI, [EBP+8]	; Address of string into ESI

	MOV		EDI, [EBP+16]	; Reset bool value
	MOV		EAX, 1
	MOV		[EDI], EAX


_validateLoop:	
	LODSB	; Puts byte in AL

	; check if signed
	PUSH	EAX				; preserve AL before first char check

	MOV		EAX, index
	CMP		EAX, 0
	JE		_checkSign
	JMP		_checkNumber


	; check first character if it's not a number
_checkSign:
	POP		EAX				; restore AL before first char check

	; check if plus sign
	CMP		AL, 43			;+
	JE		_isValidChar

	; check if negative sign
	CMP		AL, 45			;-
	JE		_isValidChar
	JMP		_continueCheck

	; check if characters are numbers
_checkNumber:
	POP		EAX				; restore AL before first char check

_continueCheck:
	; check if end of string
	CMP		AL, 0
	JE		_endOfString

	CMP		AL, 48			;0
	JL		_invalidChar
	CMP		AL, 57			;9
	JG		_invalidChar
	JMP		_isValidChar

_isValidChar:
	INC		index
	STOSB
	LOOP	_validateLoop
	JMP		_endOfString

_invalidChar:
	MOV		EDI, [EBP+16]
	MOV		EAX, 0
	MOV		[EDI], EAX

	MOV		EDX, [EBP+16]
	CALL	WriteDec

	;LEA		EAX, [EBP+16]
	;MOV		EAX, 0

	;MOV		EAX, [EBP+16]
	;MOV		EAX, [EDI]
	;CALL	WriteDec

_endOfString:
	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	;POP		EBP			; Handled by LOCAL dir
	RET		16
validate ENDP


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
