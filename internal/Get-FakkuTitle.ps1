function Get-FakkuTitle {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $WebContent = $WebRequest
        $Title = ((((($WebContent -split '<div class=\"content-name\">')[1])`
                                        -split '<h1>')[1])`
                        -split '<\/h1>')[0]

        Write-Output $Title
}
