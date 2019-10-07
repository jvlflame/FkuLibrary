function Get-PandaChaikaURL {
        [CmdletBinding()]
        param(
                [Parameter(Mandatory = $true)]
                [String]$DoujinName
        )

        $ProgressPreference = 'SilentlyContinue'
        $DoujinName = $DoujinName -replace '\p{S} ', 'bzb'

        # Match "[Artist] FileName (Comic XXX).ext"
        if ($DoujinName -match '^\[(.*?)\](.*?)\((.*?)\)') {
                $Artist = ((($DoujinName -split '\[(.*)\]')[1]) -replace ' ', '_').ToLower()
                $Title = (((((($DoujinName -split '\[(.*)\]')[2])`
                                                        -split '\(')[0]).Trim())`
                                -replace ' ', '+').ToLower()

                
                $SearchURL = "https://panda.chaika.moe/search/?title=$Title&tags=artist%3A$Artist"
        }

        # Match "[Artist] FileName.ext"
        elseif ($DoujinName -match '^\[(.*?)\]') {
                $Artist = ((($DoujinName -split '\[(.*)\]')[1]) -replace ' ', '_').ToLower()
                $Title = (((($DoujinName -split '\[(.*)\]')[2]).Trim())`
                                -replace ' ', '+').ToLower()

                $SearchURL = "https://panda.chaika.moe/search/?title=$Title&tags=artist%3A$Artist"
        }

        # Match "FileName.ext"
        elseif ($DoujinName -match '^[a-zA-Z0-9]') {
                $Artist = ''
                $Title = (($DoujinName.Trim()) -replace ' ', '+').ToLower()
                $SearchURL = "https://panda.chaika.moe/search/?title=$Title"
        }
        $SearchPage = Invoke-WebRequest -Uri $SearchURL -Method Get
        $PageCheck = $SearchPage.Links.href | Where-Object { $_ -like '/archive/*' }
        if ($null -ne $PageCheck) {
                if ($PageCheck.Count -ge 2) {
                        $PandaChaikaID = $PageCheck[0]
                }

                else {
                        $PandaChaikaID = $PageCheck
                }

                $PandaChaikaUrl = "https://panda.chaika.moe$PandaChaikaID"
        }

        Write-Output $PandaChaikaUrl
}