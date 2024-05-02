# NMAKE makefile
# see https://learn.microsoft.com/en-us/cpp/build/reference/nmake-reference

# set environment
fasm2 = c:\fasm2\fasm2.cmd
vksdk = C:\sdk\VulkanSDK\1.3.280.0\Lib


# common interfaces
OBJS =	$(vksdk)\vulkan-1.lib

# common libraries
DEFS =	/DEFAULTLIB:kernel32	\
	/DEFAULTLIB:user32


# TODO:
#	$(vksdk)\..\bin\glslangValidator -V shader.vert
#	$(vksdk)\..\bin\glslangValidator -V shader.frag
#


# restrict inference-rule matching (i.e. ignore most default rules)
# .SUFFIXES :
.SUFFIXES : .asm.obj

# specify timestamp dependent inference rules
.asm.obj :
	$(fasm2) $<


all:	00_null.exe\
	01_debug_report.exe\
	02_adv_report.exe\
	04_enum_ext.exe\
	10_null.exe


# LNK4281: triggers incorrectly, ASLR is not active for FIXED!

04_enum_ext.exe :  04_enum_ext.obj parts\debug_report.obj $(OBJS)
	link /SUBSYSTEM:CONSOLE /IGNORE:4281 $(DEFS) /FIXED /BASE:0x10000 $**

02_adv_report.exe :  02_adv_report.obj parts\debug_report.obj $(OBJS)
	link /SUBSYSTEM:CONSOLE /IGNORE:4281 $(DEFS) /FIXED /BASE:0x10000 $**

10_null.exe : 10_null.obj $(OBJS)
	link /SUBSYSTEM:CONSOLE /IGNORE:4281 $(DEFS) /FIXED /BASE:0x10000 $**

01_debug_report.exe : 01_debug_report.obj $(OBJS)
	link /SUBSYSTEM:CONSOLE /IGNORE:4281 $(DEFS) /FIXED /BASE:0x10000 $**

00_null.exe : 00_null.obj $(OBJS)
	link /SUBSYSTEM:CONSOLE /IGNORE:4281 $(DEFS) /FIXED /BASE:0x10000 $**


# additional dependancies ...
02_adv_report.obj : coffms_ext.inc vulkan.inc vulkan-1.g lazythunk.inc parts\debug_report.asm

00_null.obj \
01_debug_report.obj \
10_null.obj : vulkan.inc vulkan-1.g lazythunk.inc


.SILENT :

clean :
	del /Q *.obj 2>NUL
	del /Q *.exe 2>NUL
	del /Q *.zip 2>NUL

package : clean
	tar -a -cf ..\vwork.zip *
