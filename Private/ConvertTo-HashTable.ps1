function ConvertTo-HashTable {
    <#
    .NOTES
    Copied From PsDevTools
    #>
    [CmdletBinding(DefaultParameterSetName='byContent')]
    param (

        # The file containing the hash table, ex: PSD1 file
        [Parameter(ParameterSetName='byPath')]
        [ValidateScript({Test-Path $_})]
        [string]
        $Path,

        # The hashtable represented as a string (array)
        [Parameter(ValueFromPipeline,ParameterSetName='byContent')]
        [string[]]
        $HashTableContent,

        # Does not check the logic before executing the code contained in the PSD1 file.
        [Parameter()]
        [switch]
        $Force

    )
    
    begin {
        
        $Content = New-Object -TypeName System.Collections.ArrayList

        [string[]]$allowedCommands = @(
            'New-TimeSpan'
            'Get-Date'
        )
        [string[]]$allowedVariables = @()
        [bool]$allowEnvVariables = $false
    
    }
    
    process {

        if ($PSCmdlet.ParameterSetName -eq 'byContent') {

            foreach ($line in $HashTableContent) {
                [void]($Content.Add($line))
            }
            
        } elseif ($PSCmdlet.ParameterSetName -eq 'byPath') {

            Try {
                Write-Verbose "Content being parsed from config file: [$($Path)]."
                $Content = Get-Content -Path $Path -ErrorAction Stop
            } Catch {
                throw "Unable to parse file content: $($_.exception.message)"
            }

        }

    }
    
    end {

        $rawContent = @($Content).Where({$_ -notmatch '^#'})
        $strContent = $rawContent -join "`n"

        # Define a hashtable for all tasks (KEY=pathToParentFolder, VALUE=retentionInDays)
        Try {
            $scriptBlock = [scriptblock]::Create($strContent)
            if ($Force) {} else {
                $scriptBlock.CheckRestrictedLanguage(
                    $allowedCommands, $allowedVariables, $allowEnvVariables
                )
            }
            & $scriptBlock
        } Catch {
            Write-Warning "$($_.exception.message)"
            throw "Unable to execute parsed text as a scriptblock!"
        }

    }

}#END: function ConvertTo-HashTable {}
