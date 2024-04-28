
; vk.xml conversion script by Rickey Bowers Jr. bitRAKE
;
; reversing to update script is made easier by displaying the expected
;
;
; Vulkan API is very data-centric. Any helpers that prevent using the wrong
; constants would be beneficial, or possessing a great attention to detail.
;
;

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
; windows.h types required:
define TYPES.HINSTANCE			PTR
define TYPES.HWND			PTR
define TYPES.HMONITOR			PTR
define TYPES.HANDLE			PTR
define TYPES.SECURITY_ATTRIBUTES	PTR
define TYPES.DWORD			dd ?
define TYPES.LPCWSTR			PTR

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
; TODO: examine type and resolve value, do manually - about six of them.
		db name,':=?',value,10
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
calminstruction TAG_BEGIN.command &line& ; not used
end calminstruction
calminstruction TAG_END.command &line&
; name
; comment
;	proto.type
;	proto.name
;	param.type
;	param.name
	call ShowContent ; no content, cleared by name
end calminstruction

calminstruction TAG_BEGIN.commands &line& ; group wrapper
; comment='Vulkan command definitions'
end calminstruction
calminstruction TAG_END.commands &line&
	call ShowContent ; no content
end calminstruction

calminstruction TAG_BEGIN.comment &line&
	call ShowAttributes,line ; no attributes
end calminstruction
calminstruction TAG_END.comment &line&
; lots of internal documentation
	arrange content ,
end calminstruction

calminstruction TAG_BEGIN.component &line&
; gather for format end processing
end calminstruction
calminstruction TAG_END.component &line&
	call ShowContent ; no content
end calminstruction

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
calminstruction TAG_END.enum &line&
; forward member content for fixed arrays
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

calminstruction TAG_BEGIN.extension &line&
	local tmp
	match tmp? =name == extension_name tmp?, line
	match tmp? =number == extension_number tmp?, line
	match tmp? =supported == extension_supported tmp?, line
end calminstruction
calminstruction TAG_END.extension &line&
	call ShowContent ; no content
end calminstruction

calminstruction TAG_BEGIN.extensions &line& ; group wrapper
; comment='Vulkan extension interface definitions'
end calminstruction
calminstruction TAG_END.extensions &line&
	call ShowContent ; no content
end calminstruction

calminstruction TAG_BEGIN.feature &line&
;	arrange extension_supported, 'disabled'
; api='vulkan,vulkansc'
; name='VK_VERSION_1_0'
; number='1.0'
end calminstruction
calminstruction TAG_END.feature &line&
	call ShowContent ; no content
end calminstruction

calminstruction TAG_BEGIN.format &line&
; packed='16'
; compressed='ASTC HDR'
; name='VK_FORMAT_R16G16_SFIXED5_NV'
; class='32-bit'
; blockSize='4'
; texelsPerBlock='1'
; blockExtent='10,8,1'
end calminstruction
calminstruction TAG_END.format &line&
	call ShowContent ; no content
end calminstruction

calminstruction TAG_BEGIN.formats &line&
	call ShowAttributes,line ; no attributes
end calminstruction
calminstruction TAG_END.formats &line&
	call ShowContent ; no content
end calminstruction

calminstruction TAG_BEGIN.implicitexternsyncparams &line&
	call ShowAttributes,line ; no attributes
end calminstruction
calminstruction TAG_END.implicitexternsyncparams &line&
	call ShowContent ; no content
end calminstruction

calminstruction TAG_BEGIN.member &line&
end calminstruction
calminstruction TAG_END.member &line&
	local tmp,A,B
	match [ A ] [ B ], content
	jno okay
	arrange tmp, =member.=name =member.=type [ A * B ]
	jump done
okay:	arrange tmp, =member.=name =member.=type =content
	jump done
done:	transform tmp
	publish :MEMBERS, tmp
	arrange member.name,
	arrange member.type,
	arrange content,
end calminstruction

