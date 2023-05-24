# Not updated- Just fixed formatting.
# Worth noting they provide info in JSON if somebody wants to clean this up
# Example: https://panda.chaika.moe/archive/22789/
# JSON response: https://panda.chaika.moe/api?archive=22789

function Get-PandaArtist {
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

function Get-PandaGenres {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest
    )

    if ($WebRequest -match '<a href=\"\/tag\/publisher:(.*?)\/\">') {
        $RawGenres = (((((((((($WebRequest -split '<a href=\"\/tag\/publisher:(.*?)\/\">')[2])`
            -split '<li>')[1])`
            -split '<\/li>')[0])`
            -split '<a href=\"\/tag\/(.*?)\/">')`
            -split '<\/a>').Trim())`
            -replace '_', ' ') |
            Select-Object -Unique |
            Where-Object { $_ -notlike '' }
    }

    elseif ($WebRequest -match '<label class="label-extended">(fe)?male:<\/label>') {
        $RawGenres = ((($WebRequest -split '<ul class="tags">')[1] -split '<\/ul>')[0] |
            Select-String -Pattern '<a href="\/tag\/(fe)?male:(.*)\/">' -AllMatches).Matches |
            ForEach-Object { $_.Groups[2].Value }

        $RawGenres += (((($WebRequest -split '<ul class="tags">')[1]`
            -split '<\/ul>')[0]`
            -split '<li>')[-1] |
            Select-String -Pattern '<a href="\/tag\/(?:fe)?(?:male:)?(.*)\/' -AllMatches).Matches |
            ForEach-Object { $_.Groups[1].Value }

        $RawGenres = $RawGenres | Where-Object { $_ -ne '' } | Select-Object -Unique
    }

    else {
        $RawGenres = (((((((((($WebRequest -split '<a href=\"\/tag\/artist:(.*?)\/">')[2])`
            -split '<li>')[1])`
            -split '<\/li>')[0])`
            -split '<a href=\"\/tag\/(.*?)\/">')`
            -split '<\/a>').Trim())`
            -replace '_', ' ') |
            Select-Object -Unique |
            Where-Object { $_ -notlike '' }
    }

    $GenreString = $RawGenres -join ', '
    Write-Output $GenreString

    <# $RawGenres = $WebRequest | Where-Object { $_ -like '/tag/*' -and `
        $_ -notlike '/tag/language*' -and `
        $_ -notlike '/tag/artist*' -and `
        $_ -notlike '/tag/magazine*' -and `
        $_ -notlike '/tag/publisher*' } #>

    # Formats the genres as a comma-delimited string "Genre1, Genre2, etc." which is accepted by ComicInfo.xml format
    # $GenreString = ((($RawGenres -split '\/tag\/') -split '\/') | Where-Object { $_ -ne '' }) -join ', '
}

function Get-PandaPublisher {
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

function Get-PandaSeries {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest
    )

    $TextInfo = (Get-Culture).TextInfo
    $RawSeries = ((((($WebRequest -split '<a href=\"\/tag\/magazine:(.*?)\/\">')[1])`
        -split '<\/a><\/div>')[0])`
        -replace '%23', '#')`
        -replace '_', ' '

    $Series = $TextInfo.ToTitleCase($RawSeries)
    if ($null -eq $Series -or $Series -eq '') {
        $Series = "Unknown"
    }
    Write-Output $Series
}

function Get-PandaSummary {
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

function Get-PandaTitle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest
    )

    $Title = (((($WebRequest -split '<title>')[1])` -split '\|')[0]).Trim()

    Write-Output $Title
}
