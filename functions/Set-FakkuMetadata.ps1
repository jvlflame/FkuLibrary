function Set-FakkuMetadata {
    [CmdletBinding(DefaultParameterSetName = 'File')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'File')]
        [System.IO.FileInfo]$FilePath,

        [Parameter(Mandatory = $false, ParameterSetName = 'File')]
        [Switch]$Recurse,

        [Parameter(Mandatory = $false, ParameterSetName = 'File')]
        [String]$URL,

        [Parameter(Mandatory = $false)]
        [Int32]$Sleep,

        [Parameter(Mandatory = $false)]
        [System.IO.DirectoryInfo]$WebDriverPath = (Get-Item $PSScriptRoot).Parent,

        [Parameter(Mandatory = $false, ParameterSetName = 'URL')]
        [System.IO.DirectoryInfo]$UserProfile = (Join-Path -Path (Get-Item $PSScriptRoot).Parent -ChildPath "profiles"),

        [Parameter(Mandatory = $false)]
        [Switch]$Incognito
    )

    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Starting Fakku metadata scraper on path: $FilePath"

    # Check if FilePath is a directory or file to determine how to proceed
    if ((Get-Item -LiteralPath $FilePath) -is [System.IO.DirectoryInfo]) {
        $Archive = Get-LocalArchives -FilePath $FilePath -Recurse:$Recurse
    } else {
        $Archive = Get-Item $FilePath
    }

    if ($PSBoundParameters.ContainsKey('URL')) {
        if (Test-Path -Path $FilePath -PathType Container) {
            Write-Warning "URL parameter can only be used with an archive, not a directory."
            return
        } elseif (-Not $URL -match 'fakku') {
            Write-Warning "URL ""$URL"" is not a valid FAKKU URL."
            return
        }
    }

    $Index = 1
    $TotalIndex = $Archive.Count
    foreach ($File in $Archive) {
        $Name = $File.BaseName
        $XMLPath = Join-Path -Path $File.DirectoryName -ChildPath 'ComicInfo.xml'

        Write-Debug "$XMLPath"
        Write-Host "[$Index of $TotalIndex] Setting metadata for ""$Name"""

        Start-Sleep -Seconds $Sleep

        try {
            if (!$URL) {$FakkuURL = Get-FakkuURL -Name $File.BaseName}
            $WebRequest = (Invoke-WebRequest -Uri $FakkuURL -Method Get -Verbose:$false).Content
            $XML = Get-MetadataXML -WebRequest $WebRequest -URL $FakkuURL
            Set-MetadataXML -FilePath $File.FullName -XMLPath $XMLPath -Content $XML
            Write-Verbose "Set $FilePath with $FakkuURL."
        }

        # Fallback and use WebDriver
        catch {
            try {
                Write-Host "Attempting to use browser..."

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
                    $WebDriver.Navigate().GoToURL("https://fakku.net/login")
                    Write-Host "Please log into FAKKU then press any key to continue..."
                    [Void]$Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                }
                if (!$URL) {$FakkuURL = Get-FakkuURL -Name $File.BaseName}
                $WebDriver.Navigate().GoToURL($FakkuURL)
                $XML = Get-MetadataXML -WebRequest $WebDriver.PageSource -URL $FakkuURL
                Set-MetadataXML -FilePath $File.FullName -XMLPath $XMLPath -Content $XML
                Write-Verbose "Set $FilePath with $FakkuURL."
            } catch {
                Write-Warning "Error occurred while scraping $FakkuURL : $PSItem"
            }
        }
        $Index++
    }
    if ($WebDriver) {$WebDriver.Quit()}
    Write-Host "Complete."
}
