function Get-FakkuPublisher {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        #$TextInfo = (Get-Culture).TextInfo
        $Publisher = (((($WebRequest -split '<a href=\"\/publishers\/(.*?)\">')[2])`
                -split '<\/a><\/div>')[0]).Trim()

        #$publisher = $TextInfo.ToTitleCase($rawPublisher)
        Write-Output $Publisher
}
