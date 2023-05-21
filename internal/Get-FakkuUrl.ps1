function Get-FakkuURL {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$ComicName
    )

    $UrlName = $ComicName.ToLower()`
        -replace '★', 'bzb' `
        -replace '☆', 'byb' `
        -replace '♪', 'bvb' `
        -replace '↑', 'b' `
        -replace '×', 'x' `
        -replace '\s+', ' '

    # Matches "[Artist] ComicName (Comic XXX).ext" and extracts ComicName
    if ($UrlName -match '^\[.+?\].+\(.+?\)\.[a-z0-9]+$') {
        $UrlName = ((((($UrlName -split "]")[1]) -split "\(")[0]).Trim())
    }
    # Matches "ComicName (Comic XXX).ext" and extracts ComicName
    elseif ($UrlName -match '\(.+?\)\.[a-z0-9]+$') {
        $UrlName = ((($UrlName -split "\(")[0]).Trim())
    }

    $UrlName = ($UrlName -replace '[^-a-z0-9 ]+', '' -replace '\s', '-' -replace '-+', '-').Trim('-')
    $FakkuUrl = "https://www.fakku.net/hentai/$UrlName-english"

    Write-Output $FakkuUrl
}
