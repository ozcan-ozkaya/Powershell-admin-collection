<# Notes:

Goal - Create a Nano Server VHDX file for use as a virtual machine.

Disclaimers

!!!!!!!!!!
This script is provided primarily as an example series of cmdlets and
is not directly intended to be run as-is.
!!!!!!!!!!

This example code is provided without copyright and AS IS.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the 
demonstrations and would need to be modified for your environment.

#>

import-module c:\nanoserver\nanoserverimagegenerator
New-NanoServerImage -Edition Standard -DeploymentType Guest -MediaPath C:\ `
-BasePath C:\NanoServer\nanoserver1 -TargetPath c:\nanoserver\nanoserver1\nanoserver1.vhdx `
-ComputerName nanoserver1

# Example for VM with drivers included in the image
#New-NanoServerImage -Edition Standard -DeploymentType Host -MediaPath C:\ `
#-BasePath C:\NanoServer\nanoserver1 -TargetPath c:\nanoserve2\nanoserver2\nanoserver1.vim `
#-ComputerName nanoserver2 -OEDDrivers -Compute
