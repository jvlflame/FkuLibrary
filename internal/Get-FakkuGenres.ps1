function Get-FakkuGenres {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )
        
        $RawGenres = (((($WebRequest -split '<div class=\"row-right tags\">')[1])`
                                -split '<a class=\"js-suggest-tag')[0])`
                -split '\">(.*?)<\/a>'
        
        $Genres = ($RawGenres -notmatch '<a href*')
        # Formats the genres as a comma-delimited string "Genre1, Genre2, etc." which is accepted by ComicInfo.xml format
        $GenreString = $Genres[0..($Genres.Length - 2)] -join ", "
        Write-Output $GenreString
}