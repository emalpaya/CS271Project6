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
;				[EBP+28], [EBP+12], [EBP+16], [EBP+8]
mGetString MACRO mPrompt, mUserInput, mCount, mBytesRead
	; Display a prompt
	mDisplayString mPrompt

	; Get user's keyboard input into a memory location
	MOV		EDX, mUserInput
	MOV		ECX, mCount
	CALL	ReadString
	MOV		mUserInput, EDX
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
COUNT =		32		; length of input string can accomodate
ARRAYSIZE = 10		; Number of valid integers to get from user
;ARRAYSIZE = 1		; debug only

.data
prog_title			BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures ",13,10,0
author				BYTE	"Written by: Eva Malpaya ",13,10,0
ec1					BYTE	"**EC: Program numbers user input lines & displays running subtotal. ",13,10,0	; ec = extra credit
ec2					BYTE	"**EC: Program implements ReadVal and WriteVal for floating point values, using the FPU. ",13,10,0	; ec = extra credit
prompt_intro		BYTE	13,10,"Please provide 10 signed decimal integers. ",13,10
					BYTE	"Each number needs to be small enough to fit inside a 32 bit register. ",13,10
					BYTE	"After you have finished inputting the raw numbers I will display ",13,10
					BYTE	"a list of the integers, their sum, and their average value. ",13,10,13,10,0
prompt				BYTE	"Please enter a signed number:  ",0
error				BYTE	"ERROR: You did not enter an signed number or your number was too big. ",13,10,0
prompt_again		BYTE	"Please try again: ",0
display				BYTE	13,10,"You entered the following numbers: ",13,10,0
display_sum			BYTE	"The sum of these numbers is: ",0
display_avg			BYTE	"The rounded average is: ",0
goodbye				BYTE	13,10,"Thanks for playing!  ",0
list_delim			BYTE	", ",0
space				BYTE	" ",0
line				BYTE	"Line ",0
colon				BYTE	": ",0
subtotal			BYTE	"Subtotal: ",0
array				SDWORD	ARRAYSIZE DUP(?)
userInput			BYTE	ARRAYSIZE DUP(33)
bytesRead			DWORD	0
numInt				SDWORD	0	; the string converted to a number
sum					SDWORD	0
avg					SDWORD	0
;;;;;;; EXTRA CREDIT 2 THINGS BELOW
ec2_title			BYTE	13,10,". . . . . . . . .",13,10
					BYTE	13,10,"!!!BONUS ROUND!!! ",13,10
					BYTE	13,10,". . . . . . . . .",13,10
					BYTE	13,10,"You have reached the EXTRA CREDIT 2 portion of the program. ",13,10
					BYTE	13,10,"Please provide 10 signed decimal floating point values. ",13,10
					BYTE	"Each number needs to be small enough to fit inside a 32 bit register. ",13,10
					BYTE	"After you have finished inputting the raw numbers I will display ",13,10
					BYTE	"a list of the values, their sum, and their average value. ",13,10,13,10,0
numFPU				REAL10	0.0
arrayFPU				REAL10	ARRAYSIZE DUP(?)

