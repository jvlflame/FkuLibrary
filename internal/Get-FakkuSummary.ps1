function Get-FakkuSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest
    )

    $Summary = ((($WebRequest -split '<meta name="description" content="')[1]) -split '">')[0].Trim()`
        -replace '&(?!amp;)', '&amp;'

    Write-Output $Summary
}
