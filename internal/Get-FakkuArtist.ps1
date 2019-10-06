function Get-FakkuArtist {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [string]$WebRequest
        )

        $WebContent = $WebRequest.Content
        $RawArtist = ((((($WebContent -split '<div class=\"row-left\">Artist<\/div>')[1])`
                                        -split '\/artists\/(.*)\">')[1])`
                        -split '<\/a>')[0]
        
        $TextInfo = (Get-Culture).TextInfo
        $Artist = ($TextInfo.ToTitleCase($RawArtist)) -replace '-', ' '
        Write-Output $Artist
}