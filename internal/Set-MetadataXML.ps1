function Set-MetadataXML {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$FilePath,

        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$XmlPath,

        [Parameter(Mandatory = $true)]
        [String]$Content
    )

        Set-Content -LiteralPath $XmlPath -Value $Content -Force

        # Avoid errors with square brackets in file paths.
        if ($File.FullName -match "\[" -or $File.FullName -match "\]") {
            $TempName = ($File.FullName -replace "\[", "_") -replace "\]", "_"
            Rename-Item -LiteralPath $File -NewName $TempName
        } else {
            $TempName = $FilePath
        }

    Compress-Archive -LiteralPath $XmlPath -DestinationPath $TempName -Update
    Remove-Item -LiteralPath $XmlPath -Force
    Rename-Item -LiteralPath $TempName -NewName $FilePath
}
