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



struc VK_MAKE_API_VERSION variant, major, minor, patch
	. = ((variant) shl 29)	\
	or ((major) shl 22)	\
	or ((minor) shl 12)	\
	or (patch)
end struc
VK_API_VERSION_1_0 VK_MAKE_API_VERSION 0,1,0,0

include 'vulkan-1.g'
