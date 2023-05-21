[CmdletBinding()]
param()

Write-Verbose $PSScriptRoot
Write-Verbose 'Import everything in sub folders folder.'

foreach ($folder in @('internal', 'functions')) {
    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $root) {
        Write-Verbose "Processing folder $root."
        $files = Get-ChildItem -Path $root -Filter *.ps1 -Recurse
        $files | ForEach-Object {Write-Verbose $_.BaseName; . $_.FullName}
    }
}

Export-ModuleMember -Function (Get-ChildItem -Path "$PSScriptRoot\functions\*.ps1").BaseName