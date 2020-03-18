<# Notes:

Goal - Configure minimal post-installation settings for a server.

This script must be run after prepServer.ps1

Disclaimer - This example code is provided without copyright and AS IS.  It is free for you to use and modify.

#>

<#
Specify the configuration to be applied to the server.  This section
defines which configurations you're interested in managing.
#>

configuration configureServer
{
    Import-DscResource -ModuleName xComputerManagement -ModuleVersion 3.2.0.0
    Import-DscResource -ModuleName xNetworking -ModuleVersion 5.4.0.0
    
    Node localhost
    {
        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyOnly"
            RebootNodeIfNeeded = $true
        }
  
        xIPAddress NewIPAddress {
            IPAddress = $node.IPAddressCIDR
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
        }

        xDefaultGatewayAddress NewIPGateway {
            Address = $node.GatewayAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
            DependsOn = "[xIPAddress]NewIPAddress"
        }

        xDnsServerAddress PrimaryDNSClient {
            Address        = $node.DNSAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
            DependsOn = "[xDefaultGatewayAddress]NewIPGateway"
        }

        User Administrator {
            Ensure = "Present"
            UserName = "Administrator"
            Password = $Cred
            DependsOn = "[xDnsServerAddress]PrimaryDNSClient"
        }

        xComputer ChangeNameAndJoinDomain {
            Name = $node.ThisComputerName
            DomainName    = $node.DomainName
            Credential    = $domainCred
            DependsOn = "[User]Administrator"
        }
    }
}

<#
Specify values for the configurations you're interested in managing.
See in the configuration above how variables are used to reference values listed here.
#>
            
$ConfigData = @{
    AllNodes = @(
        @{
            Nodename = "localhost"
            ThisComputerName = "servercore2"
            InterfaceAlias = "Ethernet0"
            IPAddressCIDR = "192.168.3.102/24"
            GatewayAddress = "192.168.3.2"
            DNSAddress = "192.168.3.10"
            DomainName = "company.pri"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        }
    )
}

<#
Lastly, prompt for the necessary username and password combinations, then
compile the configuration, and then instruct the server to execute that
configuration against the settings on this local server.
#>

$domainCred = Get-Credential -UserName company\Administrator -Message "Please enter a new password for Domain Administrator."
$Cred = Get-Credential -UserName Administrator -Message "Please enter a new password for Local Administrator and other accounts."

configureServer -ConfigurationData $ConfigData

Set-DSCLocalConfigurationManager -Path .\configureServer –Verbose
Start-DscConfiguration -Wait -Force -Path .\configureServer -Verbose