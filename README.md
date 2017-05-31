# Add-NscWrappedScript
Add new script to NSClient++ script directory and create a new entry in nsc.ini or nsclient.ini file in Wrapped Scripts.

# EXAMPLE 1
Copy new script from C:\temp\test.ps1 to "PC1" and "PC2" and add new command "check_test=test.ps1" under Wrapped Scripts in ini file. 

Backup ini file before changes.

Show verbose output.

    PS > Add-NscWrappedScript -ComputerName "PC1", "PC2" -PathToScript C:\temp\test.ps1 -CommandLine check_test=test.ps1 -BackupIniFile -Verbose
    VERBOSE: Running remote on PC1
    VERBOSE: Folders found 1
    VERBOSE:     Script test.ps1 saved in C:\Program Files\NSClient++\scripts\
    VERBOSE:     NSC ini file backed up as C:\Program Files\NSClient++\nsc_20170519_2220.ini
    VERBOSE:     New command inserted check_test=test.ps1
    True
    VERBOSE: Running remote on PC2
    VERBOSE: Folders found 1
    VERBOSE:     Script test.ps1 saved in C:\Program Files\NSClient++\scripts\
    VERBOSE:     NSC ini file backed up as C:\Program Files\NSClient++\nsc_20170519_2220.ini
    VERBOSE:     New command inserted check_test=test.ps1
    True

# EXAMPLE 2
Try to add command "check_test_ps1=check_test.ps1 arg1 arg2" and copy file from "C:\temp\test.ps1" and save it in NSClient++ as check_test.ps1.

    PS > Add-NscWrappedScript -CommandLine "check_test_ps1=check_test.ps1 arg1 arg2" -PathToScript C:\temp\test.ps1 -ScriptName check_test.ps1 -Verbose
    VERBOSE: Running local
    VERBOSE: Folders found 1
    WARNING:     Command already present.
    ;check_test_ps1=check_test.ps1 arg1 arg2
    Use -Force switch to overwrite.
    False
Command ends with a warning because command is already present in ini file.


# EXAMPLE 3
Use of Force switch to overwrite and existing line in ini file. 

Replacing ";check_test_ps1=check_test.ps1 arg1 arg2" with "check_test_ps1=check_test.ps1 arg1 arg2" - the command will now be enabled.

      PS > Add-NscWrappedScript -CommandLine "check_test_ps1=check_test.ps1 arg1 arg2" -PathToScript C:\temp\test.ps1 -ScriptName check_test.ps1 -Verbose -Force
      VERBOSE: Running local
      VERBOSE: Folders found 1
      VERBOSE:     Script check_test.ps1 saved in C:\Program Files\NSClient++-0.3.9-x64-\scripts\
      VERBOSE:     Replace command in ini file
      VERBOSE:     Replace ";check_test_ps1=check_test.ps1 arg1 arg2" with "check_test_ps1=check_test.ps1 arg1 arg2"
      True
