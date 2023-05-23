function Get-FakkuCircle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest
    )

    $Circle = ((($WebRequest -split '<a href="\/circles\/.*?>')[1]) -split '<\/a>')[0].Trim()

    Write-Output $Circle
}
