Param
(
[Parameter(Mandatory=$true)][String]$ComputerName,
[Parameter(Mandatory=$true)][String]$MembersId,
[Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$Credentials,
[Parameter(Mandatory=$true)][String]$DomainNetbiosName    
)

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName=$ComputerName;
            PSDscAllowPlainTextPassword = $true
            
         }
)}

configuration AllowRemoteDesktopAdminConnections
{


[System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Credentials.UserName)", $Credentials.Password)
[String]$DomainMember=$DomainNetbiosName+"\"+$MembersId
    node ($ComputerName)
    {        
        Group ConfigureRDPGroup
        {
           Ensure = 'Present'
           GroupName = "Remote Desktop Users"
           MembersToInclude  =  @($DomainMember, "wtw_test\chetan123adm" ) 
           Credential = $DomainCreds
        }
    
        Group Administrators
         {
        	GroupName = "Administrators"
	        Ensure = "Present"
	        MembersToInclude =  @($DomainMember, "wtw_test\chetan123adm" )
            Credential = $DomainCreds
         }
        
    }
}
$workingdir = 'C:\DSC\MOF'
AllowRemoteDesktopAdminConnections -ConfigurationData $ConfigData -OutputPath $workingdir

Start-DscConfiguration -ComputerName $ComputerName -wait -force -verbose -path $workingdir 

