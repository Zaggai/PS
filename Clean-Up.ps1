<#
	.SYNOPSIS
		Clean up old (delete, move or zip) files you decided
		
		Use at your own risk. If you do not understand what this scipt does or how it has impact on your system - test it.
	
	.DESCRIPTION
		This script will either delete, move or zipfiles from folders and files you specify. You can specify age or size as filter as well.
		A log file is written each time this script run for check the of results or troubleshoot any issues.
		The recommended to use this script with -WhatIf parameter before
	
	.PARAMETER Path
		Mandatory - Specifies the path to the locations of files.
	
	.PARAMETER ExcludePath
		Omits the specified directories. Enter pattern, such as "D:\Logs\Old\", "D:\Logs\O*", "D:\Logs\Old*", *Old* or d:\*\old\
	
	.PARAMETER IncludeFile
		Mandatory - Specified the files you want to include. Enter pattern, such as "*.txt", "*.tx?" or "note*.*". Wildcards are permitted.
	
	.PARAMETER ExcludeFile
		Omits the specified files. Enter pattern,  such as "*.txt", "*.tx?" or "note*.*". Wildcards are permitted.
	
	.PARAMETER Age
		Age in days
	
	.PARAMETER Size
		Size of files - Can be defined as MB, KB or GB eg. 1 MB or 20 GB - Default is in KB.
	
	.PARAMETER Recurse
		Retrive files in the specified locations and in all child items of the locations.
	
	.PARAMETER Action
		Please choose whether you want to Delete, Move or Compress(Zip) the files
	
	.PARAMETER Logfile
		Name of log file to be created. Example: TodayDeletedFiles.log.
		Default is the current users temp directory
	
	.PARAMETER Force
		Will delete files without any confirmation.
	
	.PARAMETER Logpath
		Path where the log file to be created. Example: c:\Logs\
		Default is the current users temp directory
	
	.PARAMETER CompressMethod
		Valid method is ZipEveryFileSeparately or ConcatenateFilesIntoSingleZip.
	
	.PARAMETER ConcatenatedFileName
		When ConcatenateFilesIntoSingleZip as the compression method is chosen a valid filename is mandatoy
	
	.PARAMETER IncludePath
		Qualifies the directories. Enter pattern, such as "c:\Logs", "D:\Logs".
	
	.PARAMETER Zip
		Move the files you specify to a zip with same name as original instead of just deletion.
	
	.PARAMETER Move
		Moved the file to a folder named by the current date.
	
	.PARAMETER Delete
		Deletes the files
	
	.PARAMETER Whatif
		Shows the files would have been modified if the cmdlet runs. No files will be touched.
	
	.EXAMPLE
		PS C:\> Clean-Up.ps1 -Path 'C:\Logs\' -IncludeFile "*.csv" -Recurse -WhatIf
		Description
		-----------
		This command will display all files with extension '*.csv' in 'C:\Logs\' and Subfolders, which is possible to be deleted.
	
	.EXAMPLE
		PS C:\> Clean-Up.ps1 -Path 'C:\Logs\', 'D:\Logs' -IncludeFile "*.csv",'*.txt' -Recurse
		Description
		-----------
		This command will delete all files with extension '*.csv' and '*.txt' in 'C:\Logs\' and 'D:\Logs' and all subfolders.
	
	.EXAMPLE
		PS C:\> Clean-Up.ps1 -Path 'C:\Logs\', 'D:\Logs' -IncludeFile "*.csv",'*.txt' -ExcludeFile 'Notes*.*' -Recurse
		Description
		-----------
		This command deletes all files with extension '*.csv' and '*.txt', but not files which starts with 'Notes*' in directory 'C:\Logs\' and 'D:\Logs' and all subfolders.
	
	.EXAMPLE
		PS C:\> Clean-Up.ps1 -Path 'C:\Logs\', 'D:\Logs' -IncludeFile "*.csv",'*.txt' -ExcludePath 'D:\Logs\DoNotInclude' -ExcludeFile 'Notes*.*' -Recurse -WhatIf
	
	.EXAMPLE
		PS C:\> Clean-Up.ps1 -Path 'C:\Logs\', 'D:\Logs' -Age 60 -Recurse
		Description
		-----------
		This command deletes all files in 'C:\Logs\' and 'D:\Logs' which are older than 60 days
	
	.EXAMPLE
		PS C:\> Clean-Up.ps1 -Path 'C:\Logs\', 'D:\Logs' -IncludeFile '*.*' -Size 10mb -Recurse
		Description
		-----------
		This command deletes all files in 'C:\Logs\' and 'D:\Logs' and all subfolders which are over 10 mb.
	
	.EXAMPLE
		PS C:\> Clean-Up.ps1 -Path 'D:\Logs\' -IncludeFile * -ExcludePath 'D:\Logs\DoNotInclude' -Action Zip -CompressMethod ZipEveryFileSeparately
		Description
		-----------
		This command will zip into single zip files and delete all the original files in 'D:\Logs' and all subfolders, exclude 'D:\Logs\DoNotInclude'
	
	.EXAMPLE
		PS C:\> Clean-Up.ps1 -Path 'D:\Logs\' -IncludeFile * -ExcludePath 'D:\Logs\DoNotInclude' -Action Zip -CompressMethod ConcatenateFilesIntoSingleZip
		Description
		-----------
		This command will zip into zip files, one per directory, and delete all the original files in 'D:\Logs' and all subfolders, exclude 'D:\Logs\DoNotInclude'
	
	.NOTES
		File Name	: Clean-Up.ps1
		Author		: Lasse Zaggai (LZA)
		Requester	: Jacob Langballe Jensen (JLJ)
		Requires	: PowerShell V3 and .\Write-Log.ps1
		Created		: 2015-12-09
		Modified	: Tuesday, November 8, 2016 11:05:02 AM
		Version		: 0.16 - The first edition of the script - Please feel free to contribute to improve this script.
					: 0.17 - Updated log event.
					: 0.18 - Move-Files, Use-ExeFile and Zip-Files function added.
					: 0.19 - Possibility to specify the placement of the log file.
					: 0.20 - Support for long file names and the filename can contain spaces.
					: 0.21 - Added parameter for logfile and logpath and changed Parameters.Values from ParametersSet.parameters as they entered twice in the log.
					: 0.22 - Use \Program Files\7-Zip as first choice when seeking for Zip
					: 0.23 - Modified logfile parameter to a default value 'environment:saxologs \30DaysRetention\Clean-Up\'
							 logfile parameter to a default value 'environment:saxologs \30DaysRetention\Clean-Up\'
					: 0.50 - Modified the way Write-Log being called, PSDefaultParameterValues, MyInvocation values
							 Get-Files, Get-ChildItem parameters, the ValidateScript script, added function StringIsNullOrWhitespace .... and a lots of small tweaks to make it compatible with PS2 :(
					: 0.51 - Option to select if every file should be compressed separately or concatenate into a single zip file
					: 0.52 - Minor adjustments to Get-Files for getting the include parameter to work
					: 0.53 - Added parameter for ConcatenatedFileName
					: 0.54 - Test
		
		TFSnotes	: $/PT ES Operations/Test/IT Infrastructure Maintenance/CleanUpScript
	
	.LINK
		
	
	.ROLE
		Maintence
#>
[CmdletBinding(DefaultParameterSetName = 'LogFile',
			   ConfirmImpact = 'High',
			   SupportsShouldProcess = $true)]
param
(
	[Parameter(HelpMessage = 'Specifies the path to the locations of files')]
	$Path,
	[Parameter(HelpMessage = 'Omits the specified locations from the value defined in Path')]
	$ExcludePath,
	[Parameter(Mandatory = $true,
			   HelpMessage = 'Specified pattern of files, such as "*.txt", "note*.*". Wildcards are permitted.')]
	[String[]]$IncludeFile,
	[String[]]$ExcludeFile,
	[Parameter(HelpMessage = 'Searching Files by days, find files that are older than a entered days from current date')]
	[System.Int32]$Age,
	[Parameter(HelpMessage = 'Searching Files by Size, find files that are larger than a entered size')]
	[System.Int64]$Size,
	[switch]$Recurse,
	[Parameter(Mandatory = $true,
			   HelpMessage = 'Please choose whether you want to Delete, Move or Compress(Zip) the files')]
	[ValidateSet('Zip', 'Move', 'Delete')]
	[String]$Action,
	[Parameter(ParameterSetName = 'LogFile')]
	[ValidateScript({
			If (Test-Path $(Split-Path $_ -Parent))
			{ Return $true }
			Else
			{
				Try
				{
					New-Item -Path $(Split-Path $_ -Parent) -ItemType directory -Force
					Return $true
				}
				Catch
				{
					$Host.UI.WriteErrorLine("The path '$(Split-Path $_ -Parent)' does not exist.")
					throw "$(Split-Path $_ -Parent) Does not exist"
				}
			}
		})]
	[String]$Logfile = $(Try
		{
			$(Join-Path $(Get-ChildItem Env:Saxologs -ErrorAction SilentlyContinue).Value -ChildPath '\30DaysRetention\' |
				Join-Path -ChildPath $(Get-Variable -Name MyInvocation -Scope Script).Value.Mycommand.Name.replace('.ps1', '') |
				Join-Path -ChildPath $($((Get-Date -format "dd-MM-yyyy").ToString()) + '_' + $(Get-Variable -Name MyInvocation -Scope Script).Value.Mycommand.Name.replace('.ps1', '.log')))
		}
		Catch { }),
	[Switch]$Force,
	[Parameter(ParameterSetName = 'LogPath')]
	[ValidateScript({
			If (Test-Path $(Split-Path $_ -Parent))
			{
				If (-not (Test-Path -LiteralPath $_ -ErrorAction SilentlyContinue))
				{ New-Item -Path $_ -ItemType directory -Force }
				Return $true
			}
			Else { throw "$(Split-Path $_ -Parent) Does not exist" }
		})]
	[String]$Logpath,
	[ValidateSet('ZipEveryFileSeparately', 'ConcatenateFilesIntoSingleZip')]
	[String]$CompressMethod,
	[ValidateScript({
			if ($_.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -gt 0)
			{
				Throw "`n>>>> $_ contains invalid characters - Only filename are valid. Do not use a absolute path in filename <<<< `n"
			}
			Else
			{
				Return $true
			}
		})]
	[String]$ConcatenatedFileName
)

BEGIN
{
	$CurrentHost = $PSVersionTable.PSVersion.Major
	
	New-Variable -Name FileList
	
	function Validate-Parameter
	{
		Process
		{
			$continue = $true
			
			foreach ($Directory in $Path)
			{
				If ($Directory.Length -le 3)
				{
					Write-Log "Wrong path $Directory" -Loglevel Error -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
					$Continue = $False
					Return
				}
			}
			
			If ($ExcludePath)
			{
				If (-not $Recurse)
				{
					Write-Log "Pls. be aware that 'ExcludePath' are only accepted when using 'Recurse'" -Loglevel Error -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
					$Continue = $False
					Return
				}
			}
		}
		
		End
		{
			If (-not $continue)
			{
				Write-Log -LogTask LogFinish
				Exit - $($MyInvocation.ScriptLineNumber)
			}
			Else
			{
				$CurrentScriptName = (Get-Variable MyInvocation -Scope 1).Value.MyCommand.Definition
				
				Write-Log "Signature: $($(Get-AuthenticodeSignature -FilePath $CurrentScriptName).Status)" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				
				Write-Log "Running version: $($($(Get-Content $CurrentScriptName | Where-Object { $_ -match ': \d*\.\d*' })[-1]).Split('-')[0].Replace(': ', '').Trim())" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				
				Try
				{
					$command = Get-Command $CurrentScriptName
					
					foreach ($Param in $(Get-Command ($command.definition)).Parameters.Values | Where-Object { ($_.Aliases.Count -eq 0) })
					{
						Write-Log ("Parameter: $($Param.Name) : " + $(Get-Variable ($Param.Name)).Value) -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
						
						If (($Action -eq 'Zip') -and (!$CompressMethod))
						{
							Write-Log "When Zip option is selected make sure that CompressMethod also is specified" -LogLevel Error
							End-Script -ReturnCode $(Get-PSCallStack).ScriptLineNumber[0]
						}
						
						If ((-not $ConcatenatedFileName) -and ($Action -eq 'Zip') -and ($CompressMethod -eq 'ConcatenateFilesIntoSingleZip'))
						{
							Write-Log "When compress method is ConcatenateFilesIntoSingle make sure that -ConcatenatedFileName also is specified" -LogLevel Error
							End-Script -ReturnCode $(Get-PSCallStack).ScriptLineNumber[0]
						}
					}
				}
				Catch { }
			}
		}
	}
	
	function Set-LogFile
	{
		param
		(
			[Parameter(ParameterSetName = 'LogPath')]
			[String]$LogFilePath
		)
		
		Begin
		{
			New-Variable -Name Path -Confirm:$False -WhatIf:$False
			$CurrentScriptName = $MyInvocation.PSCommandPath
			$ScriptName = (Get-Variable -Name MyInvocation -Scope Script).Value.Mycommand.Name
		}
		
		Process
		{
			Try
			{
				If ($LogFilePath)
				{
					$Path = Join-Path -Path $LogFilePath -ChildPath $((Get-Date -format "dd-MM-yyyy").ToString() + '_' + $ScriptName.replace("ps1", "log"))
				}
				
				ElseIf ((Get-ChildItem Env:Saxologs -ErrorAction SilentlyContinue).Value)
				{
					
					If (-not (Test-Path ((Get-ChildItem Env:Saxologs).Value + "\" + $ScriptName.replace(".ps1", ""))))
					{
						$NewDirectory = New-Item -Name $ScriptName.replace(".ps1", "") -Path (Get-ChildItem Env:Saxologs).Value -ItemType Directory -Confirm:$False -WhatIf:$False
					}
					$Path = (Get-ChildItem Env:Saxologs).Value + "\" + $ScriptName.replace(".ps1", "") + "\" + (Get-Date -format "dd-MM-yyyy").ToString() + '_' + $ScriptName.replace("ps1", "log")
				}
			}
			Catch { }
		}
		
		End
		{
			If (-not ($Path))
			{
				$Path = "$env:temp\" + (Get-Date -format "dd-MM-yyyy").ToString() + '_' + $ScriptName.replace("ps1", "log")
			}
			Write-Verbose "Log file: $Path"
			Return $Path
		}
	}
	
	function Get-ValidPath
	{
		param ($DirectoryName)
		$ValidDirectories = @()
		foreach ($Directory in $DirectoryName)
		{
			If (Test-Path -LiteralPath $Directory -PathType Container)
			{
				$ValidDirectories += $Directory
				Write-Log "The path $Directory validated" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
			}
			Else
			{
				Write-Log "The path $Directory does not exist and will be ignored" -Loglevel warning -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
			}
		}
		Return $ValidDirectories
	}
	
	function StringIsNullOrWhitespace
	{
		param (
			[string]$string
		)
		
		if ($string -ne $null)
		{
			$string = $string.Trim()
		}
		
		return [string]::IsNullOrEmpty($string)
	}
	
	function Get-Path
	{
		[CmdletBinding()]
		param (
			$DirectoryName,
			[switch]$Recurse
		)
		Begin
		{
			[System.Collections.ArrayList]$Directories = @()
		}
		Process
		{
			Write-Log 'Validate path' -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
			$DirectoryName = Get-ValidPath -DirectoryName $DirectoryName
			Try
			{
				$Directories += $(Get-Item -LiteralPath $DirectoryName).FullName
				Write-Log 'Retrieving directories names' -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				
				If ($Recurse)
				{
					$Directories += $(Get-ChildItem -LiteralPath $DirectoryName -Recurse:$Recurse -ErrorAction SilentlyContinue | Where-object { $_.PSIsContainer }) | Select-Object -ExpandProperty FullName
				}
			}
			Catch
			{
				Write-Log "No sub directories found"
			}
		}
		End
		{
			$Directories
		}
	}
	
	function Extract-ExcludePath
	{
		[CmdletBinding()]
		param (
			$Directory,
			$ExcludePath
		)
		
		Begin
		{
			$ExcludeDirectories = @()
		}
		
		Process
		{
			If ($ExcludePath -eq $Null)
			{
				Return
			}
			
			If (-not (StringIsNullOrWhitespace -string $ExcludePath) -and $ExcludePath -notmatch "\w")
			{
				Write-Log "Please validate your exclusion values - Not in valid format" -loglevel Warning -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				Return $ValidDirectories = $Null
			}
			
			If (Get-Path -DirectoryName $ExcludePath)
			{
				Write-Log 'Building directories exclude ExcludePath' -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				foreach ($Path in $ExcludePath)
				{
					If ($Path[-1] -eq '\') { $Path = $Path -replace ".$" }
					$ExcludeDirectories += $Directory | Where-Object { $_ -like "$Path*" } # | Where-Object { $_ -like "*$Path"} | Where-Object { $_ -like "$Path*" }
				}
				
				$ValidDirectories = $(Compare-Object -ReferenceObject $Directory -DifferenceObject $ExcludeDirectories) | Select-Object -ExpandProperty InputObject
				
				If (-not $ValidDirectories)
				{
					Write-Log "No directory list could be built with specified the exclude statement" -loglevel Warning -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				}
			}
			Else { $ValidDirectories = $Directory }
		}
		
		End
		{
			If ($ExcludePath -eq $Null)
			{ Return $Directory }
			
			Try
			{
				Write-Log "$($($ValidDirectories).count) directories will be include" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
			}
			Catch
			{
				Write-Log "0 sub directories will be include" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				Return $ValidDirectories
			}
			Try
			{
				If ($($ValidDirectories).count -eq 1)
				{
					Return $ValidDirectories
				}
				
				Return $ValidDirectories.InputObject | Select-Object -Unique
			}
			Catch
			{
				Return $ValidDirectories | Select-Object -Unique
			}
		}
	}
	
	function Get-Files
	{
		[CmdletBinding()]
		param (
			$Path,
			$IncludeFile,
			$ExcludeFile,
			$Age = 0,
			$Size = 0
		)
		
		begin
		{
			Write-Log "Proccessing names of files (including their paths) in the specified directory" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
			#$Files = @()
			[System.Collections.ArrayList]$Directories = @()
			$Path | ForEach-Object {
				if ($_[-1] -like '\')
				{
					$Directories += $_ + '*'
				}
				Else
				{
					$Directories += $_ + '\*'
				}
			}
		}
		
		Process
		{
			$Parms = @{
				'Path' = $Directories
			}
			
			If ($IncludeFile)
			{
				$Parms.Add('Include', $IncludeFile)
			}
			
			If ($ExcludeFile)
			{
				$Parms.Add('Exclude', $ExcludeFile)
			}
			
			Write-Log "Building and adding files to the list" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
			
			$ListOfFiles = Get-Item @Parms | where-object { (!$_.PSIsContainer) -and ($_.length -ge $Size) -and ($_.LastWriteTime -lt (get-date).AddDays(- $Age)) }
			
		}
		
		End
		{
			If ($ListOfFiles)
			{
				Try
				{
					If ($ListOfFiles.count)
					{
						Write-Log "$($ListOfFiles.count) files found matching the criteria in $path" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
					}
				}
				Catch
				{
					Write-Log "1 file was found matching the criteria in $path" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				}
			}
			Else
			{
				Write-Log "No files found matching the criteria in $path" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
			}
			Return $ListOfFiles
		}
	}
	
	function End-Script
	{
		Param (
			[Int]$ReturnCode
		)
		Write-Log "Returning $ReturnCode" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
		Write-Log -logtask LogFinish -ModuleName (Get-Variable -Name MyInvocation -Scope Script).Value.Mycommand.Name -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
		Exit $ReturnCode
	}
	
	function Remove-Files
	{
		[CmdletBinding()]
		param
		(
			[ValidateNotNullOrEmpty()]
			$File
		)
		
		Process
		{
			$File | ForEach-Object {
				
				if ($(Get-Variable WhatIfPreference).Value)
				{
					$_ | Remove-Item -WhatIf:$(Get-Variable WhatIfPreference).Value
					Write-Log "What If : $($_.Fullname)" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				}
				
				Elseif (($Force) -or ($Process = $PSCmdlet.ShouldProcess($_, 'Remove Item')))
				{
					$_ | Remove-Item -Force -Confirm:$False
					
					Write-Log "$(If ($force)
						{
							'Forced deletion : '
						}
						ElseIf ($Process)
						{
							'Confirmed deletion : '
						}
					)$($_.Fullname)" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				}
				ElseIf (-not $Process)
				{
					Write-Log "Deletion cancelled: $($_.Fullname)" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				}
			}
		}
	}
	
	function Zip-Files
	{
		[CmdletBinding()]
		param
		(
			[ValidateNotNullOrEmpty()]
			$File,
			[String]$ZippedFileName
		)
		
		Begin
		{
			$ZipExeFile = Use-ExeFile -filename $ZipExcutingFile
			If (-not $ZipExeFile)
			{
				Write-Log "Not able to find the file '$ZipExcutingFile'" -Loglevel warning -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				End-Script -ReturnCode $(Get-PSCallStack).ScriptLineNumber[0]
			}
		}
		
		Process
		{
			$File | ForEach-Object {
				
				if ($(Get-Variable WhatIfPreference).Value)
				{
					$Message = 'What if: Performing the operation "Zip File" on target "' + $($_.Fullname) + '"'
					Write-Host $Message
					Write-Log $Message -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
					Remove-Item $_ -WhatIf:$(Get-Variable WhatIfPreference).Value
					Write-Log "What If : $_" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				}
				
				Elseif (($Force) -or ($Process = $PSCmdlet.ShouldProcess($_, 'Zip and Remove Item')))
				{
					
					$Fullname = $_.fullname
					$DirectoryName = $_.DirectoryName
					
					
					switch ($CompressMethod)
					{
						'ZipEveryFileSeparately' {
							$zipfilename = "`"$Fullname.zip`""
						}
						'ConcatenateFilesIntoSingleZip' {
							$zipfilename = '"' + $DirectoryName + '\' + $ZippedFileName + '.zip"'
						}
					}
					
					$Argument = " a $zipfilename `"$Fullname`""
					
					Try
					{
						$Result = Start-Process -FilePath "$($ZipExeFile.FullName)" -ArgumentList "$Argument" -PassThru -WindowStyle Hidden -Wait
						
						If (($Result.HasExited -eq $true) -and ($Result.ExitCode -eq 0))
						{
							Remove-Item $_.fullname -Force -Confirm:$False
							Write-Log "$(
								If ($force)
								{
									'Forced deletion : '
								}
								ElseIf ($Process)
								{
									If ($CompressMethod -eq 'ZipEveryFileSeparately')
									{
										"Zip file $zipfilename created and confirmed deletion of : "
									}
									Else
									{
										"Zip file $zipfilename updated and confirmed deletion of : "
									}
								}
							)$($_.Fullname)" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
						}
						Else
						{
							Write-Log "Not able to Zip $_ - The file is intact" -Loglevel warning -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
							Write-Log "$($ZipExeFile.FullName) ExitCode $($Result.ExitCode) " -Loglevel warning -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
							Remove-Item -LiteralPath $zipfilename -Force
						}
					}
					Catch
					{
						#Write-Log "Not able to Zip $_ - The file is intact" -Loglevel warning
					}
				}
				ElseIf (-not $Process)
				{
					Write-Log "Zip and Deletion cancelled: $Fullname" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				}
			}
		}
	}
	
	function Use-ExeFile
	{
		[CmdletBinding()]
		param
		([string]$filename)
		
		$CurrentExeFile = $null
		Write-Log "Searching for file $filename" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
		
		Try
		{
			If (Get-ChildItem -Path "$env:programfiles\7-Zip" -Filter $fileName -ErrorAction SilentlyContinue)
			{
				$CurrentExeFile = Get-ChildItem -Path "$env:programfiles\7-Zip" -Filter $fileName
				Write-Log "Using $($CurrentExeFile.FullName) Version: $($CurrentExeFile.VersionInfo.FileVersion)" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
			}
			
			elseif (Get-ChildItem -Path $(Get-Location) -Filter $fileName)
			{
				$CurrentExeFile = Get-ChildItem -Path $(Get-Location) -Filter $fileName
				Write-Log "Using $($CurrentExeFile.FullName) Version: $($CurrentExeFile.VersionInfo.FileVersion)" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
			}
			Else
			{
				$ExeFiles = Get-ChildItem -Path $($(get-childitem env:SystemDrive).Value + '\') -Filter $fileName -Recurse -ErrorAction SilentlyContinue
				
				ForEach ($ExeFile in $ExeFiles)
				{
					Try
					{
						If ($ExeFile.VersionInfo.FileVersion -gt $CurrentExeFile.VersionInfo.FileVersion) { $CurrentExeFile = $ExeFile }
					}
					Catch
					{
						$CurrentExeFile = $ExeFile
					}
				}
				
				Write-Log "Using $($CurrentExeFile.FullName) Version: $($CurrentExeFile.VersionInfo.FileVersion)" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
			}
		}
		
		Catch
		{
			If ($CurrentExeFile -eq $Null)
			{
				Write-Log "No $filename found" -Loglevel Error -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				End-Script -ReturnCode $(Get-PSCallStack).ScriptLineNumber[0]
			}
		}
		
		Return $CurrentExeFile
	}
	
	function Get-ScriptDirectory
	{
		$scriptInvocation = (Get-Variable MyInvocation -Scope 1).Value
		return Split-Path $scriptInvocation.MyCommand.Path
	}
	
	function Move-Files
	{
		[CmdletBinding()]
		param
		(
			[ValidateNotNullOrEmpty()]
			$File
		)
		
		Process
		{
			$File | ForEach-Object {
				
				$destination = $_.DirectoryName + '\' + (get-date -format yyyyMMdd) + '\'
				
				if ($(Get-Variable WhatIfPreference).Value)
				{
					$_ | Move-Item -Destination $destination -WhatIf:$(Get-Variable WhatIfPreference).Value
					Write-Log "What If : $_" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				}
				
				Elseif (($Force) -or ($Process = $PSCmdlet.ShouldProcess($_, 'Move Item')))
				{
					if (-not (Test-Path -LiteralPath $destination -PathType Container))
					{ New-Item -ItemType directory -Path $destination | Out-Null }
					
					$_ | Move-Item -Destination $destination -Force -Confirm:$False
					Write-Log "Move file : $($_.Fullname) to $destination\$($_.Name)" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				}
				
				ElseIf (-not $Process)
				{
					Write-Log "Move file cancelled: $($_.Fullname)" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
				}
			}
		}
	}
	
	Try
	{
		. "$(Get-ScriptDirectory)\Write-Log.ps1"
	}
	Catch
	{
		Throw ("Require script not found")
	}
	
	switch ($PsCmdlet.ParameterSetName)
	{
		'Logfile' {
			
			If (! ($Logfile))
			{
				$Logfile = Set-Logfile
			}
			Else
			{
				$Logfile = $Logfile
			}
			
		}
		'LogPath' {
			$Logfile = Set-Logfile -LogFilePath $Logpath
		}
		default
		{
			$Logfile = Set-Logfile
		}
	}
	
	If (! ($Logfile))
	{
		$Logfile = Set-Logfile
	}
	
	$PSDefaultParameterValues = @{
		"Write-Log:Logfile" = $Logfile
		"Write-Log:LogLevel" = 'Information'
		"Write-Log:LogTask" = 'LogEntry'
	}
	
	Set-StrictMode -Version Latest
	Set-PSDebug -Strict
	$ErrorActionPreference = "Stop"
	
	If (((Get-Variable Force).Value) -and ($PSCmdlet.MyInvocation.BoundParameters.Keys.Contains('Confirm')))
	{
		Set-Variable Force -Value $false -Confirm:$false -WhatIf:$False
	}
	
	$PSBoundParameters.Remove('Force') | Out-Null
	
	$OriginalWindowTitle = $Host.UI.RawUI.WindowTitle
	
	$Host.UI.RawUI.WindowTitle = $PSDefaultParameterValues.('Write-Log:Logfile')
	Write-Log -LogTask LogInit -logfile $PSDefaultParameterValues.'Write-Log:Logfile'
	
	Trap
	{
		$CurrentException = $_
		$OutText = "Unhandled Exception in Script. Exception is: $($CurrentException.exception.message)"
		End-Script -ReturnCode $(Get-PSCallStack).ScriptLineNumber[0]
	}
	
	Validate-Parameter
	$ZipExcutingFile = '7z.exe'
	
}

PROCESS
{
	Try
	{
		Write-Log "Processing directories" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
		
		$IncludeDirectories = Get-Path -DirectoryName $Path -Recurse:$Recurse
		
		$Directories = Extract-ExcludePath -Directory $IncludeDirectories -ExcludePath $ExcludePath
		
		Write-Log "Processing files" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
	}
	
	Catch
	{
		Write-Log "Processing .... " -loglevel Error -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
	}
	
	If (-not (StringIsNullOrWhitespace -string $Directories))
	{
		foreach ($Directory in $Directories)
		{
			$FileList += Get-Files -Path $Directory -IncludeFile $IncludeFile -ExcludeFile $ExcludeFile -Age $Age -Size $Size
		}
		
		Try
		{
			switch ($Action)
			{
				Zip {
					zip-Files -file $FileList -ZippedFileName $ConcatenatedFileName
				}
				Move {
					Move-Files -file $FileList
				}
				Delete {
					Remove-Files -file $FileList
				}
			}
		}
		
		Catch
		{
			Write-Log "No valid files found" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
		}
	}
	Else
	{
		Write-Log "No valid directory could be processed with the specified values" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
	}
	Write-Log "Directories and files processed" -Logfile $PSDefaultParameterValues.'Write-Log:Logfile'
}

END
{
	$Host.UI.RawUI.WindowTitle = $OriginalWindowTitle
	End-Script -ReturnCode 0
}

# SIG # Begin signature block
# MIISmQYJKoZIhvcNAQcCoIISijCCEoYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUN+VG0JTw91pmgW2T4NKF/UgN
# q1yggg11MIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BJ8wggOHoAMCAQICEhEh1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQUFADBS
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEoMCYGA1UE
# AxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMjAeFw0xNjA1MjQwMDAw
# MDBaFw0yNzA2MjQwMDAwMDBaMGAxCzAJBgNVBAYTAlNHMR8wHQYDVQQKExZHTU8g
# R2xvYmFsU2lnbiBQdGUgTHRkMTAwLgYDVQQDEydHbG9iYWxTaWduIFRTQSBmb3Ig
# TVMgQXV0aGVudGljb2RlIC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCwF66i07YEMFYeWA+x7VWk1lTL2PZzOuxdXqsl/Tal+oTDYUDFRrVZUjtC
# oi5fE2IQqVvmc9aSJbF9I+MGs4c6DkPw1wCJU6IRMVIobl1AcjzyCXenSZKX1GyQ
# oHan/bjcs53yB2AsT1iYAGvTFVTg+t3/gCxfGKaY/9Sr7KFFWbIub2Jd4NkZrItX
# nKgmK9kXpRDSRwgacCwzi39ogCq1oV1r3Y0CAikDqnw3u7spTj1Tk7Om+o/SWJMV
# TLktq4CjoyX7r/cIZLB6RA9cENdfYTeqTmvT0lMlnYJz+iz5crCpGTkqUPqp0Dw6
# yuhb7/VfUfT5CtmXNd5qheYjBEKvAgMBAAGjggFfMIIBWzAOBgNVHQ8BAf8EBAMC
# B4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAyAR4wNDAyBggrBgEFBQcCARYmaHR0cHM6
# Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3Js
# Lmdsb2JhbHNpZ24uY29tL2dzL2dzdGltZXN0YW1waW5nZzIuY3JsMFQGCCsGAQUF
# BwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNv
# bS9jYWNlcnQvZ3N0aW1lc3RhbXBpbmdnMi5jcnQwHQYDVR0OBBYEFNSihEo4Whh/
# uk8wUL2d1XqH1gn3MB8GA1UdIwQYMBaAFEbYPv/c477/g+b0hZuw3WrWFKnBMA0G
# CSqGSIb3DQEBBQUAA4IBAQCPqRqRbQSmNyAOg5beI9Nrbh9u3WQ9aCEitfhHNmmO
# 4aVFxySiIrcpCcxUWq7GvM1jjrM9UEjltMyuzZKNniiLE0oRqr2j79OyNvy0oXK/
# bZdjeYxEvHAvfvO83YJTqxr26/ocl7y2N5ykHDC8q7wtRzbfkiAD6HHGWPZ1BZo0
# 8AtZWoJENKqA5C+E9kddlsm2ysqdt6a65FDT1De4uiAO0NOSKlvEWbuhbds8zkSd
# wTgqreONvc0JdxoQvmcKAjZkiLmzGybu555gxEaovGEzbM9OuZy5avCfN/61PU+a
# 003/3iCOTpem/Z8JvE3KGHbJsE2FUPKA0h0G9VgEB7EYMIIEtjCCA56gAwIBAgIK
# fKbhTQAEAAAF1zANBgkqhkiG9w0BAQsFADA5MREwDwYDVQQKEwhTYXhvQmFuazEk
# MCIGA1UEAxMbU2F4b0JhbmtJbnRlcm5hbElzc3VpbmdDQTExMB4XDTE2MDUyNDEy
# NDg0NFoXDTE4MDUyNDEyNDg0NFowfjETMBEGCgmSJomT8ixkARkWA2RvbTETMBEG
# CgmSJomT8ixkARkWA21pZDEaMBgGA1UECxMRR1BPIE1hbmFnZWQgVXNlcnMxGTAX
# BgNVBAsTEFByb2R1Y3Rpb24gVXNlcnMxGzAZBgNVBAMTEkxhc3NlIFphZ2dhaSAo
# TFpBKTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALfSbFv7/KAuKgys
# hhdKCoNeG3IKIHe6YxLT0bZ00oD3KUSRCAUW16XwXmKQ3/97W6s/G6uwM5fUDCp4
# bYECoiEq/bb8z23UmWidrTahEnL1BWSZBkFlyr6YZyW/5mR/jwhnTItrxZHCHtpw
# FcNdahQTIy8/BODz8rhe0zM+TAKEekd//RMaQNFpUxIIh29UPKmumS4aNggQwv3o
# URrZHnkQ53Kc2gQRKgKzNw/+x0YpmuGmZWCiRyUyqzAzW6oUOra/1ULTwWbuRPck
# oRtZZcU7DDu02Xfh9CHjM26Tl7Zi9KHafc3c4kn6msMOAsgfiinj18Za9z0xWOkC
# GUb850kCAwEAAaOCAXkwggF1MD0GCSsGAQQBgjcVBwQwMC4GJisGAQQBgjcVCIL3
# 0XCH6c1Y/YUThs6RSoWr42qBWIbOyz6CycpYAgFkAgEGMBMGA1UdJQQMMAoGCCsG
# AQUFBwMDMAsGA1UdDwQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMD
# MB0GA1UdDgQWBBQWwQVg9srTCxYJ7eA6VD98o4n9bTAfBgNVHSMEGDAWgBQdvjd2
# v4Koqp7wr13dtwX8AiTlOjBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vc2Vydmlj
# ZXMuaWl0ZWNoLmRrL0ludENybC9TYXhvQmFua0ludGVybmFsSXNzdWluZ0NBMTEo
# NCkuY3JsMF8GCCsGAQUFBwEBBFMwUTBPBggrBgEFBQcwAoZDaHR0cDovL3NlcnZp
# Y2VzLmlpdGVjaC5kay9JbnRDcmwvU2F4b0JhbmtJbnRlcm5hbElzc3VpbmdDQTEx
# KDQpLmNydDANBgkqhkiG9w0BAQsFAAOCAQEAgEqXKZOKTuoCCSag5XtABdTRzOB3
# QoX2HaspHSpmZmfHO9GYmc0W8xluzp0VwNBvE8BZ8jz+qjROXk4r727jC4nK0hFe
# N5odQgXA32+gL2jbefkb3bESJhJ2glFIW2seXisZ1yYUVtZcL9ijk45rMUtYEK/5
# TMBw7t+VKQFa8P/b9BHZFyZHilwF6FFa2F2Dg7hNr8dpk6MWlicpGjfxNwc0Ixwj
# 9NZiJU6PD++7HC6sXifO2Fp1gw1eYfePkf2B32gzAGGqrdFMZ8PEOjcjqa0rL2dm
# xWHSNO7O2afIEHoRSfdmDmjx/fDLKkSKFm2EH/EwCL7ink/StV1ACiMTuTGCBI4w
# ggSKAgEBMEcwOTERMA8GA1UEChMIU2F4b0JhbmsxJDAiBgNVBAMTG1NheG9CYW5r
# SW50ZXJuYWxJc3N1aW5nQ0ExMQIKfKbhTQAEAAAF1zAJBgUrDgMCGgUAoHgwGAYK
# KwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU
# qxqVVDX1vAhD0BOZVemeL4rZoV8wDQYJKoZIhvcNAQEBBQAEggEAOhvFW6i0qBYj
# js+gdUH12JBXnGHjjIyXUZHoPzGVsjzL+QR3vcMD+UBNFE0O+i13wawpDyrCSuBG
# 7lKS5um276yB78DGpwfx02ynv/YDi29DSM6fZw4cXL1OITx9+6/ogvjmkUYs+nO+
# Mcbo0xSoiqHILGT0hbaWXuGO1QLTnyZa2MDDZXQ8Tje2hx73Xcpj2jvbNtaw12lo
# Zdi70kaItBP6cIyHpVNl92JnObRPiQ9TGV4ANHUOWwWb6tpr0grAfSGB1tIrc6Tp
# Xta3EKpUIV5956+hSMjSeJ65q2iL+UNBiq9WuBY/sfsVgTupJ+CI38sUZbpvBtfR
# iJ+m9oBa/aGCAqIwggKeBgkqhkiG9w0BCQYxggKPMIICiwIBATBoMFIxCzAJBgNV
# BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9i
# YWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIEcyAhIRIdaZp2SXPvH4Qn7pGcxTQRQw
# CQYFKw4DAhoFAKCB/TAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3
# DQEJBTEPFw0xNjExMDgxMTM3MjlaMCMGCSqGSIb3DQEJBDEWBBR/nVZOW1ENBCnM
# ZAHT/hk8J8aSyDCBnQYLKoZIhvcNAQkQAgwxgY0wgYowgYcwgYQEFGO4L6th9YOQ
# lpUFCwAknFApM+x5MGwwVqRUMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9i
# YWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFtcGluZyBD
# QSAtIEcyAhIRIdaZp2SXPvH4Qn7pGcxTQRQwDQYJKoZIhvcNAQEBBQAEggEAFfjw
# yJI9vBZ/Qmmf4qbH/TJKxr4RDBfx9MHBJWeHLP6LfaugiSd8zT8e1GWzJGmhUUn5
# oQrzQodYWRUpIMHv9NSEU5lRWEw3P8fXI/G71Z5xgUb8bZeMmCvEoXDZqM5rBQpY
# AFprN7E9iyBH+BuN0ga/kKB3pAbxm8xeDgfpoXC9AV1nIuTIH7STqScSFnZyXjod
# saV/kI/VRxBH1ii/XgJI8VyoESDbgANFeuzBPJzGRbJI6pQps4tTjniHzzS5gq8u
# +tHN3o7Da0xGwzPXOF/I7AJg2N9J9bFd7QBpb2hjL3wT9novbLAAQD03dy5+ql42
# 163YjFG02wY4gSoJTQ==
# SIG # End signature block
