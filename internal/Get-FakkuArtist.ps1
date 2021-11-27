function Get-FakkuArtist {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        # Modified to account for multiple artists
        $rawArtist = (((($WebRequest -split '<div.*>[Aa]rtist<\/div>')[1])`
            -split '<\/div>')[0]).Trim()

        $Artist = (($rawArtist -replace "`n","" -replace "`r","" | Select-String -Pattern '<a.*?artists.*?>(.*?(?=<))' -AllMatches).Matches | ForEach-Object { ($_.Groups[1].Value).Trim() }) -join ", "

        Write-Output $Artist
}
