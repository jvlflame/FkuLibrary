function Get-FakkuVolume {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest,

        [Parameter(Mandatory = $true)]
        [String]$Url
    )

    $Subdirectory = ($Url -split 'fakku.net')[1]
    # Match first since it doesn't always appear
    if ($WebRequest -match "<a href=""$Subdirectory""") {
        $Vol = ($WebRequest -split "<a href=""$Subdirectory""")[0]
        $MatchCollection = [regex]::matches($Vol, '<div class=".*?">(\d+)<\/div>')
        $Collection = $MatchCollection.Groups[-1].Value
    }

    Write-Output $Collection
}
