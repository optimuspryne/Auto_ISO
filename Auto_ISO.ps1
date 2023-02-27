function Version-Menu {
    
    #Allows you to create a menu prompt for the users to ask which version of Windows the script is working with. The selection made here is used in every other function

    #Takes two strings a parameter to build the menu
    param([string]$Title,[string]$Question)

    #Creating the two menu objects and adding them to an array.
    $win11 = New-Object System.Management.Automation.Host.ChoiceDescription '&1  Win11', 'Answer: Win11'
    $win10 = New-Object System.Management.Automation.Host.ChoiceDescription '&2  Win10', 'Answer: Win10'
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($win11, $win10)

    #Building the user prompt object using the two Parameters and the $options array.
    $choice = $host.ui.PromptForChoice($Title, $Question, $options, 0)

    #Windows11 is the Default option.
    switch ($choice) {
        0 {"11"; Break}
        1 {"10"; Break}
    }
}

function YN-Menu {

    #This function takes two strings as parameters and uses them in the creation of a Yes/No prompt for the user.  This function should work for any Yes/No question you might need.

    #Takes two strings a parameter to build the menu
    param([string]$Title,[string]$Question)
    
    #Creating the two menu objects and adding them to an array.
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Answer: Yes'
    $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Answer: No'
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    
    #Building the user prompt object using the two Parameters and the $options array.
    $choice = $host.ui.PromptForChoice($Title, $Question, $options, 0)

    #Yes is the default option
    switch ($choice) {
        0 {"Yes"; Break}
        1 {"No"; Break}
    }
}

function Function-Menu {

    #Allows you to create a menu prompt for the users to ask which version of Windows the script is working with. The selection made here is used in every other function

    #Takes two strings a parameter to build the menu
    param([string]$Title,[string]$Question)

    #Creating the two menu objects and adding them to an array.
    $justScripts = New-Object System.Management.Automation.Host.ChoiceDescription '&1  Just Update Scripts', 'Answer: justScripts'
    $everything = New-Object System.Management.Automation.Host.ChoiceDescription '&2 Run Everything', 'Answer: everything'
    $copyISO = New-Object System.Management.Automation.Host.ChoiceDescription '&3  Copy Base ISO', 'Answer: copyISO'
    $convertESD = New-Object System.Management.Automation.Host.ChoiceDescription '&4  Convert .esd to .wim', 'Answer: convertESD'
    $bootDrivers = New-Object System.Management.Automation.Host.ChoiceDescription '&5  Add Boot Drivers', 'Answer: bootDrivers'
    $wsDrivers = New-Object System.Management.Automation.Host.ChoiceDescription '&6  Add Other Drivers', 'Answer: wsDrivers'
    $makeISO = New-Object System.Management.Automation.Host.ChoiceDescription '&7  Make Custom ISO', 'Answer: makeISO'
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($justScripts, $everything, $copyISO, $convertESD, $bootDrivers, $wsDrivers, $makeISO)

    #Building the user prompt object using the two Parameters and the $options array.
    $choice = $host.ui.PromptForChoice($Title, $Question, $options, 0)

    #Windows11 is the Default option.
    switch ($choice) {
        0 {"justScripts"; Break}
        1 {"everything"; Break}
        2 {"copyISO"; Break}
        3 {"convertESD"; Break}
        4 {"bootDrivers"; Break}
        5 {"wsDrivers"; Break}
        6 {"makeISO"; Break}
    }

}

function Function-Selection {

    param ($MenuSelection, $Version)

    if ($MenuSelection -eq "justScripts"){
        Mount-WindowsImage -Path C:\WinWork\Mount\ -ImagePath "C:\WinWork\ISO\Win$($Version)\Sources\Install.wim" -Index 1
        Add-Files-And-Scripts -Version $Version
        Make-ISO -Version $Version
    }elseif ($MenuSelection -eq "copyISO"){
        Copy-ISO -Version $Version
    }elseif ($MenuSelection -eq "convertESD"){
        Convert-ESD -Version $Version
    }elseif ($MenuSelection -eq "bootDrivers"){
        Add-Boot-Drivers -Version $Version
    }elseif ($MenuSelection -eq "wsDrivers"){
        Add-WS-Drivers -Version $Version
        Dismount-WindowsImage -Path C:\WinWork\Mount\ –Save
    }elseif ($MenuSelection -eq "makeISO"){
        Make-ISO -Version $Version
    }else{
        Copy-ISO -Version $Version
        Convert-ESD -Version $Version
        Add-Boot-Drivers -Version $Version
        Add-WS-Drivers -Version $Version
        Add-Files-And-Scripts -Version $Version
        Make-ISO -Version $Version
    }

}

