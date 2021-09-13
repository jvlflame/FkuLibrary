function Get-FakkuParody {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $Parody = (((((($WebRequest -split '<div class=\"row-left\">Parody<\/div>')[1])`
                                                -split '<div class=\"row-right\"><a href=\"\/series\/(.*?)\">')[2])`
                                -split '</a></div>')[0]).Trim()

        $Parody = $Parody -replace '<[^>]*>', ''`
                -replace '[\r\n\t\f\v]', ''

        Write-Output $Parody
}
