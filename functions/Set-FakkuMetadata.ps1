function Set-FakkuMetadata {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [System.IO.FileInfo]$FilePath,
                [Parameter(Mandatory = $false)]
                [Switch]$Recurse
        )

        
        foreach ($File in (Get-LocalFakkuFiles -FilePath $FilePath -Recurse:$Recurse)) {
                $FakkuUrl = Get-FakkuURL -DoujinName $File.Name
                Try {
                        $WebRequest = Invoke-WebRequest -Uri $FakkuUrl -Method Get
                        $XMLPath = Join-Path -Path $FilePath -ChildPath 'ComicInfo.xml'
                        Write-Host "XML Path: $XMLPath"
                        Write-Host "Destination Path: $DestinationPath"
                        Write-FakkuXML -WebRequest $WebRequest.Content -XMLPath $XMLPath

                        # Temporarily rename files to bypass PowerShell path errors 
                        # that occur when path contains square brackets "[]"
                        if ($File.Name -match "\[" -or $File.Name -match "\]") {
                                $NewName = ($File.FullName -replace "\[", "_") -replace "\]", "_"
                                Rename-Item -LiteralPath $File -NewName $NewName
                        }

                        Compress-Archive -Path $XMLPath -Update -DestinationPath $NewName
                        Remove-Item -Path $XMLPath -Force
                        Rename-Item -LiteralPath $NewName -NewName $File.Name
                }

                Catch [Microsoft.PowerShell.Commands.HttpResponseException] {
                        $DoujinName = $File.BaseName
                        Write-Warning "Could not find '$DoujinName' on Fakku. Check filename to make sure it follows the approved schema."
                }
        }
}