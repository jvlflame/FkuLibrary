function Get-FakkuCircle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest
    )

    # Match first since it doesn't always appear
    if ($WebRequest -match '<a href="\/circles\/.*?>'){
        $Circle = ((($WebRequest -split '<a href="\/circles\/.*?>')[1]) -split '<\/a>')[0].Trim()
    }

    Write-Output $Circle
}
