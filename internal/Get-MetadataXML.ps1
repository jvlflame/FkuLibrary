function Get-MetadataXML {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest,
                [Parameter(Mandatory = $true)]
                [ValidateSet('Fakku', 'PandaChaika')]
                [String]$Scraper,
                [Parameter(Mandatory = $true)]
                [String]$URL
        )

        switch ($Scraper) {
                'Fakku' {
                        $Title = Get-FakkuTitle -Webrequest $WebRequest
                        $Series = Get-FakkuSeries -WebRequest $WebRequest
                        $Summary = Get-FakkuSummary -WebRequest $WebRequest
                        $Artist = Get-FakkuArtist -WebRequest $WebRequest
                        $Publisher = Get-FakkuPublisher -WebRequest $WebRequest
                        $Genres = Get-FakkuGenres -WebRequest $WebRequest
                        $Parody = Get-FakkuParody -WebRequest $WebRequest
                }

                'PandaChaika' {
                        $Title = Get-PandaChaikaTitle -Webrequest $WebRequest
                        $Series = Get-PandaChaikaSeries -WebRequest $WebRequest
                        $Summary = Get-PandaChaikaSummary -WebRequest $WebRequest
                        $Artist = Get-PandaChaikaArtist -WebRequest $WebRequest
                        $Publisher = Get-PandaChaikaPublisher -WebRequest $WebRequest
                        $Genres = Get-PandaChaikaGenres -WebRequest $WebRequest
                }
        }

        # Tries to derive Year/Month from a given comic's name
        if ($Series -match "\b\d{4}\b-\b\d{2}\b") {
                $Year = $Series.Substring($series.Length - 7, 4)
                $Year = "`n  <Year>$Year</Year>"
                $Month = $Series.Substring($series.Length - 2)
                $Month = "`n  <Month>$Month</Month>"
        } 

        elseif ($series -match "\b\d{4}\b") {
                $Year = $matches[0]
                $Year = "`n  <Year>$Year</Year>"
                $Month = ""
        } 
        
        else {
                $Year = $Month = ""
        }

        # Changed to use SeriesGroup instead of Series for Magazines/Events as they're more a grouping of series than actual series. This greatly improves how Komga sorts.
        $Content = @"
<?xml version="1.0"?>
<ComicInfo xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Title>$Title</Title>
  <AlternateSeries>$Parody</AlternateSeries>
  <Summary>$Summary</Summary>$Year$Month
  <Writer>$Artist</Writer>
  <Publisher>$Publisher</Publisher>
  <Genre>$Genres</Genre>
  <Web>$URL</Web>
  <LanguageISO>en</LanguageISO>
  <Manga>Yes</Manga>
  <SeriesGroup>$Series</SeriesGroup>
  <AgeRating>Adults Only 18+</AgeRating>
</ComicInfo>
"@

        Write-Output $Content
}
