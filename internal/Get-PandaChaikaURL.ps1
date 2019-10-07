function Get-PandaChaikaURL {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$DoujinName
        )

        $ProgressPreference = 'SilentlyContinue'

        # Match "[Artist] FileName (Comic XXX).ext"
        if ($DoujinName -match '^\[(.*?)\](.*?)\((.*?)\)') {
                $Artist = ($DoujinName -split '\[(.*)\]')[1]
                $Title = ((((($DoujinName -split '\[(.*)\]')[2])`
                                                -split '\(')[0]).Trim())`
                        -replace ' ', '+'

                $SearchURL = "https://panda.chaika.moe/search/?qsearch=$Artist+$Title"
        }

        # Match "[Artist] FileName.ext"
        elseif ($DoujinName -match '^\[(.*?)\]') {
                $Artist = ($DoujinName -split '\[(.*)\]')[1]
                $Title = ((($DoujinName -split '\[(.*)\]')[2]).Trim())`
                        -replace ' ', '+'

                $SearchURL = "https://panda.chaika.moe/search/?qsearch=$Artist+$Title"
        }

        # Match "FileName.ext"
        elseif ($DoujinName -match '^[a-zA-Z0-9]') {
                $Artist = ''
                $Title = ($DoujinName.Trim()) -replace ' ', '+'
                $SearchURL = "https://panda.chaika.moe/search/?qsearch=$Title"
        }
        Write-Host $SearchURL
        $SearchPage = Invoke-WebRequest -Uri $SearchURL -Method Get
        $PageCheck = $SearchPage.Links | Where-Object { $_.href -like '/PandaChaika/*' }
        
        if ($null -ne $PageCheck) {
                $PandaChaikaID = $PageCheck.href
                $PandaChaikaUrl = "https://panda.chaika.moe/$PandaChaikaID"
        }

        Write-Output $PandaChaikaUrl
}