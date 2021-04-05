function Get-FakkuMetadata {
    [CmdletBinding(DefaultParameterSetName = 'Url')]
    param (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Name')]
        [String]$DoujinName,

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Url')]
        [String]$Url
    )

    Switch ($PSCmdlet.ParameterSetName) {
        'Name' {
            try {
                $fakkuUrl = Get-FakkuURL -DoujinName $DoujinName
                $fakkuData = Invoke-WebRequest $fakkuUrl -Method Get -Verbose:$false
                $xml = Get-MetadataXML -WebRequest $fakkuData -Scraper Fakku
            } catch {
                try {
                    $pandaChaikaUrl = Get-PandaChaikaURL -DoujinName $DoujinName
                    $pandaChaikaData = Invoke-WebRequest $pandaChaikaUrl -Method Get -Verbose:$false
                    $xml = Get-MetadataXML -Webrequest $pandaChaikaData -Scraper PandaChaika
                } catch {
                    Write-Warning "Doujin $DoujinName not found..."
                    return
                }
            }

            Write-Output $xml
        }

        'Url' {
            try {
                if ($Url -match 'fakku') {
                    $fakkuData = Invoke-WebRequest $Url -Method Get -Verbose:$false
                    $xml = Get-MetadataXML -WebRequest $fakkuData -Scraper Fakku
                } elseif ($Url -match 'panda.chaika') {
                    $pandaChaikaData = Invoke-WebRequest $Url -Method Get -Verbose:$false
                    $xml = Get-MetadataXML -Webrequest $pandaChaikaData -Scraper PandaChaika
                } else {
                    Write-Warning "Url $Url is not a valid fakku or panda.chaika url"
                }
            } catch {
                Write-Warning "Error occurred while scraping $Url : $PSItem"
            }

            Write-Output $xml
        }
    }
}
