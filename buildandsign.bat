# Automated Build and Signing Script for Msbuild with Wix installer
#
# Copyright Kenneth Dick 01/06/2016
# 
#
#
nuget restore MY.sln
set MYVersion=%APPVEYOR_BUILD_VERSION%
set MYConfiguration="Release"
set cert="MY_csc2.p12"

aws s3 sync s3://%BUCKET%/win/ sync/

if not exist "sync\%cert%" (
echo WARNING Signing Certificate Not Found
) else (
 copy sync\%cert% %cert%
)

set PATH="C:\Program Files (x86)\WiX Toolset v3.10\bin";%PATH%
set PATH="C:\Program Files (x86)\Windows Kits\8.1\bin\x64";%PATH%
msbuild MY.sln /p:Configuration=%MYConfiguration%  /p:Targets="Build" /p:BuildInParallel=true /m
if exist "%cert%" (
signtool sign  /f %cert% /p %CERT_PASS% /t http://timestamp.digicert.com  /a ".\MY.App\bin\Release\MY.exe"
signtool sign /f %cert% /p %CERT_PASS% /t http://timestamp.digicert.com /a ".\MY.App\bin\Release\*.dll"
)
Candle -dVATRP.Version=%MYVersion% -dConfiguration=%MYConfiguration% -dOutDir=.\Setup\Out -dPlatform=x86 -dTargetDir=.\Setup\Out -dTargetExt=.msi -out .\Setup\obj\ -arch x86 -ext WixNetFxExtension.dll -ext WixUtilExtension.dll -ext WixUIExtension.dll .\Setup\Setup.wxs
Light -out .\Setup\Out\Setup_%MYVersion%.msi -pdbout .\Setup\obj\Setup.wixpdb -cultures:null -ext WixNetFxExtension.dll -ext WixUtilExtension.dll -ext WixUIExtension.dll -contentsfile .\Setup\obj\Setup.wixproj.BindContentsFileListnull.txt -outputsfile .\Setup\obj\Setup.wixproj.BindOutputsFileListnull.txt -builtoutputsfile .\Setup\obj\Setup.wixproj.BindBuiltOutputsFileListnull.txt  .\Setup\obj\Setup.wixobj
rd /S /Q .\Setup\obj
if exist "%cert%" (
signtool sign /f %cert% /p %CERT_PASS% /t http://timestamp.digicert.com /a ".\Setup\Out\PUC_Setup_%MYVersion%.msi"
)
