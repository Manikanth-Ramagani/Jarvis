Param
(
    [String] $SqlServer,
    [String] $dbname,
    [String] $Restore, #If restore is set to 1 then restore will happen.
    [String] $Backup, #If backup is set to 1 then Backup will happen.
    [String] $BackupPath,#If backup is set to 1 then Backup will happen.
    [String[]] $differential_DB
    
)
    # Following modifies the Write-Verbose behavior to turn the messages on globally for this session
    $VerbosePreference = "Continue"

    #$dt = Get-Date -Format yyyyMMddHHmmss
    IF([string]::IsNullOrWhiteSpace($SqlServer) ) 
    {
        throw "parameter $SqlServer cannot be empty"
    }
    IF([string]::IsNullOrWhiteSpace($dbname) ) 
    {
        throw "parameter $dbname cannot be empty"
    }
    IF([string]::IsNullOrWhiteSpace($Restore) ) 
    {
        $Restore = 0
    }
    IF([string]::IsNullOrWhiteSpace($Backup) ) 
    {
        $Backup = 0
    }
    
    $paths = @("H:\MSSQL11.MSSQLSERVER\MSSQL\DATA","E:\MSSQL11.MSSQLSERVER\MSSQL\DATA","O:\MSSQL11.MSSQLSERVER\MSSQL\DATA","H:\MSSQL12.MSSQLSERVER\MSSQL\DATA","E:\MSSQL12.MSSQLSERVER\MSSQL\DATA","O:\MSSQL12.MSSQLSERVER\MSSQL\DATA")
    
    foreach($path in  $paths)
    {
        if((Test-Path $path) -eq 0)
        {
           new-item $path -itemtype directory
        }
    }
    [string]$Bakfiles=''
    foreach($fileName in $differential_DB)
    { 
    $Bakfiles = $Bakfiles + "DISK = '$BackupPath\$fileName',"
    }
    $Bakfiles=$Bakfiles.trimend(",")


    IF($Backup -eq 1) 
    {
    #Backup
    #Backup-SqlDatabase -ServerInstance $SqlServer -Database $dbname -BackupFile $PathToBackup -ConnectionTimeout 0
    OSQL -S $SqlServer -E -Q "BACKUP DATABASE $dbname TO DISK = 'E:\MSSQL11.MSSQLSERVER\MSSQL\bak\$dbname.bak' WITH INIT"  
    #Restore with overwrite
        
    OSQL -S $SqlServer -E -Q "BACKUP DATABASE $dbname FROM $Bakfiles WITH INIT"
         

    }

    IF($Restore -eq 1 ) 
    {
    IF($dbname -eq 'feedstore') 
    {
     write-host 'restoring Jeminfra'
     OSQL -S $SqlServer -E -Q "RESTORE DATABASE $dbname FROM $Bakfiles  WITH REPLACE, RECOVERY, FILE = 1, MOVE '$($dbname)_data' TO 'H:\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.mdf',MOVE '$($dbname)_Log' TO 'H:\MSSQL12.MSSQLSERVER\MSSQL\DATA\$($dbname)_0.ldf'"
     }
     ELSE 
     {
     write-host 'restoring Jem_Data'
     OSQL -S $SqlServer -E -Q "RESTORE DATABASE $dbname FROM $Bakfiles  WITH REPLACE, RECOVERY, FILE = 1, MOVE '$($dbname)' TO 'H:\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.mdf',MOVE '$($dbname)_Log' TO 'H:\MSSQL12.MSSQLSERVER\MSSQL\DATA\$($dbname)_0.ldf'"
     }
    
    }

    
    
