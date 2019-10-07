function Get-PandaChaikaArtist {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $TextInfo = (Get-Culture).TextInfo
        $RawArtist = (((($WebRequest -split '<a href=\"\/tag\/artist:(.*?)\/\">')[1])`
                                -split '<\/a>')[0]) -replace '_', ' '
        $Artist = $TextInfo.ToTitleCase($RawArtist)
        Write-Output $Artist
}

function Get-PandaChaikaGenres {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $RawGenres = (((((((($WebRequest -split '<a href=\"\/tag\/publisher:(.*?)\/\">')[2])`
                                                                -split '<li>')[1])`
                                                -split '<\/li>')[0])`
                                -split '<a href=\"\/tag\/(.*?)\/">')`
                        -split '<\/a>').Trim() | Select-Object -Unique | Where-Object { $_ -notlike '' }

        <# $RawGenres = $WebRequest | Where-Object { $_ -like '/tag/*' -and `
                        $_ -notlike '/tag/language*' -and `
                        $_ -notlike '/tag/artist*' -and `
                        $_ -notlike '/tag/magazine*' -and `
                        $_ -notlike '/tag/publisher*' } #>

        # Formats the genres as a comma-delimited string "Genre1, Genre2, etc." which is accepted by ComicInfo.xml format
        # $GenreString = ((($RawGenres -split '\/tag\/') -split '\/') | Where-Object { $_ -ne '' }) -join ', '

        $GenreString = $RawGenres -join ', '
        Write-Output $GenreString
}

function Get-PandaChaikaPublisher {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $TextInfo = (Get-Culture).TextInfo
        $RawPublisher = ((($WebRequest -split '<a href=\"\/tag\/publisher:(.*?)\/\">')[1])`
                        -split '<\/a>')[0]

        $Publisher = $TextInfo.ToTitleCase($RawPublisher)
        Write-Output $Publisher
}

function Get-PandaChaikaSeries {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $TextInfo = (Get-Culture).TextInfo
        $RawSeries = (((($WebRequest -split '<a href=\"\/tag\/magazine:(.*?)\/\">')[1])`
                                -split '<\/a><\/div>')[0])`
                -replace '_', ' '
        
        $Series = $TextInfo.ToTitleCase($RawSeries)
        Write-Output $Series
}

function Get-PandaChaikaSummary {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $Summary = ((((($WebRequest -split '<th>Description</th>')[1])`
                                        -split '<td>')[1])`
                        -split '<\/td>')[0]
        
        Write-Output $Summary
}

function Get-PandaChaikaTitle {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $Title = (((($WebRequest -split '<title>')[1])`
                                -split '\|')[0]).Trim()
        
        Write-Output $Title
}