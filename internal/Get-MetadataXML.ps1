function Get-MetadataXML {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest,
        [Parameter(Mandatory = $true)]
        [String]$URL
    )

    $Title = Get-FakkuTitle -Webrequest $WebRequest
    $Series = Get-FakkuSeries -WebRequest $WebRequest
    $Summary = Get-FakkuSummary -WebRequest $WebRequest
    $Artist = Get-FakkuArtist -WebRequest $WebRequest
    $Publisher = Get-FakkuPublisher -WebRequest $WebRequest
    $Genres = Get-FakkuGenres -WebRequest $WebRequest
    $Parody = Get-FakkuParody -WebRequest $WebRequest

    # Tries to derive Year/Month from a given comic's name
    $Year = $Month = ""
    if ($Series -match "\b\d{4}-\d{2}\b") {
        $Year = "`n  <Year>$($Series.Substring($Series.Length - 7, 4))</Year>"
        $Month = "`n  <Month>$($Series.Substring($Series.Length - 2))</Month>"
    } elseif ($Series -match "\b\d{4}\b") {
        $Year = "`n  <Year>$($Matches.Values)</Year>"
    }

    $Content = @"
<?xml version="1.0"?>
<ComicInfo xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Title>$Title</Title>
  <AlternateSeries>$Parody</AlternateSeries>
  <Summary>$Summary</Summary>$Year$Month
  <Writer>$Artist</Writer>
  <Publisher>$Publisher</Publisher>
  <Tags>$Genres</Tags>
  <Web>$URL</Web>
  <LanguageISO>en</LanguageISO>
  <Manga>Yes</Manga>
  <SeriesGroup>$Series</SeriesGroup>
  <AgeRating>Adults Only 18+</AgeRating>
</ComicInfo>
"@

    Write-Output $Content
}
