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
        $summary = $rawSummary -replace '<br><br>', ''
        Write-Output $summary
}
