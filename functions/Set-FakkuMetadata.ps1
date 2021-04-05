function Set-FakkuMetadata {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true, Position = 1)]
                [System.IO.FileInfo]$FilePath,

                [Parameter(Mandatory = $false)]
                [String]$FakkuUrl,

                [Parameter(Mandatory = $false)]
                [String]$PandaChaikaUrl,

                [Parameter(Mandatory = $false)]
                [Switch]$Recurse
        )

        $ProgressPreference = 'SilentlyContinue'
        Write-Host "Starting Fakku metadata scraper on path: $FilePath"

        # Check if FilePath is a directory or file to determine how to proceed
        if ((Get-Item -Path $FilePath) -is [System.IO.DirectoryInfo]) {
                $Archive = Get-LocalArchives -FilePath $FilePath -Recurse:$Recurse
        } else {
                $Archive = Get-Item $FilePath
        }

        if (Test-Path -Path $FilePath -PathType Container) {
                if ($FakkuUrl -or $PandaChaikaUrl) {
                        Write-Warning "Parameters -FakkuUrl and -PandaChaikaUrl can only be used with a direct file path, not a directory..."
                        return
                }
        }

        $Index = 1
        $TotalIndex = $Archive.Count
        foreach ($File in $Archive) {
                if (!$FakkuUrl) {
                        $FakkuUrl = Get-FakkuURL -DoujinName $File.BaseName
                }
                $DoujinName = $File.BaseName
                $XMLPath = Join-Path -Path $File.DirectoryName -ChildPath 'ComicInfo.xml'
                Write-Host "($Index of $TotalIndex) Setting metadata for $DoujinName"

                try {
                        $WebRequest = Invoke-WebRequest -Uri $FakkuUrl -Method Get -Verbose:$false
                        $xml = $null
                        $xml = Get-MetadataXML -WebRequest $WebRequest.Content -Scraper Fakku
                        Set-MetadataXML -FilePath $File.Name -XMLPath $XMLPath -Content $xml
                }

                # If the Fakku URL returns an error, fallback to panda.chaika.moe
                catch {
                        Write-Warning "$DoujinName not found on Fakku..."
                        if (!$PandaChaikaUrl) {
                                $PandaChaikaUrl = Get-PandaChaikaURL -DoujinName $DoujinName
                        }

                        try {
                                $WebRequest = Invoke-WebRequest -Uri $PandaChaikaUrl -Method Get -Verbose:$false
                                $xml = $null
                                $xml = Get-MetadataXML -WebRequest $WebRequest.Content -Scraper PandaChaika
                                Set-MetadataXML -FilePath $File.Name -XMLPath $XMLPath -Content $xml
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
