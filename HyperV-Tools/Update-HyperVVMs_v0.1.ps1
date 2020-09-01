Param(
	[Parameter(Mandatory=$true)]	
	[string]$InputFile,
	[Parameter(Mandatory=$true)]
	[string]$Output
)

$InputPath = gci -Path $InputFile
$OutputPath = "$Output"

$ChildPath = "HyperV" + "_" + "VM" + "_" + "Report" + "_"
$Log = Join-Path -Path $OutputPath -ChildPath ("$ChildPath" + "{0:yyyyMMdd}.csv" -f (Get-Date))

$hvhosts = Import-Csv "$InputPath"

$Report = @()
foreach($hvhost in $hvhosts){
	$VMS = Get-VM -ComputerName $hvhost.hostname
	foreach($vm in $vms){
		$obj = New-Object PSObject -Property @{
			'Name' = $hvhost.hostname
			'VMName' = $VM.Name
			'State' = $VM.Status
		}
	
	$Report += $obj
	}
}

foreach($Rep in $Report){
Write-Host ("Checking {0} for WSUS Updates" -f $Rep.VMName) -foregroundcolor green
Write-Host ("Wuinstall search output") -foregroundcolor yellow 
invoke-command -ComputerName $rep.VMName -ScriptBlock {c:\temp\wuinstall.exe /search}  
}

$Report | Export-Csv $Log -NoTypeInfo
		
