function Get-FakkuUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Name
    )

    $UrlName = $Name.ToLower()`
        -replace '★', 'bzb' `
        -replace '☆', 'byb' `
        -replace '♪', 'bvb' `
        -replace '↑', 'b' `
        -replace '×', 'x' `
        -replace '\s+', ' '

    # Matches "[Artist] Title (Comic XXX).ext" and extracts Title
    if ($UrlName -match '^\[.+?\].+\(.+?\)\.[a-z0-9]+$') {
        $UrlName = ((($UrlName -split "]")[1]) -split "\(")[0].Trim()
    }
    # Matches "Title (Comic XXX).ext" and extracts Title
    elseif ($UrlName -match '\(.+?\)\.[a-z0-9]+$') {
        $UrlName = ($UrlName -split "\(")[0].Trim()
    }

    $UrlName = ($UrlName -replace '[^-a-z0-9]+', '' -replace '\s', '-' -replace '-+', '-').Trim('-')
    $FakkuUrl = "https://www.fakku.net/hentai/$UrlName-english"

    Write-Output $FakkuUrl
}