.code
main PROC
	; Introduce the program
	PUSH	OFFSET ec2			;20
	PUSH	OFFSET ec1			;16
	PUSH	OFFSET prog_title	;12
	PUSH	OFFSET author		;8
	CALL	introduction

	; Get 10 valid integers from the user
	PUSH	OFFSET subtotal		;60	;ec
	PUSH	OFFSET colon		;56
	PUSH	OFFSET line			;52 ;ec
	PUSH	OFFSET space		;48	
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


	; Calculate the sum
	LEA		EDI, sum
	PUSH	EDI
	;PUSH	sum					;16
	PUSH	OFFSET array		;12
	PUSH	ARRAYSIZE			;8
	CALL	calculateSum


	; Calculate the average
	PUSH	sum					;20
	LEA		EDI, avg
	PUSH	EDI
	;PUSH	avg					;16
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
	CALL	CrLf

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EXTRA CREDIT 2 PORTION BELOW
;;;;;;;;;;;;;;;;;;;;;;;;;

		; Introduce the program
	PUSH	OFFSET ec2_title	;8
	CALL	ec_introduction

	; Get 10 valid integers from the user
	LEA		EDI, numFPU	
	PUSH	EDI					;44
	PUSH	OFFSET error		;40
	PUSH	OFFSET arrayFPU		;36
	PUSH	OFFSET userInput	;32
	PUSH	bytesRead			;28
	PUSH	COUNT				;24
	PUSH	ARRAYSIZE			;20
	PUSH	OFFSET prompt_intro	;16
	PUSH	OFFSET prompt		;12
	PUSH	OFFSET prompt_again	;8
	CALL	ec_testProgram


	; Calculate the sum
	;LEA		EDI, sum
	;PUSH	EDI					;16
	;PUSH	OFFSET array		;12
	;PUSH	ARRAYSIZE			;8
	;CALL	ec_calculateSum


	; Calculate the average
	;PUSH	sum					;20
	;LEA		EDI, avg
	;PUSH	EDI
	;PUSH	OFFSET array		;12
	;PUSH	ARRAYSIZE			;8
	;CALL	ec_calculateAvg
	


	; Display the integers, their sum, and their average
	;mDisplayString display
	;PUSH	OFFSET list_delim	;36
	;PUSH	OFFSET display		;32
	;PUSH	OFFSET display_sum	;28
	;PUSH	OFFSET display_avg	;24
	;PUSH	OFFSET array		;20
	;PUSH	ARRAYSIZE			;16
	;PUSH	sum					;12	
	;PUSH	avg					;8
	;CALL	ec_displayResults


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
	mDisplayString [EBP+16]
	mDisplayString [EBP+20]

	; restore registers
	POP		EBP
	RET		16
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
	; Create local variables
	LOCAL	lineNumber: DWORD
	LOCAL	subTotalSum: DWORD

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
	MOV		lineNumber, 1
	MOV		subTotalSum, 0

	MOV		ECX, [EBP+20]	; array length into ECX
	MOV		EDI, [EBP+36]	; Address of array into EDI

	; Display the prompt intro
	mDisplayString [EBP+16]	;prompt_intro

	; Get 10 valid integers from the user.
	MOV		ECX, [EBP+20]	;ARRAYSIZE
_fillLoop:
	;PUSH	ECX

	;PUSH	OFFSET subtotal		;60
	;PUSH	OFFSET colon		;56
	;PUSH	OFFSET line			;52
	;PUSH	OFFSET space		;48	

	;EXTRA CREDIT 1
	mDisplayString [EBP+52]		;line
	PUSH	lineNumber
	CALL	WriteVal
	mDisplayString [EBP+56]		;colon

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
	;CALL	WriteInt		; debug only
	MOV		[EDI], EAX		; EAX into EDI
	ADD		EDI, 4			; Move into next spot in the array

	; EXTRA CREDIT 1
	ADD		subTotalSum, EAX
	mDisplayString [EBP+60]		;subtotal
	PUSH	subTotalSum
	CALL	WriteVal
	CALL	CrLf

	MOV		EAX, 0
	MOV		[ESI], EAX		; reset numInt to 0


	INC		lineNumber		; EXTRA CREDIT 1
	LOOP	_fillLoop
	

	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	;POP		EBP
	RET		56
testProgram ENDP

;--------------------------------------
; 
; (if necessary).
; preconditions:	
; postconditions:	
; receives:			
; returns:			-
;--------------------------------------
ReadVal PROC
	; Create local variables
	LOCAL	isValid:	DWORD	; bool for character validation
	LOCAL	isNegative:	DWORD

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
	MOV		isNegative, 0

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

	;;;;;;debug
		; Display a prompt
	;mDisplayString [EBP+20]

	; Get user's keyboard input into a memory location
	;MOV		EDX, [EBP+12]
	;MOV		ECX, [EBP+16]
	;CALL	ReadString
	;MOV		[EBP+12], EDX
	;MOV		[EBP+8], EAX
	;;;;;;end debug

	; if string is too large, automatically set as invalid
	MOV		EAX, [EBP+8]
	CMP		EAX, 4
	JG		_sizeInvalid
	; if string empty, automatically set as invalid
	CMP		EAX, 0
	JE		_sizeInvalid


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
	MOV		EAX, 0
	MOV		[EDI], EAX
	;MOV		EAX, 1
	;MOV		[EDI], EAX
	
_convertLoop:				; For numChar in numString
	LODSB	; Puts byte in AL

	; check if signed
	;PUSH	EAX				; preserve AL before first char check

	;MOV		EAX, ECX
	;CMP		EAX, 0
	;JE		_potentialSign
	;JMP		_isNumber


	; check first character if it's not a number
