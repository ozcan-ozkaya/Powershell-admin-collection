<# Notes:


Goal - Ensure DHCP is installed and install if not.

Disclaimer

This example code is provided without copyright and AS IS.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the 
demonstrations and would need to be modified for your environment.

#>

Configuration installDHCP
{
    Node localhost 
    {
        WindowsFeature DHCPServer {
            Ensure = "Present"
            Name = "DHCP"
        }
    }
}

installDHCP

Start-DscConfiguration -Wait -Force -Path .\installDHCP -Verbose