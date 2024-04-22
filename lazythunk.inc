
; instance and device lazy thunk
;	- requires function vector table to be writable
;	+ only updates functions along runtime path
;
; TODO: limit data generation to used functions. Currently, the instance and
; device function lists need to be updated with used commands - it'd be better
; to just include them all.
;
;🟪🟥🟧🟨🟩🟦🟩🟨🟧🟥🟪🟥🟧🟨🟩🟦🟩🟨🟧🟥🟪🟥🟧🟨🟩🟦🟩🟨🟧🟥🟪

section '.data$t' data readable writeable align 64
iterate function,\
\; prior to instance creation these global commands are dispatchable
	vkCreateInstance,\
	vkEnumerateInstanceVersion,\; 1.1
	vkEnumerateInstanceExtensionProperties,\
	vkEnumerateInstanceLayerProperties,\
\; valid instance MUST be used to dispatch these
	vkDestroyInstance,\
	vkGetDeviceProcAddr,\
\; VK_EXT_debug_report
	vkCreateDebugReportCallbackEXT,\
	vkDebugReportMessageEXT,\
	vkDestroyDebugReportCallbackEXT

	calminstruction function line&
		arrange line, =fastcall [=instance.=function], line
		assemble line
	end calminstruction

	if % = 1
		instance.FunctionTable:
		repeat %%
			indx %
			instance.function dq instance.lazythunk
		end repeat
		instance.StringTable:
		repeat %%
			dq .% ; required to mirror function pointers
		end repeat
		indx 1
	end if
	.% db `function,0
end iterate

iterate function,\
	vkBuildAccelerationStructuresKHR

	calminstruction function line&
		arrange line, =fastcall [=device.=function], line
		assemble line
	end calminstruction

	if % = 1
		device.FunctionTable:
		repeat %%
			indx %
			device.function dq device.lazythunk
		end repeat
		device.StringTable:
		repeat %%
			dq .% ; required to mirror function pointers
		end repeat
		indx 1
	end if
	.% db `function,0
end iterate

;🟪🟥🟧🟨🟩🟦🟩🟨🟧🟥🟪🟥🟧🟨🟩🟦🟩🟨🟧🟥🟪🟥🟧🟨🟩🟦🟩🟨🟧🟥🟪
section '.text$t' code readable executable align 64
instance.lazythunk:
	mov eax, [rsp]		; return address
	push rcx rdx r8 r9

	mov ecx, [rax-4]	; call offset
	add eax, ecx		; pointer needing update

	mov ecx, instance.FunctionTable
	sub ecx, eax
	neg ecx
	mov edx, [instance.StringTable + rcx]

	push rax
	enter 40, 0
	:vkGetInstanceProcAddr [instance], rdx
	leave

	pop rcx
	mov [rcx], rax

	pop r9 r8 rdx rcx
	jmp rax

align 64;, codepad #
device.lazythunk:
	mov eax, [rsp]		; return address
	push rcx rdx r8 r9

	mov ecx, [rax-4]	; call offset
	add eax, ecx		; pointer needing update

	mov ecx, device.FunctionTable
	sub ecx, eax
	neg ecx
	mov edx, [device.StringTable + rcx]

	push rax
	enter 40, 0
	vkGetDeviceProcAddr [device], rdx
	leave

	pop rcx
	mov [rcx], rax

	pop r9 r8 rdx rcx
	jmp rax