_potentialSign:
	;POP		EAX				; restore AL before first char check

	; check if plus sign
	CMP		AL, 43			;+
	JE		_continueConvert

	; check if negative sign
	CMP		AL, 45			;-
	JE		_isNeg
	JMP		_startConvert

_isNeg:
	MOV		isNegative, 1
	JMP		_continueConvert

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

	CMP		isNegative, 1
	JE		_makeNeg
	JMP		_endReadVal

_makeNeg:
	MOV		EAX, [EDI]
	IMUL	EAX, -1
	MOV		[EDI], EAX		; store resulting integer in numInt

	;MOV		EAX, [EDI]		; mov numInt into EAX
	;MOV		ESI, [EBP+12]	; mov userInput into ESI
	;MOV		[ESI], EAX		; mov numInt into userInput? Why?

	; reset userInput
	;PUSH	[EBP+8]					;12	;bytesRead
	;PUSH	[EBP+12]				;8	;userInput
	;CALL	resetString

_endReadVal:	

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
	;CALL	WriteDec	; debug only

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
; postconditions:	number (val)
; receives:			
; returns:			
;--------------------------------------
WriteVal PROC
	; Create local variables
	LOCAL	string[33]:	BYTE	; placeholder in string
	LOCAL	reverseString[33]: BYTE	;placeholder for reversed string
	LOCAL	number: DWORD	; placeholder for number
	LOCAL	byteCounter: DWORD

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

	MOV		byteCounter, 0

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
	CMP		EAX, 0
	JL		_negNegative
	JMP		_isANumberLoop

_negNegative:
	NEG		EAX

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
	INC		byteCounter
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
	;MOV		AL, 43			;+
	;STOSB
	;INC		byteCounter
	;LEA		EDX, string			; debug only
	;CALL	WriteString			; debug only
	JMP		_addNullTerminator

_isNegative:
	MOV		AL, 45			;-
	;LEA		EDX, string			; debug only
	;CALL	WriteString			; debug only
	STOSB
	INC		byteCounter

_addNullTerminator:
	; add null-terminator
	MOV		AL, 0
	STOSB
	INC		byteCounter

	; reverse the string
	; Adapted from StringManipulator.asm demo video (retrieved March 2021):
	  MOV	ECX, byteCounter
	  LEA	ESI, string
	  ADD	ESI, ECX
	  DEC	ECX
	  DEC	ESI
	  DEC	ESI
	  LEA	EDI, reverseString

	; Reverse string
_revLoop:
	STD
	LODSB
	CLD
	STOSB
	LOOP	_revLoop

	; add null-terminator
	MOV		AL, 0
	STOSB

	; print the ascii representation
	LEA		EDX, reverseString			; debug only
	;CALL	WriteString			; debug only
	mDisplayString EDX

	; debug only
	;LEA		EDX, string			; debug only
	;CALL	WriteString			; debug only
	;mDisplayString EDX


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


	;PUSH	sum					;16
	;PUSH	OFFSET array		;12
	;PUSH	ARRAYSIZE			;8
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
	PUSH	EAX		
	PUSH	EBX		
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI


	; calculate
	MOV		ESI, [EBP+12]	;array
	MOV		ECX, [EBP+8]	;ARRAYSIZE
	MOV		EDI, [EBP+16]
	MOV		EAX, [EDI]	;sum

_sumLoop:
	MOV		EBX, [ESI]
	ADD		EAX, EBX			; add value in the array to sum
	ADD		ESI, TYPE SDWORD	; point to next element in the array
	LOOP	_sumLoop

	;MOV		[EBP+16], EAX
	;MOV		EAX, [EBP+16]	; debug only
	;CALL	WriteInt		; debug only

	MOV		EDI, [EBP+16]
	MOV		[EDI], EAX

	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	POP		EBP
	RET		12
calculateSum ENDP


	;PUSH	sum					;20
	;PUSH	avg					;16
	;PUSH	OFFSET array		;12
	;PUSH	ARRAYSIZE			;8
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
	PUSH	EAX		
	PUSH	EBX		
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI


	; calculate the average
	MOV		EAX, [EBP+20]
	MOV		EBX, [EBP+8]
	CDQ
	IDIV	EBX

	; if the average is negative, round down instead.
	; Used the below link as reference for rounding 
	; negatives to 'floor' (Retrieved March 2021):
	; https://www.calculator.net/rounding-calculator.html?cnum=-321.9&cpre=0&cpren=2&cmode=nearest&sp=0&x=0&y=0
	CMP		EAX, 0
	JL		_roundDown
	JMP		_storeAverage

