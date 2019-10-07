function Get-FakkuPublisher {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $WebContent = $WebRequest
        $TextInfo = (Get-Culture).TextInfo
        $RawPublisher = ((($WebContent -split '<div class=\"row-right\"><a href=\"\/publishers\/(.*?)\">')[2])`
                        -split '<\/a><\/div>')[0]
        
        $Publisher = $TextInfo.ToTitleCase($RawPublisher)
        Write-Output $Publisher
}