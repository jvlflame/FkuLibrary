function Set-FakkuMetadata {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true, Position = 1)]
                [System.IO.FileInfo]$FilePath,

                [Parameter(Mandatory = $false)]
                [String]$Url,

                [Parameter(Mandatory = $false)]
                [Switch]$Recurse,

                [Parameter(Mandatory = $false)]
                [Switch]$Log,

                [Parameter(Mandatory = $false)]
                [System.IO.FileInfo]$LogPath = ".\fkulibrary.log"
        )

        function Write-FakkuLog {
                param(
                        [Switch]$Log,
                        [System.IO.FileInfo]$LogPath,
                        [String]$Source
                )

                if ($Log) {
                        [PSCustomObject]@{
                                FilePath = $FilePath
                                Url      = $FakkuUrl
                                Source   = $Source
                        } | Export-Csv -Path $LogPath -Append
                }
        }

        $ProgressPreference = 'SilentlyContinue'
        Write-Host "Starting Fakku metadata scraper on path: $FilePath"

        # Check if FilePath is a directory or file to determine how to proceed
        if ((Get-Item -Path $FilePath) -is [System.IO.DirectoryInfo]) {
                $Archive = Get-LocalArchives -FilePath $FilePath -Recurse:$Recurse
        } else {
                $Archive = Get-Item $FilePath
        }

        if (Test-Path -Path $FilePath -PathType Container) {
                if ($Url) {
                        Write-Warning "Parameters -FakkuUrl and -PandaChaikaUrl can only be used with a direct file path, not a directory..."
                        return
                }
        }

        if ($PSBoundParameters.ContainsKey('Url')) {
                if ($Url -match 'fakku') {
                        $UriLocation = 'fakku'
                } elseif ($Url -match 'panda.chaika') {
                        $UriLocation = 'panda.chaika'
                } else {
                        Write-Warning "Url $Url is not a valid fakku or panda.chaika url"
                        return
                }
                Write-Debug "UriLocation: $UriLocation"
        }

        $Index = 1
        $TotalIndex = $Archive.Count
        foreach ($File in $Archive) {
                if ($UriLocation) {
                        if ($UriLocation -eq 'fakku') {
                                $FakkuUrl = $Url
                        }
                        if ($UriLocation -eq 'panda.chaika') {
                                $PandaChaikaUrl = $Url
                        }
                }

                Write-Debug "FakkuUrl: $FakkuUrl"
                Write-Debug "PandaChaikaUrl: $PandaChaikaUrl"

                $DoujinName = $File.BaseName
                $XMLPath = Join-Path -Path $File.DirectoryName -ChildPath 'ComicInfo.xml'
                Write-Host "($Index of $TotalIndex) Setting metadata for $DoujinName"

                try {
                        if (!$UriLocation) {
                                $FakkuUrl = Get-FakkuURL -DoujinName $File.BaseName
                        }
                        $WebRequest = Invoke-WebRequest -Uri $FakkuUrl -Method Get -Verbose:$false
                        $xml = $null
                        $xml = Get-MetadataXML -WebRequest $WebRequest.Content -Scraper Fakku
                        Set-MetadataXML -FilePath $File.Name -XMLPath $XMLPath -Content $xml
                        Write-FakkuLog -Log:$Log -LogPath $LogPath -Source "Fakku"
                        Write-Verbose "Set $FilePath with $FakkuUrl"
                        Write-Debug "Set $FilePath using Fakku"
                }

                # If the Fakku URL returns an error, fallback to panda.chaika.moe
                catch {
                        try {
                                if (!$UriLocation) {
                                        Write-Warning "$DoujinName not found on Fakku..."
                                        $PandaChaikaUrl = Get-PandaChaikaURL -DoujinName $File.BaseName
                                }
                                $WebRequest = Invoke-WebRequest -Uri $PandaChaikaUrl -Method Get -Verbose:$false
                                $xml = $null
                                $xml = Get-MetadataXML -WebRequest $WebRequest.Content -Scraper PandaChaika
                                Set-MetadataXML -FilePath $File.Name -XMLPath $XMLPath -Content $xml
                                Write-FakkuLog -Log:$Log -LogPath $LogPath -Source "PandaChaikaMoe"
                                Write-Verbose "Set $FilePath with $PandaChaikaUrl"
                                Write-Debug "Set $FilePath using Panda.Chaika.Moe"
                        }

                        catch {
                                Write-Warning "$DoujinName not found on panda.chaika..."
                                #Write-Error | Out-File -FilePath (Join-Path -Path ../$PSScriptRoot -ChildPath 'log.txt') -NoClobber -Append
                        }
                }

                <#
                [Microsoft.PowerShell.Commands.HttpResponseException]
                catch [System.Net.WebException] {
                        Write-Host "Could not find '$DoujinName' on Fakku. Manga is inaccessible without authentication."
                } #>

                $Index++
                # Start-Sleep -Seconds 1
        }
        Write-Host "Complete!"
}
