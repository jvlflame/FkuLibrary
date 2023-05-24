# Not updated- Just fixed formatting.

function Get-PandaUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Name
    )

    $ProgressPreference = 'SilentlyContinue'
    # $Name = $Name -replace '\p{S} ', 'bzb'

    # Match "[Artist] FileName (Comic XXX).ext"
    if ($Name -match '^\[(.*?)\](.*?)\((.*?)\)') {
        $Artist = ((($Name -split '\[(.*)\]')[1]) -replace ' ', '_').ToLower()
        $Title = ((((((($Name -split '\[(.*)\]')[2])`
            -split '\(')[0]).Trim())`
            -replace '#', '%23')`
            -replace ' ', '+').ToLower()

        $SearchURL = "https://panda.chaika.moe/search/?title=$Title&tags=artist%3A$Artist"
    }

    # Match "[Artist] FileName.ext"
    elseif ($Name -match '^\[(.*?)\]') {
        $Artist = ((($Name -split '\[(.*)\]')[1]) -replace ' ', '_').ToLower()
        $Title = ((((($Name -split '\[(.*)\]')[2]).Trim())`
            -replace '#', '%23')`
            -replace ' ', '+').ToLower()

        $SearchURL = "https://panda.chaika.moe/search/?title=$Title&tags=artist%3A$Artist"
    }

    # Match "FileName.ext"
    elseif ($Name -match '^[a-zA-Z0-9]') {
        $Artist = ''
        $Title = ((($Name.Trim()) -replace "#", '%23') -replace ' ', '+').ToLower()
        $SearchURL = "https://panda.chaika.moe/search/?title=$Title"
    }

    $SearchPage = Invoke-WebRequest -Uri $SearchURL -Method Get -Verbose:$false
    $PageCheck = $SearchPage.Links.href | Where-Object { $_ -like '/archive/*' }
    if ($null -ne $PageCheck) {
        if ($PageCheck.Count -gt 1) {
                $Results = @()
                $PageCheck | Select-Object -First 3 | ForEach-Object {
                    $WebRequest = Invoke-WebRequest -Uri "https://panda.chaika.moe$_" -Verbose:$false
                    $Results += [PSCustomObject]@{
                        PandaChaikaID = $_
                        Publisher     = Get-PandaPublisher -Webrequest $WebRequest
                    }
                }

                $MatchedFakku = $Results | Where-Object { $_.Publisher -eq 'fakku' }
                if ($MatchedFakku) {
                    if ($MatchedFakku.Count -gt 1) {
                        $PandaChaikaID = $MatchedFakku[0].PandaChaikaID
                    } else {
                        $PandaChaikaID = $MatchedFakku.PandaChaikaID
                    }
                } else {
                        $PandaChaikaID = $Results[0].PandaChaikaID
                }
            }

        else {
            $PandaChaikaID = $PageCheck
        }
        $PandaChaikaUrl = "https://panda.chaika.moe$PandaChaikaID"
    }
    Write-Output $PandaChaikaUrl
}
