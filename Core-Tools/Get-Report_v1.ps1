Param ([string]$Pass,[string]$InputCSV,[string]$OutputCSV)

$Computers = Import-Csv -Path $InputCSV

function Get-ComputerInfo {
	[cmdletbinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [String]
        $computerName
    )


$secureStringPwd = $Pass | ConvertTo-SecureString -AsPlainText -Force
$secureStringText = $secureStringPwd | ConvertFrom-SecureString
Set-Content ".\ExportedPwd.txt" $secureStringText

$userName = "<entery domain\user>"
$pwdTxt = Get-Content ".\ExportedPwd.txt"
$securePWD = $pwdtxt | ConvertTo-SecureString
$cred = New-Object System.Management.Automation.PSCredential($username,$securePwd)
$cimSession = New-CimSession -Credential $cred -ComputerName $computerName

$osInfo       = Get-CimInstance Win32_OperatingSystem -CimSession $cimSession -ErrorAction Stop
$computerInfo = Get-CimInstance Win32_ComputerSystem -CimSession $cimSession -ErrorAction Stop
$procInfo = Get-CimInstance Win32_Processor -CimSession $cimSession -ErrorAction Stop
$ramInfo  = Get-CimInstance Win32_PhysicalMemory -CimSession $cimSession -ErrorAction Stop
$diskInfo     = Get-CimInstance Win32_LogicalDisk -CimSession $cimSession -ErrorAction Stop

$computerObject = [PSCustomObject]@{
	

            ComputerName        = $computerInfo.Name
	        HostName		    = $computerInfo.Name + "." + $computerInfo.Domain
            OS                  = $osInfo.Caption
            Build               = $("$($osInfo.Version) Build $($osInfo.BuildNumber)")
            Domain              = $computerInfo.Domain
            #Workgroup           = $computerInfo.Workgroup
            DomainJoined        = $computerInfo.PartOfDomain
	        Proc                = foreach($Proc in $procInfo){
                $computerObject.Proc += $Proc.Name
            }
	        RAM	                = $ramInfo | Measure -Property Capacity -Sum | foreach {[math]::round($_.Sum / 1GB)}
            Disks               = $diskInfo
            Error               = $false
            ErrorMessage        = $null

        }

Remove-CimSession -CimSession $cimSession -ErrorAction SilentlyContinue
$computerObject


}

[System.Collections.ArrayList]$ComputerArray = @()
ForEach($computer in $computers) {

    #Use the Add method of the ArrayList to add the returned object from the Get-ComputerInformation function 
    #Piping this to Out-Null is important to suppress the result output from adding the object to the array
    $computerArray.Add((Get-ComputerInfo -computerName $computer.Host_Name)) | Out-Null

}

$ComputerArray | Export-Csv -Path $OutputCSV -NoTypeInformation
