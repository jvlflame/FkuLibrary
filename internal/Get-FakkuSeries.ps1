function Get-FakkuSeries {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest
    )

    # Match first since it doesn't always appear
    if ($WebRequest -match '<a href="\/collections\/.*?>'){
        $Series = ((($WebRequest -split '<a href="\/collections\/.*?>')[1]) -split '<\/a>')[0].Trim()
    }

    Write-Output $Series
}
