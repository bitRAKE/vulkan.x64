
; Enumerating extensions

include 'vulkan.inc'
include 'lazythunk.inc'
section '.text$t' code readable executable align 64

extrn debug_report_callback:QWORD

enum_inst_ext: fastcall?.frame = 0
	virtual at rbp - .local
		.buffer rb 1024 ; wsprintfA restriction
		.local := $ - $$
	end virtual
	virtual at rbp + 16
		.count dd ?
		assert $-$$ < 33 ; don't exceed shadow-space
	end virtual
	enter .frame + .local, 0

	vkEnumerateInstanceExtensionProperties 0, addr .count, 0
	test eax, eax
	jnz .error

	imul eax, [.count], sizeof VkExtensionProperties ; 260
	__chkstk rax ; touch/probe

	lea r8, [rsp + .frame]
	vkEnumerateInstanceExtensionProperties 0, addr .count, r8
	test eax, eax ; VK_SUCCESS
	jz .good
	cmp eax, VK_INCOMPLETE
	jnz .error
	; don't keep looking, accept what has been written
.good:
	dec [.count] ; allow for zero
	js .done

	imul edx, [.count], sizeof VkExtensionProperties ; 260
	virtual at rsp + rdx + .frame
		.vk_ext VkExtensionProperties
	end virtual
	mov r8d, [.vk_ext.specVersion]
	lea r9, [.vk_ext.extensionName]
	:wsprintfA addr .buffer, addr .template, r8, r9
	xchg r8, rax ; bytes to message
	:WriteFile [hConOut], addr .buffer, r8, 0, 0
	jmp .good
.done:
.error:
	leave
	retn
	.frame := fastcall?.frame

.template db '%d',9,'%s',10,0



public mainCRTStartup ; linker expects this for CONSOLE subsystem
mainCRTStartup: fastcall?.frame = 0
	pop rax
	:GetStdHandle dword STD_OUTPUT_HANDLE
	mov [createDbgReportInfo.pUserData], rax
	mov [hConOut],rax


	call enum_inst_ext


	vkCreateInstance dword createInfo, nullptr, dword instance
	xchg ecx,eax
	jrcxz @F

	int3 ; to debugger
@@:
	; persistent debug callback outside of instance creation/termination
	vkCreateDebugReportCallbackEXT [instance],\
		dword createDbgReportInfo, nullptr, dword hDbgReportCallback
	test eax, eax
	jnz @F

; now debugging is active
; device

	vkDestroyDebugReportCallbackEXT [instance], [hDbgReportCallback], nullptr
@@:
	vkDestroyInstance [instance], nullptr
	:ExitProcess rcx ; VK_SUCCESS
	assert fastcall?.frame <= 8*4 ; don't exceed shadow space

;🟪🟥🟧🟨🟩🟦🟩🟨🟧🟥🟪🟥🟧🟨🟩🟦🟩🟨🟧🟥🟪🟥🟧🟨🟩🟦🟩🟨🟧🟥🟪

section '.data$t' data readable writeable align 64

hConOut dq ? ; HANDLE
instance dq ? ; VkInstance
device dq ? ; VkDevice
hDbgReportCallback dq ? ; VkDebugReportCallbackEXT


appName db "Hello Triangle",0
appVersion VK_MAKE_API_VERSION 0,1,0,0

engineName db "No Engine",0
engineVersion VK_MAKE_API_VERSION 0,1,0,0

align 8
appInfo VkApplicationInfo\
	sType: VK_STRUCTURE_TYPE_APPLICATION_INFO,\
	pApplicationName: appName,\
	applicationVersion: appVersion,\
	pEngineName: engineName,\
	engineVersion: engineVersion,\
	apiVersion: VK_API_VERSION_1_0

instExtensions array\
	<db "VK_EXT_debug_report",0> ; legacy debugging features

instLayers array\
	<db "VK_LAYER_KHRONOS_validation",0>
;	<db "VK_LAYER_LUNARG_api_dump",0>

align 8
createInfo VkInstanceCreateInfo\
	sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,\
	pApplicationInfo: appInfo,\
	enabledExtensionCount: sizeof instExtensions,\
	ppEnabledExtensionNames: instExtensions,\
	enabledLayerCount: sizeof instLayers,\
	ppEnabledLayerNames: instLayers,\
	pNext: createDbgReportInfo

align 8
; old VK_EXT_debug_report method (deprecated)
createDbgReportInfo VkDebugReportCallbackCreateInfoEXT\
	sType: VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT,\
	flags:	VK_DEBUG_REPORT_ERROR_BIT_EXT or\
		VK_DEBUG_REPORT_DEBUG_BIT_EXT,\
	pfnCallback: debug_report_callback
