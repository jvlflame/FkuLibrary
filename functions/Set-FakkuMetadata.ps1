function Set-FakkuMetadata {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [System.IO.FileInfo]$FilePath,
                [Parameter(Mandatory = $false)]
                [Switch]$Recurse
        )

        $ProgressPreference = 'SilentlyContinue'
        Write-Host "Starting Fakku metadata scraper"
        $LocalArchives = Get-LocalArchives -FilePath $FilePath -Recurse:$Recurse
        $Index = 1
        $TotalIndex = $LocalArchives.Count
        foreach ($File in $LocalArchives) {
                $FakkuUrl = Get-FakkuURL -DoujinName $File.BaseName
                $FileName = $File.FullName
                $DoujinName = $File.BaseName
                $XMLPath = Join-Path -Path $FilePath -ChildPath 'ComicInfo.xml'
                Write-Host "($Index of $TotalIndex) Setting metadata for $FileName"
                Try {
                        $WebRequest = Invoke-WebRequest -Uri $FakkuUrl -Method Get
                        Write-MetadataXML -WebRequest $WebRequest.Content -XMLPath $XMLPath -Fakku
                        Set-MetadataXML -FilePath $File.Name -XMLPath $XMLPath
                }

                Catch [Microsoft.PowerShell.Commands.HttpResponseException] {
                        # Write-Warning "Could not find on Fakku. Attempting to search panda.chaika.moe..."
                        $PandaChaikaUrl = Get-PandaChaikaURL -DoujinName $DoujinName

                        Try {
                                $WebRequest = Invoke-WebRequest -Uri $PandaChaikaUrl -Method Get
                                Write-MetadataXML -WebRequest $WebRequest.Content -XMLPath $XMLPath -PandaChaika
                                Set-MetadataXML -FilePath $File.Name -XMLPath $XMLPath
                        }

                        Catch {
                                Write-Warning "Could not find metadata for $FileName. Skipping..."
                        }
                }

                Catch [System.Net.WebException] {
                        Write-Warning "Could not access '$DoujinName' on Fakku. Manga is inaccessible without authentication."
                }

                $Index++
                Start-Sleep -Seconds 1
        }
        Write-Host "Complete!"
}