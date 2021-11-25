function Get-FakkuSummary {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        # Will try to detect where line breaks should be present and insert them (letter/number directly following punctuation)
        $Summary = (((($WebRequest -split '<meta name="description" content=" ')[1])`
                -split '">')[0]).Trim()`
                -replace '(\.|\?|\!)([a-zA-Z0-9])', '$1`n`n$2'`
                -replace '&', '&amp;'

        # Removing as new site layout requires getting description from the header
        <#$Summary = $rawSummary -replace '<br>', "`n"`
                -replace '<br />', "`n"`
                -replace '<br/>', "`n"`
                -replace '</p>', "`n"`
                -replace'<a[^>]*>(.*?)<\/a>', '$1'`
                -replace '<[^>]*>', ''`
                -replace '&', '&amp;'#>
        Write-Output $Summary
}
