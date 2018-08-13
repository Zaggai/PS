		function Get-WinEventLogs
		{
			[CmdletBinding(DefaultParameterSetName = 'SearchingByDate')]
			param
			(
				[Parameter(ParameterSetName = 'SearchingByTime')]
				[int]$Hours = 4,
				[Parameter(ParameterSetName = 'SearchingByDate')]
				[int]$Days = 1,
				[string[]]$computername,
				[int[]]$IncludeID = (446,1157),
				[int[]]$ExcludeID,
				[Parameter(ParameterSetName = 'SearchingByMinute')]
				[int]$Minute
			)
			
			function Get-SAXODomainCredential
			{
				param ($DNS)
				
				switch ($DNS)
				{
					'mid' { Return $midas2 }
					'sys' { Return $sys }
					'tst2' { Return $tst2 }
					'dmz' { Return $DMZ }
				}
			}
			
			$OutPut       = @()
			
			switch ($PsCmdlet.ParameterSetName)
			{
				'SearchingByDate' {
					If ($Days -gt 0) { $Days = $Days * -1 }
					$StartTimestamp = (get-date).AddDays($Days)
				}
				
				'SearchingByTime' {
					If ($Hours -gt 0) { $Hours = $Hours * -1 }
					$StartTimestamp = (get-date).AddHours($Hours)
				}
				
				'SearchingByMinute' {
					If ($Minute -gt 0) { $Minute = $Minute * -1 }
					$StartTimestamp = (get-date).AddMinutes($Minute)
				}
				
			}
			
			$EndTimeStamp = get-date
	
			Foreach ($computer in $computername)
			{
				Try
				{
					$output += Get-WinEvent -ComputerName $computer -Credential $(Get-SAXODomainCredential -Dns (Resolve-DnsName $computer).Name.split('.')[1]) -FilterHashTable @{ ProviderName = 'SaxoAdmService'; StartTime = $using:StartTimestamp } -ErrorAction SilentlyContinue |
					Select-Object Machinename, TimeCreated, Id, LevelDisplayName, Message
				}
				Catch
				{
					$RemoteSession =  New-PSSession -ComputerName $computer -Credential $(Get-SAXODomainCredential -Dns (Resolve-DnsName $computer).Name.split('.')[1])
					
					$Output        += Invoke-Command -Session $RemoteSession -ScriptBlock {
						$result = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashTable @{ ProviderName = 'SaxoAdmService'; StartTime = $using:StartTimestamp } |
						Select-Object Machinename, TimeCreated, Id, LevelDisplayName, Message
						Return $result
					}
					Get-PSSession | Remove-PSSession
				}
			}

			If ($IncludeID)
			{
				$OutPut | Where-Object { $_.Id -notin $ExcludeID} | Where-Object { $_.Id -in $IncludeID } | Select-Object -Property TimeCreated,Id,PSComputerName,Message #Format-Table -Property TimeCreated,Id,PSComputerName,Message -Wrap
			}
			Else
			{
				$OutPut | Where-Object { $_.Id -notin $ExcludeID} 
			}		
		}
		
		Export-ModuleMember -Function Get-WinEventLogs
		