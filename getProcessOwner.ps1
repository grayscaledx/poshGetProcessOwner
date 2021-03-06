﻿Function Get-ProcessOwner{
<#
.SYNOPSIS
Queries target computer for current processes and collects process owners, process name, and command line arguments used for execution.

.DESCRIPTION
Queries the target computer for all processes that are running on the selected target or targets.  The level of privilege used to execute
the function will dictate the scope of the information returned.  If you're looking for all processes to be returned from a target destination,
the appropriate administrative level will be required.

The current version of the function will only passthrough the current account the function is executed as to any remote systems.

.PARAMETER ComputerName
The name or IP address of the target host to query.

.EXAMPLE
Get-ProcessOwner -ComputerName 192.168.100.15
Returns all processes on target host at IP address 192.168.100.15.

.EXAMPLE
Get-ProcessOwner -ComputerName ApplicationServer01.contoso.com | Where-Object {$_.IsService -eq $True}
(This example is compatible with PowerShell 2.0 and later)
Returns all services running on target host ApplicationServer01.contoso.com.

.EXAMPLE
Get-ProcessOwner -ComputerName ApplicationServer01.contoso.com | Where-Object -Property IsService -eq $True
(This example is compatible with PowerShell 3.0 and later)
Returns all services running on target host ApplicationServer01.contoso.com.

.EXAMPLE
Get-ProcessOwner -ComputerName ApplicationServer01.contoso.com | Where-Object {$_.ProcessOwner -match "appSvcUser"}
(This example is compatible with PowerShell 2.0 and later)
Returns all processes running under the appSvcUser user context (irrespective of domain) on target host ApplicationServer01.contoso.com.

.EXAMPLE
Get-ProcessOwner -ComputerName ApplicationServer01.contoso.com | Where-Object -Property ProcessOwner -eq "SYSTEM"
(This example is compatible with PowerShell 3.0 and later)
Returns all processes running under the local SYSTEM user context on target host ApplicationServer01.contoso.com.
#>
[CmdletBinding()]
param(
    [Parameter(HelpMessage="A target computer host name or IP address to query.",
               ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True)]
    [string[]]$ComputerName = 'localhost',
    [Parameter(HelpMessage="A valid username to check processes against.")]
    $UserAccount = $null
)


BEGIN {
    Write-Verbose "Initializing results object..."
    $processContainer = @()
    Write-Verbose "User Account is null: $($UserAccount -eq $null)"
}
PROCESS {
        foreach ($CurrentComputer in $ComputerName){

        try{

                Write-Verbose "Querying target $CurrentComputer for processes via WMI..."
                $CurrentProcesses = Get-WmiObject -ComputerName $CurrentComputer win32_process -ErrorAction Stop

                Write-Verbose "Querying target $CurrentComputer for running services via WMI..."
                $CurrentServices = Get-WmiObject -ComputerName $CurrentComputer win32_service -ErrorAction Stop
            
                Write-Verbose "Processes Received; Building Query Object..."
                foreach ($ComputerProcess in $CurrentProcesses){           

                    if ($CurrentServices.ProcessID -contains $ComputerProcess.ProcessID){
                        Write-Verbose "ProcessID $($ComputerProcess.ProcessID) `/ $($ComputerProcess.ProcessName) is a service..."
                        $isService = $True
                    } else {
                        $isService = $False
                    }
                
                    $processProps = @{
                                        'ProcessOwner'=$ComputerProcess.GetOwner().User;
                                        'ProcessName'=$ComputerProcess.ProcessName;
                                        'ProcessID'=$ComputerProcess.ProcessID;
                                        'CommandLine'=$ComputerProcess.CommandLine;
                                        'ComputerName'=$ComputerProcess.PSComputerName
                                        'IsService'=$isService
                                     }
                    $processObj = New-Object -TypeName psobject -Property $processProps
                    $processObj.PSObject.TypeNames.Insert(0,'GDX.ProcessOwner')
                    $processContainer += $processObj
                            
                }
            }

        catch [System.Exception] {Write-Output "WMI query failed on $CurrentComputer.  Please run with Verbose option for more information"}

        catch {Write-Output "Something unexpected occurred..."}

        Write-Verbose "Finished processing query on target -- $CurrentComputer"

        }
        
}
END {}

}
