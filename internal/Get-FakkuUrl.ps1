function Get-FakkuURL {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [string]$DoujinName
        )
        
        # Gets the filename and converts it to a parseable Fakku web URL
        # The filename must match exactly what is presented by Fakku or scrape will fail
        $CleanFileName = ((((($DoujinName.Name -split "]")[1])`
                                        -split "\(")[0]).Trim()) -replace " ", "-"
        
        
        $FakkuUrl = "https://www.fakku.net/hentai/$CleanFileName-english"
        Write-Output $FakkuUrl
}