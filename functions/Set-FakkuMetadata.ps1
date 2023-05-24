function Set-FakkuMetadata {
    [CmdletBinding(DefaultParameterSetName = 'File')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'File')]
        [System.IO.FileInfo]$FilePath,

        [Parameter(Mandatory = $false, ParameterSetName = 'File')]
        [Switch]$Recurse,

        [Parameter(Mandatory = $false, ParameterSetName = 'File')]
        [String]$Url,

        [Parameter(Mandatory = $false)]
        [Int32]$Sleep,

        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo]$UrlFile,

        [Parameter(Mandatory = $true, ParameterSetName = 'Batch')]
        [System.IO.FileInfo]$InputFile,

        [Parameter(Mandatory = $false)]
        [System.IO.DirectoryInfo]$WebDriverPath = (Get-Item $PSScriptRoot).Parent,

        [Parameter(Mandatory = $false)]
        [System.IO.DirectoryInfo]$UserProfile = (Join-Path -Path (Get-Item $PSScriptRoot).Parent -ChildPath "profiles"),

        [Parameter(Mandatory = $false, ParameterSetName = 'URL')]
        [Switch]$Headless,

        [Parameter(Mandatory = $false)]
        [Switch]$Incognito,

        [Parameter(Mandatory = $false)]
        [Switch]$Log,

        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo]$LogPath = (Get-Item $PSScriptRoot).Parent
    )

    function Write-FakkuLog {
        param(
            [Switch]$Log,
            [System.IO.FileInfo]$LogPath,
            [String]$Source
        )

        if ($Log) {
            [PSCustomObject]@{
                FilePath = $FilePath
                Url      = $FakkuUrl
                Source   = $Source
            } | Export-Csv -Path $LogPath -Append
        }
}

    $ProgressPreference = 'SilentlyContinue'

    Switch ($PSCmdlet.ParameterSetName) {
        'File' {
            # Check if FilePath is a directory or file to determine how to proceed
            if ((Get-Item -LiteralPath $FilePath) -is [System.IO.DirectoryInfo]) {
                $Archive = Get-LocalArchives -FilePath $FilePath -Recurse:$Recurse
            } else {
                $Archive = Get-Item $FilePath
            }

            if ($PSBoundParameters.ContainsKey('Url')) {
                if (Test-Path -Path $FilePath -PathType Container) {
                    Write-Warning "URL parameter can only be used with an archive, not a directory."
                    return
                } elseif (-Not $Url -match 'fakku') {
                    Write-Warning "URL ""$Url"" is not a valid FAKKU URL."
                    return
                }
            }
        }

        'Batch' {
            $Archive = Get-Content -Path $InputFile |
                Where-Object { Test-Path -Path $_.trim().trim('"') } |
                ForEach-Object { Get-Item -Path $_.trim().trim('"') }
        }
    }

    if ($PSBoundParameters.ContainsKey('UrlFile')) {
        if ($Url) {
            Write-Warning "URL parameter is not compatible with batch tagging."
            return
        }
        $Links = Get-Content -Path $UrlFile | Where-Object { $_.trim() -match "fakku" }
        if ($Links.Count -ne $Archive.Count) {
            Write-Warning "File count does not equal URL count."
            return
        }
    }


    $Index = 1
    $TotalIndex = $Archive.Count
    foreach ($File in $Archive) {
        $WorkName = $File.BaseName
        $XmlPath = Join-Path -Path $File.DirectoryName -ChildPath 'ComicInfo.xml'
        # Clear-Variable -Name Xml, FakkuUrl

        Write-Debug "$XmlPath"
        Write-Host "[$Index of $TotalIndex] Setting metadata for ""$WorkName"""
        Start-Sleep -Seconds $Sleep

        if ($Links) {
            $FakkuUrl = $Links[$Index - 1] # Maybe not best practice
        } else {
            $FakkuUrl = $Url
        }

        try {
            if (!$FakkuUrl) {$FakkuUrl = Get-FakkuUrl -Name $WorkName}
            $WebRequest = (Invoke-WebRequest -Uri $FakkuUrl -Method Get -Verbose:$false).Content
            $Xml = Get-MetadataXML -WebRequest $WebRequest -Url $FakkuUrl
            Set-MetadataXML -FilePath $File.FullName -XmlPath $XmlPath -Content $Xml

            Write-FakkuLog -Log:$Log -LogPath $LogPath -Source "FAKKU"
            Write-Verbose "Set $FilePath with $FakkuUrl."
            Write-Debug "Set $File using FAKKU."
        }

        # WebDriver fallback
        catch {
            try {
                # TO-DO refactor WebDriver initialization into an internal function
                Write-Debug "Starting WebDriver."

                try {
                    Add-Type -Path (Get-Item (Join-Path -Path $WebDriverPath -ChildPath 'webdriver.dll'))
                    $WebDriverExe = Get-Item (Join-Path -Path $WebDriverPath -ChildPath '*driver.exe') |
                        Select-Object -First 1
                } catch {
                    Write-Warning "Can't find WebDriver.dll or executable."
                    return
                }

                Switch ($WebDriverExe.Name) {
                    'msedgedriver.exe' {
                        $DriverOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions
                        $DriverService = [OpenQA.Selenium.Edge.EdgeDriverService]::CreateDefaultService($WebDriverPath)
                        $Driver = [OpenQA.Selenium.Edge.EdgeDriver]
                        $ProfilePath = Join-Path -Path $UserProfile -ChildPath "Edge"
                        $DriverOptions.AddArgument("user-data-dir=$ProfilePath")
                        if ($Incognito) {$DriverOptions.AddArgument("inprivate")}
                    }
                    'chromedriver.exe' {
                        $DriverOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
                        $DriverService = [OpenQA.Selenium.Chrome.ChromeDriverService]::CreateDefaultService($WebDriverPath)
                        $Driver = [OpenQA.Selenium.Chrome.ChromeDriver]
                        $ProfilePath = Join-Path -Path $UserProfile -ChildPath "Chrome"
                        $DriverOptions.AddArgument("user-data-dir=$ProfilePath")
                        if ($Incognito) {$DriverOptions.AddArgument("incognito")}
                    }
                    # Untested, but I just hope it works lol.
                    'geckodriver.exe' {
                        $DriverOptions = New-Object OpenQA.Selenium.firefox.FirefoxOptions
                        $DriverService = [OpenQA.Selenium.firefox.FirefoxDriverService]::CreateDefaultService($WebDriverPath)
                        $Driver = [OpenQA.Selenium.firefox.FirefoxDriver]
                        if ($UserProfile) {$DriverOptions.AddArgument("P $UserProfile")}
                        $ProfilePath = Join-Path -Path $UserProfile -ChildPath "Firefox"
                        $DriverOptions.AddArgument("profile $ProfilePath")
                        if ($Incognito) {$DriverOptions.AddArgument("private")}
                    }
                    Default {
                        Write-Warning "Couldn't find compatible WebDriver executable."
                        return
                    }
                }

                $DriverService.SuppressInitialDiagnosticInformation = $true
                $DriverService.HideCommandPromptWindow = $true
                # Initialize new WebDriver if can't find one
                if (-Not $WebDriver.WindowHandles) {
                    $WebDriver = New-Object $Driver -ArgumentList @($DriverService, $DriverOptions)
                    if (-Not $Headless) {
                        $WebDriver.Navigate().GoToURL("https://fakku.net/login")
                        Write-Host "Please log into FAKKU then press any key to continue..."
                        [Void]$Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                    }
                }
                $WebDriver.Navigate().GoToURL($FakkuUrl)
                $Xml = Get-MetadataXML -WebRequest $WebDriver.PageSource -Url $FakkuUrl
                Set-MetadataXML -FilePath $File.FullName -XmlPath $XmlPath -Content $Xml

                Write-FakkuLog -Log:$Log -LogPath $LogPath -Source "FAKKU"
                Write-Verbose "Set $FilePath with $FakkuUrl."
                Write-Debug "Set $File using FAKKU."
            }

            # Panda fallback
            catch {
                try {
                    Write-Debug "Falling back on Panda."

                    $PandaUrl = Get-PandaURL -Name $WorkName
                    $WebRequest = Invoke-WebRequest -Uri $PandaUrl -Method Get -Verbose:$false
                    $Xml = Get-MetadataXML -WebRequest $WebRequest.Content -Url $PandaUrl
                    Set-MetadataXML -FilePath $File.FullName -XmlPath $XmlPath -Content $Xml

                    Write-FakkuLog -Log:$Log -LogPath $LogPath -Source "Panda"
                    Write-Verbose "Set $FilePath with $PandaUrl"
                    Write-Debug "Set $FilePath using Panda."
                } catch {
                    Write-Warning "Error occurred while scraping $FakkuUrl : $PSItem"
                }
            }
        }
        $Index++
    }
    if ($WebDriver) {$WebDriver.Quit()}
    Write-Host "Complete."
}
