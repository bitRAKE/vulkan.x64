format MS64 COFF
include 'coffms_ext.inc'
include 'win64a.inc' ; fastcall
include 'vulkan-1.g'

; uses	user32.wvsprintfA
;	kernel32.WriteFile

; Only a single symbol is public, debug_report_callback. This is possible
; because the output handle needs to be in the pUserData member of the
; VkDebugReportCallbackCreateInfoEXT structure:
;	:GetStdHandle dword STD_OUTPUT_HANDLE
;	mov [createDbgReportInfo.pUserData], rax
;
; TODO: cache reporting state to simplify output?

public debug_report_callback

section '.text$t' code readable executable align 64

; legacy VK_EXT_debug_report method, PFN_vkDebugReportCallbackEXT function type
;
;	RCX	flags, VkDebugReportFlagsEXT
;	RDX	objectType, VkDebugReportObjectTypeEXT
;	R8	object, pointer of objectType
;	R9	location, component defined value
; +32	dd messageCode, test triggering callback, layer defined
; +40	dq pLayerPrefix, component making callback
; +48	dq pMessage, detail of trigger
; +56	dq pUserData, we didn't specify anything in the structure
debug_report_callback: fastcall?.frame = 0
	virtual at rbp - .local
		.buffer		rb 1024
	align.assume rbp, 16
	align 16
	.local := $ - $$
		dq ?, ? ; rbp, return
		dq ?, ?	; unused shadow space
		.pObjectStr	dq ?
		.pFlagStr	dq ?
		.messageCode	dd ?,?
		.pLayerPrefix	dq ?
		.pMessage	dq ?
		.pUserData	dq ?
	end virtual
	enter .frame + .local, 0

	; note: report_flags.limit is the unknown index
	mov eax, report_flags.limit

	; note: zero doesn't change EAX, clamp underflow
	bsr eax, ecx

	; clamp overflow
	mov ecx, report_flags.limit
	cmp eax, ecx
	cmovnc eax, ecx

	; lookup string
	mov eax, [report_flags + rax*4]
	mov [.pFlagStr], rax

	; resolve object type string
	cmp edx, report_object_type.simple_entries
	jc .obj_type_simple
	mov ecx, report_object_type.complex_entries
@@:	cmp [report_object_type.complex + (rcx-1)*8], edx
	loopnz @B
	cmovnz edx, ecx ; unknown object type
	jnz .obj_type_simple
	mov edx, [report_object_type.complex + (rcx-1)*8 + 4]
	jmp @F
.obj_type_simple:
	mov edx, [report_object_type + rdx*4]
@@:
	mov [.pObjectStr], rdx

	:wvsprintfA addr .buffer, dword template_report, addr .pObjectStr
	cmp eax, sizeof template_report ; expected length greater
	jna @F
	xchg r8, rax ; bytes to message
	:WriteFile [.pUserData], addr .buffer, r8, 0, 0
@@:	xor eax, eax ; always return VK_FALSE
	leave
	retn
.frame := fastcall?.frame

;:                                                                             :

section '.rdata$t' data readable align 64

label template_report:template_report.bytes
db '%s ',27,'[%s',27,'[m:%d ',\
	27,'[38;5;178m','%s',27,'[m',': ',\
	27,'[38;5;42m','%s',27,'[m',10,0
.bytes := $ - template_report

align 4
label report_flags:4
; enum VkDebugReportFlagBitsEXT values to simple string lookup
iterate _UTF8,\
	'34mINFO',\
	'33mWARN',\
	'31mPERF',\
	'91mERROR',\
	'95mDEBUG',\
	\; zero bits set or unknown bit
	'1;5;31mUNKNOWN'

	if % = 1
		.limit := %% - 1 ; 0-based indexing
		repeat %%
			dd .%
		end repeat
	end if
	.% db _UTF8,0
end iterate

