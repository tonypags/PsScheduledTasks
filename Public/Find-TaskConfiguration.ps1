function Find-TaskConfiguration {
    <#
    .SYNOPSIS
    Return tasks where a certain criteria is found
    .DESCRIPTION
    .PARAMETER ActionArgument
    Search Task Actions for a string within the
    argument text field ("*"" is a wildcard).
    .EXAMPLE
    Find-TaskConfiguration -ActionArgument '*scriptname.ps1*'

    Returns MSFT_ScheduledTask objects matching the given argument string.
    #>
    [CmdletBinding(DefaultParameterSetName='byActionArg')]
    param (
        # Search Task Actions for a string within the argument text field
        [Parameter(ParameterSetName='byActionArg')]
        [Alias('Command','cmd','a')]
        [string]
        $ActionArgument,

        # Search Task Names for a string
        [Parameter(ParameterSetName='byTaskName')]
        [Alias('Name')]
        [string]
        $TaskName,

        # Search Task Principles for a username
        [Parameter(ParameterSetName='byPrinciple')]
        [Alias('User')]
        [string]
        $Principle
    )

    Confirm-RequiresAdmin

    $filter = switch ($PSCmdlet.ParameterSetName) {
        'byActionArg' {{
            $_.actions.execute -like "*$($ActionArgument)*" -or
            $_.actions.arguments -like "*$($ActionArgument)*"
        }}
        'byTaskName' {{
            $_.TaskName -like "*$($TaskName)*"
        }}
        'byPrinciple' {{
            $_.Principal.UserId -like "*$($Principle)*"
        }}
    }

    Get-ScheduledTask | Where-Object $filter |
    Select-Object -Property @(
        'TaskPath'
        'TaskName'
        @{n='Principal';e={ $_.Principal.UserId }}
        @{n='Command';e={ "$($_.Actions.Execute) $($_.Actions.Arguments)" }}
    )

}#END: function Find-TaskConfiguration {}
