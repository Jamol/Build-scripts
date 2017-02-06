:: run from VS Command Prompt

setlocal enabledelayedexpansion

set VSBIN="C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin"
if not exist "C:\Program Files (x86)" (
	set VSBIN="C:\Program Files\Microsoft Visual Studio 14.0\VC\bin"
)

set CURRENTPATH=%~dp0

cd %VSBIN%
call !VSBIN!\vcvars32.bat" 

cd %CURRENTPATH%

perl Configure VC-WIN32 

call ms\do_nasm 

nmake -f ms\ntdll.mak 

