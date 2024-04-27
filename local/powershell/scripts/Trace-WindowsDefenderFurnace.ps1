#Requires -RunAsAdministrator
<#
.SYNOPSIS
Trace Windows Defender when it turns your laptop into a furnace.
.DESCRIPTION
Trace why Windows Defender is consuming large amounts of recouces by
generating a trace report and then displaying the top consumers.
.PARAMETER KeepTraceFile
Do not automatically delete the *.etl file after the trace.
.NOTES
*.etl files may contain sensitive or privlidged data. This script
generated *.etl files at c:\.
#>
param([switch]$KeepTraceFile)

$traceFile = Join-Path 'c:\' defender-trace.etl # save privlidged data to drive root

New-MpPerformanceRecording -recordto $traceFile # Interactive. Starts tracing and requires user to press 'enter' to stop.

# Show info about the trace.
Get-MpPerformanceReport -TopProcesses 10 $TraceFile 
Get-MpPerformanceReport -TopScans 10 $TraceFile 
Get-MpPerformanceReport -TopFiles 10 $TraceFile 
Get-MpPerformanceReport -TopPaths 10 $TraceFile 
Get-MpPerformanceReport -TopExtensions 10 $TraceFile  # File extensions

# Delete the trace.
if (-not $KeepTraceFile) { Remove-Item $traceFile }