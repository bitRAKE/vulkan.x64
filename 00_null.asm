
; minimal needed to create a vulkan instance
; version 1.0 api is assumed

include 'vulkan.inc'
section '.text$t' code readable executable align 64

public mainCRTStartup ; linker expects this for CONSOLE subsystem
mainCRTStartup: fastcall?.frame = 0
	pop rax

	:vkCreateInstance dword create_info, nullptr, dword instance
	xchg ecx,eax
	jrcxz @F

	int3 ; to debugger
@@:
	:vkDestroyInstance [instance], nullptr
	:ExitProcess rcx ; VK_SUCCESS
	assert fastcall?.frame <= 8*4 ; don't exceed shadow space


section '.data$t' data readable writeable align 64

	instance dq ? ; VkInstance

	align 8
	create_info VkInstanceCreateInfo\
		sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
