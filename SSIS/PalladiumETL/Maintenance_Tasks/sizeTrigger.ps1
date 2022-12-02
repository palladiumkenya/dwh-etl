# Drives to check: set to $null or empty to check all local (non-network) drives
# $drives = @("C","D");
$drives = "C";



# The minimum disk size to check for raising the warning
$minSize = 150GB;



# SMTP configuration: username, password & so on
$email_username = "bonniemych@gmail.com";
$email_password = "diwecesvbijymdrc";
$email_smtp_host = "smtp.gmail.com";
$email_smtp_port = 25;
$email_smtp_SSL = 1;
$email_from_address = "bonniemych@gmail.com";
$email_to_addressArray = @("bonniemych@gmail.com", "boniface.mavyuva@thepalladiumgroup.com");




if ($drives -eq $null -Or $drives -lt 1) {
    $localVolumes = Get-WMIObject win32_volume;
    $drives = @();
    foreach ($vol in $localVolumes) {
        if ($vol.DriveType -eq 3 -And $vol.DriveLetter -ne $null ) {
            $drives += $vol.DriveLetter[0];
        }
    }
}
foreach ($d in $drives) {
    Write-Host ("`r`n");
    Write-Host ("Checking drive " + $c + " ...");
    $disk = Get-PSDrive $c;
    if ($disk.Free -lt $minSize) {
        Write-Host ("Drive " + $c + " has less than " + $minSize `
            + " bytes free (" + $disk.free + "): sending e-mail...");

        $message = new-object Net.Mail.MailMessage;
        $message.From = $email_from_address;
        foreach ($to in $email_to_addressArray) {
            $message.To.Add($to);
        }
        $message.Subject =  ("[RunningLow] WARNING: " + $env:computername + " drive " + $d);
        $message.Subject += (" has less than " + $minSize + " bytes free ");
        $message.Subject += ("(" + $disk.Free + ")");
        $message.Body =     "Hello, good sir `r`n`r`n";
        $message.Body +=    "This is an automatic e-mail message ";
        $message.Body +=    "sent by the Resource Checker script ";
        $message.Body +=    ("to inform you that " + $env:computername + " drive " + $d + " ");
        $message.Body +=    "is running low on free space. `r`n`r`n";
        $message.Body +=    "--------------------------------------------------------------";
        $message.Body +=    "`r`n";
        $message.Body +=    ("Machine HostName: " + $env:computername + " `r`n");
        $message.Body +=    "Machine IP Address(es): ";
        $ipAddresses = Get-NetIPAddress -AddressFamily IPv4;
        foreach ($ip in $ipAddresses) {
            if ($ip.IPAddress -like "127.0.0.1") {
                continue;
            }
            $message.Body += ($ip.IPAddress + " ");
        }
        $message.Body +=    "`r`n";
        $message.Body +=    ("Used space on drive " + $c + ": " + $disk.Used + " bytes. `r`n");
        $message.Body +=    ("Free space on drive " + $c + ": " + $disk.Free + " bytes. `r`n");
        $message.Body +=    "--------------------------------------------------------------";
        $message.Body +=    "`r`n`r`n";
        $message.Body +=    "This warning will fire when the free space is lower ";
        $message.Body +=    ("than " + $minSize + " bytes `r`n`r`n");
        $message.Body +=    "Sincerely, `r`n`r`n";
        $message.Body +=    "-- `r`n";
        # $message.Body +=    "Mavyuva, Boniface`r`n";
                # $message.Body +=        "boniface.mavyuva@thepalladiumgroup.com";



       $smtp = new-object Net.Mail.SmtpClient($email_smtp_host, $email_smtp_port);
        $smtp.EnableSSL = $email_smtp_SSL;
        $smtp.Credentials = New-Object System.Net.NetworkCredential($email_username, $email_password);
        $smtp.send($message);
        $message.Dispose();
        write-host "... E-Mail sent!" ;
    }
    else {
        Write-Host ("Drive " + $c + " has more than " + $minSize + " bytes free: nothing to do.");
    }
}
