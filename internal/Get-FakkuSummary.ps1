function Get-FakkuSummary {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $rawSummary = ((((($WebRequest -split '<div class="row-left">Description<\/div>')[1])`
                                        -split '<div class="row-right">')[1]`
                                -split '<\/div>')[0]).Trim()

        # Removes the <br><br> string which appears in the raw HTML when the description on Fakku has line breaks
        # Added filtering for other tags and changed line break to insert new lines
        $summary = $rawSummary -replace '<br>', "`n"`
                -replace '<br />', "`n"`
                -replace '<br/>', "`n"`
                -replace '</p>', "`n"`
                -replace'<a[^>]*>(.*?)<\/a>', '$1'`
                -replace '<[^>]*>', ''`
                -replace '&', '&amp;'
        Write-Output $summary
}
