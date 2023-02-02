$scriptpath = $MyInvocation.MyCommand.Definition 
[string]$dir = Split-Path $scriptpath  
set-location $dir

#$dir = Write-Host $pwd

#Variables
$PcName = "GiveMeAName"
$Gmail_Address = "Your_Gmail_Address"
$Password = "SMPT_Generated_Password"
$Logfile = ".\Log_IP.log"
$LogTime = Get-Date -Format "MM/dd/yyyy - hh:mm:ss -"
$oldip = gc .\ip.txt
$readlog = gc -Delimiter '`n' .\Log_IP.log
$connection = Test-Connection -ComputerName "8.8.8.8" -Quiet

#Log Function
Function LogWrite
{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
}

if ($connection) {
    #Try a few servers in case one of them is down
    try {
        $currentip = (New-Object net.webclient).downloadstring("https://api.ipify.org/")
    } catch {
        $currentip = (New-Object net.webclient).downloadstring("https://ipinfo.io/ip")
    }

    #Gmail settings
    $SMTPServer = "smtp.gmail.com"
    $From = $Gmail_Address
    $ToUsers = "Mail_Addresses1", "Mail_Addresses2", "Mail_Addresses3";
    $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Gmail_Address, $Password);
     

    Write-Host "Your previous IP was: $oldip"
    Write-Host "Your current IP is: $currentip"

    if ($currentip){
        LogWrite "$LogTime $currentip"
        $subject = "$PcName IP has changed! $currentip"
        $body = "$PcName IP has Changed from: $oldip, to $currentip,`n `n $PcName Log:`n $readlog"

    #if $currentip servers are down..
    }
    else {
        Write-Host "Servers are down"
        LogWrite "$LogTime $currentip 'Servers are down'"
        $subject = "$PcName IP cannot be found!"
        $body = "Last $PcName known IP was $oldip,`n `n $PcName Log:`n $readlog `n Check if the ipify.org and ipinfo.io is up and running."
    }
    

    if ($oldip -ne $currentip -or ([string]::IsNullOrWhiteSpace($oldip)) ) {
        foreach ($ToUser in $ToUsers) {
        Write-Host "Sending email notification to $ToUser" -ForegroundColor Green
        $SMTPClient.Send($From, $ToUser, $Subject, $Body)
        }
    }

    else {LogWrite "No Changes $LogTime $currentip"}

    $currentip | Out-File .\ip.txt -Force

    Write-Host "New IP saved in file is: $currentip"

} else {
    #Connection is down Schedule script to run again in 3 minutes
    LogWrite "$LogTime $oldip 'Internet connection is down'"
    $taskName = "Scheduled IP Check"
    $action = New-ScheduledTaskAction -Execute $dir"\startup.cmd" 
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(3)
    $settings = New-ScheduledTaskSettingsSet
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Register-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -TaskName $taskName
}
