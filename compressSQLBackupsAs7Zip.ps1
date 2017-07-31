Import-Module -Name PSLogging

$LogName = “SQLBaktoZip_" + $(get-date -f yyyy-MM-dd) +  ".log”
$LogPath = $PSScriptRoot
$Days = 4
$7zPath = $PSScriptRoot + "7za.exe"
$LogPathAndFileName  = $LogPath + $LogName

Start-Log -LogPath $LogPath -LogName $LogName -ScriptVersion “1.0”

Set-Alias sz (Join-Path -Path $PSScriptRoot -ChildPath "7za.exe")

Write-LogInfo -LogPath $LogPathAndFileName -Message "Start ZIPing of bak and tran files" -TimeStamp

##$path = "C:\install\sqlbackup\7za.exe "



get-childitem -recurse |
where { $_.extension -match ".(bak|trn)" -and
-not (test-path ($_.fullname -replace "(bak|trn)", "7z")) } |
foreach { 

    Write-LogInfo -LogPath $LogPathAndFileName -Message ("zip file: " + $_.fullname) -TimeStamp

    & sz a ($_.fullname -replace "(bak|trn)", "7z") $_.fullname | set out 
    ## $ok = ($out -like '*Everything is Ok*')
    Write-LogInfo -LogPath $LogPathAndFileName -Message ("zip result: " + $out) -TimeStamp
    $ok = ($out -like '*Everything is Ok*')
    $ok = $LASTEXITCODE -eq 0
    
    if ($ok)
        {
          ## testing archive 
           Write-LogInfo -LogPath $LogPathAndFileName -Message ("test 7zip file: " + $_.Name) -TimeStamp
          & sz t ($_.fullname -replace "(bak|trn)", "7z") $_.fullname | set out 
          ## $ok = ($out -like '*Everything is Ok*')
          $ok = $LASTEXITCODE -eq 0
          if ($ok)
                {
                ## delete original file
                    Write-LogInfo -LogPath $LogPathAndFileName -Message ("del file: " + $_.Name) -TimeStamp
                    try
                     {
                         del $_.fullname -ErrorAction Stop
                     }
                     catch
                     {
                          $ErrorMessage = $_.Exception.Message
                          $FailedItem = $_.Exception.ItemName
                          Write-LogInfo -LogPath $LogPathAndFileName -Message ("Error : " + $ErrorMessage + ":" + $FailedItem) -TimeStamp
                     }
                }
        }



    }


## step 2 : löschen der BAKs

Write-LogInfo -LogPath $LogPathAndFileName -Message "Start cleaning up bak tran" -TimeStamp
get-childitem -recurse |
where { $_.extension -match ".(bak|trn)" -and
(test-path ($_.fullname -replace "(bak|trn)", "7z")) } |
foreach { 

            ## testing archive
          Write-LogInfo -LogPath $LogPathAndFileName -Message ("test 7zip file: " + $_.Name) -TimeStamp
          & sz t ($_.fullname -replace "(bak|trn)", "7z") $_.fullname | set out 
          $ok = $out -like '*Everything is Ok*'
          if ($ok)
                {
                ## delete original file
                 Write-LogInfo -LogPath $LogPathAndFileName -Message ("del file: " + $_.Name) -TimeStamp
                     try
                     {
                         del $_.fullname -ErrorAction Stop
                     }
                     catch
                     {
                          $ErrorMessage = $_.Exception.Message
                          $FailedItem = $_.Exception.ItemName
                          Write-LogInfo -LogPath $LogPathAndFileName -Message ("Error : " + $ErrorMessage + ":" + $FailedItem) -TimeStamp
                     }
                
                }

}

$limit = (Get-Date).AddDays(-1*$Days)
$path = $PSScriptRoot

# Delete files older than the $limit.
Write-LogInfo -LogPath $LogPathAndFileName -Message ("del old files ") -TimeStamp
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit -and $_.extension -match ".(7z|rar)" } | Remove-Item -Force

# Delete any empty directories left behind after deleting the old files.
##Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse


##Robocopy

Write-LogInfo -LogPath $LogPathAndFileName -Message ("robocopy files ") -TimeStamp
#robocopy.exe C:\install\sqlbackup\SQLCL7 \\192.168.211.9\S$\sqlbackup\SQLCL7\ /MIR /MAXAGE:5 /ETA /MT:16 /NP /R:1 /W:1 /XF *.trn *.bak /LOG:C:\install\sqlbackup\pdc03_sqlcl7_dgv.log
Write-LogInfo -LogPath $LogPathAndFileName -Message ("robocopy ende ") -TimeStamp

##Robocopy Ende


Stop-Log -LogPath $LogPathAndFileName

