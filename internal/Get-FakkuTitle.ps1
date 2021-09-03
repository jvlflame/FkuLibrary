function Get-FakkuTitle {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $title = (((((($WebRequest -split '<div class=\"content-name\">')[1])`
                                                -split '<h1>')[1])`
                                -split '<\/h1>')[0]).Trim()
        $title = $title -replace '&', '&amp;'

        Write-Output $title
}
