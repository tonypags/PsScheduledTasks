function New-EmailTaskFromXml {
    <#
    .SYNOPSIS
    Sends an email using pre-defined parameters.
    .DESCRIPTION
    Sends an email after importing parameters from XML.
    .EXAMPLE
    $props = @{}
    $props.SendDate = (get-date).adddays(7)
    $props.TaskPath = '\TP\Internal\'
    $props.TaskName = 'Temp test task {0}' -f (get-date).tostring('fffffff')
    $props.Description = 'Can be anything or null'
    $props.XmlPath = 'c:\temp\temp.xml'
    $props.Credential = Get-Credential
    New-EmailTaskFromXml @props
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(

        # When the email will be sent
        [Parameter(Mandatory)]
        [ValidateScript({$_.Kind -eq 'Local'})]
        [datetime]
        $SendDate,

        # Ensure the TaskPath exists in Task Scheduler
        [Parameter(Mandatory)]
        [ValidatePattern('^\\[\s\w\\]+\\$')]
        [string]
        $TaskPath,

        # Also used as the log filename
        [Parameter(Mandatory)]
        [ValidateLength(1,255)]
        [string]
        $TaskName,

        [Parameter()]
        [ValidateLength(1,4096)]
        [string]
        $Description,

        # Task Principle
        [Parameter(Mandatory)]
        [PsCredential]
        $Credential,

        [Parameter(Mandatory)]
        [string]
        $Basename,

        [Parameter(Mandatory)]
        [ValidateScript({(Test-Path $_) -and $_ -match '\.xml$'})]
        [string]
        $XmlPath,

        # This is normally a subfolder under the XmlPath's parent
        [Parameter(Mandatory)]
        [ValidateScript({(Test-Path $_)})]
        [string]
        $LogPath

    )#END: param()

    # This can't be longer than 260 chars
    $cmdArgs = " -command ""& { `$xp=Import-CliXml '$($xmlPath)';Send-Mailmessage @xp }"" >> $($LogPath)\$($Basename).txt"
    if ($cmdArgs.Length -gt 260) {
        Write-Error "Command Argument is > 260 long: $($cmdArgs.Length)"
        $LogPath = 'C:\Temp\Logs'
        Write-Warning "Changing LogPath to $LogPath\."
        # This next line should be the same as the one above
        $cmdArgs = " -command ""& { `$xp=Import-CliXml '$($xmlPath)';Send-Mailmessage @xp }"" >> $($LogPath)\$($Basename).txt"
    }

    # Create Task Action
    $actProps = @{
        Execute = "powershell.exe"
        Argument = $cmdArgs
    }
    $action = New-ScheduledTaskAction @actProps

    # Create Task Trigger
    $trigger = New-ScheduledTaskTrigger -Once -At $SendDate

    # Create Task Settings
    $settingProps = Get-MyStdTaskSettings
    $setting = New-ScheduledTaskSettingsSet @settingProps

    # Register Task
    $regProps = @{
        Force = $true
        TaskPath = $TaskPath
        TaskName = $TaskName
        Description = $Description
        User = $Credential.Username
        Settings = $setting
        Trigger = $trigger
        Action = $action
    }

    if ($pscmdlet.ShouldProcess( $TaskName, "Create Task" )) {

        Register-ScheduledTask @regProps -Password $Credential.GetNetworkCredential().Password
        Write-Host "[$((Get-Date).tostring('s'))] Task created: $($TaskName) at $($SendDate)"
    }

    # Pause to keep Windows Task Scheduler from crashing, if we call this function within a loop
    Start-Sleep -Seconds 1

}#END: function New-EmailTaskFromXml {}
