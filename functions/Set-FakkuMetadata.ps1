function Set-FakkuMetadata {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [System.IO.FileInfo]$FilePath,
                [Parameter(Mandatory = $false)]
                [Switch]$Recurse
        )

        $ProgressPreference = 'SilentlyContinue'

        foreach ($File in (Get-LocalArchives -FilePath $FilePath -Recurse:$Recurse)) {
                $FakkuUrl = Get-FakkuURL -DoujinName $File.BaseName
                $DoujinName = $File.BaseName

                Try {
                        $WebRequest = Invoke-WebRequest -Uri $FakkuUrl -Method Get
                        $XMLPath = Join-Path -Path $FilePath -ChildPath 'ComicInfo.xml'
                        Write-FakkuXML -WebRequest $WebRequest.Content -XMLPath $XMLPath
                        Set-MetadataXML -FilePath $File.Name -XMLPath $XMLPath
                }

                Catch [Microsoft.PowerShell.Commands.HttpResponseException] {
                        Write-Warning "Could not find '$DoujinName' on Fakku. Manga may not exist on Fakku, the filename does not follow the approved schemas, or may be inaccessible without authentication."
                }

                Catch [System.Net.WebException] {
                        Write-Warning "Could not access '$DoujinName' on Fakku. Manga is inaccessible without authentication."
                }

                Start-Sleep -Seconds 1
        }
}