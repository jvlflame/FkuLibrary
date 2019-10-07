function Get-FakkuSummary {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $RawSummary = ((((($WebRequest -split '<div class=\"row-left\">Description<\/div>')[1])`
                                        -split 'row-limit\">')[1])`
                        -split '<\/div>')[0]

        # Removes the <br><br> string which appears in the raw HTML when the description on Fakku has line breaks
        $Summary = $RawSummary -replace '<br><br>', ''
        Write-Output $Summary
}