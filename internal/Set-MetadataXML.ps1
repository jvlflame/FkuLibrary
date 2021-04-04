function Set-MetadataXML {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$FilePath,
                [Parameter(Mandatory = $true)]
                [String]$XMLPath,
                [Parameter(Mandatory = $true)]
                [String]$Content
        )

        Set-Content -LiteralPath $XMLPath -Value $Content -Force

        # Temporarily rename files to bypass PowerShell path errors
        # that occur when path contains square brackets "[]"
        if ($File.Name -match "\[" -or $File.Name -match "\]") {
                $NewName = ($File.FullName -replace "\[", "_") -replace "\]", "_"
                Rename-Item -LiteralPath $File -NewName $NewName
        }

        Compress-Archive -Path $XMLPath -Update -DestinationPath $NewName
        Remove-Item -Path $XMLPath -Force
        Rename-Item -LiteralPath $NewName -NewName $FilePath
}
