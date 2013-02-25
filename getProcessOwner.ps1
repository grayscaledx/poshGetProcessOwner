Function Get-ProcessOwner{
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
Get-ProcessOwner -ComputerName dathost
Gets all processes on target 'dathost'
#>
[CmdletBinding()]
param(
    [Parameter(HelpMessage="A target computer host name or IP address to query.",
               ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True)]
    [string[]]$ComputerName = 'localhost',
    [Parameter(HelpMessage="A valid username to check processes against.")]
    $UserAccount = $null,
    [Parameter(HelpMessage="Enable if you want to filter for service ownership only")]
    [switch]$ServicesOnly
)


BEGIN {
    Write-Verbose "Initializing results object..."
    $processContainer = @()
    Write-Verbose "User Account is null: $($UserAccount -eq $null)"
}
PROCESS {
        foreach ($CurrentComputer in $ComputerName){

            Write-Verbose "Querying target $CurrentComputer for running services via WMI..."
            $CurrentServices = Get-WmiObject -ComputerName $CurrentComputer win32_service
            
            Write-Verbose "Querying target $CurrentComputer for processes via WMI..."
            $CurrentProcesses = Get-WmiObject -ComputerName $CurrentComputer win32_process

            Write-Verbose "Processes Received; Building Query Object..."
            foreach ($ComputerProcess in $CurrentProcesses){           
                
                #Write-Debug "ComputerProcess PID is $($ComputerProcess.ProcessID) and type is $($ComputerProcess.ProcessID.GetType().Fullname)"
                #Write-Debug "ComputerServices PIDs are $($CurrentServices.ProcessID) and type is $($CurrentServices.ProcessID.GetType().Fullname)"
                #Write-Debug "Is the current process ID in the service pool? $($CurrentServices.ProcessID -contains $ComputerProcess.ProcessID)`n`n"

                #Write-Verbose "Checking if ProcessID $ComputerProcess.ProcessID is a service..."
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
                $processContainer += $processObj
                
                <#
                Found the way to compare running process IDs and service IDs to filter for services
                running under a user context using Compare-Object
                
                $processes = Get-Wmiobject -ComputerName <computerName> win32_process
                $services = Get-Wmiobject -ComputerName <computerName> win32_service
                $servicePids = Compare-Object $processes.ProcessID $services.ProcessID -IncludeEqual -ExcludeDifferent | Sort-Object -Property InputObject | Select-Object -ExpandProperty InputObject
                
                $servicePids will contain a sorted list of process IDs of services.  This is only required to tie to user $processes.GetOwner().User for services user ownership.
                #>

            }
        }
}
END {
    # lazy man's forced formatting.  will work on custom XML later
    Write-Output $processContainer #| Format-Table -Property ComputerName, ProcessOwner, ProcessName, Commandline
}

}
