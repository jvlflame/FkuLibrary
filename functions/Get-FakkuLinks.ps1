function Get-FakkuLinks {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ParameterSetName = 'Path')]
        [String]$FilePath,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$Recurse,

        [Parameter(Position = 0, ParameterSetName = 'Name')]
        [String]$ComicName
    )

    begin {
        if ($FilePath) {
            $Archives = Get-LocalArchives -FilePath $FilePath -Recurse:$Recurse
        }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Name' {
                [PSCustomObject]@{
                    Fakku = Get-FakkuUrl -ComicName $ComicName
                }
            }

            'Path' {
                foreach ($File in $Archives) {
                    [PSCustomObject]@{
                        Fakku = Get-FakkuUrl -ComicName $File.BaseName
                    }
                }
            }
        }
    }

}
