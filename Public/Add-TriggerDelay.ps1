function Add-TriggerDelay {
    <#
    .SYNOPSIS
    Postpone a task trigger
    .DESCRIPTION
    Postpone a task to not run for a given time period.
    .EXAMPLE
    PS C:\> $props = @{
        TaskPath = "\TP\Internal\"
        TaskName = 'Alert Notice'
        NextRun = (Get-Date).AddMinutes(10)
    }
    Add-TriggerDelay @props

    Prevents the task from running for 10 minutes.
    #>
    [CmdletBinding()]
    param (
        
        # Location of the task
        [Parameter()]
        [string]
        $TaskPath,
        
        # Name of the task to change
        [Parameter(Mandatory)]
        [string]
        $TaskName,
        
        # No trigger will execute prior to this time.
        [Parameter()]
        [datetime]
        $NextRun,
        
        # Username and password for the task "run-as" account
        [Parameter()]
        [PsCredential]
        $Credential
    )

    $getProps = @{
        TaskPath = $TaskPath
        TaskName = $TaskName
    }
    $Task = Get-ScheduledTask @getProps

    if ($NextRun) {
        @($Task.Triggers) | ForEach-Object {$_.StartBoundary = $NextRun.ToString('s')}
    }

    $setProps = @{
        InputObject = $Task
        User = $Credential.Username
    }
    Set-ScheduledTask @setProps -Password $Credential.GetNetworkCredential().Password

}#END: function Add-TriggerDelay {}
