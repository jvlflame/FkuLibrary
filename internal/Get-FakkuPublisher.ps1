function Get-FakkuPublisher {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [string]$WebRequest
        )

        $RawPublisher = $WebRequest.Links.href | Where-Object { $_ -like '/publishers*' }
        $Publisher = ($RawPublisher -split 'publishers\/')[1]
        Write-Output $Publisher
}