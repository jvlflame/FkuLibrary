function Set-FakkuMetadata {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [System.IO.FileInfo]$FilePath,
                [Parameter(Mandatory = $true)]
                [Switch]$Recurse
        )

        
        foreach ($File in (Get-LocalFakkuFiles -FilePath $FilePath -Recurse:$Recurse)) {
                $FakkuUrl = Get-FakkuURL -DoujinName $File.BaseName
                try {
                        $WebRequest = Invoke-WebRequest -Uri $FakkuUrl -Method Get
                        Write-FakkuXML -WebRequest $WebRequest -XMLPath (Join-Path -Path $FilePath -ChildPath 'ComicInfo.xml')
                }
                catch {
                        Write-Error ""$File.BaseName" not found on Fakku"
                }
        }
}