calminstruction TAG_BEGIN.name &line&
	call ShowAttributes,line ; no attributes
end calminstruction
calminstruction TAG_END.name &line&
	local var
	arrange var, scope
	arrange var, var=.=name
	publish var, content
	arrange content ,
end calminstruction

calminstruction TAG_BEGIN.param &line& ; resolve manually
end calminstruction
calminstruction TAG_END.param &line&
; command param details
	arrange content ,
end calminstruction

calminstruction TAG_BEGIN.plane &line&
; index='1'
; widthDivisor='1'
; heightDivisor='1'
; compatible='VK_FORMAT_R16G16_UNORM'
end calminstruction
calminstruction TAG_END.plane &line&
	call ShowContent ; no content
end calminstruction

calminstruction TAG_BEGIN.platform &line&
; name='screen'
; protect='VK_USE_PLATFORM_SCREEN_QNX'
; comment='QNX Screen Graphics Subsystem'
end calminstruction
calminstruction TAG_END.platform &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.platforms &line&
; comment='Vulkan platform names, reserved for use with platform- and window system-specific extensions'
end calminstruction
calminstruction TAG_END.platforms &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.proto &line&
	call ShowAttributes,line ; no attributes
end calminstruction
calminstruction TAG_END.proto &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.registry &line&
	call ShowAttributes,line ; no attributes
end calminstruction
calminstruction TAG_END.registry &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.remove &line&
end calminstruction
calminstruction TAG_END.remove &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.require &line&
; comment='functionality re-used unmodified from VK_NV_external_sci_sync'
; depends='VKSC_VERSION_1_0'
; api='vulkansc'
end calminstruction
calminstruction TAG_END.require &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.spirvcapabilities &line&
; comment='SPIR-V Capabilities allowed in Vulkan and what is required to use it'
end calminstruction
calminstruction TAG_END.spirvcapabilities &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.spirvcapability &line&
; name='Matrix'
end calminstruction
calminstruction TAG_END.spirvcapability &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.spirvextension &line&
; name='SPV_KHR_variable_pointers'
end calminstruction
calminstruction TAG_END.spirvextension &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.spirvextensions &line&
; comment='SPIR-V Extensions allowed in Vulkan and what is required to use it'
end calminstruction
calminstruction TAG_END.spirvextensions &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.spirvimageformat &line&
; name='Rgba32f'
end calminstruction
calminstruction TAG_END.spirvimageformat &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.sync &line&
; comment='Machine readable representation of the synchronization objects and their mappings'
end calminstruction
calminstruction TAG_END.sync &line&
	call ShowContent ; no content
end calminstruction
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

calminstruction TAG_BEGIN.tag &line&
end calminstruction
calminstruction TAG_END.tag &line&
	call ShowContent ; no content
end calminstruction
calminstruction TAG_BEGIN.tags &line&
end calminstruction
calminstruction TAG_END.tags &line&
	call ShowContent ; no content
end calminstruction

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
	; dispatch based on category
	match tmp? =category == value tmp?, line
	jyes dispatch
	; audit: requires, no content?
	exit

inner:	arrange var, scope ; scopes using type should clear the global
	arrange var, var=.=type
	publish var, content
	jump done

dispatch: ; unwrap category string
	arrange tmp, =eval 'define var type_',value
	assemble tmp
	arrange tmp, =var line
	transform tmp
	assemble tmp
done:
	arrange content ,
end calminstruction

calminstruction TAG_BEGIN.types &line&
end calminstruction
calminstruction TAG_END.types &line&
	call ShowContent ; no content
end calminstruction

calminstruction TAG_BEGIN.unused &line&
end calminstruction
calminstruction TAG_END.unused &line&
	call ShowContent ; no content
end calminstruction

;------------------------------------------------------------------------------
; https://github.com/KhronosGroup/Vulkan-Docs/blob/main/xml/vk.xml?raw=true
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
format binary as 'inc'
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
;stringify try
;display try
	publish NAMED, try
	exit
