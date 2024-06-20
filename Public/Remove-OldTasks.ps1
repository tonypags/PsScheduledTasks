function Remove-OldTasks {
    <#
    .SYNOPSIS
    Removes old tasks that won't run again.
    .EXAMPLE
    Remove-OldTasks -Verbose -TaskPath '\TP\Internal\' -Retention (New-Timespan -Days 7)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]
        $TaskPath,

        [Parameter()]
        [AllowNull()]
        [SupportsWildcards()]
        [string]
        $TaskName,

        # Old Tasks will be kept after last run for this long
        [Parameter()]
        [timespan]
        $Retention = (New-Timespan -Days 3)
    )

    # This needs to run as admin to see all local tasks
    Confirm-RequiresAdmin

    $Now = Get-Date
    
    $NowZero = $Now.Date
    $NewestDateToRemove = $NowZero - $Retention

    Write-Debug "About to populate `$Tasks"
    $taskprops = @{}
    $taskprops.TaskPath = $TaskPath
    if ($TaskName) {$taskprops.TaskName = $TaskName}
    $Tasks = Get-ScheduledTask @taskProps -ea 0 -ev errTasks |
    Get-ScheduledTaskInfo |
        Where-Object {
            # Is not going to run again
            -not ($_.NextRunTime) -and

            # ...and hasn't run since given retention has passed
            $_.LastRunTime -lt $NewestDateToRemove
        }
    #

    # Using stored variable (we've had some weird errors when pipeing directly from the collection)
    Write-Debug "`$Tasks populated"
    if ($Tasks) {
        
        $Tasks | Foreach-Object {
            
            if ($pscmdlet.ShouldProcess( $_.TaskName, "Unregister Task" )) {
                
                Write-Verbose "Removing task: $($_.TaskName)"

                # Wait to avoid error: The system cannot find the file specified.
                Start-Sleep -Seconds 1

                $_ | Unregister-ScheduledTask -Confirm:$false -ea 0
            }

            # Pause after each task is removed
            Start-Sleep 1
        }

    } else {
        
        if ($errTasks -like '*No*MSFT_ScheduledTask objects found*') {
            Write-Warning "No Scheduled Tasks found"
        } elseif ($errTasks) {
            $errTasks | ForEach-Object {Write-Warning $_.Exception.Message}
        }

    }#END: if ($Tasks) {}

}#END: function Remove-OldTasks {}
