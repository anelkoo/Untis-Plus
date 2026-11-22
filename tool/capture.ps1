# Saves raw WebUntis responses for one week into debug-capture/ (git-ignored), so parsing can be
# built against real data. Asks for the password itself and never writes it or the session to disk.
# Usage: .\tool\capture.ps1 -Date 2026-11-25
param(
  [string]$Date = (Get-Date -Format 'yyyy-MM-dd'),
  [string]$Server = 'htbla-grieskirchen.webuntis.com',
  [string]$School = 'htbla-grieskirchen'
)
$ErrorActionPreference = 'Stop'
$out = Join-Path $PSScriptRoot '..\debug-capture'
New-Item -ItemType Directory -Force $out | Out-Null

$day = [datetime]::ParseExact($Date, 'yyyy-MM-dd', $null)
$monday = $day.AddDays(-(([int]$day.DayOfWeek + 6) % 7))
$sunday = $monday.AddDays(6)
$web = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$rpcUrl = "https://$Server/WebUntis/jsonrpc.do?school=$School"

# Decodes the body as UTF-8 text; PowerShell returns application/json-rpc bodies as raw bytes.
function Get-Text($url, $headers = @{}) {
  $r = Invoke-WebRequest $url -Headers $headers -WebSession $web -UseBasicParsing
  [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray())
}
function Invoke-Rpc($method, $params) {
  $body = @{ id = '1'; method = $method; params = $params; jsonrpc = '2.0' } | ConvertTo-Json -Depth 10
  $r = Invoke-WebRequest $rpcUrl -Method Post -Body $body -ContentType 'application/json' -WebSession $web -UseBasicParsing
  [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray())
}
function Save-Response($name, [scriptblock]$fetch) {
  try { $text = & $fetch } catch { $text = "ERROR: $($_.Exception.Message)" }
  [IO.File]::WriteAllText((Join-Path $out $name), $text, [Text.UTF8Encoding]::new($false))
  Write-Host "$name  ($($text.Length) chars)"
}

$user = Read-Host 'Benutzername'
$secure = Read-Host 'Passwort' -AsSecureString
$password = [Net.NetworkCredential]::new('', $secure).Password
$auth = Invoke-Rpc 'authenticate' @{ user = $user; password = $password; client = 'UntisPlus' } | ConvertFrom-Json
$password = $null
if ($auth.error) { throw "Login: $($auth.error.message)" }
$personId = $auth.result.personId
$personType = $auth.result.personType

$fields = @('id', 'name', 'longname')
Save-Response 'getTimetable.json' {
  Invoke-Rpc 'getTimetable' @{ options = @{
      element = @{ id = $personId; type = $personType }
      startDate = [int]$monday.ToString('yyyyMMdd'); endDate = [int]$sunday.ToString('yyyyMMdd')
      showLsText = $true; showSubstText = $true; showInfo = $true
      klasseFields = $fields; teacherFields = $fields; subjectFields = $fields; roomFields = $fields
    } }
}
Save-Response 'getExams.json' {
  Invoke-Rpc 'getExams' @{ startDate = [int]$monday.ToString('yyyyMMdd'); endDate = [int]$sunday.ToString('yyyyMMdd'); examTypeId = 0 }
}

$token = (Get-Text "https://$Server/WebUntis/api/token/new").Trim()
if ($token -notmatch '^[\w-]+\.[\w-]+\.[\w-]+$') { Write-Host 'Kein API-Token bekommen; REST-Abfragen laufen ohne.'; $token = '' }
$bearer = if ($token) { @{ Authorization = "Bearer $token" } } else { @{} }
Save-Response 'api_exams.json' {
  Get-Text "https://$Server/WebUntis/api/exams?startDate=$($monday.ToString('yyyyMMdd'))&endDate=$($sunday.ToString('yyyyMMdd'))&klasseId=-1&withGrades=false" $bearer
}
Save-Response 'weekly_data.json' {
  Get-Text "https://$Server/WebUntis/api/public/timetable/weekly/data?elementType=$personType&elementId=$personId&date=$($monday.ToString('yyyy-MM-dd'))&formatId=1"
}
Save-Response 'rest_entries.json' {
  Get-Text "https://$Server/WebUntis/api/rest/view/v1/timetable/entries?start=$($monday.ToString('yyyy-MM-dd'))&end=$($sunday.ToString('yyyy-MM-dd'))&format=1&resourceType=STUDENT&resources=$personId&timetableType=MY_TIMETABLE" $bearer
}

