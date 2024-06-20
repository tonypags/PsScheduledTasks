@{
    DisallowDemandStart = $true
    ExecutionTimeLimit = (New-TimeSpan -Minutes 30)
    MultipleInstances = 'Parallel' # Parallel|Queue|IgnoreNew
    Priority = 3
    RestartCount = 2
    RestartInterval = (New-TimeSpan -Minutes 1)
    StartWhenAvailable = $true
    Compatibility = 'Win8' # At|V1|Vista|Win7|Win8
}
