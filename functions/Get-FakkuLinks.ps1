function Get-FakkuLinks {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ParameterSetName = 'Path')]
        [String]$FilePath,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$Recurse,

        [Parameter(Position = 0, ParameterSetName = 'Name')]
        [String]$Name
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
                    Fakku = Get-FakkuUrl -Name $Name
                }
            }

            'Path' {
                foreach ($File in $Archives) {
                    [PSCustomObject]@{
                        Fakku = Get-FakkuUrl -Name $File.BaseName
                    }
                }
            }
        }
    }

}
