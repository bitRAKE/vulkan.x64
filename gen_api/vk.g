; https://registry.khronos.org/vulkan/specs/1.3/registry.html
; vk.xml conversion script by Rickey Bowers Jr. bitRAKE
;
; Revisions continue to add variablity to the API: platforms, sub-sets, ...
;
; Vulkan API is very data-centric. Any helpers that prevent using the wrong
; constants would be beneficial, or possessing a great attention to detail.
;

; FIXME: fasmg struct macro doesn't verify structure tail alignment?
; patch struct.inc:
;	if sizeof name mod alignment > 0
;		display 'warning: struct ',`name,' not aligned to its natural boundary',10
;	end if

; TODO: add _INFO structure type default value to structure definition

; TODO: option for terse API: _OPTION_TERSE_ := 1 ; (could strip them afterward)
;	- no aliases
;	- remove extensions and layer string constants (just use the strings)
;
; TODO: option to remove all comments: _OPTION_NO_COMMENTS_ := 1 ; (could strip them afterward)

_OPTION_API_ = "vulkan" ; vulkansc ; to resolve overlap

format binary as 'inc'
db 10
db ';------------------------------------------------------------------------------',10
db '; This file is auto-generated: MAKE changes in the generator!',10
db '; (Or note every change above until the generator can be updated.)',10
db ';------------------------------------------------------------------------------',10

calminstruction calminstruction?.initsym? var*, val&
	publish var, val
end calminstruction

define TYPES
define TYPES.PTR		dq ?	; change this for 32-bit
define TYPES.void		PTR	; needed for void*
define TYPES.char		db ?
define TYPES.float		dd ?
define TYPES.double		dq ?
define TYPES.int8_t		db ?
define TYPES.uint8_t		db ?
define TYPES.int16_t		dw ?
define TYPES.uint16_t		dw ?
define TYPES.uint32_t		dd ?
define TYPES.uint64_t		dq ?
define TYPES.int		dd ?
define TYPES.int32_t		dd ?
define TYPES.int64_t		dq ?
define TYPES.size_t		dq ?
; video.xml types					enum
define TYPES.StdVideoH264ChromaFormatIdc		uint32_t
define TYPES.StdVideoH264ProfileIdc			uint32_t
define TYPES.StdVideoH264LevelIdc			uint32_t
define TYPES.StdVideoH264PocType			uint32_t
define TYPES.StdVideoH264AspectRatioIdc			uint32_t
define TYPES.StdVideoH264WeightedBipredIdc		uint32_t
define TYPES.StdVideoH264ModificationOfPicNumsIdc	uint32_t
define TYPES.StdVideoH264MemMgmtControlOp		uint32_t
define TYPES.StdVideoH264CabacInitIdc			uint32_t
define TYPES.StdVideoH264DisableDeblockingFilterIdc	uint32_t
define TYPES.StdVideoH264SliceType			uint32_t
define TYPES.StdVideoH264PictureType			uint32_t
define TYPES.StdVideoH264NonVclNaluType			uint32_t

define TYPES.StdVideoH265ChromaFormatIdc		uint32_t
define TYPES.StdVideoH265ProfileIdc			uint32_t
define TYPES.StdVideoH265LevelIdc			uint32_t
define TYPES.StdVideoH265SliceType			uint32_t
define TYPES.StdVideoH265PictureType			uint32_t
define TYPES.StdVideoH265AspectRatioIdc			uint32_t
; "vk_video/vulkan_video_codec_av1std.h"
; "vk_video/vulkan_video_codec_av1std_decode.h"
define TYPES.StdVideoAV1Profile				uint32_t
define TYPES.StdVideoAV1Level				uint32_t
define TYPES.StdVideoAV1SequenceHeader			uint32_t

;--------------------------------------------------
; FIXME: minor research, verify for your use case!
;--------------------------------------------------
;	required platform types: "windows.h"
define TYPES.HINSTANCE			PTR
define TYPES.HWND			PTR
define TYPES.HMONITOR			PTR
define TYPES.HANDLE			PTR
define TYPES.SECURITY_ATTRIBUTES	PTR
define TYPES.DWORD			dd ?
define TYPES.LPCWSTR			PTR
;	required platform types: "directfb.h"
define TYPES.IDirectFB			PTR
define TYPES.IDirectFBSurface		PTR
;	required platform types: "ggp_c/vulkan_types.h"
define TYPES.GgpStreamDescriptor	uint32_t
define TYPES.GgpFrameToken		uint64_t
;	required platform types: "nvscibuf.h"
define TYPES.NvSciBufAttrList		PTR
define TYPES.NvSciBufObj		PTR
;	required platform types: "nvscisync.h"
define TYPES.NvSciSyncAttrList		PTR
define TYPES.NvSciSyncObj		PTR
define TYPES.NvSciSyncFence		PTR
;	required platform types: "screen/screen.h"
define TYPES._screen_context		PTR
define TYPES._screen_window		PTR
define TYPES._screen_buffer		PTR
;	required platform types: "wayland-client.h"
define TYPES.wl_display			PTR
define TYPES.wl_surface			PTR
;	required platform types: "X11/Xlib.h"
define TYPES.Display			PTR
define TYPES.VisualID			uint64_t ; system dependant
define TYPES.Window			uint64_t ; system dependant
;	required platform types: "X11/extensions/Xrandr.h"
define TYPES.RROutput			uint64_t ; system dependant
;	required platform types: "xcb/xcb.h"
define TYPES.xcb_connection_t		PTR
define TYPES.xcb_visualid_t		uint32_t
define TYPES.xcb_window_t		uint32_t
;	required platform types: "zircon/types.h"
define TYPES.zx_handle_t		uint32_t

define TYPES.MTLDevice_id		PTR
define TYPES.MTLCommandQueue_id		PTR
define TYPES.MTLBuffer_id		PTR
define TYPES.MTLTexture_id		PTR
define TYPES.IOSurfaceRef		PTR
define TYPES.MTLSharedEvent_id		PTR

;------------------------------------------------------------------------------

define attributes
define scope ; follow hierarchy with tag vector
define member
define type
define content ; gather content across lines
define MEMBERS ; type struct/union variable to stack

values	= 0	; enumerations, constants
types	= 0	;
structs	= 0	;

; some debug helpers:

calminstruction ShowLine line&
	match , line
	jyes skip
	stringify line
	display line
	display 10
skip:
end calminstruction
calminstruction ShowAttributes &line&
	local named,quoted
	match , line
	jyes done
more:	match named == quoted line?, line
	jno done
	stringify named
	display named
	display '='
	stringify quoted
	display quoted
	display 10
	jump more
done:
end calminstruction
calminstruction ShowContent
	local any
	match , content
	jyes skip
	match any, content
	stringify any
	display any
	display 10
skip:
end calminstruction
;	arrange line, =ShowScope
;	assemble line
macro ShowScope
irpv S, scope
	if % = %%
		display `S,10
	else
		display `S,'.'
	end if
end irpv
end macro


macro VALUE_RESOLVE name*, value*
	local char
	char = value and 0xFF
	if char = '&' ; &quot;
		virtual at 0
			db value
			load char:$-12 from 6
		end virtual
		db 'constdefine ',name,' "',char,'"',10
	else if char = '(' ; (~)
;FIXME: only single character negate
		char = (value shr 16) and 0xFF
		db name,':=-',char+1,10
	else
		db name,':=',value,10
	end if
end macro

macro EXT_NUMBER name*,extension*,offset*
	local V,v
	eval 'v=1000000000+(',extension,'-1)*1000+',offset
	repeat 1,V:v
		db name,':=',`V,10
	end repeat
