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
mGetString MACRO mPrompt, mUserInput, mCount, mBytesRead
	; Display a prompt
	mDisplayString mPrompt

	; Get user's keyboard input into a memory location
	;MOV		EDI, userInput
	;MOV		AL,0
	;STOSB	
	MOV		EDX, mUserInput
	MOV		ECX, mCount
	CALL	ReadString
	MOV		mUserInput, EDX
	;MOV		EDI, userInput
	;MOV		AL, 0
	;STOSB
	MOV		mBytesRead, EAX

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
COUNT =		33		; length of input string can accomodate
;ARRAYSIZE = 10		; Number of valid integers to get from user
ARRAYSIZE = 5		; debug only

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
list_delim			BYTE	", ",0
array				SDWORD	ARRAYSIZE DUP(?)
userInput			BYTE	ARRAYSIZE DUP(33)
bytesRead			DWORD	0
numInt				SDWORD	0	; the string converted to a number
sum					SDWORD	0
avg					SDWORD	0

.code
main PROC
	; Introduce the program
	PUSH	OFFSET prog_title
	PUSH	OFFSET author
	CALL	introduction

	; Get 10 valid integers from the user
	LEA		EDI, numInt	
	PUSH	EDI					;44
	PUSH	OFFSET error		;40
	PUSH	OFFSET array		;36
	PUSH	OFFSET userInput	;32
	PUSH	bytesRead			;28
	PUSH	COUNT				;24
	PUSH	ARRAYSIZE			;20
	PUSH	OFFSET prompt_intro	;16
	PUSH	OFFSET prompt		;12
	PUSH	OFFSET prompt_again	;8
	CALL	testProgram


	; Store these numeric values in an array


	; Calculate the sum
	PUSH	sum					;16
	PUSH	OFFSET array		;12
	PUSH	ARRAYSIZE			;8
	CALL	calculateSum


	; Calculate the average
	PUSH	avg					;16
	PUSH	OFFSET array		;12
	PUSH	ARRAYSIZE			;8
	CALL	calculateAvg
	


	; Display the integers, their sum, and their average
	;mDisplayString display
	PUSH	OFFSET list_delim	;36
	PUSH	OFFSET display		;32
	PUSH	OFFSET display_sum	;28
	PUSH	OFFSET display_avg	;24
	PUSH	OFFSET array		;20
	PUSH	ARRAYSIZE			;16
	PUSH	sum					;12	
	PUSH	avg					;8
	CALL	displayResults


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
testProgram PROC
	PUSH	EBP
	MOV		EBP, ESP
	; preserve registers	
	PUSH	EAX		
	PUSH	EBX		
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI

	MOV		ECX, [EBP+20]	; array length into ECX
	MOV		EDI, [EBP+36]	; Address of array into EDI

	; Display the prompt intro
	mDisplayString [EBP+16]	;prompt_intro

	; Get 10 valid integers from the user.
	MOV		ECX, [EBP+20]	;ARRAYSIZE
_fillLoop:
	;PUSH	ECX

	PUSH	[EBP+44]		;32	;numInt
	PUSH	[EBP+8]			;28	;prompt_again
	PUSH	[EBP+40]		;24	;error
	PUSH	[EBP+12]		;20	;prompt
	PUSH	[EBP+24]		;16	;COUNT
	PUSH	[EBP+32]		;12	;userInput
	PUSH	[EBP+28]		;8	;bytesRead
	CALL	ReadVal

	; debug only
	;MOV		EDI, [EBP+32]
	;MOV		EAX, [EDI]
	;CALL	WriteDec
	;CALL	CrLf

	;POP		ECX

	; move the validated value into the array
	;MOV		EDI, [EBP+36]	; Address of array into EDI
	MOV		ESI, [EBP+44]	; address of numInt into ESI
	MOV		EAX, [ESI]		; numInt into EAX
	MOV		[EDI], EAX		; EAX into EDI
	ADD		EDI, 4			; Move into next spot in the array
	MOV		EAX, 0
	MOV		[ESI], EAX		; reset numInt to 0

	LOOP	_fillLoop
	

	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	POP		EBP
	RET		40
