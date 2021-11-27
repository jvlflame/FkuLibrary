function Get-FakkuGenres {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        # Purposefully chose to omit the "Unlimited" tag
        $Genres = (($WebRequest -replace "`n","" -replace "`r","" | Select-String -Pattern '<a href="\/tags\/.*?>(.*?(?=<))' -AllMatches).Matches | ForEach-Object { ($_.Groups[1].Value).Trim() }) -join ", "

        Write-Output $Genres
}