end macro

; Notes:
;  + Information is mostly stored in tag attributes, but there are exceptions
; where important information is stored as "content" (i.e. between open and
; close tags). Half the tags are just wrappers around collections.
;
;


;------------------------------------------------------------------------------
;							type category routines
calminstruction type_include &line&
	local tmp,filename
	match tmp? =name == filename tmp?, line
	jyes acc
	err
acc:	arrange tmp, =INCLUDE
	publish :tmp, filename
end calminstruction

calminstruction type_define &line& ; manual conversion
end calminstruction

calminstruction type_basetype &line&
	local N,T
	match =typedef T, type.type
	jno okay
;	match tmp? N, type.name" why doesn't this work? lazy optional match?
	match N, type.name
	match =* N, type.name ; possible pointer
	arrange N, =TYPES.N
	publish N:, T
okay:
end calminstruction

calminstruction type_bitmask &line&
	local N,T,tmp
	match =typedef T, type.type
;	match tmp? =alias == tmp tmp?, line ; also works
	jno skip_aliases
	match N, type.name
	arrange N, =TYPES.N
	match tmp? =api == tmp tmp?, line
	jyes api_overwrite
	publish N:, T
	jump skip_aliases
api_overwrite:
	publish N, T
skip_aliases:
	arrange T,
	arrange N, =type.=name
	publish N, T
	arrange N, =type.=type
	publish N, T
end calminstruction

