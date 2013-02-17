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
    [string[]]$ComputerName = 'localhost'
)


BEGIN {
    Write-Verbose "Initializing results object..."
    $processContainer = @()
}
PROCESS {
        foreach ($CurrentComputer in $ComputerName){

            Write-Verbose "Querying host $CurrentComputer for processes via WMI..."
            $CurrentProcesses = Get-WmiObject -ComputerName $CurrentComputer win32_process

            Write-Verbose "Processes Received; Building Query Object..."
            foreach ($ComputerProcess in $CurrentProcesses){           
                $processProps = @{
                                    'ProcessOwner'=$ComputerProcess.GetOwner().User;
                                    'ProcessName'=$ComputerProcess.ProcessName;
                                    'CommandLine'=$ComputerProcess.CommandLine;
                                    'ComputerName'=$ComputerProcess.PSComputerName
                                 }
                $processObj = New-Object -TypeName psobject -Property $processProps
                $processContainer += $processObj

            }
        }
}
END {
    # lazy man's forced formatting.  will work on custom XML later
    Write-Output $processContainer #| Format-Table -Property ComputerName, ProcessOwner, ProcessName, Commandline
}

}