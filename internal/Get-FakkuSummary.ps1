function Get-FakkuSummary {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $Summary = (((($WebRequest -split '<meta name="description" content="')[1])`
                -split '">')[0]).Trim()`
                -replace '&(?!amp;)', '&amp;'

        # Removed since description is grabbed from header now
        <#$Summary = $rawSummary -replace '<br>', "`n"`
                -replace '<br />', "`n"`
                -replace '<br/>', "`n"`
                -replace '</p>', "`n"`
                -replace'<a[^>]*>(.*?)<\/a>', '$1'`
                -replace '<[^>]*>', ''`
                -replace '&', '&amp;'#>
        Write-Output $Summary
}
