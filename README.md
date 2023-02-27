# Auto_ISO

A script to automate the process of loading drivers and scripts to a windows installation ISO

-----
# Table of Contents
[General Overview](https://github.com/optimuspryne/Auto_ISO/edit/main/README.md#general-overview)

[Functions Overview](https://github.com/optimuspryne/Auto_ISO/edit/main/README.md#functions-overview)

* [Get-Started](https://github.com/optimuspryne/Auto_ISO#get-started)
* [Copy-ISO](https://github.com/optimuspryne/Auto_ISO#copy-iso)
* [Convert-ESD](https://github.com/optimuspryne/Auto_ISO#convert-esd)
* [Add-Boot-Drivers](https://github.com/optimuspryne/Auto_ISO#add-boot-drivers)
* [Add-WS-Drivers](https://github.com/optimuspryne/Auto_ISO#add-ws-drivers)
* [Add-Files-And-Scripts](https://github.com/optimuspryne/Auto_ISO#add-files-and-scripts)
* [Make-ISO](https://github.com/optimuspryne/Auto_ISO#make-iso)
* [Version-Menu](https://github.com/optimuspryne/Auto_ISO#version-menu)
* [YN-Menu](https://github.com/optimuspryne/Auto_ISO#yn-menu)
	

# General Overview


This script will allow you to create a custom Windows ISO.  It has the ability to load drivers into startup and into the main installation.  It will copy your unattend.xml file to %WinDir%\Panther and it will also copy your custom scripts and files to %WinDir%\Setup\Scripts and %WinDir%\Setup\Files

The script operates from the following location on your computer: C:\WinWork.  The thing the the script asks you is if you'd like it to make the necessary folders for you. So if this is your first time running the script, just let it make the folders for you.  If you insist on making the folders yourself, the directory structure of C:\WinWork should be identical to the following:

C:\WinWork\

C:\WinWork\Files
  
C:\WinWork\Scripts
  
C:\WinWork\Mount
  
C:\WinWork\ISO
     
C:\WinWork\ISO\Win10
     
C:\WinWork\ISO\Win11
  
C:\WinWork\Drivers
     
C:\WinWork\Drivers\Boot
     
C:\WinWork\Drivers\Win10
     
C:\WinWork\Drivers\Win11
     
The only "required" file you need before starting the script is a fresh Windows installation ISO.  You should make sure every ISO is named in the following format:

WindowsXX.iso ('XX' is your Windows version, i.e. 10 or 11.  The name is not case sensitive)

Any ISO you wish to customize should be located in the root of the working directory: C:\WinWork\.  If you have any custom scripts or files (Your unattend.xml file has to be in C:\WinWork\Files) they should be copied to C:\WinWork\Scripts or C:\WinWork\Files.  Any driver files you need included in windows setup should be copied to C:\WinWork\Drivers\Boot.  If you want to pack in any drivers to the main installation, copy those files to C:\WinWork\Drivers\WinXX ('XX' is the OS version).

  

# Functions Overview


### Get-Started

The 'main' function the the script.  There are 9 major steps:

Step 1: It starts by asking if you'd like to create the folders that the script uses.  It then prompts you to copy all of your files, drivers, and    
            scripts to the correct folders.
  
Step 2: It then asks you which version of Windows the script should work with (10 or 11).
  
Step 3a: Then you're asked if you would like to 'just update scripts and files'. If you choose 'yes' here, the script proceeds assuming you've already run 	    through the once before.  This option will simply mount the install.wim and then copy/overwrite your custom scripts and files.  This saves time if 		 all you need to do is update a script.

Step 3b: If you choose 'no' when asked if you want to 'just update scripts and files' then the script will proceed as if this is your first time running 
         through.

Step 4: Calls the Copy-Iso function.  See [Copy-Iso](https://github.com/optimuspryne/Auto_ISO#copy-iso)

Step 5: Calls the Convert-ESD function.  See [Convert-ESD](https://github.com/optimuspryne/Auto_ISO#convert-esd)

Step 6: Calls the Add-Boot-Drivers function.  See [Add-Boot-Drivers](https://github.com/optimuspryne/Auto_ISO#add-boot-drivers)

Step 7: Calls the Add-WS-Drivers function.  See [Add-WS-Drivers](https://github.com/optimuspryne/Auto_ISO#add-ws-drivers)

Step 8: Calls the Add-Files-And-Scripts function.  See [Add-Files-And-Scripts](https://github.com/optimuspryne/Auto_ISO#add-files-and-scripts)

Step 9: Calls the Make-ISO function.  See [Make-ISO](https://github.com/optimuspryne/Auto_ISO#make-iso)



### Copy-ISO

This function is passed the $Version variable when called.  It uses this variable to mount the correct ISO, located at C:\WinWork.  The ISO is mounted with a drive letter of W:\.  Then the contents of the ISO are copied using xcopy to C:\WinWork\ISO\WinXX ('XX' is determined by $Version variable so that the contents are copied to the correct folder). Once the files are copied, the ISO is unmounted.




### Convert-ESD

This function is passed the $Version variable when called.  It uses the variable to make sure it's operating in the correct directory.  The function exports the 'Windows X Pro' index (usually index:6 when checked using 'DISM /Get-WimInfo') from the encrypted install.esd file.  The index is exported as an install.wim file to C:\WinWork\ISO\WinXX\Sources\ ('XX' is determined by $Version so that the correct wim file is exported), and then the install.esd file is deleted, as it's no longer needed.



### Add-Boot-Drivers

This function is passed the $Version variable when called.  It uses the variable to make sure it's operating in the correct directory.  This function mounts the Boot.wim (index:2) file located at C:\WinWork\ISO\WinXX\Sources\Boot.wim ('XX' is determined by $Version so that the correct wim file is mounted) to C:\WinWork\Mount.  Any driver files (.inf, etc.) that you've copied to C:\WinWork\Drivers\Boot will be added to the mounted wim file.  Then the Boot.wim file is unmounted.



### Add-WS-Drivers

This function is passed the $Version variable when called.  It uses the variable to make sure it's operating in the correct directory.  This function mounts the install.wim (index:1) file located at C:\WinWork\ISO\WinXX\Sources\Install.wim ('XX' is determined by $Version so that the correct wim file is mounted) to C:\WinWork\Mount.  Any driver files (.inf, etc.) that you've copied to C:\WinWork\Drivers\WinXX will be added to the mounted wim file.



### Add-Files-And-Scripts

This function is passed the $Version and $Mode variables when called.  $Version (10 or 11) is used to make sure it's operating in the correct directory and $Mode (0 or 1) is used to determine if the user is just updating scripts and files or if they're running the script in it's entirety.

- $Mode = 0: The install.wim located at C:\WinWork\ISO\WinXX\Sources\Install.wim ('XX' is determined by $Version so that the correct wim file is mounted) 
           is mounted to C:\WinWork\Mount, because at this point in the script it hasn't been mounted by the Add-WS-Drivers function yet.  The 
           'Panther' folder at C:\WinWork\Mount\Windows should already exist so it's not created again.  Then the files and scripts folders at 
           C:\WinWork\Mount\Windows\Setup are overwritten by any files located at C:\WinWork\Files\ & C:\WinWork\Scripts.  The unattend.xml file at 
           C:\WinWork\Mount\Windows\Panther is also overwritten.  Then the wim file is dismounted.
               
- $Mode = 1: This mode assumes the install.wim file at C:\WinWork\ISO\WinXX\Sources\Install.wim has already been mounted by the Add-WS-Drivers 
	     function.  The 'Panther' directory is created at C:\WinWork\Mount\Windows\.  Then all of the files and scripts located at C:\WinWork\Files\ & 
	     C:\WinWork\Scripts are copied to C:\WinWork\Mount\Windows\Setup\ (The directories are automatically created during the copy process).  The 
	     unattend.xml is then copied to C:\WinWork\Mount\Windows\Panther.  Then the wim file is dismounted.



### Make-ISO

This function is passed the $Version variable when called.  It uses the variable to make sure names the new ISO appropriately.  First the directory is changed to C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\ and then oscdimg.exe is called.  Oscdimg creates a new ISO from the contents of C:\WinWork\ISO\WinXX ('XX' is determined by $Version so that the correct directory is used) to C:\WinWork\ called WindowsXX_Custom.iso.  This is the end of the script.



### Version-Menu

This function creates a menu prompt for the user to ask which version of Windows the script is working with. The selection made here is added to a variable and passed to every almost every function in the script.



### YN-Menu

This function takes two strings as parameters and uses them in the creation of a Yes/No prompt for the user.  This function should work for any Yes/No question you might need.







