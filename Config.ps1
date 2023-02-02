Write-Host '  ______                  _       _      ______                        '
Write-Host ' / _____) _              | |  _  | |    / _____)                       '
Write-Host '( (____ _| |_ _____ _____| |_| |_| |__ ( (____  _____ ____   ___ _____ '
Write-Host ' \____ (_   _) ___ (____ | (_   _)  _ \ \____ \| ___ |  _ \ /___) ___ |'
Write-Host ' _____) )| |_| ____/ ___ | | | |_| | | |_____) ) ____| | | |___ | ____|'
Write-Host '(______/  \__)_____)_____|\_) \__)_| |_(______/|_____)_| |_(___/|_____)'
Write-Host ""
Write-Host ""
Write-Host "StealthSense: Open-Source PC Surveillance Solution"
Write-Host ""
Write-Host "https://github.com/LogicBypass/StealthSense" -ForegroundColor Green
Write-Host "https://www.linkedin.com/in/logicbypass/" -ForegroundColor Green
Write-Host ""
Write-Host ""
Start-Sleep 2
Write-Host "Before you start you need to generate Gmail SMPT App Password" -ForegroundColor Red
Write-Host "Follow the link and create a Gmail SMTP Password" 
Write-Host "https://support.cloudways.com/en/articles/5131076-how-to-configure-gmail-smtp"  -ForegroundColor Green
Start-Sleep 2
Write-Host ""

$PCNameInput = Read-Host -Prompt "Give your PC a name"
$Your_Gmail_Address = Read-Host -Prompt "Insert your Gmail Address"
$Password_from_gmail_api  = Read-Host -Prompt "Insert your Gmail Generated Password"
$CountMailsToSend = Read-Host -Prompt "How many emails do you want the notifications sent to? (1-*)"


while (![int]::TryParse($CountMailsToSend, [ref]$null)) {
  Write-Host "Invalid input. Please enter a number."
  $CountMailsToSend = Read-Host -Prompt "How many emails do you want the notifications sent to? (1-*)"
}

$IteratedUsers = @()

for ($i = 1; $i -le $CountMailsToSend; $i++) {
  $varName = "Mail_Addresses$i"
  Set-Variable -Name $varName -Value (Read-Host -Prompt "Insert address $i where to send email")
  $IteratedUsers += '"'+(Get-Variable -Name $varName).Value+'"'
}
$ToUsersString = ($IteratedUsers -join ', ')


$Export = @"
`$scriptpath = `$MyInvocation.MyCommand.Definition 
[string]`$dir = Split-Path `$scriptpath  
set-location `$dir

#`$dir = Write-Host `$pwd

#Variables
`$PcName = "$($PCNameInput)"
`$Gmail_Address = "$($Your_Gmail_Address)"
`$Password = "$($Password_from_gmail_api)"
`$Logfile = ".\Log_IP.log"
`$LogTime = Get-Date -Format "MM/dd/yyyy - hh:mm:ss -"
`$oldip = gc .\ip.txt
`$readlog = gc -Delimiter '`n' .\Log_IP.log
`$connection = Test-Connection -ComputerName "8.8.8.8" -Quiet

#Gmail settings
`$SMTPServer = "smtp.gmail.com"
`$From = `$Gmail_Address
`$ToUsers = $($ToUsersString);
`$SMTPClient = New-Object Net.Mail.SmtpClient(`$SMTPServer, 587)
`$SMTPClient.EnableSsl = `$true
`$SMTPClient.Credentials = New-Object System.Net.NetworkCredential(`$Gmail_Address, `$Password);

#Log Function
Function LogWrite
{
   Param ([string]`$logstring)
   Add-content `$Logfile -value `$logstring
}

if (`$connection) {
    #Try a few servers in case one of them is down
    try {
        `$currentip = (New-Object net.webclient).downloadstring("https://api.ipify.org/")
    } catch {
        `$currentip = (New-Object net.webclient).downloadstring("https://ipinfo.io/ip")
    }
     

    Write-Host "Your previous IP was: `$oldip"
    Write-Host "Your current IP is: `$currentip"

    if (`$currentip){
        LogWrite "`$LogTime `$currentip"
        `$subject = "`$PcName IP has changed! `$currentip"
        `$body = "`$PcName IP has Changed from: `$oldip, to `$currentip,`n `n `$PcName Log:`n `$readlog"

    #if `$currentip servers are down..
    }
    else {
        Write-Host "Servers are down"
        LogWrite "`$LogTime `$currentip 'Servers are down'"
        `$subject = "`$PcName IP cannot be found!"
        `$body = "Last `$PcName known IP was `$oldip,`n `n `$PcName Log:`n `$readlog `n Check if the ipify.org and ipinfo.io is up and running."
    }
    

    if (`$oldip -ne `$currentip -or ([string]::IsNullOrWhiteSpace(`$oldip)) ) {
        foreach (`$ToUser in `$ToUsers) {
        Write-Host "Sending email notification to `$ToUser" -ForegroundColor Green
        `$SMTPClient.Send(`$From, `$ToUser, `$Subject, `$Body)
        }
    }

    else {LogWrite "No Changes `$LogTime `$currentip"}

    `$currentip | Out-File .\ip.txt -Force

    Write-Host "New IP saved in file is: `$currentip"

} else {
    #Connection is down Schedule script to run again in 3 minutes
    LogWrite "`$LogTime `$oldip 'Internet connection is down'"
    `$taskName = "Scheduled IP Check"
    `$action = New-ScheduledTaskAction -Execute `$dir"\startup.cmd" 
    `$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(3)
    `$settings = New-ScheduledTaskSettingsSet
    Unregister-ScheduledTask -TaskName `$taskName -Confirm:`$false
    Register-ScheduledTask -Action `$action -Trigger `$trigger -Settings `$settings -TaskName `$taskName
}
"@


$Export | Out-File .\StealthSense.ps1 -Force
