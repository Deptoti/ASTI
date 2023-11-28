<#
.Synopsis
Created on:   25/10/2023
Created by:   Mateus Nubile


powershell.exe -executionpolicy bypass -file .\Remove-Printer.ps1 -PrinterName "BRA_STS_Terminal_Samsung_M4070_Azure"

.Example
.\Remove-Printer.ps1 -PrinterName "BRA_STS_Terminal_Samsung_M4070_Azure"
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $True)]
    [String]$PrinterName
)

Try {
    #Remove Printer
    $PrinterExist = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
    if ($PrinterExist) {
        Remove-Printer -Name $PrinterName -Confirm:$false
    }
}
Catch {
    Write-Warning "Error removing Printer"
    Write-Warning "$($_.Exception.Message)"
}