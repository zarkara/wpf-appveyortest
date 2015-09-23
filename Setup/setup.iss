[Setup] AppName=My Program
AppVerName=My Program version 1.5
DefaultDirName={pf}\My Program
DefaultGroupName=My Program
UninstallDisplayIcon={app}\WPF1.exe
Compression=lzma
SolidCompression=yes
OutputDir=userdocs:Inno Setup Examples Output
[Files] Source: “WPF1\bin\Release\WPF1.exe”; DestDir: “{app}”
[Icons] Name: “{group}\My Program”; Filename: “{app}\WPF1.exe”