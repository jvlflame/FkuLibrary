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
    $SeriesNumber = Get-FakkuVolume -WebRequest $WebRequest -URL $URL
    $Group = Get-FakkuGroup -WebRequest $WebRequest
    $Summary = Get-FakkuSummary -WebRequest $WebRequest
    if ($Group -match "\b\d{4}\b") {$Year = $Matches.Values}
    if ($Group -match "\b-\d{2}\b") {$Month = $Group.Substring($Group.Length - 2)}
    $Artist = Get-FakkuArtist -WebRequest $WebRequest
    $Circle = Get-FakkuCircle -WebRequest $WebRequest
    $Publisher = Get-FakkuPublisher -WebRequest $WebRequest
    $Genres = Get-FakkuGenres -WebRequest $WebRequest
    $Parody = Get-FakkuParody -WebRequest $WebRequest

    # Writes XML in a less hacky way
    $StringWriter = New-Object System.IO.StringWriter
    $XMLWriter = New-Object System.XMl.XmlTextWriter($StringWriter)
    # XML settings
    $XMLWriter.Formatting = "Indented"
    $XMLWriter.Indentation = 2
    $XmlWriter.IndentChar = " "
    # Start writing
    $XMLWriter.WriteStartElement("ComicInfo")
    $XMLWriter.WriteAttributeString("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
    $XMLWriter.WriteAttributeString("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
    $XmlWriter.WriteElementString("Title", $Title)
    if ($Series) {
        $XmlWriter.WriteElementString("Series", $Series)
        $XmlWriter.WriteElementString("Number", $SeriesNumber)
    }
    $XmlWriter.WriteElementString("AlternateSeries", $Parody)
    $XmlWriter.WriteElementString("Summary", $Summary)
    if ($Year) {$XmlWriter.WriteElementString("Year", $Year)}
    if ($Month) {$XmlWriter.WriteElementString("Month", $Month)}
    $XmlWriter.WriteElementString("Writer", $Artist)
    $XmlWriter.WriteElementString("Publisher", $Publisher)
    if ($Circle) {$XmlWriter.WriteElementString("Imprint", $Circle)}
    $XmlWriter.WriteElementString("Tags", $Genres)
    $XmlWriter.WriteElementString("Web", $URL)
    $XmlWriter.WriteElementString("LanguageISO", "en")
    $XmlWriter.WriteElementString("Manga", "Yes")
    $XmlWriter.WriteElementString("SeriesGroup", $Group)
    $XmlWriter.WriteElementString("AgeRating", "Adults Only 18+")
    $XMLWriter.WriteEndElement()

    $XmlWriter.Flush()
    $StringWriter.Flush()

    Write-Output $StringWriter.ToString()
}
