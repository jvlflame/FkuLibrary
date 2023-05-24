function Get-MetadataXML {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$WebRequest,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Fakku', 'Panda')]
        [String]$Scraper = 'Fakku',

        [Parameter(Mandatory = $true)]
        [String]$Url
    )
    switch ($Scraper) {
        'Fakku' {
            $Title = Get-FakkuTitle -Webrequest $WebRequest
            $Series = Get-FakkuSeries -WebRequest $WebRequest
            $SeriesNumber = Get-FakkuVolume -WebRequest $WebRequest -Url $Url
            $Group = Get-FakkuGroup -WebRequest $WebRequest
            $Summary = Get-FakkuSummary -WebRequest $WebRequest
            $Artist = Get-FakkuArtist -WebRequest $WebRequest
            $Circle = Get-FakkuCircle -WebRequest $WebRequest
            $Publisher = Get-FakkuPublisher -WebRequest $WebRequest
            $Genres = Get-FakkuGenres -WebRequest $WebRequest
            $Parody = Get-FakkuParody -WebRequest $WebRequest
        }

        'Panda' {
            $Title = Get-PandaTitle -Webrequest $WebRequest
            $Group = Get-PandaSeries -WebRequest $WebRequest
            $Summary = Get-PandaSummary -WebRequest $WebRequest
            $Artist = Get-PandaArtist -WebRequest $WebRequest
            $Publisher = Get-PandaPublisher -WebRequest $WebRequest
            $Genres = Get-PandaGenres -WebRequest $WebRequest
        }
    }
    # Month/Year from magazine name
    if ($Group -match "\b\d{4}\b") {$Year = $Matches.Values}
    if ($Group -match "\b-\d{2}\b") {$Month = $Group.Substring($Group.Length - 2)}

    # Writes XML in a less hacky way
    $StringWriter = New-Object System.IO.StringWriter
    $XmlWriter = New-Object System.XMl.XmlTextWriter($StringWriter)
    # XML settings
    $XmlWriter.Formatting = "Indented"
    $XmlWriter.Indentation = 2
    $XmlWriter.IndentChar = " "
    # Start writing
    $XmlWriter.WriteStartElement("ComicInfo")
    $XmlWriter.WriteAttributeString("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
    $XmlWriter.WriteAttributeString("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
    $XmlWriter.WriteElementString("Title", $Title)
    if ($Series) {
        $XmlWriter.WriteElementString("Series", $Series)
        $XmlWriter.WriteElementString("Number", $SeriesNumber)
    }
    if ($Parody) {$XmlWriter.WriteElementString("AlternateSeries", $Parody)}
    $XmlWriter.WriteElementString("Summary", $Summary)
    if ($Year) {$XmlWriter.WriteElementString("Year", $Year)}
    if ($Month) {$XmlWriter.WriteElementString("Month", $Month)}
    $XmlWriter.WriteElementString("Writer", $Artist)
    $XmlWriter.WriteElementString("Publisher", $Publisher)
    if ($Circle) {$XmlWriter.WriteElementString("Imprint", $Circle)}
    $XmlWriter.WriteElementString("Tags", $Genres)
    $XmlWriter.WriteElementString("Web", $Url)
    $XmlWriter.WriteElementString("LanguageISO", "en")
    $XmlWriter.WriteElementString("Manga", "Yes")
    $XmlWriter.WriteElementString("SeriesGroup", $Group)
    $XmlWriter.WriteElementString("AgeRating", "Adults Only 18+")
    $XmlWriter.WriteEndElement()

    $XmlWriter.Flush()
    $StringWriter.Flush()

    Write-Output $StringWriter.ToString()
}
