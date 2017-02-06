:: Visual Studio X64 Cross Tools Command

:: setlocal enabledelayedexpansion

set VSBIN="C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin"
if not exist "C:\Program Files (x86)" (
	set VSBIN="C:\Program Files\Microsoft Visual Studio 14.0\VC\bin"
)

set CURRENTPATH=%~dp0

:: cd %VSBIN%
:: call !VSBIN!\vcvars32.bat" 

cd %CURRENTPATH%

perl Configure no-asm VC-WIN64A 

call ms\do_win64a 

nmake -f ms\ntdll.mak 

