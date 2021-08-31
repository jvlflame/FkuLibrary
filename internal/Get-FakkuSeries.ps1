function Get-FakkuSeries {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        #$TextInfo = (Get-Culture).TextInfo
        $Series = (((($WebRequest -split '<div class=\"row-right\"><a href=\"\/magazines\/(.*?)\">')[2])`
                                -split '<\/a><\/div>')[0]).Trim()
	if ([string]::IsNullOrEmpty($Series)) {
		$Series = (((($WebRequest -split '<div class=\"row-right\"><a href=\"\/events\/(.*?)\">')[2])`
                                	-split '<\/a><\/div>')[0]).Trim()
	}

        #$Series = $TextInfo.ToTitleCase($rawSeries)
        Write-Output $Series
}
