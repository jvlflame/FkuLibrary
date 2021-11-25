function Get-FakkuArtist {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        # Modified to account for multiple artists
        $rawArtist = (((($WebRequest -split '<div class=\"(.*?)\">Artist<\/div>')[2])`
            -split '<\/div>')[0]).Trim()

        $Artist = (($rawArtist | Select-String -Pattern '<a[^>]* href="[^>]*>([^<]*)' -AllMatches).Matches | ForEach-Object { ($_.Groups[1].Value).Trim() } | Where-Object {$_ -ne ""}) -join ", "

        Write-Output $Artist
}
