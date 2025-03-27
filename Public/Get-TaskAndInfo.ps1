function Get-TaskAndInfo {
    <#
    .SYNOPSIS
    Runs Get-ScheduledTask and Get-ScheduledTaskInfo
    .DESCRIPTION
    Runs Get-ScheduledTask and Get-ScheduledTaskInfo and combines the results
    .EXAMPLE
    Get-TaskAndInfo # Returns all tasks
    .EXAMPLE
    Get-TaskAndInfo -TaskPath '\Level3\' # Returns tasks in this folder only (no recurse)
    #>
    [CmdletBinding()]
    param(
        # TaskPath must start and end with a backslash [\]
        [Parameter()]
        [AllowNull()]
        [ValidatePattern('^\\$|^\\.+\\$')]
        [string]
        $TaskPath
    )

    # Get the tasks
    $props = @{ErrorAction='Stop'}
    if ($TaskPath) {$props.TaskPath = $TaskPath}
    Try {$Tasks = Get-ScheduledTask @props} Catch {
        Write-Error $_
        return
    }

    if ($Tasks) {
        $TasksInfo = $Tasks | Get-ScheduledTaskInfo
    } else {
        Write-Warning 'No tasks found!'
        return
    }

    # Return the info required for any checks
    foreach ($task in $Tasks) {

        $thisInfo = @($TasksInfo).Where({
            $_.TaskName -eq $task.TaskName -and
            $_.TaskPath -eq $task.TaskPath
        })

        $Commands = @()
        $task.Actions | ForEach-Object {$Commands += "$($_.Execute) $($_.Arguments)"}
        $Cadence = $task.Triggers | ForEach-Object {Resolve-TriggerDescription -Trigger $_}

        # write-debug 'here' -debug
        [PSCustomObject]@{

            Hostname = $env:COMPUTERNAME
            TaskPath = $task.TaskPath
            TaskName = $task.TaskName
            Description = $task.Description
            State = $task.State
            LastTaskResult = $thisInfo.LastTaskResult
            LastRunTime = $thisInfo.LastRunTime
            NextRunTime = $thisInfo.NextRunTime
            NumberOfMissedRuns = $thisInfo.NumberOfMissedRuns
            Principle = $task.Principal.UserId
            Commands = $Commands -join ' ;  '
            Actions = $task.Actions
            Triggers = $task.Triggers
            Cadence = $Cadence -join ' & '
            Settings = $task.Settings
            Date = $task.Date
        }
    }

}#END: function Get-TaskAndInfo {}
