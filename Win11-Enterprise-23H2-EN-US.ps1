Write-Host -ForegroundColor Green "Starting OSDCloud ZTI"

Start-Sleep -Seconds 5

#Change Display Resolution for Virtual Machine

if ((Get-MyComputerModel) -match 'Virtual') {

Write-Host -ForegroundColor Green "Setting Display Resolution to 1600x"

Set-DisRes 1600

}

#Make sure I have the latest OSD Content

Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"

Install-Module OSD -Force

Write-Host -ForegroundColor Green "Importing OSD PowerShell Module"

Import-Module OSD -Force

#Start OSDCloud ZTI the RIGHT way

Write-Host -ForegroundColor Green "Start OSDCloud"

Start-OSDCloud -OSLanguage en-us -OSVersion 'Windows 11' -OSBuild 23H2 -OSEdition Enterprise -ZTI

#================================================
#   PostOS
#================================================
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <ProtectYourPC>3</ProtectYourPC>
            </OOBE>
            <UserAccounts>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Name>Test</Name>
                        <Group>Administrators</Group>
                        <DisplayName>Test</DisplayName>
                        <Description>Test Account</Description>
                        <Password>
                            <Value>VABlAHMAdABQAGEAcwBzAHcAbwByAGQA</Value>
                            <PlainText>false</PlainText>
                        </Password>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
        </component>
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>0409:00000409</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
        </component>
    </settings>
    <cpi:offlineImage cpi:source="wim:c:/osdbuilder/featureupdates/19044.1706.220505-0136.21h2_release_svc_refresh_clientbusiness_vol_x64fre_en-us/sources/install.wim#Windows 10 Enterprise" xmlns:cpi="urn:schemas-microsoft-com:cpi" />
</unattend>
'@

#================================================
#   Set Unattend.xml
#================================================
$PantherUnattendPath = 'C:\Windows\Panther\Unattend'
if (-NOT (Test-Path $PantherUnattendPath)) {
    New-Item -Path $PantherUnattendPath -ItemType Directory -Force | Out-Null
}
$UnattendPath = Join-Path $PantherUnattendPath 'Unattend.xml'
$UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8
Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath -Verbose

#Restart from WinPE

Write-Host -ForegroundColor Green "Restarting in 20 seconds!"

Start-Sleep -Seconds 20

wpeutil reboot