calminstruction type_handle &line&
	local N,T
	match =( N, type.name
	jno skip_aliases
	arrange T, =PTR
	arrange N, =TYPES.N
	publish N:, T
skip_aliases:
	arrange N, =type.=name
	arrange T,
	publish N, T
end calminstruction

calminstruction type_enum &line&
	local tmp, N,T
	match tmp? =name == N tmp?, line ; quoted

	arrange tmp, =eval 'define N ',N
	assemble tmp
	arrange tmp, =N
	transform tmp

	arrange N, =TYPES.tmp
	arrange T, =uint32_t
	publish N:, T
end calminstruction

calminstruction type_funcpointer &line& ; manual conversion
	local N,T
	match tmp? =VKAPI_PTR * N, type.name
	arrange T, =PTR
	arrange N, =TYPES.N
	publish N:, T

	arrange N, =type.=name
	arrange T,
	publish N, T
end calminstruction

calminstruction type_struct line&
	local tmp, name, alias
	match tmp? =name == name tmp?, line
	match tmp? =alias == alias tmp?, line
	jyes other
	arrange name, MEMBERS | name
	arrange tmp, =STRUCT
	publish :tmp, name
	exit

other:	arrange name, =db name,' constequ ',alias,10
	arrange tmp, =ALIASES
	publish :tmp, name
end calminstruction

calminstruction type_union &line&
	local tmp,value
	match tmp? =name == value tmp?, line
	arrange value, value | MEMBERS
	arrange tmp, =UNION
	publish :tmp, value
end calminstruction

;------------------------------------------------------------------------------
;							Tag BEGIN/END routines

define type.name
define member.name
define param.name
define proto.name
calminstruction TAG_BEGIN.name &line&
	call ShowAttributes,line ; no attributes

; used by (unique global names above):
;	registry.types.type
;	registry.types.type.member
;	registry.commands.command.param
;	registry.commands.command.proto

	local tmp
	match =type, scope
	jyes skip
	match =member, scope
	jyes skip
	match =param, scope
	jyes skip
	match =proto, scope
	jyes skip
	arrange tmp, =ShowScope
	assemble tmp
skip:
end calminstruction
calminstruction TAG_END.name &line&
	local var
	arrange var, scope
	arrange var, var=.=name
	publish var, content
	arrange content ,
end calminstruction


macro TAG_BEGIN.commands &_line& ; comment='Vulkan command definitions'
	calminstruction TAG_BEGIN.command &line& ; not used
	end calminstruction
	calminstruction TAG_END.command &line&
	end calminstruction

	calminstruction TAG_BEGIN.proto &line&
	end calminstruction
	calminstruction TAG_END.proto &line&
		arrange content ,
		arrange proto.name,
		arrange proto.type,
	end calminstruction

	calminstruction TAG_BEGIN.param &line&
	end calminstruction
	calminstruction TAG_END.param &line&
		arrange content ,
		arrange param.name,
		arrange param.type,
	end calminstruction

	calminstruction TAG_BEGIN.implicitexternsyncparams &line&
	end calminstruction
	calminstruction TAG_END.implicitexternsyncparams &line&
		call ShowAttributes,line ; no attributes
		call ShowContent ; no content
	end calminstruction
end macro
macro TAG_END.commands &line&
	ShowContent ; no content
	purge TAG_BEGIN.implicitexternsyncparams,TAG_END.implicitexternsyncparams
	purge TAG_BEGIN.param,TAG_END.param
	purge TAG_BEGIN.proto,TAG_END.proto
	purge TAG_BEGIN.command,TAG_END.command
end macro

calminstruction TAG_BEGIN.comment &line&
	call ShowAttributes,line ; no attributes
end calminstruction
calminstruction TAG_END.comment &line&
; lots of internal documentation
	arrange content ,
end calminstruction

define pos
define BITPOS BITPOS
namespace BITPOS ; custom number formating ...
	define ?0	'1'
	define ?1	'2'
	define ?2	'4'
	define ?3	'8'
	define ?4	'10h'
	define ?5	'20h'
	define ?6	'40h'
	define ?7	'80h'
	define ?8	'100h'
	define ?9	'200h'
	define ?10	'400h'
	define ?11	'800h'
	define ?12	'1000h'
	define ?13	'2000h'
	define ?14	'4000h'
	define ?15	'8000h'
	define ?16	'10000h'
	define ?17	'20000h'
	define ?18	'40000h'
	define ?19	'80000h'
	define ?20	'100000h'
	define ?21	'200000h'
	define ?22	'400000h'
	define ?23	'800000h'
	define ?24	'1000000h'
	define ?25	'2000000h'
	define ?26	'4000000h'
	define ?27	'8000000h'
	define ?28	'10000000h'
	define ?29	'20000000h'
	define ?30	'40000000h'
	define ?31	'80000000h'
	define ?32	'100000000h'
	define ?33	'200000000h'
	define ?34	'400000000h'
	define ?35	'800000000h'
	define ?36	'1000000000h'
	define ?37	'2000000000h'
	define ?38	'4000000000h'
	define ?39	'8000000000h'
	define ?40	'10000000000h'
	define ?41	'20000000000h'
	define ?42	'40000000000h'
	define ?43	'80000000000h'
	define ?44	'100000000000h'
	define ?45	'200000000000h'
	define ?46	'400000000000h'
	define ?47	'800000000000h'
end namespace

define extension_supported '|'
define extension_number '|'
define extension_name '|'

define member.enum
calminstruction TAG_BEGIN.enum &line&
	local tmp, val, name

	match =enums, scope
	jyes enums
	match =require, scope
	jno bypass

	arrange tmp, =eval 'redefine pos ',extension_supported
	assemble tmp ; unwrap string
	match =disabled, pos
	jyes bypass

	match tmp? =offset == val tmp?, line
	jno enums
	arrange pos, extension_number
	match tmp? =extnumber == pos tmp?, line

	match tmp? =name == name tmp?, line
	jno audit

	arrange tmp,=EXT_NUMBER name,pos,val
	jump done
enums:
	match tmp? =name == name tmp?, line
	jno audit
	match tmp? =bitpos == val tmp?, line
	jyes bitpos
	match tmp? =alias == val tmp?, line
	jyes alias
	match tmp? =value == val tmp?, line
	jyes good
audit:
	exit; just fixed array sizes defined elsewhere
	call ShowAttributes,line
	arrange tmp, =ShowScope
	jump done
bitpos:
	arrange tmp, =eval 'redefine pos ?',val
	assemble tmp
	transform pos, BITPOS
	jno audit
	arrange tmp, =db name,':=',pos,10
	jump done
good:
	arrange tmp,=VALUE_RESOLVE name, val
	jump done

alias:	arrange name, =db name,' constequ ',val,10
	arrange tmp, =ALIASES
	publish :tmp, name
	exit
;	arrange tmp, =db name,' equ ',val,10
done:	assemble tmp

bypass: ; member, remove
end calminstruction
calminstruction TAG_END.enum &line& ; forward member content for fixed arrays
	match , line
	jno skip
	local var
	arrange var, scope
	arrange var, var=.=enum ; only: member.enum
	publish var, content
	arrange content ,
skip:
end calminstruction

calminstruction TAG_BEGIN.enums &line& ; wrapper for enum
; name='VkMemoryUnmapFlagBitsKHR'
; type='bitmask'
; bitwidth='64'
;
; needed to determine size of enum 32/64
end calminstruction
calminstruction TAG_END.enums &line&
	call ShowContent ; no content
end calminstruction

calminstruction TAG_BEGIN.unused &line& ; child of enums
end calminstruction
calminstruction TAG_END.unused &line&
	call ShowContent ; no content
end calminstruction



macro TAG_BEGIN.extensions &_line& ; comment='Vulkan extension interface definitions'
	calminstruction TAG_BEGIN.extension &line&
		local tmp
		match tmp? =name == extension_name tmp?, line
		match tmp? =number == extension_number tmp?, line
		match tmp? =supported == extension_supported tmp?, line

	end calminstruction
	calminstruction TAG_END.extension &line&
		call ShowContent ; no content
	end calminstruction
end macro
macro TAG_END.extensions &_line&
	ShowContent ; no content
	purge TAG_BEGIN.extension,TAG_END.extension
	purge TAG_BEGIN.extensions,TAG_END.extensions
end macro


calminstruction TAG_BEGIN.feature &line&
;	arrange extension_supported, 'disabled'
; api='vulkan,vulkansc'
; name='VK_VERSION_1_0'
; number='1.0'
end calminstruction
calminstruction TAG_END.feature &line&
	call ShowContent ; no content
end calminstruction


macro TAG_BEGIN.formats &_line&
	calminstruction TAG_BEGIN.format &line&
		; component
	end calminstruction
	calminstruction TAG_END.format &line&
		call ShowContent ; no content
	end calminstruction

	calminstruction TAG_BEGIN.component &line&
		; name, bits, 
	end calminstruction
	calminstruction TAG_END.component &line&
		call ShowContent ; no content
	end calminstruction

	calminstruction TAG_BEGIN.plane &line&
	end calminstruction
	calminstruction TAG_END.plane &line&
		call ShowContent ; no content
	end calminstruction

	calminstruction TAG_BEGIN.spirvimageformat &line&
	; name='Rgba32f'
	end calminstruction
	calminstruction TAG_END.spirvimageformat &line&
		call ShowContent ; no content
	end calminstruction
end macro
macro TAG_END.formats &line&
	ShowAttributes line ; no attributes
	ShowContent ; no content
	purge TAG_BEGIN.spirvimageformat,TAG_END.spirvimageformat
	purge TAG_BEGIN.plane,TAG_END.plane
	purge TAG_BEGIN.component,TAG_END.component
	purge TAG_BEGIN.format,TAG_END.format
end macro


macro TAG_BEGIN.platforms &line&
	calminstruction TAG_BEGIN.platform &line&
	; name='win32'
	; protect='VK_USE_PLATFORM_WIN32_KHR'
	; comment='QNX Screen Graphics Subsystem'
	end calminstruction
	calminstruction TAG_END.platform &line&
		call ShowContent ; no content
	end calminstruction
end macro
macro TAG_END.platforms &line&
	ShowContent ; no content
	purge TAG_BEGIN.platform,TAG_END.platform
end macro


calminstruction TAG_BEGIN.registry &line& ; top level wrapper
end calminstruction
calminstruction TAG_END.registry &line&
	call ShowAttributes,line ; no attributes
	call ShowContent ; no content
end calminstruction



macro TAG_BEGIN.remove &line&
	; enum,type,command
	calminstruction TAG_BEGIN.command &line&
	end calminstruction
	calminstruction TAG_END.command &line&
		call ShowContent
	end calminstruction
end macro
macro TAG_END.remove &line&
	ShowContent ; no content
	purge TAG_BEGIN.command,TAG_END.command
end macro


; feature & extension
macro TAG_BEGIN.require &_line&
	; enum,type,command
	calminstruction TAG_BEGIN.command &line&
	end calminstruction
	calminstruction TAG_END.command &line&
		call ShowContent
	end calminstruction
end macro
macro TAG_END.require &line&
	ShowContent ; no content
	purge TAG_BEGIN.command,TAG_END.command
end macro



; "SPIR-V Extensions allowed in Vulkan and what is required to use it"
calminstruction TAG_BEGIN.enable &line&
; extension="VK_NVX_multiview_per_view_attributes"
; version="VK_VERSION_1_3"
; property="VkPhysicalDeviceVulkan12Properties"
; member="shaderRoundingModeRTZFloat64" value="VK_TRUE"
; value="VK_SUBGROUP_FEATURE_PARTITIONED_BIT_NV"
; requires="VK_VERSION_1_2,VK_KHR_shader_float_controls"
;
; struct='VkPhysicalDeviceRawAccessChainsFeaturesNV'
; feature='shaderRawAccessChains'
; requires='VK_NV_raw_access_chains'
end calminstruction
calminstruction TAG_END.enable &line&
	call ShowContent ; no content
end calminstruction

macro TAG_BEGIN.spirvcapabilities &_line&
	calminstruction TAG_BEGIN.spirvcapability &line&
	; name='Matrix'
	end calminstruction
	calminstruction TAG_END.spirvcapability &line&
		call ShowContent ; no content
	end calminstruction
end macro
macro TAG_END.spirvcapabilities &line&
	ShowContent ; no content
	purge TAG_BEGIN.spirvcapability,TAG_END.spirvcapability
end macro

macro TAG_BEGIN.spirvextensions &_line&
; comment='SPIR-V Extensions allowed in Vulkan and what is required to use it'
	calminstruction TAG_BEGIN.spirvextension &line&
	; name='SPV_KHR_variable_pointers'
	end calminstruction
	calminstruction TAG_END.spirvextension &line&
		call ShowContent ; no content
	end calminstruction
end macro
macro TAG_END.spirvextensions &line&
	ShowContent ; no content
	purge TAG_BEGIN.spirvextension,TAG_END.spirvextension
end macro


macro TAG_BEGIN.sync &_line&
; comment='Machine readable representation of the synchronization objects and their mappings'
	calminstruction TAG_BEGIN.syncaccess &line&
	; name='VK_ACCESS_2_NONE'
	; alias='VK_ACCESS_NONE'
	end calminstruction
	calminstruction TAG_END.syncaccess &line&
		call ShowContent ; no content
	end calminstruction
	
	calminstruction TAG_BEGIN.syncequivalent &line&
	; stage='VK_PIPELINE_STAGE_2_INDEX_INPUT_BIT'
	; access='VK_ACCESS_2_SHADER_STORAGE_WRITE_BIT'
	end calminstruction
	calminstruction TAG_END.syncequivalent &line&
		call ShowContent ; no content
	end calminstruction
	
	calminstruction TAG_BEGIN.syncpipeline &line&
	; name='graphics mesh'
	; depends='VK_NV_mesh_shader,VK_EXT_mesh_shader'
	end calminstruction
	calminstruction TAG_END.syncpipeline &line&
		call ShowContent ; no content
	end calminstruction
	
	calminstruction TAG_BEGIN.syncpipelinestage &line&
	; order='None'
	; before='VK_PIPELINE_STAGE_2_EARLY_FRAGMENT_TESTS_BIT'
	end calminstruction
	calminstruction TAG_END.syncpipelinestage &line&
	; sync bit symbol names
		arrange content ,
	end calminstruction
	
	calminstruction TAG_BEGIN.syncstage &line&
	; name='VK_PIPELINE_STAGE_2_NONE'
	; alias='VK_PIPELINE_STAGE_NONE'
	end calminstruction
	calminstruction TAG_END.syncstage &line&
		call ShowContent ; no content
	end calminstruction
	
	calminstruction TAG_BEGIN.syncsupport &line&
	; queues='graphics,compute,transfer'
	; stage='VK_PIPELINE_STAGE_2_VIDEO_DECODE_BIT_KHR'
	end calminstruction
	calminstruction TAG_END.syncsupport &line&
		call ShowContent ; no content
	end calminstruction
end macro
macro TAG_END.sync &_line&
	ShowContent ; no content
	purge TAG_BEGIN.syncaccess,TAG_END.syncaccess
	purge TAG_BEGIN.syncequivalent,TAG_END.syncequivalent
	purge TAG_BEGIN.syncpipeline,TAG_END.syncpipeline
	purge TAG_BEGIN.syncpipelinestage,TAG_END.syncpipelinestage
	purge TAG_BEGIN.syncstage,TAG_END.syncstage
	purge TAG_BEGIN.syncsupport,TAG_END.syncsupport
end macro



macro TAG_BEGIN.tags &line& ; group of author tags
	calminstruction TAG_BEGIN.tag &line&
	end calminstruction
	calminstruction TAG_END.tag &line&
		; name - name of the tag
		; author - company or project name
		; contact - name and contact information
		call ShowContent ; no content
	end calminstruction
end macro
macro TAG_END.tags &line&
	ShowContent ; no content
	purge TAG_BEGIN.tag,TAG_END.tag
end macro

define member.enum
macro TAG_BEGIN.types &_line&
	calminstruction TAG_BEGIN.member &line&
	end calminstruction
	calminstruction TAG_END.member &line&
		local tmp,A,B

		; API filtering
		match tmp? =api == A tmp?, line
		jno go
		check A = _OPTION_API_
		jno skip

	go:	match , member.enum
		jyes ggo
;arrange tmp, =member.=enum
;transform tmp
;stringify tmp
;display tmp
;display 10
		arrange tmp, =member.=name =member.=type =member.=enum ]
		jump done
	ggo:	match [ A ] [ B ], content
		jno okay
		arrange tmp, =member.=name =member.=type [ A * B ]
		jump done
	okay:	arrange tmp, =member.=name =member.=type =content
		jump done
	done:	transform tmp
		publish :MEMBERS, tmp
	skip:	arrange content,
		arrange member.name,
		arrange member.type,
		arrange member.enum,
	end calminstruction
