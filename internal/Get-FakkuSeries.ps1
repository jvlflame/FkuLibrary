function Get-FakkuSeries {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        $Series = (((($WebRequest -split '<a.*magazines.*?>')[1])`
                -split '<\/a>')[0]).Trim()

        # Will use event instead if there is no magazine
	if ([string]::IsNullOrEmpty($Series)) {
		$Series = (((($WebRequest -split '<a.*events.*?>')[1])`
                        -split '<\/a>')[0]).Trim()
	}

        Write-Output $Series
}
