# --- CONFIGURATION: Define Log Path ---
$LogDir = "C:\Users\Public\SOC_Logs"
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir }
$LogFile = "$LogDir\Report_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"

# Start Recording everything to the text file
Start-Transcript -Path $LogFile -Append

Write-Host "=========================================================="
Write-Host "SOC ENDPOINT TRIAGE REPORT"
Write-Host "Timestamp: $(Get-Date)"
Write-Host "System IP: $((Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' } | Select-Object -First 1).IPAddress)"
Write-Host "Run As: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
Write-Host "=========================================================="

# 1. PERSISTENCE CHECK (Auto-runs)
Write-Host "`n[!] PERSISTENCE: Checking Auto-Start locations..." -ForegroundColor Yellow
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider | Format-List
Get-ScheduledTask | Where-Object { $_.State -eq "Ready" -and $_.TaskPath -notlike "\Microsoft*" } | Select-Object TaskName, @{N='Command';E={$_.Actions.Execute}} | Format-Table -AutoSize

# 2. NETWORK CONNECTIONS (C2 Beacons)
Write-Host "`n[!] NETWORK: Active Established Connections..." -ForegroundColor Yellow
Get-NetTCPConnection -State Established | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, 
    @{N='Process';E={(Get-Process -Id $_.OwningProcess).ProcessName}} | Format-Table -AutoSize

# 3. SUSPICIOUS PROCESSES (Execution in Temp/AppData)
Write-Host "`n[!] PROCESSES: Running from suspicious paths..." -ForegroundColor Red
Get-Process | Where-Object { $_.Path -like "*\Temp\*" -or $_.Path -like "*\AppData\Local\*" } | Select-Object Name, Id, Path | Format-Table -AutoSize

# 4. SECURITY LOG AUDIT (Last 24 Hours)
Write-Host "`n[!] SECURITY LOGS: Failed Logons and Admin Usage..." -ForegroundColor Cyan
$FailedLogons = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=(Get-Date).AddDays(-1)} -ErrorAction SilentlyContinue
$AdminShells = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4688; StartTime=(Get-Date).AddDays(-1)} -ErrorAction SilentlyContinue | Where-Object {$_.Properties[8].Value -eq "%%1937"}

Write-Host "Count of Failed Logons: $($FailedLogons.Count)"
Write-Host "Count of Admin Shells:  $($AdminShells.Count)"

# 5. COMMAND HISTORY (Last 20 commands)
Write-Host "`n[!] SHELL HISTORY: Most recent PowerShell commands..." -ForegroundColor Green
try { Get-Content (Get-PSReadlineOption).HistorySavePath -Tail 20 } catch { "No history file found." }

Write-Host "`n=========================================================="
Write-Host "ANALYSIS COMPLETE. Log saved to: $LogFile"
Write-Host "=========================================================="

Stop-Transcript