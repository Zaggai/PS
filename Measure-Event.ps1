#requires -Version 3.0

<#PSScriptInfo
	.VERSION 1.0.0.0
	.GUID d05fef8b-7fdd-4121-988d-56788598db1a
	.AUTHOR Lasse Zaggai
	.COMPANYNAME
	.COPYRIGHT 
	.TAGS Powershell, Eventlog, Information
	.LICENSEURI 
	.PROJECTURI 
	.ICONURI 
	.EXTERNALMODULEDEPENDENCIES 
	.REQUIREDSCRIPTS 
	.EXTERNALSCRIPTDEPENDENCIES 
	.RELEASENOTES
	.DESCRIPTION This will count events found by ID and display first found date on remote computer(s).
#>

<#
	.SYNOPSIS
		This will count events on remote computer.
	.DESCRIPTION
		This will count events found by ID and display first found date on remote computer(s).
	.PARAMETER
		Computername
	.PARAMETER
		WindowsLogs
	.PARAMETER
  		EventID
	.PARAMETER
  		Credential
	.NOTES
		File Name  	: Measure-Event.ps1
		Author     	: Lasse Zaggai (LZA)
		Requires   	: PowerShell V3
		Created		: 2016-07-28
		Modified	: Friday, July 28, 2016
		Version		: 1.00 - The first edition of the script
	.ROLE
		Server Management
	.EXAMPLE
		PS C:\> Measure-Event -EventID 6000,100 -ComputerName Comp1,Comp2,Comp3 -WindowsLogs Application -Credential domain\user
		
		-----------
		This command will find count all events 6000 and 100 on the computers and dispaly the first appearance date 

			Computer				  : Comp1
			Number of ID 6000         : 0
			First instance of ID 6000 : 
			Number of ID 100          : 38
			First instance of ID 100  : 25/11/2015 14:04:34

			Computer                  : Comp2
			Number of ID 6000         : 77
			First instance of ID 6000 : 14/02/2013 09:58:09
			Number of ID 100          : 13
			First instance of ID 100  : 19/10/2014 22:29:40

			Computer                  : Comp3
			Number of ID 6000         : 0
			First instance of ID 6000 : 
			Number of ID 100          : 12
			First instance of ID 100  : 14/02/2015 14:54:37
#>

[CmdletBinding(DefaultParameterSetName = 'BySource')]
param
(
  [Parameter(ParameterSetName = 'ByID')]
  [Parameter(ParameterSetName = 'BySource', Mandatory)]
  [string[]]$ComputerName,

  [Parameter(ParameterSetName = 'ByID')]
  [Parameter(ParameterSetName = 'BySource', Mandatory)]
  [ValidateSet('Application', 'Security', 'System')]
  [String]$WindowsLogs,
  [int[]]$EventID,
  [System.Management.Automation.CredentialAttribute()][Object]$Credential
)

Begin {
  $Result       = [ordered]@{}
  $Collection   = @()
  $i            = 0 
}

Process {

  Foreach ($computer in $ComputerName) {

    Write-Progress -Id 0 -Activity 'Getting Event' -Status 'Processing Event log' -PercentComplete (($i / $ComputerName.Count) * 100)

    $PercentComplete = 33
    Write-Progress -Id 1 -Activity 'Checking event log' -Status ('Processing {0}' -f $computer) -PercentComplete ($PercentComplete)
	
    If ( $Credential )
    {
      $OutPut = Get-WinEvent -ComputerName $computer -Credential $Credential -FilterHashtable @{ Logname = $WindowsLogs; ID = $eventId } -ErrorAction SilentlyContinue
    }
    Else
    {
      Try
      {
        $OutPut = Get-WinEvent -ComputerName $computer -FilterHashtable @{ Logname = $WindowsLogs; ID = $eventId } -ErrorAction SilentlyContinue
      }
      Catch [Management.Automation.ErrorRecord ]
      {
        Write-Warning -Message ('No connection to {0}' -f $computer)
      }
      
      Finally {
      
        Write-Progress -Id 1 -Activity 'Checking event log' -Status ('Processing {0}' -f $computer) -PercentComplete ($PercentComplete + 33)      
      }
      
    }

    If ($OutPut) {
      $Result.Add('Computer', $computer )

      Foreach ($event in $eventId) {             
        $Result.Add(('Number of ID {0}' -f $event), ( $OutPut | Where-Object { ($_.ID -eq $event) } ).Count )
        $Result.Add(('First instance of ID {0}' -f $event), ( $OutPut | Where-Object { ($_.ID -eq $event) } | Sort-Object | Select-Object -Last 1 | Select-Object).TimeCreated )
      }        
    
      $Collection += [pscustomobject] $Result
    
    }
    
    $Result.Clear()
    
    Write-Progress -Id 1 -Completed -Activity 'Checking event log'
    $i++   

    Write-Progress -Id 0 -Completed -Activity 'Getting Event'
  }
}


End {
  $Collection
}
