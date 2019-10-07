function Set-FakkuMetadata {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true, Position = 1)]
                [System.IO.FileInfo]$FilePath,
                [Parameter(Mandatory = $false)]
                [Switch]$Recurse
        )

        $ProgressPreference = 'SilentlyContinue'
        Write-Host "Starting Fakku metadata scraper on path: $FilePath"
        
        # Check if FilePath is a directory or file to determine how to proceed
        if ((Get-Item -Path $FilePath) -is [System.IO.DirectoryInfo]) { $Archive = Get-LocalArchives -FilePath $FilePath -Recurse:$Recurse }
        else { $Archive = Get-Item $FilePath }

        $Index = 1
        $TotalIndex = $Archive.Count
        foreach ($File in $Archive) {
                $FakkuUrl = Get-FakkuURL -DoujinName $File.BaseName
                $FileName = $File.FullName
                $DoujinName = $File.BaseName
                $XMLPath = Join-Path -Path $File.DirectoryName -ChildPath 'ComicInfo.xml'
                Write-Host "($Index of $TotalIndex) Setting metadata for $DoujinName"

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
                                #Write-Error | Out-File -FilePath (Join-Path -Path ../$PSScriptRoot -ChildPath 'log.txt') -NoClobber -Append
                        }
                }

                Catch [System.Net.WebException] {
                        Write-Host "Could not find '$DoujinName' on Fakku. Manga is inaccessible without authentication."
                }

                $Index++
                # Start-Sleep -Seconds 1
        }
        Write-Host "Complete!"
}