testProgram ENDP

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
	PUSH	ESI
	PUSH	EDI

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

	; if this point is reached, string is valid
	JMP		_stringIsValid

_sizeInvalid:
	MOV		isValid, 0
_notifyInvalid:
	mDisplayString [EBP+24]			;error
	;MOV		isValid, 1				;reset checker

	; reset userInput
	;PUSH	[EBP+8]					;12	;bytesRead
	;PUSH	[EBP+12]				;8	;userInput
	;CALL	resetString

	JMP		_startLoop

_stringIsValid:

; convert to SDWORD
	MOV		ECX, [EBP+8]	; String length into ECX
	;INC		ECX			; Account for null-terminator
	MOV		ESI, [EBP+12]	; Address of userInput into ESI

	MOV		EDI, [EBP+32]	; numInt
	;MOV		EAX, 1
	;MOV		[EDI], EAX
	
_convertLoop:				; For numChar in numString
	LODSB	; Puts byte in AL

	; check if signed
	PUSH	EAX				; preserve AL before first char check

	MOV		EAX, ECX
	CMP		EAX, 0
	JE		_potentialSign
	JMP		_isNumber


	; check first character if it's not a number
_potentialSign:
	POP		EAX				; restore AL before first char check

	; check if plus sign
	CMP		AL, 43			;+
	JE		_continueConvert

	; check if negative sign
	CMP		AL, 45			;-
	JE		_continueConvert
	JMP		_startConvert

	; check if characters are numbers
_isNumber:
	POP		EAX				; restore AL before first char check

	; confirmed not trying to convert a sign character at this point1
_startConvert:
	; do something with AL
	SUB		AL, 48
	MOVSX	EBX, AL

	MOV		EAX, [EDI]		; move numInt into EAX
	IMUL	EAX, 10			; multiply numInt by 10

	ADD		EAX, EBX		; Add these two together to update numInt
	MOV		[EDI], EAX		; store resulting integer in numInt
_continueConvert:
	LOOP	_convertLoop	; repeat for length of string

	;MOV		EAX, [EDI]		; mov numInt into EAX
	;MOV		ESI, [EBP+12]	; mov userInput into ESI
	;MOV		[ESI], EAX		; mov numInt into userInput? Why?

	; reset userInput
	;PUSH	[EBP+8]					;12	;bytesRead
	;PUSH	[EBP+12]				;8	;userInput
	;CALL	resetString

	
	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	;POP		EBP					; Handled by LOCAL dir
	RET		28
ReadVal ENDP

;--------------------------------------
; 
; (if necessary).
; preconditions:	
; postconditions:	
; receives:			aString, stringLength,
; returns:			
;--------------------------------------
resetString PROC
	PUSH	EBP
	MOV		EBP, ESP

	; preserve registers
	PUSH	EAX		
	PUSH	EBX		
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI

	MOV		AL, 0
	MOV		EDI, [EBP+8]		; aString
	MOV		ECX, [EBP+12]		; stringLength
	REP		STOSB
;_resetLoop:
	;STOSB						; move 0 from AL into userInpug
	;REP
	;LOOP	_resetLoop


	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	POP		EBP			; Handled by LOCAL dir
	RET		8
resetString ENDP


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
	RET		12
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
	; Create local variables
	LOCAL	string[33]:	BYTE	; placeholder in string
	LOCAL	number: DWORD	; placeholder for number

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

	; Convert numeric SDWORD value to string of ascii digits
	MOV		EAX, 0
	MOV		EAX, [EBP+8]	
	MOV		number, EAX

	; Prep local variable to hold the converted string
	;MOV		EAX, OFFSET string
	;MOV		EDI, EAX
	;XOR		EDI, EDI
	LEA			EDI, string


_startNumberConversion:
	MOV		ECX, 99
	MOV		EAX, number		; divide by 10

	; not sign character at this point
