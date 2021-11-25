function Get-FakkuSeries {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$WebRequest
        )

        # (Removed title case in favor of official stylization)
        #$TextInfo = (Get-Culture).TextInfo 
        $Series = (((($WebRequest -split '<a href=\"\/magazines\/(.*?)\">')[2])`
                -split '<\/a><\/div>')[0]).Trim()

        # Will use event instead if there is no magazine
	if ([string]::IsNullOrEmpty($Series)) {
		$Series = (((($WebRequest -split '<a href=\"\/events\/(.*?)\">')[2])`
                        -split '<\/a><\/div>')[0]).Trim()
	}
        
        $Series = $Series -replace '<[^>]*>', ''`
                -replace '[\r\n\t\f\v]', ''

        #$Series = $TextInfo.ToTitleCase($rawSeries)
        Write-Output $Series
}
