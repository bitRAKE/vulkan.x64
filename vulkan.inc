format MS64 COFF
include 'win64a.inc'
include 'coffms_ext.inc' ; extension/external helper

struc(NAME) array? items&
	local elems
	label NAME:elems
	iterate item, items
		if % = 1 ; lead with pointer array
			elems := %%
			repeat %%
				dq .%
			end repeat
		end if
		.% item
	end iterate
end struc

macro __chkstk reg0*,GUARD_SIZE:4096 ; touch/probe to commit stack
	local try,more
	jmp try
more:	sub rsp, GUARD_SIZE
	sub reg0, GUARD_SIZE
	mov [rsp], reg0
try:	cmp reg0, GUARD_SIZE
	jnc more
	sub rsp, reg0
	and spl,-16 ; ABI requirement
end macro


struc VK_MAKE_API_VERSION variant, major, minor, patch
	. = ((variant) shl 29)	\
	or ((major) shl 22)	\
	or ((minor) shl 12)	\
	or (patch)
end struc
VK_API_VERSION_1_0 VK_MAKE_API_VERSION 0,1,0,0

include 'vulkan-1.g'