end macro
macro TAG_END.types &line&
	ShowContent ; no content
	purge TAG_BEGIN.member,TAG_END.member
end macro
calminstruction TAG_BEGIN.type &line&
	match , line
	jno outer
	exit
outer:	; unique struct/union member vector
	local i,tmp
	initsym MEMBERS, MEMBERS.0
	match tmp.i, MEMBERS
	compute i, i+1
	arrange MEMBERS, tmp.i
end calminstruction
calminstruction TAG_END.type &line&
	local value,tmp,var
	match , line
	jyes inner

	; API filtering
	match tmp? =api == A tmp?, line
	jno go
	check A = _OPTION_API_
	jno skip
go:
	; dispatch based on category
	match tmp? =category == value tmp?, line
	jyes dispatch
skip:
	; registry.types
	; registry.feature.require
	; registry.feature.remove
	; registry.extensions.extension.require
	exit

inner:
	; registry.types.type
	; registry.types.type.member
	; registry.commands.command.param
	; registry.commands.command.proto
	arrange var, scope ; scopes using type should clear the global
	arrange var, var=.=type
	publish var, content
	arrange content ,
	exit

dispatch: ; unwrap category string
	arrange tmp, =eval 'define var type_',value
	assemble tmp
	arrange tmp, =var line
	transform tmp
	assemble tmp
	arrange type.type,
	arrange content ,
