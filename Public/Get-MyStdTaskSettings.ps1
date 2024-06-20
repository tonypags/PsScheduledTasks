function Get-MyStdTaskSettings {
    [CmdletBinding()]
    param ()
    
    $hashPath = "$PSScriptRoot\..\etc\MyStandardTaskSettings.psd1"
    Get-Content $hashPath | ConvertTo-HashTable

}#END: Get-MyStdTaskSettings
