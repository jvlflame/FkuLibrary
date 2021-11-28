function Get-FakkuURL {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$DoujinName
        )
        # Added other special character exceptions
        # It looks like some links convert apostrophes (') to 'bgb' while some don't. Can't really be bothered to write an elegant solution that checks both link possibilites
        $DoujinName -replace '★', 'bzb' `
                -replace '☆', 'byb' `
                -replace '♪', 'bvb' `
                -replace '↑', 'b' `
                -replace '×', 'x' `
                -replace '  ', ' '
        # Gets the filename and converts it to a parseable Fakku web URL
        # The filename must match exactly what is presented by Fakku or scrape will fail
        # Match and clean "[Artist] FileName (Comic XXX).ext" (This works incorrectly when titles have parentheses in them)
        # Inadvertently removes titles in brackets, but that's a rare occurence
        if ($DoujinName -match '^\[.*?\]') {
                $CleanFileName = ((((($DoujinName -split "]")[1])`
                        -split "\(")[0]).Trim())`
                        -replace ' ', '-'`
                        -replace '--{2,}', '-'
        }

        # Match and clean "FileName (Comic XXX).ext"
        elseif ($DoujinName -match '\(') {
                $CleanFileName = ((($DoujinName -split "\(")[0]).Trim())`
                        -replace ' ', '-'`
                        -replace '--{2,}', '-'
}

        # Match and clean "FileName.ext"
        elseif ($DoujinName -match '^[a-zA-Z0-9]') {
                $CleanFileName = $DoujinName -replace ' ', '-'`
                        -replace '--{2,}', '-'
        }

        if ($CleanFileName.Substring($CleanFileName.Length - 1) -match "-") {
                $CleanFileName = $CleanFileName.Substring(0, $CleanFileName.Length - 1)
        }

        $FakkuUrl = "https://www.fakku.net/hentai/$CleanFileName-english"
        Write-Output $FakkuUrl
}
