# Microsoft Developer Studio Project File - Name="MPegDll" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=MPegDll - Win32 DirectX Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "MPegDll.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "MPegDll.mak" CFG="MPegDll - Win32 DirectX Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "MPegDll - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "MPegDll - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "MPegDll - Win32 DirectX Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "MPegDll - Win32 DirectX Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "MPegDll - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /MT /w /W0 /Ot /Og /Oi /Oy /Ob1 /D "WIN32" /D "_NDEBUG" /D "_WINDOWS" /YX /FD /Gs /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x419 /d "NDEBUG"
# ADD RSC /l 0x409 /d "_NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 winmm.lib /nologo /subsystem:windows /dll /machine:I386 /out:"Release/ELAMP.ESP"
# SUBTRACT LINK32 /profile

!ELSEIF  "$(CFG)" == "MPegDll - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "MPegDll_"
# PROP BASE Intermediate_Dir "MPegDll_"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "MPegDll_"
# PROP Intermediate_Dir "MPegDll_"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /G4 /MTd /W3 /Gm /Gi /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x419 /d "_DEBUG"
# ADD RSC /l 0x419 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib winmm.lib /nologo /subsystem:windows /dll /profile /map /debug /machine:I386 /out:"MPegDll_/ELAMP.ESP"

!ELSEIF  "$(CFG)" == "MPegDll - Win32 DirectX Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "MPegDll___Win32_DirectX_Release"
# PROP BASE Intermediate_Dir "MPegDll___Win32_DirectX_Release"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "MPegDll___Win32_DirectX_Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /w /W0 /Ot /Og /Oi /Oy /Ob1 /D "WIN32" /D "_NDEBUG" /D "_WINDOWS" /YX /FD /Gs /c
# ADD CPP /nologo /MT /w /W0 /GX /Ox /Ot /Og /Oi /Ob2 /D "_NDEBUG" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_DIRECTX" /D "_WIN32_DCOM" /FR /YX /FD /Gs /LD /c
# ADD BASE MTL /nologo /D "_NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_NDEBUG" /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "_NDEBUG"
# ADD RSC /l 0x409 /d "_NDEBUG" /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 winmm.lib /nologo /subsystem:windows /dll /machine:I386 /out:"Release/ELAMP.ESP"
# SUBTRACT BASE LINK32 /profile
# ADD LINK32 kernel32.lib user32.lib winmm.lib ole32.lib dsound.lib /nologo /subsystem:windows /dll /machine:I386 /out:"Release/ELAMP.ESP"
# SUBTRACT LINK32 /profile

!ELSEIF  "$(CFG)" == "MPegDll - Win32 DirectX Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "MPegDll___Win32_DirectX_Debug"
# PROP BASE Intermediate_Dir "MPegDll___Win32_DirectX_Debug"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "MPegDll___Win32_DirectX_Debug"
# PROP Intermediate_Dir "MPegDll___Win32_DirectX_Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /G4 /MTd /W3 /Gm /Gi /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX /FD /c
# ADD CPP /nologo /MTd /W3 /Gm /Gi /GX /ZI /Od /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_DIRECTX" /D "_WIN32_DCOM" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x419 /d "_DEBUG"
# ADD RSC /l 0x419 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib winmm.lib /nologo /subsystem:windows /dll /profile /map /debug /machine:I386 /out:"MPegDll_/ELAMP.ESP"
# ADD LINK32 kernel32.lib user32.lib winmm.lib ole32.lib dsound.lib /nologo /subsystem:windows /dll /profile /map /debug /machine:I386 /out:"MPegDll_/ELAMP.ESP"

!ENDIF 

# Begin Target

# Name "MPegDll - Win32 Release"
# Name "MPegDll - Win32 Debug"
# Name "MPegDll - Win32 DirectX Release"
# Name "MPegDll - Win32 DirectX Debug"
# Begin Group "Source Files"

# PROP Default_Filter "*.cpp;*.c"
# Begin Source File

SOURCE=.\Audio.cpp
# End Source File
# Begin Source File

SOURCE=.\decoder.cpp
# End Source File
# Begin Source File

SOURCE=.\helper.cpp
# End Source File
# Begin Source File

SOURCE=.\module.cpp
# End Source File
# Begin Source File

SOURCE=.\player.cpp
# End Source File
# Begin Source File

SOURCE=.\stream.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "*.h"
# Begin Source File

SOURCE=.\args.h
# End Source File
# Begin Source File

SOURCE=.\audio.h
# End Source File
# Begin Source File

SOURCE=.\common.h
# End Source File
# Begin Source File

SOURCE=.\decoder.h
# End Source File
# Begin Source File

SOURCE=..\ESP\ElSound.h
# End Source File
# Begin Source File

SOURCE=.\helper.h
# End Source File
# Begin Source File

SOURCE=.\Huffman.h
# End Source File
# Begin Source File

SOURCE=.\player.h
# End Source File
# Begin Source File

SOURCE=.\stream.h
# End Source File
# Begin Source File

SOURCE=.\Tables.h
# End Source File
# End Group
# Begin Source File

SOURCE=.\ELAMP.rc
# End Source File
# Begin Source File

SOURCE=.\MpegDll.def
# End Source File
# End Target
# End Project
