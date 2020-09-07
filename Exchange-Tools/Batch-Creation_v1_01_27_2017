Param([string]$Database,[int]$SizeInMBs)
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction 'SilentlyContinue'
	If(($SizeInMBs -eq $null) -or ($SizeInMBs -lt 1)){
		$SizeInMBs = 15
		}
#Perhaps stop script if SizeInMbs is an invalid value.

#Processing path variables for output.
$HistoryDir="C:\Temp\Evac"
$BatchDir="C:\Temp\Evac\Processing"
$Log=Join-Path -Path $HistoryDir -ChildPath ("{0:yyyyMMdd-hhmmss}.txt" -f (Get-Date))

#Grab the Exchange mailboxes from specific databaes.
#Need to change this to load the necessary attributes into a PSObject.
$Mailboxes = Get-Mailbox -Database $Database | ? {$_.Displayname -notlike "*SystemMailbox*"}
$Mailboxes | Export-Csv C:\Temp\Evac\Masterlist.csv

#Take the list of mailboxes and translate into an arraylist
$CSV = Import-Csv C:\Temp\Evac\Masterlist.csv
$formatlist = $CSV | %{$_.Alias}
[System.Collections.arrayList]$MasterList = $formatlist

#Necessary variables for batch processing.
[int]$Size = $null
[array]$BatchList = $null
[int]$BatchNum = 0

#Begin processing the mailboxes in the Master List.
	While ($MasterList -ne $null) {
		Write-Host ("Processing Batch List")
		
		Foreach($Mailbox in $($MasterList)){
			#Pulling Mailboxes and their stats		
			$Name = Get-Mailbox $Mailbox			
			$Stats = Get-MailboxStatistics $Name
			
			#Updating Global Variables
			$Size += $Stats.TotalItemSize.value.tomb() + $Stats.TotalDeletedItemSize.value.tomb()							
			$BatchList+= $Stats.MailboxGuid  			
			
			#Removing processed mailboxes from the Master List of mailboxes
			Write-Output ("Removing {0} from the Master List" -f $Name.DisplayName) | Out-File $log -Append
			$FormatName = $Name.Alias 
			$MasterList.Remove("$FormatName")
			
			#Breaks the processing if batch reaches a certain size
			If ($Size -gt $SizeInMbs){
				Write-Output ("Total Size of this Batch is {0} MBs" -f $size) | Out-File $log -Append
				$Size = $null
				$BatchNum++
				Break
			}
		}
		
		#Write the decrementing number of mailboxes left in the Master List		

		write-host ("Master List now has {0} mailboxes remaining" -f $MasterList.Count)-foregroundcolor green
		If($MasterList.Count -eq 0){
		Write-Output ("Total Size of this Batch is {0} MBs" -f $size)| Out-File $log -Append 
		}
		Write-Output ("End of a Batch")| Out-File $log -Append 
		
		#Check for Database Folder for Batch Files
		if(!(Test-Path -Path "C:\Temp\Evac\$Database")) {New-Item -ItemType Directory -Path "C:\Temp\Evac\$Database"}
		
		#Batch files creation and reseting batch list for next pass
		$BatchName = "Batch" + $BatchNum + ".csv"
		$BatchDir = $HistoryDir + "\" + $Database + "\" + $BatchName
		$BatchList | Export-Csv $BatchDir -NoType
		$BatchList = $null
		
				
	}
