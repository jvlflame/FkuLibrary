function Set-FakkuMetadata {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [System.IO.FileInfo]$FilePath
        )

        
        foreach ($File in (Get-LocalFakkuFiles -FilePath $FilePath)) {
                $FakkuUrl = Get-FakkuURL -DoujinName $File.BaseName
                        
                try {
                        $WebRequest = Invoke-WebRequest -Uri $FakkuUrl

                }
                catch {
                        Write-Error ""$File.BaseName" not found on Fakku"
                }
        }
}