_isANumberLoop:
	MOV		EBX, 10
	CDQ
	IDIV	EBX

	;PUSH	EAX				; save quotient for next character
	MOV		EBX, EAX

	MOV		EAX, EDX
	ADD		EAX, 48			; add 48 
	;MOV		AL, AX		; add to string
	STOSB					
	;LEA		EDX, string			; debug only
	;CALL	WriteString			; debug only
	;POP		EAX				; restore quotient
	MOV		EAX, EBX

	CMP		EAX, 0
	JE		_noMoreLoops
	JMP		_continueIsANumber

_noMoreLoops:
	MOV		ECX, 1

_continueIsANumber:
	LOOP	_isANumberLoop


	; check sign
	MOV		EAX, number
	CMP		EAX, 0
	JGE		_isPositive
	JMP		_isNegative

_isPositive:
	MOV		AL, 43			;+
	STOSB
	;LEA		EDX, string			; debug only
	;CALL	WriteString			; debug only
	JMP		_addNullTerminator

_isNegative:
	MOV		AL, 45			;-
	;LEA		EDX, string			; debug only
	;CALL	WriteString			; debug only
	STOSB

_addNullTerminator:
	; add null-terminator
	MOV		AL, 0
	STOSB

	; reverse the string

	; print the ascii representation
	LEA		EDX, string			; debug only
	;CALL	WriteString			; debug only
	mDisplayString EDX


_endOfWriteVal:
	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	;POP		EBP			; Handled by LOCAL dir
	RET		4
WriteVal ENDP

;--------------------------------------
; 
; (if necessary).
; preconditions:	
; postconditions:	
; receives:			
; returns:			
;--------------------------------------
calculateSum PROC
	PUSH	EBP
	MOV		EBP, ESP
	; preserve registers	


	; restore registers
	POP		EBP
	RET		12
calculateSum ENDP

;--------------------------------------
; 
; (if necessary).
; preconditions:	
; postconditions:	
; receives:			
; returns:			
;--------------------------------------
calculateAvg PROC
	PUSH	EBP
	MOV		EBP, ESP
	; preserve registers	


	; restore registers
	POP		EBP
	RET		12
calculateAvg ENDP

;--------------------------------------
; Traverses an array and prints out its values with a space
; in-between each number.
;
; preconditions:	someArray is a DWORD array the size of ARRAYSIZE,
;					ARRAYSIZE is the size of the array,
;					someTitle contains a string
; postconditions:	EAX, EBX, ECX, EDX changed but restored
; receives:			someTitle, someArray, ARRAYSIZE 
; returns:			none; output to terminal only
;--------------------------------------
printArray PROC
	PUSH	EBP
	MOV		EBP, ESP

	; preserve registers
	PUSH	EAX		
	PUSH	EBX		
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI

	; Access the list
	MOV		ECX, [EBP+8]	; List length into ECX
	MOV		ESI, [EBP+12]	; Address of list into EDI


	; traverse the list and print each number
	; with a space in-between. Prints new line
	; every 20 numbers
_displayLoop:
	MOV		EAX, [ESI]		; Print out a number in the list
	;CALL	WriteDec		; debug only
	PUSH	EAX				;8
	CALL	WriteVal

	;MOV		AL, 44
	;STOSB
	;MOV		EDX, [EBP+16]
	mDisplayString [EBP+16]		; print out a comma ;44
	;MOV		AL, 32
	;LEA		EDI, EAX
	;mDisplayString EDI		; print out a space ;32

	ADD		ESI, 4			; Move to the next element in list
	LOOP	_displayLoop

	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	POP		EBP			
	RET		12
printArray ENDP


;--------------------------------------
; 
; (if necessary).
; preconditions:	
; postconditions:	
; receives:			
; returns:			
;--------------------------------------
displayResults PROC
	PUSH	EBP
	MOV		EBP, ESP
	; preserve registers	
	PUSH	EAX		
	PUSH	EBX		
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI

	; Display the integers
	mDisplayString [EBP+32]
	PUSH	[EBP+36]	;16	;list_delim
	PUSH	[EBP+20]	;12	;array
	PUSH	[EBP+16]	;8	;ARRAYSIZE
	CALL	printArray


	; Display the sum
	mDisplayString [EBP+28]

	; Display the average
	mDisplayString [EBP+24]

	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	POP		EBP
	RET		32
displayResults ENDP

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