function Make-Directories {

        #Creates the directories necessary for this script to operate.
        Write-Host "Making Directories..."
        New-Item -Path C:\WinWork\ISO\Win10 -ItemType Directory
        New-Item -Path C:\WinWork\ISO\Win11 -ItemType Directory
        New-Item -Path C:\WinWork\Drivers\Win10 -ItemType Directory
        New-Item -Path C:\WinWork\Drivers\Win11 -ItemType Directory
        New-Item -Path C:\WinWork\Drivers\Boot -ItemType Directory
        New-Item -Path C:\WinWork\Mount -ItemType Directory
        New-Item -Path C:\WinWork\Scripts -ItemType Directory
        New-Item -Path C:\WinWork\Files -ItemType Directory
}

function Copy-ISO {
    
    #Takes paramter containing either 10 or 11 to denote Windows version.
    param ($Version)

    # ISO image - replace with path to ISO to be mounted
    $isoImg = "C:\WinWork\Windows$($Version).iso"
    # Drive letter - use desired drive letter
    $driveLetter = "W:"

    # Mount the ISO, without having a drive letter auto-assigned
    $diskImg = Mount-DiskImage -ImagePath $isoImg  -NoDriveLetter

    # Get mounted ISO volume
    $volInfo = $diskImg | Get-Volume

    # Mount volume with specified drive letter (requires Administrator access)
    mountvol $driveLetter $volInfo.UniqueId

    #Copy contents of ISO to specified directory.  Directory is determined by the contents of $Version
    xcopy /E /I W:\ "C:\WinWork\ISO\Win$($Version)"

    # Unmount ISO
    DisMount-DiskImage -ImagePath $isoImg
}

function Convert-ESD {

    #Takes paramter containing either 10 or 11 to denote Windows version.
    param ($Version)

    #After the contents of your ISO are copied.  These commands export the 'Pro' index from the encrypted install.esd file as an install.wim file.  Then the install.esd file is deleted as it's no longer needed
    Export-WindowsImage -SourceImagePath "C:\WinWork\ISO\Win$($Version)\Sources\Install.esd" -SourceIndex 6 -DestinationImagePath "C:\WinWork\ISO\Win$($Version)\Sources\Install.wim" -CompressionType Max -CheckIntegrity
    Remove-Item -Force  "C:\WinWork\ISO\Win$($Version)\sources\install.esd"
}

function Add-Boot-Drivers {

    #Takes paramter containing either 10 or 11 to denote Windows version.
    param ($Version)

    #Any driver files (.inf, etc.) that you've copied to C:\WinWork\Drivers\Boot will be added to the Boot.wim file.
    Mount-WindowsImage -Path C:\WinWork\Mount\ -ImagePath "C:\WinWork\ISO\Win$($Version)\Sources\Boot.wim" -Index 2
    Add-WindowsDriver -Path C:\WinWork\Mount\ -Driver C:\WinWork\Drivers\Boot -Recurse
    Dismount-WindowsImage -Path C:\WinWork\Mount\ –Save
}

function Add-WS-Drivers {

    #Takes paramter containing either 10 or 11 to denote Windows version.
    param ($Version)

    #Any driver files (.inf, etc.) that you've copied to C:\WinWork\Drivers\WinXX\ will be added to the Install.wim file.
    Mount-WindowsImage -Path C:\WinWork\Mount\ -ImagePath "C:\WinWork\ISO\Win$($Version)\Sources\Install.wim" -Index 1
    Add-WindowsDriver -Path C:\WinWork\Mount\ -Driver "C:\WinWork\Drivers\Win$($Version)" -Recurse
}

