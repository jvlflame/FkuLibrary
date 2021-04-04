function Get-FakkuArtist {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $artist = (((($WebRequest -split '<div class=\"row-right\"><a href=\"\/artists\/(.*?)\">')[2])`
                                -split '<\/a><\/div>')[0]).Trim()

        Write-Output $artist
}
