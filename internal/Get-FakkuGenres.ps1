function Get-FakkuGenres {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $rawGenres = (((($WebRequest -split '<div class="table-cell w-full align-top text-left -mb-2">')[1])`
                -split 'class="inline-block cursor-pointer bg-gray-100 leading-loose rounded py-1 px-3 mr-2 dark:bg-gray-800 text-gray-900 dark:text-gray-400 js-suggest-tag"')[0])`
                -replace "`n","" -replace "`r",""

        try {
                $Genres = ($rawGenres | Select-String -Pattern '>([^<]*)<' -AllMatches).Matches | ForEach-Object { ($_.Groups[1].Value).Trim() } | Where-Object {$_ -ne ""}
        } catch {
                # Do nothing
        }

        # Formats the genres as a comma-delimited string "Genre1, Genre2, etc." which is accepted by ComicInfo.xml format
        $genreString = $genres[0..($Genres.Length - 1)] -join ", "
        Write-Output $genreString
}