zero:
	arrange try, 0
	publish NAMED, try
end calminstruction
;------------------------------------------------------------------------------

Offset = 0
AlignMax = 0
AlignNeeded = 0

macro output_type_line member&
	local n,t,bits,name,type,N,T,bytes,diff

	bytes = -1 ; size unknown
	match * n t, member
		define name n
		define type *t
		T type_down PTR
		bytes type_size PTR
	else match n t, member
		define name n
		define type t
		match any : bits, t
			if bits = 24 | bits = 16 | bits = 8
				bytes = bits shr 3
				repeat bytes
					define T rb %%
					break
				end repeat
			else
				err 'field size not supported'
			end if
		else match part [ value ], t
			T type_down part
			match base =?, T
				T type_reserve base
			end match
			T reequ T value
; BUG: this breaks easy too!
bytes = 0 ; bypass
; bytes type_size base
; bytes = bytes * value ; enum lookup
		else
			T type_down t
			bytes type_size t
		end match
	else
;:BUG 'type' name is getting consumed. So, fake it until I run down the error ...
;VkDescriptorType
;VkLayerSettingTypeEXT
;VkImageType
;VkImageType
;VkDeviceMemoryReportEventTypeEXT
;VkRayTracingShaderGroupTypeKHR
;VkRayTracingShaderGroupTypeKHR
;VkAccelerationStructureTypeNV
;VkAccelerationStructureMemoryRequirementsTypeNV
;VkScopeNV
;VkPerformanceCounterScopeKHR
;VkPerformanceValueTypeINTEL
;VkPerformanceOverrideTypeINTEL
;VkPerformanceConfigurationTypeINTEL
;VkAccelerationStructureTypeKHR
;VkAccelerationStructureTypeKHR
;VkDescriptorType
;VkAccelerationStructureMotionInstanceTypeNV
;VkMicromapTypeEXT
;VkMicromapTypeEXT
;VkScopeKHR
		define name type
		type equ member
		T type_down member
		bytes type_size member
display '.' ;|ERROR| this will disappear when fixed!
	end match

	; does type need an alignment?
	if bytes = 2 | bytes = 4 | bytes = 8
		diff = Offset and (bytes-1)
		if diff
			repeat bytes-diff
				db 9,9,'rb ',`%%,10
				Offset = Offset + %%
				break
			end repeat
		end if
		if bytes > AlignMax
			AlignMax = bytes
		end if
	end if
	Offset = Offset + bytes


	match n, name
		N name_filter n
	end match
	match any, N T
		db 9,`any
	end match

	match xxx, type
	match yyy, T
	if `xxx <> `yyy ; comment complex type when lowered
		db ' ; ',`xxx
	end if
	end match
	end match
	db 10
end macro




irpv I,UNION
	rawmatch name | vector, I
		db 'struct ',name,10
		db 'union',10
		irpv M, vector
			Offset = 0 ; no alignment output
			output_type_line M
		end irpv
		db 'ends',10
		db 'ends',10
	end rawmatch
end irpv



irpv S,STRUCT
	rawmatch member | sname, S
		db 'struct ',sname,10
		Offset = 0
		AlignMax = 0
		irpv M, member
			output_type_line M
		end irpv

		; does structure need tail padding alignment?
		if AlignMax > 1
		diff = Offset and (AlignMax-1)
		if diff
			repeat AlignMax-diff
				db 9,9,'rb ',`%%,10
				Offset = Offset + %%
				break
			end repeat
		end if
		end if

		; store structure max alignment
		repeat 1,O:AlignMax
			eval 'define TBYTES.',sname,' O'
		end repeat

		db 'ends',10
	end rawmatch
end irpv




;irpv I,INCLUDE ; not needed
;end irpv

db '; avoid/prune constant and structure aliases?',10
irpv A,ALIASES
	A
end irpv
