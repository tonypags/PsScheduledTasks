function Confirm-RequiresAdmin {
    <#
    .NOTES
    Copied From PsWinAdmin
    #>
    param()
    if (-not
        ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
            ).IsInRole(`
                [Security.Principal.WindowsBuiltInRole] "Administrator"
            )
        )
    {
        throw "Administrator rights are required to run this script!"
    }
}
