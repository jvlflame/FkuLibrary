function Get-FakkuTitle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest
    )

    $Title = ($WebRequest -split '<title>(.*?)[Hh]entai by.*<\/title>')[1].Trim()`
        -replace '&(?!amp;)', '&amp;'

    Write-Output $Title
}
