poshGetProcessOwner
===================

PowerShell function used to help find user-context ownership for processes/services

TODO List
+ Add progress information - COMPLETED
+ Add proper error logging - COMPLETED (debating taking directly from $Error so the error object type isn't lost as a result of -ErrorAction)
+ Finish adding functionality for alternate credentials (Get-WmiObject throws an error saying it will not accept credentials for local queries)

Special to the following people/resources:

@concentrateddon - Don Jones
@darkoperator - Carlos Perez
@juneb_get_help - June Blender and MS Help Documentation Team et. al (Get-Help -eq "Awesome")
@JeffHicks - Jeffery Hicks
Manning Publications (Good technical books that aren't a dry read!)