end calminstruction

;------------------------------------------------------------------------------
; https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/main/xml/vk.xml
; Not a general XML parser ...
;	- can inject spaces in content
retaincomments
isolatelines
calminstruction reader! &line&
	match =purge ?, line
	jyes process
	match <?=xml? any ?>, line
	jyes skip
	match <!-- any? -->, line
	jyes skip

	local head,tmp,tag
_line:
	match tag line?, line, <>
	jno skip
	match <tag/>, tag
	jyes complete
	match </tag>, tag
	jyes close
	match <tag>, tag
	jyes open
	arrange content, content tag
_tag:
	match , line
	jno _line
skip:	exit

open:	arrange tmp,
	match head tmp?, tag
	take attributes, tmp
	arrange tmp, =TAG_BEGIN.tag
	assemble tmp
	take scope, head
	jump _tag
complete:
	arrange tmp, =TAG_BEGIN.tag
	assemble tmp

	arrange tmp,
	match tag tmp?, tag
	take attributes, tmp
	arrange head, tag
	take scope, head

close:	take , scope
	arrange tmp, =TAG_END.tag attributes
	assemble tmp
	take , attributes
	jump _tag
process:
	assemble line
end calminstruction
include 'vk.xml',mvmacro ?,reader
purge ?
removecomments
combinelines

