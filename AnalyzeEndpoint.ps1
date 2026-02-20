<#
.SYNOPSIS
    Easy Endpoint Auditor (EEA) - Automated Forensic Triage Tool
.DESCRIPTION
    Automated collector for Persistence, Network, and Security artifacts.
.AUTHOR
    [ashwanth-saran/GitHub Username]
.DATE_CREATED
    2026-02-20
#>

# 1. SETUP LOGGING
$LogDir = "C:\Users\Public\SOC_Tools\SOC_Logs"
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir }
$LogFile = "$LogDir\Analysis_Report_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"

Start-Transcript -Path $LogFile -Append

Write-Host "=========================================================="
Write-Host "SYSTEM SNAPSHOT: $(Get-Date)"
Write-Host "Endpoint IP: $((Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' } | Select-Object -First 1).IPAddress)"
Write-Host "Logged User: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
Write-Host "=========================================================="

# 2. NETWORK ANALYSIS
Write-Host "`n[!] NETWORK: Active Established Connections..." -ForegroundColor Yellow
Get-NetTCPConnection -State Established | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, 
    @{N='ProcessName';E={(Get-Process -Id $_.OwningProcess).ProcessName}},
    @{N='PID';E={$_.OwningProcess}} | Format-Table -AutoSize

# 3. PERSISTENCE AUDIT
Write-Host "`n[!] PERSISTENCE: Checking Registry and Tasks..." -ForegroundColor Yellow
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider | Format-List
Get-ScheduledTask | Where-Object { $_.State -eq "Ready" -and $_.TaskPath -notlike "\Microsoft*" } | Select-Object TaskName, @{N='Command';E={$_.Actions.Execute}} | Format-Table -AutoSize

# 4. SUSPICIOUS PROCESS PATHS
Write-Host "`n[!] PROCESSES: Searching Temp/AppData Execution..." -ForegroundColor Red
Get-Process | Where-Object { $_.Path -like "*\Temp\*" -or $_.Path -like "*\AppData\Local\*" } | Select-Object Name, Id, Path | Format-Table -AutoSize

# 5. SECURITY EVENT AUDIT
Write-Host "`n[!] SECURITY LOGS: Checking for Brute Force & Admin Usage..." -ForegroundColor Cyan
$FailedLogons = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=(Get-Date).AddDays(-1)} -ErrorAction SilentlyContinue
$AdminShells = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4688; StartTime=(Get-Date).AddDays(-1)} -ErrorAction SilentlyContinue | Where-Object {$_.Properties[8].Value -eq "%%1937"}

Write-Host "Failed Logon Attempts (Last 24H): $($FailedLogons.Count)"
Write-Host "Admin Privilege Shells (Last 24H): $($AdminShells.Count)"

Stop-Transcript