_roundDown:
	DEC		EAX

_storeAverage:
	MOV		EDI, [EBP+16]
	MOV		[EDI], EAX

	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	POP		EBP
	RET 16
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
	;CALL	WriteInt		; debug only
	PUSH	EAX				;8
	;CALL	WriteInt		; debug only
	CALL	WriteVal

	CMP		ECX, 1
	JE		_noDelim
	mDisplayString [EBP+16]		; print out delim character


_noDelim:
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


	;PUSH	OFFSET list_delim	;36
	;PUSH	OFFSET display		;32
	;PUSH	OFFSET display_sum	;28
	;PUSH	OFFSET display_avg	;24
	;PUSH	OFFSET array		;20
	;PUSH	ARRAYSIZE			;16
	;PUSH	sum					;12	
	;PUSH	avg					;8
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
	CALL	CrLf			; Was told can use this per Piazza question @446 discussion thread


	; Display the sum
	mDisplayString [EBP+28]
	PUSH	[EBP+12]	;8	;sum
	CALL	WriteVal
	CALL	CrLf			; Was told can use this per Piazza question @446 discussion thread

	; Display the average
	mDisplayString [EBP+24]
	PUSH	[EBP+8]		;8	;sum
	CALL	WriteVal
	CALL	CrLf			; Was told can use this per Piazza question @446 discussion thread

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EXTRA CREDIT 2 PORTION BELOW
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;--------------------------------------
; Introduces the program title and programmer's name, introduces
; the program itself, and displays the extra credit print statements 
; (if necessary).
; preconditions:	intro1, intro2 are strings
; postconditions:	
; receives:			intro1, intro2
; returns:			none
;--------------------------------------
ec_introduction PROC
	PUSH	EBP
	MOV		EBP, ESP
	; preserve registers	

	; Introduce the new part of the program
	mDisplayString [EBP+8]

	; restore registers
	POP		EBP
	RET		4
ec_introduction ENDP

;--------------------------------------
; 
; (if necessary).
; preconditions:	
; postconditions:	
; receives:			
; returns:			
;--------------------------------------
ec_testProgram PROC
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

	FINIT

	; Display the prompt intro
	mDisplayString [EBP+16]	;prompt_intro

	; Get 10 valid integers from the user.
	MOV		ECX, [EBP+20]	;ARRAYSIZE
_fillLoop:
	PUSH	[EBP+44]		;32	;numFPU
	PUSH	[EBP+8]			;28	;prompt_again
	PUSH	[EBP+40]		;24	;error
	PUSH	[EBP+12]		;20	;prompt
	PUSH	[EBP+24]		;16	;COUNT
	PUSH	[EBP+32]		;12	;userInput
	PUSH	[EBP+28]		;8	;bytesRead

	CALL	ReadFloatVal

	; move the validated value into the array
	;MOV		EDI, [EBP+36]	; Address of array into EDI
	MOV		ESI, [EBP+44]	; address of numInt into ESI
	MOV		EAX, [ESI]		; numInt into EAX
	;CALL	WriteInt		; debug only
	MOV		[EDI], EAX		; EAX into EDI
	ADD		EDI, 4			; Move into next spot in the array

	MOV		EAX, 0.0
	MOV		[ESI], EAX		; reset numFPU to 0

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
ec_testProgram ENDP

;--------------------------------------
; 
; (if necessary).
; preconditions:	
; postconditions:	
; receives:			
; returns:			-
;--------------------------------------
ReadFloatVal PROC
	; Create local variables
	LOCAL	isValidEC:	DWORD	; bool for character validation
	LOCAL	isNegativeEC:	DWORD
	LOCAL	leftFloat: REAL10	; left portion of FPU before .
	LOCAL	rightFloat: REAL10	; Right portion of FPU after .

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
	MOV		isValidEC, 1
	MOV		isNegativeEC, 0
	MOV		leftFloat, 0.0
	MOV		rightFloat, 0.0

_startLoopEC:
	; Invoke myGetString macro to get user input in form of string of digits
	;prompt, userInput, count, bytesRead

	MOV		EAX, isValidEC
	CMP		EAX, 0
	JE		_getStringAgainEC
	JMP		_getStringEC



