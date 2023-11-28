<#
.Synopsis
Created on:   25/10/2023
Created by:   Mateus Nubile


Simple script to install a SHARED printer on network

#### Win32 app Commands ####

Install:
powershell.exe -executionpolicy bypass -file InstallPrinterSamsung.ps1 -PrinterName "\\10.10.12.11\BRA_STS_Terminal_Samsung_M4070_Azure"
powershell.exe -executionpolicy bypass -file UninstallPrinterSamsung.ps1 -PrinterName "\\10.10.12.11\BRA_STS_Terminal_Samsung_M4070_Azure"

Detection:
HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PrinterPorts
\\10.10.12.11\BRA_STS_Operacional_Samsung_M4080_Azure
#>

[CmdletBinding()]
Param (
        
    [Parameter(Mandatory = $True)]
    [String]$PrinterName
    
)

#Reset Error catching variable
$Throwbad = $Null
 


function Write-LogEntry {
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,
        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "logPrinterSamsung.log",
        [switch]$Stamp
    )

    #Build Log File appending System Date/Time to output
    $LogFile = Join-Path -Path $env:SystemRoot -ChildPath $("Temp\$FileName")
    $Time = -join @((Get-Date -Format "HH:mm:ss.fff"), " ", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))
    $Date = (Get-Date -Format "MM-dd-yyyy")

    If ($Stamp) {
        $LogText = "<$($Value)> <time=""$($Time)"" date=""$($Date)"">"
    }
    else {
        $LogText = "$($Value)"   
    }
	
    Try {
        Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $LogFile -ErrorAction Stop
    }
    Catch [System.Exception] {
      #Write-Warning -Message "Unable to add log entry to $LogFile.log file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
    }
}

Write-LogEntry -Value "##################################"
Write-LogEntry -Stamp -Value "Installation started"
Write-LogEntry -Value "##################################"
Write-LogEntry -Value "Install Printer using the following values..."
#Write-LogEntry -Value "Port Name: $PortName"
#Write-LogEntry -Value "Printer IP: $PrinterIP"
Write-LogEntry -Value "Printer Name: $PrinterName"
#Write-LogEntry -Value "Driver Name: $DriverName"
#Write-LogEntry -Value "INF File: $INFFile"


If (-not $ThrowBad) {
    Try {

        #Add Printer
        $PrinterExist = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
        if (-not $PrinterExist) {
            Write-LogEntry -Stamp -Value "Adding Printer ""$($PrinterName)"""
            Add-Printer -ConnectionName $PrinterName
        }
        else {
            Write-LogEntry -Stamp -Value "Printer ""$($PrinterName)"" already exists. Removing old printer..."
            Remove-Printer -Name $PrinterName -Confirm:$false
            Write-LogEntry -Stamp -Value "Adding Printer ""$($PrinterName)"""
            Add-Printer -connectionName $PrinterName
        }

        $PrinterExist2 = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
        if ($PrinterExist2) {
            Write-LogEntry -Stamp -Value "Printer ""$($PrinterName)"" added successfully"
        }
        else {
            Write-Warning "Error creating Printer"
            Write-LogEntry -Stamp -Value "Printer ""$($PrinterName)"" error creating printer"
            $ThrowBad = $True
        }
    }
    Catch {
        Write-Warning "Error creating Printer"
        Write-Warning "$($_.Exception.Message)"
        Write-LogEntry -Stamp -Value "Error creating Printer"
        Write-LogEntry -Stamp -Value "$($_.Exception)"
        $ThrowBad = $True
    }
}

If ($ThrowBad) {
    Write-Error "An error was thrown during installation. Installation failed. Refer to the log file in %temp% for details"
    Write-LogEntry -Stamp -Value "Installation Failed"
}