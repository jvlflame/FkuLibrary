function Get-FakkuParody {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        # In the rare case there's multiple Parody attributions, it will only take the first
        $Parody = (((($WebRequest -split '<a href=\"\/series\/(.*?)\">')[2])`
            -split '<\/a>')[0]).Trim()`
            -replace ',', ''`
            -replace '&', '&amp;'

        Write-Output $Parody
}
