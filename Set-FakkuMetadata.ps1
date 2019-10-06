function Set-FakkuMetadata {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [System.IO.FileInfo]$FilePath
        )

        function Get-LocalFakkuFiles {
                [CmdletBinding()]
                param(
                        [Parameter(Mandatory = $true)]
                        [System.IO.FileInfo]$FilePath
                )
        
                $LocalFakkuFiles = Get-ChildItem -Path $FilePath | Where-Object { 
                        $_.Name -like '*.zip'`
                                -or $_.Name -like '*.cbz'`
                                -or $_.Name -like '*.rar'`
                                -or $_.Name -like '*.cbr'`
                                -or $_.Name -like '*.7z'`
                                -or $_.Name -like '*.cb7' 
                }

                Write-Output $LocalFakkuFiles
        }

        function Get-FakkuArtist {
                [CmdletBinding()]
                param(
                        [Parameter(Mandatory = $true)]
                        [string]$WebRequest
                )

                $WebContent = $WebRequest.Content
                $RawArtist = ((((($WebContent -split '<div class=\"row-left\">Artist<\/div>')[1])`
                                                -split '\/artists\/(.*)\">')[1])`
                                -split '<\/a>')[0]
                
                $TextInfo = (Get-Culture).TextInfo
                $Artist = ($TextInfo.ToTitleCase($RawArtist)) -replace '-', ' '
                Write-Output $Artist
        }

        function Get-FakkuGenres {
                [CmdletBinding()]
                param(
                        [Parameter(Mandatory = $true)]
                        [string]$WebRequest
                )
                
                $WebContent = $WebRequest.Content
                $RawGenres = (((($WebContent -split '<div class=\"row-right tags\">')[1])`
                                        -split '<a class=\"js-suggest-tag')[0])`
                        -split '\">(.*?)<\/a>'
                
                $Genres = ($RawGenres -notmatch '<a href*')
                # Formats the genres as a comma-delimited string "Genre1, Genre2, etc." which is accepted by ComicInfo.xml format
                $GenreString = $Genres[0..($Genres.Length - 2)] -join ", "
                Write-Output $GenreString
        }

        function Get-FakkuPublisher {
                [CmdletBinding()]
                param(
                        [Parameter(Mandatory = $true)]
                        [string]$WebRequest
                )

                $RawPublisher = $WebRequest.Links.href | Where-Object { $_ -like '/publishers*' }
                $Publisher = ($RawPublisher -split 'publishers\/')[1]
                Write-Output $Publisher
        }

        function Get-FakkuSummary {
                [CmdletBinding()]
                param(
                        [Parameter(Mandatory = $true)]
                        [string]$WebRequest
                )

                $WebContent = $WebRequest.Content
                $RawSummary = ((((($WebContent -split '<div class=\"row-left\">Description<\/div>')[1])`
                                                -split 'row-limit\">')[1])`
                                -split '<\/div>')[0]

                # Removes the <br><br> string which appears in the raw HTML when the description on Fakku has line breaks
                $Summary = $RawSummary -replace '<br><br>', ''
                Write-Output $Summary
        }
      
        function Get-FakkuURL {
                [CmdletBinding()]
                param(
                        [Parameter(Mandatory = $true)]
                        [string]$DoujinName
                )
                
                # Gets the filename and converts it to a parseable Fakku web URL
                # The filename must match exactly what is presented by Fakku or scrape will fail
                $CleanFileName = ((((($DoujinName.Name -split "]")[1])`
                                                -split "\(")[0]).Trim()) -replace " ", "-"
                
                
                $FakkuUrl = "https://www.fakku.net/hentai/$CleanFileName-english"
                Write-Output $FakkuUrl
        }

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
        
        foreach ($File in (Get-LocalFakkuFiles -FilePath $FilePath)) {
                $FakkuUrl = Get-FakkuURL -DoujinName $File.BaseName
                        
                try {
                        $WebRequest = Invoke-WebRequest -Uri $FakkuUrl

                }
                catch {
                        Write-Error ""$File.BaseName" not found on Fakku"
                }

                <#
                        $CleanFileName = ((((($File.Name -split "]")[1])`
                                                        -split "\(")[0]).Trim()) -replace " ", "-"
                
                        $FakkuUrl = "https://www.fakku.net/hentai/$CleanFileName-english"
                
                        try {
                                $WebRequest = Invoke-WebRequest -Uri $FakkuUrl
                        }
                
                        catch {
                                Write-Host ""$File.FileName" not found on Fakku"
                        }
                
                        $RawTags = $WebRequest.Links | Where-Object { $_.href -like '/tags/*' }
                        $Tags = ($RawTags.href -split '\/tags\/')
                        #>
        }
}