_getStringAgainEC:
	mGetString [EBP+28], [EBP+12], [EBP+16], [EBP+8]
	JMP		_continueStartLoopEC
_getStringEC:
	mGetString [EBP+20], [EBP+12], [EBP+16], [EBP+8]

	;;;;;;debug
		; Display a prompt
	;mDisplayString [EBP+20]

	; Get user's keyboard input into a memory location
	;MOV		EDX, [EBP+12]
	;MOV		ECX, [EBP+16]
	;CALL	ReadString
	;MOV		[EBP+12], EDX
	;MOV		[EBP+8], EAX
	;;;;;;end debug

	; if string is too large, automatically set as invalid
	MOV		EAX, [EBP+8]
	CMP		EAX, 4
	JG		_sizeInvalidEC
	; if string empty, automatically set as invalid
	CMP		EAX, 0
	JE		_sizeInvalidEC


_continueStartLoopEC:
	;PUSH	[isValid]				;16	
	LEA		EDI, isValidEC
	PUSH	EDI						;16
	PUSH	[EBP+8]					;12	;bytesRead
	PUSH	[EBP+12]				;8	;userInput
	CALL	ec_validate

	; if input is invalid, display error message
	MOV		EAX, isValidEC
	CMP		EAX, 0
	JE		_notifyInvalidEC

	; if this point is reached, string is valid
	JMP		_stringIsValidEC

_sizeInvalidEC:
	MOV		isValidEC, 0
_notifyInvalidEC:
	mDisplayString [EBP+24]			;error
	;MOV		isValid, 1				;reset checker

	; reset userInput
	;PUSH	[EBP+8]					;12	;bytesRead
	;PUSH	[EBP+12]				;8	;userInput
	;CALL	resetString

	JMP		_startLoopEC

_stringIsValidEC:

; convert to REAL10
	MOV		ECX, [EBP+8]	; String length into ECX
	;INC		ECX			; Account for null-terminator
	MOV		ESI, [EBP+12]	; Address of userInput into ESI

	
	LEA		EDI, leftFloat	
	MOV		EAX, 0.0
	MOV		[EDI], EAX
	;MOV		EAX, 1
	;MOV		[EDI], EAX
	
_convertLoopLeftEC:				; For numChar in numString
	LODSB	; Puts byte in AL

	; check if signed
	;PUSH	EAX				; preserve AL before first char check

	;MOV		EAX, ECX
	;CMP		EAX, 0
	;JE		_potentialSign
	;JMP		_isNumber

	; check if period
	CMP		AL, 46			;.
	JE		_startRight



	; check first character if it's not a number
_potentialSignLeftEC:
	;POP		EAX				; restore AL before first char check

	; check if plus sign
	CMP		AL, 43			;+
	JE		_continueConvertLeftEC

	; check if negative sign
	CMP		AL, 45			;-
	JE		_isNegLeftEC
	JMP		_startConvertLeftEC

_isNegLeftEC:
	MOV		isNegativeEC, 1
	JMP		_continueConvertLeftEC

	; check if characters are numbers
_isNumberLeftEC:
	POP		EAX				; restore AL before first char check

	; confirmed not trying to convert a sign character at this point1
_startConvertLeftEC:
	; do something with AL
	FLD		[EDI]
	FLD		48.0
	FSUB
	FSTP	[EDI]

	FLD		[EDI]
	FLD		10.0
	FMUL	
	FSTP	[EDI]

	ADD		EAX, EBX		; Add these two together to update numInt
	MOV		[EDI], EAX		; store resulting integer in numInt
_continueConvertLeftEC:
	LOOP	_convertLoopEC	; repeat for length of string

	CMP		isNegativeEC, 1
	JE		_makeNegLeftEC
	JMP		_endReadValLeftEC

_makeNegLeftEC:
	MOV		EAX, [EDI]
	IMUL	EAX, -1
	MOV		[EDI], EAX		; store resulting integer in numInt

	;MOV		EAX, [EDI]		; mov numInt into EAX
	;MOV		ESI, [EBP+12]	; mov userInput into ESI
	;MOV		[ESI], EAX		; mov numInt into userInput? Why?

	; reset userInput
	;PUSH	[EBP+8]					;12	;bytesRead
	;PUSH	[EBP+12]				;8	;userInput
	;CALL	resetString

