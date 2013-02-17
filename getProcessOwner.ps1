Function Get-ProcessOwner{
<#
.SYNOPSIS
Queries target computer for current processes and collects process owners, process name, and command line arguments used for execution.
.DESCRIPTION
Queries the target computer for all processes that are running on the selected target or targets.  The level of privilege used to execute
the function will dictate the scope of the information returned.  If you're looking for all processes to be returned from a target destination,
the appropriate administrative level will be required.
.PARAMETER ComputerName
The name or IP address of the target host to query.
.EXAMPLE
Hello World!
#>
[CmdletBinding()]
param(
    [Parameter(HelpMessage="A target computer host name or IP address to query.",
               ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True)]
    [string[]]$ComputerName = 'localhost'
)


BEGIN {
    $ComputerProcesses = $ComputerName | ForEach-Object { Get-WmiObject -ComputerName $ComputerName win32_process }
}
PROCESS {
    foreach ($TargetComputer in $ComputerProcesses){
        Write-Output $TargetComputer
    }
}
END {}

}