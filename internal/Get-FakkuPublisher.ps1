function Get-FakkuPublisher {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $WebContent = $WebRequest
        $Publisher = ((($WebContent -split '<div class=\"row-right\"><a href=\"\/publishers\/(.*?)\">')[2])`
                        -split '<\/a><\/div>')[0]

        Write-Output $Publisher
}