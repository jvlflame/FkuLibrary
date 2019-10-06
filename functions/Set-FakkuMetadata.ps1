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
                        Write-FakkuXML -WebRequest $WebRequest
                }
                catch {
                        Write-Error ""$File.BaseName" not found on Fakku"
                }
        }
}