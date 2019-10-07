function Get-FakkuSeries {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $TextInfo = (Get-Culture).TextInfo
        $RawSeries = ((($WebContent -split '<div class=\"row-right\"><a href=\"\/magazines\/(.*?)\">')[2])`
                        -split '<\/a><\/div>')[0]
        
        $Series = $TextInfo.ToTitleCase($RawSeries)
        Write-Output $Series
}