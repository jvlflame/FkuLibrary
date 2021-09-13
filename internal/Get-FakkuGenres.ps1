function Get-FakkuGenres {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $rawGenres = (((($WebRequest -split '<div class="row-right tags">')[1])`
                                -split 'class="js-suggest-tag"')[0])

        try {
                $genres = ($rawGenres | Select-String -Pattern '(.*)<\/a>' -AllMatches).Matches | ForEach-Object { ($_.Groups[1].Value).Trim() }
        } catch {
                # Do nothing
        }

        # Formats the genres as a comma-delimited string "Genre1, Genre2, etc." which is accepted by ComicInfo.xml format
        $genreString = $genres[0..($Genres.Length - 1)] -join ", "
        Write-Output $genreString
}
