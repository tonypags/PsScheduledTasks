function Get-TaskAndInfo {
    <#
    .SYNOPSIS
    Runs Get-ScheduledTask and Get-ScheduledTaskInfo
    .DESCRIPTION
    Runs Get-ScheduledTask and Get-ScheduledTaskInfo and combines the results
    .EXAMPLE
    Get-TaskAndInfo -TaskPath '\TP\Internal\'
    #>
    [CmdletBinding()]
    param(
        # TaskPath must start and end with a backslash [\]
        [Parameter(Mandatory)]
        [ValidatePattern('^\\.+\\$')]
        [string]
        $TaskPath
    )

    $ColumnOrder = @(
        'TaskPath'
        'TaskName'
        'State'
        'LastTaskResult'
        'LastRunTime'
        'NextRunTime'
        'NumberOfMissedRuns'
        'Principle'
        'Actions'
        'Triggers'
        'Settings'
        'Date'
    )

    # Get the tasks from a folder
    $Tasks = Get-ScheduledTask -TaskPath $TaskPath -ea 0
    if ($Tasks) {
        $TasksInfo = $Tasks | Get-ScheduledTaskInfo
    } else {
        Write-Error "No tasks found under $($TaskPath)!"
        return
    }

    # Return the info required for any checks
    foreach ($task in $Tasks) {

        $thisInfo = @($TasksInfo).Where({
            $_.TaskName -eq $task.TaskName -and
            $_.TaskPath -eq $task.TaskPath
        })

        [PSCustomObject]@{

            TaskPath = $task.TaskPath
            TaskName = $task.TaskName
            State = $task.State
            LastTaskResult = $thisInfo.LastTaskResult
            LastRunTime = $thisInfo.LastRunTime
            NextRunTime = $thisInfo.NextRunTime
            NumberOfMissedRuns = $thisInfo.NumberOfMissedRuns
            Principle = $task.Principal.UserId
            Actions = $task.Actions
            Triggers = $task.Triggers
            Settings = $task.Settings
            Date = $task.Date

        } | Select-Object $ColumnOrder

    }

}#END: function Get-TaskAndInfo {}
