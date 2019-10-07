function Write-MetadataXML {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest,
                [Parameter(Mandatory = $true)]
                [System.IO.FileInfo]$XMLPath,
                [Parameter(Mandatory = $false)]
                [Switch]$Fakku,
                [Parameter(Mandatory = $false)]
                [Switch]$PandaChaika
        )

        if ($Fakku) {
                $Title = Get-FakkuTitle -Webrequest $WebRequest
                $Series = Get-FakkuSeries -WebRequest $WebRequest
                $Summary = Get-FakkuSummary -WebRequest $WebRequest
                $Artist = Get-FakkuArtist -WebRequest $WebRequest
                $Publisher = Get-FakkuPublisher -WebRequest $WebRequest
                $Genres = Get-FakkuGenres -WebRequest $WebRequest
                # $Parody = Get-FakkuParody -WebRequest $WebRequest
        }

        elseif ($PandaChaika) {
                $Title = Get-PandaChaikaTitle -Webrequest $WebRequest
                $Series = Get-PandaChaikaSeries -WebRequest $WebRequest
                $Summary = Get-PandaChaikaSummary -WebRequest $WebRequest
                $Artist = Get-PandaChaikaArtist -WebRequest $WebRequest
                $Publisher = Get-PandaChaikaPublisher -WebRequest $WebRequest
                $Genres = Get-PandaChaikaGenres -WebRequest $WebRequest
        }

        Set-Content -LiteralPath $XMLPath -Value '<?xml version="1.0"?>' -Force
        
        $Content = @(
                '<ComicInfo xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                "  <Title>$Title</Title>"
                "  <Series>$Series</Series>"
                "  <Summary>$Summary</Summary>"
                "  <Writer>$Artist</Writer>"
                "  <Publisher>$Publisher</Publisher>"
                "  <Genre>$Genres</Genre>"
                # "  <Tags>$Parody</Tags>"
                "  <LanguageISO>en</LanguageISO>"
                "  <AgeRating>Adults Only 18+</AgeRating>"
                "  <Manga>Yes</Manga>"
                "</ComicInfo>"
        )

        Add-Content -LiteralPath $XMLPath -Value $Content
}