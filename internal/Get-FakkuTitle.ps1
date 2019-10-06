function Get-FakkuTitle {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [string]$WebRequest
        )

        $WebContent = $WebRequest.Content
        $Title = ((((($WebContent -split '<div class=\"content-name\">')[1])`
                                        -split '<h1>')[1])`
                        -split '<\/h1>')[0]

        Write-Output $Title
}
