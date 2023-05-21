function Set-MetadataXML {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$FilePath,

        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$XMLPath,

        [Parameter(Mandatory = $true)]
        [String]$Content
    )

        Set-Content -LiteralPath $XMLPath -Value $Content -Force

        # Avoid errors with square brackets in file paths.
        if ($File.FullName -match "\[" -or $File.FullName -match "\]") {
            $TempName = ($File.FullName -replace "\[", "_") -replace "\]", "_"
            Rename-Item -LiteralPath $File -NewName $TempName
        } else {
            $TempName = $FilePath
        }

    Compress-Archive -LiteralPath $XMLPath -DestinationPath $TempName -Update
    Remove-Item -LiteralPath $XMLPath -Force
    Rename-Item -LiteralPath $TempName -NewName $FilePath
}
