function Resolve-TriggerDescription {
    <#
    .SYNOPSIS
    Parses the trigger object to summarize the cadence in natural language.
    .EXAMPLE
    Resolve-TriggerDescription -Trigger $task.Trigger
    Weekly (Mon/Tue/Fri) every 0.00:05:00 for 0.23:59:00
    #>
    param(
        # MSFT_TaskDailyTrigger type from task object
        [System.Object]
        $Trigger
    )

    # abstract logic for converting numbers into days of the week string
    $sbBitwiseDays = {
        param(
            [int]$Value
        )
        Enum DayOfWeek {
            Sunday = 1
            Monday = 2
            Tuesday = 4
            Wednesday = 8
            Thursday = 16
            Friday = 32
            Saturday = 64
        }
        $array = [Enum]::GetValues([DayOfWeek]) | Where-Object { $_ -band $value }
        $abbrev = foreach ($day in $array) { $day.ToString().SubString(0,3) }
        $abbrev -join '/'
    }

    $strDescription = ''
    
    # the properties are not always consistent
    if ($Trigger.DaysInterval) {

        if ($Trigger.DaysInterval -gt 1) {
            $strDescription += "Every $($Trigger.DaysInterval) Days"
        } else {
            $strDescription += "Daily"
        }

    } elseif ($Trigger.WeeksInterval) {
        
        $daysOfWeek = switch ($Trigger.DaysOfWeek) {
            62  {'Weekdays'  ; break}
            65  {'Weekends'  ; break}
            127 {'Every Day' ; break}
            Default {
                if ($Trigger.DaysOfWeek -in (1..127)) {
                    Invoke-Command $sbBitwiseDays -ArgumentList $Trigger.DaysOfWeek
                } else {
                    Write-Error "Unhandled DaysOfWeek value: $($Trigger.DaysOfWeek)"
                    $Trigger.DaysOfWeek
                }
            }
        }

        if ($Trigger.WeeksInterval -gt 1) {
            $strDescription += "Every $($Trigger.WeeksInterval) Weeks"
        } else {
            $strDescription += "Weekly"
        }
        $strDescription += " ($($daysOfWeek))"

    } else {
        # This is once or monthly
        $strDescription += 'Monthly or One Time'
        # Monthly has no trigger info in the object :(  we just need to look at last/next dates and infer the cadence
        # Once will be similar but the next/last dates could be anywhere, may be one or the other or both.
        # Due to this ambiguity it is not feasible to create a description for these types of triggers
        # Plus, the trigger parameter value will not contain last/next dates! These are in the parent task object.
    }

    # If Duration or Interval is present, they will both be present
    if ($Trigger.Repetition.Duration) {
        $Duration = [System.Xml.XmlConvert]::ToTimeSpan($Trigger.Repetition.Duration)
        $Interval = [System.Xml.XmlConvert]::ToTimeSpan($Trigger.Repetition.Interval)
        $strRepeats = " every $($Interval.toString()) for $($Duration.toString())"
        $strDescription += $strRepeats
    }

    $strDescription

}#END: Resolve-TriggerDescription
