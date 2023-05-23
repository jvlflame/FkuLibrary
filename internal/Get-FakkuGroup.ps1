function Get-FakkuGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest
    )

    $Group = ((($WebRequest -split '<a href="\/magazines\/.*?>')[1]) -split '<\/a>')[0].Trim()

    # Will use event instead if there is no magazine
    if (-Not $Group) {
        $Group = ((($WebRequest -split '<a href="\/events\/.*?>')[1]) -split '<\/a>')[0].Trim()
    }

    Write-Output $Group
}
