function Get-MetadataXML {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest,
                [Parameter(Mandatory = $true)]
                [ValidateSet('Fakku', 'PandaChaika')]
                [String]$Scraper
        )

        switch ($Scraper) {
                'Fakku' {
                        $Title = Get-FakkuTitle -Webrequest $WebRequest
                        $Series = Get-FakkuSeries -WebRequest $WebRequest
                        $Summary = Get-FakkuSummary -WebRequest $WebRequest
                        $Artist = Get-FakkuArtist -WebRequest $WebRequest
                        $Publisher = Get-FakkuPublisher -WebRequest $WebRequest
                        $Genres = Get-FakkuGenres -WebRequest $WebRequest
                        # $Parody = Get-FakkuParody -WebRequest $WebRequest
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

        $Content = @"
<?xml version="1.0"?>
<ComicInfo xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Title>$Title</Title>
  <Series>$Series</Series>
  <Summary>$Summary</Summary>
  <Writer>$Artist</Writer>
  <Publisher>$Publisher</Publisher>
  <Genre>$Genres</Genre>
  <LanguageISO>en</LanguageISO>
  <AgeRating>Adults Only 18+</AgeRating>
  <Manga>Yes</Manga>
</ComicInfo>
"@

        Write-Output $Content
}