_endReadValLeftEC:	


_startRight:
	MOV		EDI, [EBP+32]	; numFPU
	MOV		EAX, 0.0
	MOV		[EDI], EAX
	;MOV		EAX, 1
	;MOV		[EDI], EAX

_convertLoopRightEC:				; For numChar in numString
	LODSB	; Puts byte in AL

	; check if signed
	;PUSH	EAX				; preserve AL before first char check

	;MOV		EAX, ECX
	;CMP		EAX, 0
	;JE		_potentialSign
	;JMP		_isNumber

	; check if period
	CMP		AL, 46			;.



	; check first character if it's not a number
_potentialSignRightEC:
	;POP		EAX				; restore AL before first char check

	; check if plus sign
	CMP		AL, 43			;+
	JE		_continueConvertRightEC

	; check if negative sign
	CMP		AL, 45			;-
	JE		_isNegRightEC
	JMP		_startConvertRightEC

_isNegRightEC:
	MOV		isNegativeEC, 1
	JMP		_continueConvertRightEC

	; check if characters are numbers
_isNumberRightEC:
	POP		EAX				; restore AL before first char check

	; confirmed not trying to convert a sign character at this point1
_startConvertRightEC:
	; do something with AL
	SUB		AL, 48
	MOVSX	EBX, AL

	MOV		EAX, [EDI]		; move numInt into EAX
	IMUL	EAX, 10			; multiply numInt by 10

	ADD		EAX, EBX		; Add these two together to update numInt
	MOV		[EDI], EAX		; store resulting integer in numInt
_continueConvertRightEC:
	LOOP	_convertLoopEC	; repeat for length of string

	CMP		isNegativeEC, 1
	JE		_makeNegRightEC
	JMP		_endReadValRightEC

_makeNegRightEC:
	MOV		EAX, [EDI]
	IMUL	EAX, -1
	MOV		[EDI], EAX		; store resulting integer in numInt

	;MOV		EAX, [EDI]		; mov numInt into EAX
	;MOV		ESI, [EBP+12]	; mov userInput into ESI
	;MOV		[ESI], EAX		; mov numInt into userInput? Why?

	; reset userInput
	;PUSH	[EBP+8]					;12	;bytesRead
	;PUSH	[EBP+12]				;8	;userInput
	;CALL	resetString

_endReadValRightEC:	

	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	;POP		EBP					; Handled by LOCAL dir
	RET		28
ReadFloatVal ENDP

;--------------------------------------
; 
; (if necessary).
; preconditions:	
; postconditions:	
; receives:			
; returns:			
;--------------------------------------
ec_validate PROC
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


_validateLoopEC:	
	LODSB	; Puts byte in AL

	; check if signed
	PUSH	EAX				; preserve AL before first char check

	MOV		EAX, index
	CMP		EAX, 0
	JE		_checkSignEC
	JMP		_checkNumberEC


	; check first character if it's not a number
_checkSignEC:
	POP		EAX				; restore AL before first char check

	; check if plus sign
	CMP		AL, 43			;+
	JE		_isValidCharEC

	; check if negative sign
	CMP		AL, 45			;-
	JE		_isValidCharEC
	JMP		_continueCheckEC

	; check if characters are numbers
_checkNumberEC:
	POP		EAX				; restore AL before first char check

_continueCheckEC:
	; check if end of string
	CMP		AL, 0
	JE		_endOfStringEC

	CMP		AL, 48			;0
	JL		_invalidCharEC
	CMP		AL, 57			;9
	JG		_invalidCharEC
	CMP		AL, 46			;.
	JNE		_invalidCharEC
	JMP		_isValidCharEC

_isValidCharEC:
	INC		index
	STOSB
	LOOP	_validateLoopEC
	JMP		_endOfStringEC

_invalidCharEC:
	MOV		EDI, [EBP+16]
	MOV		EAX, 0
	MOV		[EDI], EAX

	MOV		EDX, [EBP+16]
	;CALL	WriteDec	; debug only

	;LEA		EAX, [EBP+16]
	;MOV		EAX, 0

	;MOV		EAX, [EBP+16]
	;MOV		EAX, [EDI]
	;CALL	WriteDec

_endOfStringEC:
	; restore registers
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX		
	POP		EAX
	;POP		EBP			; Handled by LOCAL dir
	RET		12
ec_validate ENDP


END main
