Function Get-ProcessOwner{
<#
.SYNOPSIS
Queries target computer for current processes and collects process owners, process name, and command line arguments used for execution.
.DESCRIPTION
Queries the target computer for all processes that are running on the selected target or targets.  The level of privilege used to execute
the function will dictate the scope of the information returned.  If you're looking for all processes to be returned from a target destination,
the appropriate administrative level will be required.
.PARAMETER

.EXAMPLE

#>
[CmdletBinding()]
param(

)


BEGIN {}
PROCESS {

}
END {}

}