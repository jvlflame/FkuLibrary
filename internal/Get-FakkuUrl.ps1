function Get-FakkuURL {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$DoujinName
        )
        $DoujinName = $DoujinName -replace '★', 'bzb' `
                -replace '&', '' `
                -replace '-', '' `
                -replace '  ', ' '
        # Gets the filename and converts it to a parseable Fakku web URL
        # The filename must match exactly what is presented by Fakku or scrape will fail
        # Match and clean "[Artist] FileName (Comic XXX).ext"
        if ($DoujinName -match '^\[(.*?)\](.*?)\((.*?)\)') {
                $CleanFileName = (((((($DoujinName -split "]")[1])`
                                                        -split "\(")[0]).Trim())`
                                -replace '[^-a-z0-9 ]+', '')`
                        -replace ' ', '-'
        }

        # Match and clean "FileName (Comic XXX).ext"
        elseif ($DoujinName -match '^\[(.*?)\]') {
                $CleanFileName = (((($DoujinName -split "\(")[0]).Trim())`
                                -replace '[^-a-z0-9 ]+', '')`
                        -replace ' ', '-'
        }

        # Match and clean "FileName.ext"
        elseif ($DoujinName -match '^[a-zA-Z0-9]') {
                $CleanFileName = ($DoujinName -replace '[^-a-z0-9 ]+', '')`
                        -replace ' ', '-'
        }
        $FakkuUrl = "https://www.fakku.net/hentai/$CleanFileName-english"
        Write-Output $FakkuUrl
}
