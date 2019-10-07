function Get-FakkuArtist {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $Artist = ((($WebRequest -split '<div class=\"row-right\"><a href=\"\/artists\/(.*?)\">')[2])`
                        -split '<\/a><\/div>')[0]
        
        Write-Output $Artist
}