function Add-Files-And-Scripts {
    
    <#Takes two paramters.  $Version contains either 10 or 11 to denote Windows version.  $Mode is either 0 or 1.
    $Mode = 0 assumes you've already run through the script once so it will mount install.wim and then copies/overwrites the files and scripts.  Useful for updating scripts.
    $Mode = 1 assumes this is your first time running the script.  This means install.wim is already mounted. It creates the "Panther" folder and then copies the files and scripts.#>

    param ($Version)
        
    New-Item -Path C:\WinWork\Mount\Windows\Panther -ItemType Directory

    Copy-Item -Path "C:\WinWork\Scripts\" -Destination "C:\WinWork\Mount\Windows\Setup\Scripts" -Recurse
    Copy-Item -Path "C:\WinWork\Files\" -Destination "C:\WinWork\Mount\Windows\Setup\Files" -Recurse

    #Copies the unattend.xml file to \Windows\Panther\ so that the install will detect it and use it.
    Copy-Item -Path "C:\WinWork\Files\unattend.xml" -Destination "C:\WinWork\Mount\Windows\Panther\"

    #This is a file specific to my use case, can be commented out if not needed.
    Copy-Item -Path "C:\WinWork\Files\Workstation Setup.lnk" -Destination "C:\WinWork\Mount\Users\Public\Desktop\"

    Dismount-WindowsImage -Path C:\WinWork\Mount\ -Save
}

function Make-ISO {

    #Takes paramter containing either 10 or 11 to denote Windows version.
    param ($Version)

    $currentDate = Get-Date -Format MM-dd-yyyy

    #Creates bootable ISO from the files located in C:\WinWork\ISO\WinXX.
    CD "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\"
    ./oscdimg.exe -h -m -o -u2 -udfver102 -bootdata:2#p0,e,bC:\WinWork\ISO\Win$Version\boot\etfsboot.com#pEF,e,bC:\WinWork\ISO\Win$Version\efi\microsoft\boot\efisys.bin -lWin11 "C:\WinWork\ISO\Win$($Version)" "C:\WinWork\Windows $($Version) $($currentDate).iso"
}

function Get-Started {

    #This is the main function of the script.

    #Asks the user if they would like the script create the necessary Directories in C:\.
    $directoryPrompt = YN-Menu -Title "Please Confirm" -Question "Do you need to create the Directories on your C:\ Drive?"

    #If user chooses yes, then the following directories will be created in C:\
    if ($directoryPrompt -eq "Yes") {
       Make-Directories
    }
    
    Write-Host "At this point, your ISO files should be located at C:\WinWork. Make sure they are renamed Windows10.iso or Windows11.iso`n
    You should also have your driver files copied C:\WinWork\Drivers\Win10 or C:\WinWork\Drivers\Win11 respectively`n
    Any drivers that you need during setup should be copied to C:\WinWork\Drivers\Boot\ (storage drivers, etc.)`n
    If you haven't already copied the required files do so now and press enter when you're ready`n"
    Read-Host “Press ENTER to continue...”

    #Calling Version-Menu function to acquire Windows version that ISO needs to be created for.  $WinVer will contain either 10 or 11 and be used in every function call.
    $winVer = Version-Menu -Title "Please Answer." -Question "Which Windows version you making an ISO for?"
    

    #Using Function-Menu to figure what the user needs to script to do.  'Everything' option will run the entire script in order.
    $whichFunction = Function-Menu -Title "Please Confirm" -Question "What do you need this script to do?"

    Function-Selection -MenuSelection $whichFunction -Version $winVer

    do {

    $end = YN-Menu -Title "Please Confirm" -Question "Do you need the script to peform any other functions?"

        if ($end -eq 'Yes'){
            $whichFunction = Function-Menu -Title "Please Confirm" -Question "What do you need this script to do?"
            Function-Selection -MenuSelection $whichFunction -Version $winVer
        }

    }until($end -eq 'No')
}

Get-Started