;------------------------------------------------------------------------------

calminstruction(NAMED) type_down type ; types that don't reduce are structures
	local try
	arrange try, type
more:	transform try, TYPES
	jyes more
	publish NAMED, try
end calminstruction

define FNAMES ; resolve naming conflicts, add more as discovered
define FNAMES.format		_format
define FNAMES.display		_display
calminstruction(NAMED) name_filter name&
	local try
	arrange try, name
more:	transform try, FNAMES
	jyes more
	publish NAMED, try
end calminstruction

define RTYPES ; reserve if type reduces
define RTYPES.db	rb
define RTYPES.dw	rw
define RTYPES.dd	rd
define RTYPES.dq	rq
calminstruction(NAMED) type_reserve type
	local try
	arrange try, type
more:	transform try, TYPES
	jyes more
	match try =?, try
	transform try, RTYPES
	publish NAMED, try
end calminstruction

define TBYTES ; bytes if type reduced or structure in namespace
define TBYTES.db	1
define TBYTES.dw	2
define TBYTES.dd	4
define TBYTES.dq	8
calminstruction(NAMED) type_size type ;--------------- add structures to TBYTES
	local try
	arrange try, type
more:	transform try, TYPES
	jyes more
	match try =?, try
	transform try, TBYTES
	jno zero
	publish NAMED, try
	exit