align 4
label report_object_type:4
; enum VkDebugReportObjectTypeEXT values to simple string lookup
iterate <_UTF8, OBJECT>,\
	'Unknown',			VK_DEBUG_REPORT_OBJECT_TYPE_UNKNOWN_EXT,\
	'Instance',			VK_DEBUG_REPORT_OBJECT_TYPE_INSTANCE_EXT,\
	'Physical Device',		VK_DEBUG_REPORT_OBJECT_TYPE_PHYSICAL_DEVICE_EXT,\
	'Device',			VK_DEBUG_REPORT_OBJECT_TYPE_DEVICE_EXT,\
	'Queue',			VK_DEBUG_REPORT_OBJECT_TYPE_QUEUE_EXT,\
	'Semaphore',			VK_DEBUG_REPORT_OBJECT_TYPE_SEMAPHORE_EXT,\
	'Command Buffer',		VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_BUFFER_EXT,\
	'Fence',			VK_DEBUG_REPORT_OBJECT_TYPE_FENCE_EXT,\
	'Device Memory',		VK_DEBUG_REPORT_OBJECT_TYPE_DEVICE_MEMORY_EXT,\
	'Buffer',			VK_DEBUG_REPORT_OBJECT_TYPE_BUFFER_EXT,\
	'Image',			VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_EXT,\
	'Event',			VK_DEBUG_REPORT_OBJECT_TYPE_EVENT_EXT,\
	'Query Pool',			VK_DEBUG_REPORT_OBJECT_TYPE_QUERY_POOL_EXT,\
	'Buffer View',			VK_DEBUG_REPORT_OBJECT_TYPE_BUFFER_VIEW_EXT,\
	'Image View',			VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_VIEW_EXT,\
	'Shader Module',		VK_DEBUG_REPORT_OBJECT_TYPE_SHADER_MODULE_EXT,\
	'Pipeline Cache',		VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_CACHE_EXT,\
	'Pipeline Layout',		VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_LAYOUT_EXT,\
	'Render Pass',			VK_DEBUG_REPORT_OBJECT_TYPE_RENDER_PASS_EXT,\
	'Pipeline',			VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_EXT,\
	'Descriptor Set Layout',	VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT_EXT,\
	'Sampler',			VK_DEBUG_REPORT_OBJECT_TYPE_SAMPLER_EXT,\
	'Descriptor Pool',		VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_POOL_EXT,\
	'Descriptor Set',		VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_SET_EXT,\
	'Framebuffer',			VK_DEBUG_REPORT_OBJECT_TYPE_FRAMEBUFFER_EXT,\
	'Command Pool',			VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_POOL_EXT,\
	'Surface KHR',			VK_DEBUG_REPORT_OBJECT_TYPE_SURFACE_KHR_EXT,\
	'Swapchain KHR',		VK_DEBUG_REPORT_OBJECT_TYPE_SWAPCHAIN_KHR_EXT,\
	'Debug Report Callback',	VK_DEBUG_REPORT_OBJECT_TYPE_DEBUG_REPORT_CALLBACK_EXT_EXT,\
	'Display KHR',			VK_DEBUG_REPORT_OBJECT_TYPE_DISPLAY_KHR_EXT,\
	'Display Mode KHR',		VK_DEBUG_REPORT_OBJECT_TYPE_DISPLAY_MODE_KHR_EXT,\
\; search on remaining ...
	'Validation Cache',		VK_DEBUG_REPORT_OBJECT_TYPE_VALIDATION_CACHE_EXT_EXT,\
	'Sampler YCbCr Conversion',	VK_DEBUG_REPORT_OBJECT_TYPE_SAMPLER_YCBCR_CONVERSION_EXT,\
	'Descriptor Update Template',	VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_UPDATE_TEMPLATE_EXT,\
	'CU Module NVX',		VK_DEBUG_REPORT_OBJECT_TYPE_CU_MODULE_NVX_EXT,\
	'CU Function NVX',		VK_DEBUG_REPORT_OBJECT_TYPE_CU_FUNCTION_NVX_EXT,\
	'Acceleration Structure KHR',	VK_DEBUG_REPORT_OBJECT_TYPE_ACCELERATION_STRUCTURE_KHR_EXT,\
	'Acceleration Structure NV',	VK_DEBUG_REPORT_OBJECT_TYPE_ACCELERATION_STRUCTURE_NV_EXT,\
	'Cuda Module NV',		VK_DEBUG_REPORT_OBJECT_TYPE_CUDA_MODULE_NV_EXT,\
	'Cuda Function NV',		VK_DEBUG_REPORT_OBJECT_TYPE_CUDA_FUNCTION_NV_EXT,\
	'Buffer Collection Fuchsia',	VK_DEBUG_REPORT_OBJECT_TYPE_BUFFER_COLLECTION_FUCHSIA_EXT

; generate two tables: sequencial run and search rest

	if OBJECT < %
		dd .% ; sequencial run
	else
		if OBJECT = VK_DEBUG_REPORT_OBJECT_TYPE_VALIDATION_CACHE_EXT_EXT
			.simple_entries := ($ - report_object_type)/4
			.complex:
		end if
		dd OBJECT, .% ; key, value
	end if
	if % = %% ; finish with strings
		.complex_entries := ($ - .complex)/8
		repeat %%
			indx %
			.% db _UTF8,0
		end repeat
	end if
end iterate
