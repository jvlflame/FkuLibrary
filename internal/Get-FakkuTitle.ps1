function Get-FakkuTitle {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        # Site layout change makes it easier to grab title from <title> tag
        $Title = (($WebRequest -split '<title>(.*?)[Hh]entai by.*<\/title>')[1]).Trim()`
                -replace '&(?!amp;)', '&amp;'

        Write-Output $Title
}