zero:
	arrange try, 0
	publish NAMED, try
end calminstruction

define TLIGN ; required alignment
define TLIGN.db 1
define TLIGN.dw 2
define TLIGN.dd 4
define TLIGN.dq 8
calminstruction(NAMED) type_align type ;--------------- add structures to TLIGN
	local try
	arrange try, type
more:	transform try, TYPES
	jyes more
	match try =?, try
	transform try, TLIGN
	jno zero
	publish NAMED, try
	exit
zero:
	arrange try, 1
	publish NAMED, try
end calminstruction

;------------------------------------------------------------------------------

Offset = 0
AlignMax = 0

define _sym	; filtered name
define ty	; reduced type
bytes = 0	; bytes of type
lign = 1	; type alignment required
calminstruction output_type_line s_or_u*, member&
	local tmp,sym,tty,count,bits
	compute count, 1

	match * =const * sym =const tty, member
	jyes ppointer
	match * sym =const tty, member
	jyes pointer
	match * sym tty, member ; void
	jyes pointer
	match sym tty [ count ], member
	jyes fixed
	match sym tty : bits, member
	jyes field
	match sym tty, member
	jno audit
	arrange tmp,=ty =type_down tty
	assemble tmp
	arrange tmp,=bytes =type_size ty
	assemble tmp
	jump ready
ppointer:
	arrange tmp,=ty =type_down =PTR
	assemble tmp
	arrange tty, **tty
	arrange tmp,=bytes =type_size ty
	assemble tmp
	jump ready
pointer:
	arrange tmp,=ty =type_down =PTR
	assemble tmp
	arrange tty, *tty
	arrange tmp,=bytes =type_size ty
	assemble tmp
	jump ready
fixed:
	arrange tmp,=ty =type_reserve tty
	assemble tmp
;TODO: non-reduced types need FIXME:
;	NAME TYPE
;	rb (COUNT-1)*sizeof TYPE
	arrange tty, tty[count]
	arrange ty, ty count
	arrange tmp,=bytes =type_size ty
	assemble tmp
	jump ready
field:
; TODO: other cases
	compute count, bits shr 3
	arrange tmp,=ty =type_reserve =db
	assemble tmp
	arrange tty, tty:bits
	arrange ty, ty count
	compute bytes, count
	jump ready

; Unions require an update of the offset and alignment, so the total bytes
; and alignment can be determined at end. Structures need the same, but also
; type alignment prior.
ready:
	arrange tmp,=lign =type_align ty
	assemble tmp

	local bump
	compute bump, 0
	check s_or_u ; union doesn't need alignment
	jno even

	compute bump, Offset and (lign-1)
	check bump
	jno even
	emit 1, 9
	emit 3, 'rb '
	arrange tmp, bump
	stringify tmp
	emit lengthof tmp, tmp
	emit 1, 10
even:
	arrange tmp,=_sym =name_filter sym ; avoid name conflicts
	assemble tmp

	emit 1, 9
	stringify _sym
	emit lengthof _sym, _sym
	emit 1, ' '
	stringify ty
	emit lengthof ty, ty

; _OPTION_COMMENT_TYPE_ and changed:
	emit 3, ' ; '
	stringify tty
	emit lengthof tty, tty
	emit 1, 10

	check AlignMax < lign
	jno asame
	compute AlignMax, lign
asame:	compute Offset, Offset + bump + bytes
	exit

audit:	arrange tmp, member
	stringify tmp
	display tmp
	display 10
end calminstruction







irpv I,UNION
	rawmatch name | vector, I
		db 'struct ',name,10
		db 'union',10
AlignMax = 1
MaxOffset = 0
		irpv M, vector
Offset = 0
			output_type_line 0,M
;TODO: gather max offset for real size
if MaxOffset < Offset
	MaxOffset = Offset
end if
		end irpv
		db 'ends',10
		db 'ends',10
; set bytes & align
	end rawmatch
end irpv



irpv S,STRUCT
	rawmatch member | sname, S
Offset = 0
AlignMax = 1
		db 'struct ',sname,10
		irpv M, member
			output_type_line 1,M
		end irpv
