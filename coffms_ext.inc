
; https://devblogs.microsoft.com/oldnewthing/20041025-00/?p=37483
extrn __ImageBase ; the linker knows
hInstance equ __ImageBase ; also used as a psuedo-handle

nullptr := 0

; TODO:
;	- fastjmp or ABI parameter abstraction

; Using a compact syntax external libraries can be referenced in a way that both includes the library and specifies the function as external. The LIBRARY file name (without the extension) is limited to the symbol naming within fasmg.
;	:LIBRARY:FUNCTION [PARAMETERS,...]
;
; The MS linker doesn't have a concept that connects an external symbol to a specific library - the first library in the search order matching the symbol halts the search. Given that the same functions are present and linked differently for different execution environments - it's often desireable to NOT specify the libraries in the object files (i.e. select the target environment at link-time).
;	:FUNCTION [PARAMETERS,...]

; Note: If feature is unused then nothing is output.
postpone
irpv lib, COFF..libraries
	if % = 1
		section '.drectve' linkinfo linkremove
	end if
	db '/DEFAULTLIB:',`lib,'.lib '
end irpv
; TODO: Specify size based on compiler mode, to allow mixing 32-bit and 64-bit code.
irpv fun, COFF..functions
	extrn `fun as fun: QWORD
end irpv
end postpone

; Use the COFF namespace to track libraries and functions.
namespace COFF
	define LIBRARIES LIBRARIES
	define FUNCTIONS FUNCTIONS
end namespace

calminstruction ?? line&
	local var, val, tmp, library, function, parameters
	match : library : function parameters?, line
	jyes lib_filter
	match : function parameters?, line
	jyes fun_filter
	assemble line
	exit
lib_filter:
	; only one instance per library
	transform library, COFF.LIBRARIES
	jyes fun_filter
	; create a case-insensative reference
	arrange var, =COFF.=LIBRARIES.library?
	; we double up to prevent forward referencing (infinite loop)
	publish var, library
	publish var, library
	; gather unique vector of uses
	take COFF..libraries, library
fun_filter:
	; only one instance per function
	transform function, COFF.FUNCTIONS
	jyes pprocess
	; create a case-sensative reference
	arrange var, =COFF.=FUNCTIONS.function
	; we double up to prevent forward referencing (infinite loop)
	publish var, function
	publish var, function
	; gather unique vector of uses, preserve function
	transform var
	take COFF..functions, var
pprocess:
	arrange line, =fastcall function,parameters
	assemble line
end calminstruction

 



