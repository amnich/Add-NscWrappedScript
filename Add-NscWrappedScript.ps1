<#
.SYNOPSIS
Add new script to NSClient++

.DESCRIPTION
Add new script to NSClient++ script directory and create a new entry in nsc.ini file in [Wrapped Scripts].

.PARAMETER PathToScript
Path to a script that will be copied to NSClient script directory. 

.PARAMETER CommandLine
Command that will be inserted into nsc.ini [Wrapped Scripts].
Like 
check_test_bat=check_test.bat arg1 arg2
check_test_vbs=check_test.vbs /arg1:1 /arg2:1 /variable:1
check_test_ps1=check_test.ps1 arg1 arg2

.PARAMETER BackupIniFile
Backup nsc.ini file in same directory with current date and time.
Like nsc_20170519_2125.ini

.PARAMETER ComputerName
Specifies the computers on which the command runs.

.PARAMETER NscFolder
Directory where NSClient++ is installed.
Default is $env:ProgramFiles\NSClient*

.EXAMPLE
Add-NscWrappedScript -ComputerName "PC1", "PC2" -PathToScript C:\temp\test.ps1 -CommandLine check_test=test.ps1 -BackupIniFile -Verbose
VERBOSE: Running remote on PC1
VERBOSE: Folders found 1
VERBOSE:     Script test.ps1 saved in C:\Program Files\NSClient++\scripts\
VERBOSE:     NSC ini file backed up as C:\Program Files\NSClient++\nsc_20170519_2220.ini
VERBOSE:     New command inserted check_test=test.ps1
VERBOSE: Running remote on PC2
VERBOSE: Folders found 1
VERBOSE:     Script test.ps1 saved in C:\Program Files\NSClient++\scripts\
VERBOSE:     NSC ini file backed up as C:\Program Files\NSClient++\nsc_20170519_2220.ini
VERBOSE:     New command inserted check_test=test.ps1
#>
Function Add-NscWrappedScript {
    param(
        [parameter()]
        [ValidateScript( {Test-Path $_ })]
        $PathToScript,
        [parameter()]
        [ValidateNotNullorEmpty()]
        $CommandLine,
        [switch]$BackupIniFile,
        [parameter(ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [String[]]$ComputerName,
        $NscFolder = "$env:ProgramFiles\NSClient*"
    )
    BEGIN {
        $ScriptContent = Get-Content $PathToScript
        Write-Debug "Script content: `n$($ScriptContent | out-string)"
        $ScriptName = Split-Path $PathToScript -Leaf
        Write-debug "Script name $ScriptName"
        $pattern = "\[Wrapped Scripts\]"
        $NSCini = "nsc.ini"
        $NSCiniBackup = "nsc_$(get-date -Format "yyyyMMdd_HHmm")`.ini"
        $ScriptBlock = {
            
            try {
                if ($using:NscFolder) {
                    $VerbosePreference = "continue"
                    Write-Verbose "Running remote on $env:computername"
                    $NscFolder = $using:NscFolder
                    $BackupIniFile = $using:BackupIniFile
                    $ScriptContent = $using:ScriptContent
                    $ScriptName = $using:ScriptName
                    $NSCini = $using:NSCini
                    $NSCiniBackup = $using:NSCiniBackup
                    $pattern = $using:pattern
                    $CommandLine = $using:CommandLine
                }
            }
            catch {
                Write-Verbose "Running local"
            }
            #find NSC folder
            $Folders = Get-ChildItem "$NSCFolder"
            Write-Verbose "Folders found $($folders.count)"
            Write-Debug "$($folders | out-string)"
            foreach ($folder in $Folders) {
                try {
                    $ScriptContent | out-file  "$($folder.FullName)\scripts\$ScriptName" -Force
                    Write-Verbose "    Script $ScriptName saved in $($folder.FullName)\scripts\"
                    $NscIniPath = "$($folder.FullName)\$NSCini"
                    if (!(Test-Path $NscIniPath)) {
                        Write-Error "$NscIniPath missing"
                    }
                    #if command is missing add it
                    if (!(Select-String -Path $NscIniPath -pattern ([regex]::Escape($CommandLine)))) {
                        #backup switch present then backup file as NSC_yyyyMMdd_HHmm.ini
                        if ($BackupIniFile) {
                            Copy-Item $NscIniPath $($nscinipath.Replace($NSCini, $NSCiniBackup)) -Force 
                            Write-Verbose "    NSC ini file backed up as $($nscinipath.Replace($NSCini,$NSCiniBackup))"
                        }
                        #get content of ini file
                        (Get-Content $NscIniPath) | Foreach-Object {
                            $_ # send the current line to output
                            if ($_ -match $pattern) {
                                #Add Lines after the selected pattern 
                                $CommandLine
                                Write-Verbose "    New command inserted $CommandLine"
                            }
                        } | Set-Content $NscIniPath   
                    }
                    else {
                        Write-verbose "    Command already present."
                    }
                }
                catch {
                    $error[0]
                }
            }

        }
    }
    PROCESS {
        if ($ComputerName) {
            Invoke-Command -ScriptBlock $scriptblock -ComputerName $ComputerName
        }
        else {
            & $ScriptBlock
        }  
    }
}
