function Write-FakkuXML {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [string]$WebRequest,
                [Parameter(Mandatory = $true)]
                [System.IO.FileInfo]$XMLPath,
                [Parameter()]
                [String]$Genres
        )

        $Summary = Get-FakkuSummary -WebRequest $WebRequest
        $Artist = Get-FakkuArtist -WebRequest $WebRequest
        $Publisher = Get-FakkuPublisher -WebRequest $WebRequest
        $Genres = Get-FakkuGenres -WebRequest $WebRequest
        Set-Content -LiteralPath $XMLPath -Value '<?xml version="1.0"?>' -Force

        $Content = @(
                '<ComicInfo xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                "  <Title>$Title</Title>"
                "  <Series>$Series</Series>"
                "  <Summary>$Summary</Summary>"
                "  <Writer>$Artist</Writer>"
                "  <Publisher>$Publisher</Publisher>"
                "  <Genre>$Genres</Genre>"
                "  <LanguageISO>en</LanguageISO>"
                "  <AgeRating>Adults Only 18+</AgeRating>"
                "  <Manga>Yes</Manga>"
                "</ComicInfo>"
        )

        Add-Content -LiteralPath $XMLPath -Value $Content
}