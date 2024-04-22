
; This reaches beyond the 01_debug_report.asm example in a number of way:
;  + debugging is enabled beyond instance creation/termination.
;  + debug reporting has been modularized - into an external OBJ.
;  + lazy thunking is being used to access all vulkan commands at runtime.

; Prior to enabling the SDK validation layers, we can produce custom debug
; reporting for the creation/termination process. VkDebugReport* is an older
; interface but includes many of the same features of VkDebugUtilsMessenger*.

include 'vulkan.inc'
include 'lazythunk.inc'
section '.text$t' code readable executable align 64

extrn debug_report_callback:QWORD

public mainCRTStartup ; linker expects this for CONSOLE subsystem
mainCRTStartup: fastcall?.frame = 0
	pop rax
	:GetStdHandle dword STD_OUTPUT_HANDLE
	mov [createDbgReportInfo.pUserData], rax
	mov [hConOut],rax

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
	flags:	VK_DEBUG_REPORT_INFORMATION_BIT_EXT or\
		VK_DEBUG_REPORT_WARNING_BIT_EXT or\
		VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT or\
		VK_DEBUG_REPORT_ERROR_BIT_EXT or\
		VK_DEBUG_REPORT_DEBUG_BIT_EXT,\
	pfnCallback: debug_report_callback