# Teacher timetables: the teacher list, and the first teacher from your own week.
$teacherId = $null
try {
  $own = (Get-Content (Join-Path $out 'getTimetable.json') -Raw | ConvertFrom-Json).result
  $teacherId = ($own | ForEach-Object { $_.te } | Where-Object { $_.id } | Select-Object -First 1).id
} catch {}
Save-Response 'getTeachers.json' { Invoke-Rpc 'getTeachers' @{} }
Save-Response 'teacher_pageconfig.json' {
  Get-Text "https://$Server/WebUntis/api/public/timetable/weekly/pageconfig?type=2&date=$($monday.ToString('yyyy-MM-dd'))"
}
if ($teacherId) {
  Write-Host "Lehrer-ID für den Test: $teacherId"
  Save-Response 'teacher_getTimetable.json' {
    Invoke-Rpc 'getTimetable' @{ options = @{
        element = @{ id = $teacherId; type = 2 }
        startDate = [int]$monday.ToString('yyyyMMdd'); endDate = [int]$sunday.ToString('yyyyMMdd')
        showLsText = $true; showSubstText = $true; showInfo = $true
        klasseFields = $fields; teacherFields = $fields; subjectFields = $fields; roomFields = $fields
      } }
  }
  Save-Response 'teacher_weekly_data.json' {
    Get-Text "https://$Server/WebUntis/api/public/timetable/weekly/data?elementType=2&elementId=$teacherId&date=$($monday.ToString('yyyy-MM-dd'))&formatId=1"
  }
}

# Another class (teacher timetables could be built from all class timetables).
$otherClass = $null
Save-Response 'classes_pageconfig.json' {
  Get-Text "https://$Server/WebUntis/api/public/timetable/weekly/pageconfig?type=1&date=$($monday.ToString('yyyy-MM-dd'))"
}
try {
  $classes = (Get-Content (Join-Path $out 'classes_pageconfig.json') -Raw | ConvertFrom-Json).data.elements
  $otherClass = ($classes | Where-Object { $_.id -ne $auth.result.klasseId } | Select-Object -First 1).id
} catch {}
Save-Response 'getKlassen.json' { Invoke-Rpc 'getKlassen' @{} }
if ($otherClass) {
  Write-Host "Andere Klasse für den Test: $otherClass"
  Save-Response 'class_getTimetable.json' {
    Invoke-Rpc 'getTimetable' @{ options = @{
        element = @{ id = $otherClass; type = 1 }
        startDate = [int]$monday.ToString('yyyyMMdd'); endDate = [int]$sunday.ToString('yyyyMMdd')
        showLsText = $true; showSubstText = $true; showInfo = $true
        klasseFields = $fields; teacherFields = $fields; subjectFields = $fields; roomFields = $fields
      } }
  }
  Save-Response 'class_weekly_data.json' {
    Get-Text "https://$Server/WebUntis/api/public/timetable/weekly/data?elementType=1&elementId=$otherClass&date=$($monday.ToString('yyyy-MM-dd'))&formatId=1"
  }
  Save-Response 'class_rest_entries.json' {
    Get-Text "https://$Server/WebUntis/api/rest/view/v1/timetable/entries?start=$($monday.ToString('yyyy-MM-dd'))&end=$($sunday.ToString('yyyy-MM-dd'))&format=1&resourceType=CLASS&resources=$otherClass&timetableType=STANDARD" $bearer
  }
}

# Homework and exams over a longer range (two weeks back, eight weeks ahead).
$from = $monday.AddDays(-14).ToString('yyyyMMdd')
$to = $monday.AddDays(56).ToString('yyyyMMdd')
Save-Response 'homeworks.json' {
  Get-Text "https://$Server/WebUntis/api/homeworks/lessons?startDate=$from&endDate=$to" $bearer
}
Save-Response 'exams_range.json' {
  Get-Text "https://$Server/WebUntis/api/exams?startDate=$from&endDate=$to&klasseId=-1&withGrades=false" $bearer
}

try { Invoke-Rpc 'logout' @{} | Out-Null } catch {}
Write-Host "Fertig. Dateien in $((Resolve-Path $out).Path)"
