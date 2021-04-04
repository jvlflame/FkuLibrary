function Get-FakkuPublisher {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $TextInfo = (Get-Culture).TextInfo
        $rawPublisher = (((($WebRequest -split '<div class=\"row-right\"><a href=\"\/publishers\/(.*?)\">')[2])`
                                -split '<\/a><\/div>')[0]).ToLower().Trim()

        $publisher = $TextInfo.ToTitleCase($rawPublisher)
        Write-Output $publisher
}
