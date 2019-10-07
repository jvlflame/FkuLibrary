function Get-FakkuPublisher {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $TextInfo = (Get-Culture).TextInfo
        $RawPublisher = ((($WebRequest -split '<div class=\"row-right\"><a href=\"\/publishers\/(.*?)\">')[2])`
                        -split '<\/a><\/div>')[0]
        
        $Publisher = $TextInfo.ToTitleCase($RawPublisher)
        Write-Output $Publisher
}