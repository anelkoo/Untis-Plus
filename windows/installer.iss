; Built by CI: iscc /DAppVersion=x.y.z windows\installer.iss
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={{6E1B7C52-4D0A-4C1F-9C55-3B1D8B2E7A10}
AppName=Untis+
AppVersion={#AppVersion}
AppPublisher=anelkoo
DefaultDirName={localappdata}\Programs\Untis+
DefaultGroupName=Untis+
PrivilegesRequired=lowest
OutputDir=..\dist
OutputBaseFilename=UntisPlus-Setup
Compression=lzma2
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\untis_plus.exe

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\Untis+"; Filename: "{app}\untis_plus.exe"
Name: "{userdesktop}\Untis+"; Filename: "{app}\untis_plus.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Desktop-Verknüpfung erstellen"; Flags: unchecked

[Run]
Filename: "{app}\untis_plus.exe"; Description: "Untis+ starten"; Flags: nowait postinstall skipifsilent