; post alignment
repeat Offset and (AlignMax-1)
	db 9,'rb ',`%%,10
	Offset = Offset + %%
	break
end repeat
;repeat 1, _O:Offset, _A:AlignMax
;	if _O
;	eval 'define TBYTES.',sname,' ',`_O
;	eval 'define TLIGN.',sname,' ',`_A
;	display 'define TBYTES.',sname,' ',`_O,10
;	display 'define TLIGN.',sname,' ',`_A,10
;	end if
;end repeat
		db 'ends',10
	end rawmatch
end irpv




;irpv I,INCLUDE ; not needed
;end irpv

db '; avoid/prune constant and structure aliases?',10
irpv A,ALIASES
	A
end irpv

;--------------------------------------------------------------------- Problems:
; remove duplicate const lines
;?remove aliases


; multiple: (extension overlap?)
;2	VK_SAMPLER_ADDRESS_MODE_MIRROR_CLAMP_TO_EDGE:=4
;2	VK_STRUCTURE_TYPE_DEVICE_GROUP_PRESENT_CAPABILITIES_KHR:=1000060007
;3	VK_DESCRIPTOR_UPDATE_TEMPLATE_TYPE_PUSH_DESCRIPTORS_KHR:=1
;	VK_DEBUG_REPORT_OBJECT_TYPE_SAMPLER_YCBCR_CONVERSION_EXT:=1000156000
;
;need to exclude other arch, or add sizes for their dependant types?
;removing structures with unknown types in other arch
;
;	VkBufferCollectionCreateInfoFUCHSIA.collectionToken
;
;
; struct NM_FINDITEM not aligned to its natural boundary
; VkPhysicalDeviceProperties.limits not aligned to its natural boundary
; VkSparseImageMemoryRequirements.imageMipTailSize not aligned to its natural boundary
; VkSparseImageMemoryRequirements.imageMipTailOffset not aligned to its natural boundary
; VkSparseImageMemoryRequirements.imageMipTailStride not aligned to its natural boundary
; struct VkSparseImageMemoryRequirements not aligned to its natural boundary
; VkImageFormatProperties.maxResourceSize not aligned to its natural boundary
; struct VkImageFormatProperties not aligned to its natural boundary
; VkImageCreateInfo.pQueueFamilyIndices not aligned to its natural boundary
; VkSparseImageMemoryBind.memory not aligned to its natural boundary
; VkSparseImageMemoryBind.memoryOffset not aligned to its natural boundary
; VkComputePipelineCreateInfo.stage not aligned to its natural boundary
; VkPhysicalDeviceGroupProperties.physicalDevices not aligned to its natural boundary
; struct VkDisplayModeProperties2KHR not aligned to its natural boundary
; VkAttachmentSampleLocationsEXT.sampleLocationsInfo not aligned to its natural boundary
; struct VkAttachmentSampleLocationsEXT not aligned to its natural boundary
; VkSubpassSampleLocationsEXT.sampleLocationsInfo not aligned to its natural boundary
; struct VkSubpassSampleLocationsEXT not aligned to its natural boundary
; VkPipelineSampleLocationsStateCreateInfoEXT.sampleLocationsInfo not aligned to its natural boundary
; VkNativeBufferANDROID.usage2 not aligned to its natural boundary
; VkShaderStatisticsInfoAMD.resourceUsage not aligned to its natural boundary
; VkGeometryNV.geometry not aligned to its natural boundary
; VkPerformanceValueINTEL.data not aligned to its natural boundary
; struct VkPerformanceValueINTEL not aligned to its natural boundary
; VkPipelineExecutableStatisticKHR.value not aligned to its natural boundary
; VkPhysicalDeviceVulkan12Properties.maxTimelineSemaphoreValueDifference not aligned to its natural boundary
; VkAccelerationStructureGeometryTrianglesDataKHR.vertexData not aligned to its natural boundary
; VkAccelerationStructureGeometryInstancesDataKHR.data not aligned to its natural boundary
; VkAccelerationStructureGeometryKHR.geometry not aligned to its natural boundary
; VkVideoSessionMemoryRequirementsKHR.memoryRequirements not aligned to its natural boundary
; VkVideoDecodeAV1PictureInfoKHR.pTileOffsets not aligned to its natural boundary
; VkVideoDecodeAV1PictureInfoKHR.pTileSizes not aligned to its natural boundary
; struct VkVideoDecodeAV1PictureInfoKHR not aligned to its natural boundary
; VkDescriptorGetInfoEXT.data not aligned to its natural boundary
; VkBufferCollectionPropertiesFUCHSIA.sysmemColorSpaceIndex not aligned to its natural boundary
; VkBufferConstraintsInfoFUCHSIA.bufferCollectionConstraints not aligned to its natural boundary
; VkImageFormatConstraintsInfoFUCHSIA.sysmemPixelFormat not aligned to its natural boundary
; VkImageFormatConstraintsInfoFUCHSIA.pColorSpaces not aligned to its natural boundary
; struct VkImageFormatConstraintsInfoFUCHSIA not aligned to its natural boundary
; VkAccelerationStructureTrianglesOpacityMicromapEXT.indexBuffer not aligned to its natural boundary
; VkAccelerationStructureTrianglesDisplacementMicromapNV.indexBuffer not aligned to its natural boundary
; VkDispatchGraphCountInfoAMDX.infos not aligned to its natural boundary
;
; undefined:
;	VkPipelineMultisampleStateCreateFlags	(future)
;	VkPipelineDynamicStateCreateFlags
;	VkBuildAccelerationStructureFlagsNV






