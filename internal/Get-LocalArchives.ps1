function Get-LocalArchives {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [System.IO.FileInfo]$FilePath,
                [Parameter(Mandatory = $false)]
                [Switch]$Recurse
        )
        
        $LocalFakkuFiles = Get-ChildItem -Path $FilePath -Recurse:$Recurse | Where-Object { 
                $_.Name -like '*.zip'`
                        -or $_.Name -like '*.cbz'`
                        -or $_.Name -like '*.rar'`
                        -or $_.Name -like '*.cbr'`
                        -or $_.Name -like '*.7z'`
                        -or $_.Name -like '*.cb7' 
        }
    
        Write-Output $LocalArchives
}