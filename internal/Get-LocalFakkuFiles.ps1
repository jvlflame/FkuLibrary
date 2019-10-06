function Get-LocalFakkuFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$FilePath
    )

    $LocalFakkuFiles = Get-ChildItem -Path $FilePath | Where-Object { 
        $_.Name -like '*.zip'`
            -or $_.Name -like '*.cbz'`
            -or $_.Name -like '*.rar'`
            -or $_.Name -like '*.cbr'`
            -or $_.Name -like '*.7z'`
            -or $_.Name -like '*.cb7' 
    }

    Write-Output $LocalFakkuFiles
}