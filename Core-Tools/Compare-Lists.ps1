$path = Get-ChildItem -Path "C:\Lists\Phase-2-Moves.csv"
$CSV = Import-Csv $Path
$Users = Foreach($CS in $CSV){Get-Mailbox $CS.Guid -ea 'SilentlyContinue'}
$formatlist = $Users | %{$_.Guid}
[System.Collections.arrayList]$MasterList = $formatlist

$CompPath = Get-ChildItem -Path "C:\Lists\Comp-List.csv"
$CompCSV = Import-Csv $Path
$CompUsers = Foreach($CompCS in $CompCSV){
	$CompFormat = $item.Guid
	$MasterList.Remove("$CompFormat")
	}
 $MasterList | Export-Csv "C:\Lists\Final-Phase2-Moves.csv" -NoType


#DisplayName
$Mailboxes = Get-Mailbox -Database <Database Name> | ? {$_.Displayname -notlike "*SystemMailbox*"}
 $Mailboxes | Export-Csv C:\Lists\Masterlist.csv -NoType
$CSV = Import-Csv C:\Lists\Masterlist.csv
$formatlist = $CSV | %{$_.Alias}
[System.Collections.arrayList]$MasterList = $formatlist

$CompPath = Get-ChildItem -Path "C:\Lists\Migration_list_from_Client.csv"
$CompCSV = Import-Csv $CompPath
Foreach($CompCS in $CompCSV){
	$Name = Get-Mailbox $CompCS.DisplayName
	$CompFormat = $Name.Alias
	$MasterList.Remove("$CompFormat")
	}
 $MasterList | Out-File "C:\Lists\FinalList.txt"

#Output for Batch-FromList ps1
$List = Get-Content "C:\Lists\FinalList.txt"
$FinalList = foreach($lis in $list){Get-Mailbox $lis | select DisplayName,Guid}

#PrimarySMTPAddress
$Mailboxes = Get-Mailbox -Database <Database Name> | ? {$_.Displayname -notlike "*SystemMailbox*"}
 $Mailboxes | Export-Csv C:\Lists\Masterlist.csv -NoType
$CSV = Import-Csv C:\Lists\Masterlist.csv
$formatlist = $CSV | %{$_.Alias}
[System.Collections.arrayList]$MasterList = $formatlist

$CompPath = Get-ChildItem -Path "C:\Lists\Migration_list_from_Client.csv"
$CompCSV = Import-Csv $CompPath
Foreach($CompCS in $CompCSV){
	$Name = Get-Mailbox $CompCS.PrimarySMTPAddress
	$CompFormat = $Name.Alias
	$MasterList.Remove("$CompFormat")
	}
 $MasterList | Out-File "C:\Lists\FinalList.txt"

#Output for Batch-FromList ps1
$List = Get-Content "C:\Lists\FinalList.txt"
$FinalList = foreach($lis in $list){Get-Mailbox $lis | select DisplayName,Guid}
$FinalList | Export-Csv C:\Lists\Final-List.csv -NoType
