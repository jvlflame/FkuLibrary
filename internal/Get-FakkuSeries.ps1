function Get-FakkuSeries {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [string]$WebRequest
        )

        $WebContent = $WebRequest.Content
        $Series = ((($WebContent -split '<div class=\"row-right\"><a href=\"\/magazines\/(.*?)\">')[2])`
                        -split '<\/a><\/div>')[0]

        Write-Output $Series
}