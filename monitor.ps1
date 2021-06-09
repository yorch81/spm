################################################################################# 
## 
## Simple Performance Monitor
## 
################################################################################ 

$computername = $env:COMPUTERNAME

## Gets CPU usage
$AVGProc = Get-WmiObject -computername $computername win32_processor | 
Measure-Object -property LoadPercentage -Average | Select Average

## Gets RAM usage
$OS = gwmi -Class win32_operatingsystem -computername $computername |
Select-Object @{Name = "MemoryUsage"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }}

## Gets Drive C usage
$vol = Get-WmiObject -Class win32_Volume -ComputerName $computername -Filter "DriveLetter = 'C:'" |
Select-object @{Name = "C PercentFree"; Expression = {“{0:N2}” -f  (($_.FreeSpace / $_.Capacity)*100) } }

## Gets usage
$uCPU = $AVGProc.Average
$uRAM = $OS.MemoryUsage
$uDrvC = $vol.'C PercentFree'

$result += [PSCustomObject] @{ 
        ServerName = "$computername"
        CPULoad = "$($AVGProc.Average)%"
        MemLoad = "$($OS.MemoryUsage)%"
        CDrive = "$($vol.'C PercentFree')%"
    }

Foreach($Entry in $result) {
    $CurTime = Get-Date -Format "dd/MM/yyyy HH:mm"

    $txtMon = $CurTime + "," + $Entry.CPULoad + "," + $Entry.MemLoad + "," + $Entry.CDrive
}
 
$CurDate = Get-Date -Format "dd_MM_yyyy"

$fileMon = "C:\monitor\monitor_" + ($CurDate) + ".csv"

if(![System.IO.File]::Exists($fileMon)){
    $headerMon = "DateTime" + "," + "CPU Usage" + "," + "RAM Usage" + "," + "Free Space C"

    Add-Content $fileMon $headerMon
}

## Write monitor log
Add-Content $fileMon $txtMon

## CPU alert greater than 85 perc
if($uCPU -gt 85){
	Write-Host "Sending CPU alert"
}

## RAM alert greater than 85 perc
if($uRAM -gt 85){
	Write-Host "Sending Memory alert"
}

## Drive C alert lower than 15 perc
if($uDrvC -lt 15){
	Write-Host "Sending Disk alert"
}