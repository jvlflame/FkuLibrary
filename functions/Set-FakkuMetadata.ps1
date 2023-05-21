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
        [System.IO.FileInfo]$WebDriverPath = (Get-Item $PSScriptRoot).Parent,

        [Parameter(Mandatory = $false)]
        [Switch]$Persist,

        # Ensure the profile isn't currently in use or this option will not work.
        [Parameter(Mandatory = $false)]
        [Switch]$UserProfile,

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

    if (Test-Path -Path $FilePath -PathType Container) {
        if ($Url) {
            Write-Warning "URL parameter can only be used with a direct file path, not a directory."
            return
        }
    }

    if ($PSBoundParameters.ContainsKey('URL')) {
        if (-Not $URL -match 'fakku') {
            Write-Warning "URL $URL is not a valid FAKKU URL."
            return
        }
    }

    $Index = 1
    $TotalIndex = $Archive.Count
    foreach ($File in $Archive) {
        $ComicName = $File.BaseName
        $XMLPath = Join-Path -Path $File.DirectoryName -ChildPath 'ComicInfo.xml'

        Write-Debug "$XMLPath"
        Write-Host "[$Index of $TotalIndex] Setting metadata for $ComicName"

        try {
            if (!$URL) {$URL = Get-FakkuURL -ComicName $File.BaseName}
            $WebRequest = (Invoke-WebRequest -Uri $URL -Method Get -Verbose:$false).Content
            $XML = Get-MetadataXML -WebRequest $WebRequest.Content -URL $URL
            Set-MetadataXML -FilePath $File.FullName -XMLPath $XMLPath -Content $XML
            Write-Verbose "Set $FilePath with $URL."
        }

        # Fallback and use WebDriver
        catch {
            try {
                if (!$URL) {$URL = Get-FakkuURL -ComicName $File.BaseName}
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
                        if ($UserProfile) {
                            $DriverOptions.AddArgument("user-data-dir=$env:LOCALAPPDATA\Microsoft\Edge\User Data")
                            $DriverOptions.AddArgument("profile-directory=$UserProfile")
                        }
                        if ($Incognito) {$DriverOptions.AddArgument("inprivate")}
                    }
                    'chromedriver.exe' {
                        $DriverOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
                        $DriverService = [OpenQA.Selenium.Chrome.ChromeDriverService]::CreateDefaultService($WebDriverPath)
                        $Driver = [OpenQA.Selenium.Chrome.ChromeDriver]
                        if ($UserProfile) {
                            $DriverOptions.AddArgument("user-data-dir=$env:LOCALAPPDATA\Google\Chrome\User Data")
                            $DriverOptions.AddArgument("profile-directory=$UserProfile")
                        }
                        if ($Incognito) {$DriverOptions.AddArgument("incognito")}
                    }
                    'geckodriver.exe' {
                        $DriverOptions = New-Object OpenQA.Selenium.firefox.FirefoxOptions
                        $DriverService = [OpenQA.Selenium.firefox.FirefoxDriverService]::CreateDefaultService($WebDriverPath)
                        $Driver = [OpenQA.Selenium.firefox.FirefoxDriver]
                        if ($UserProfile) {$DriverOptions.AddArgument("P $UserProfile")}
                        if ($Incognito) {$DriverOptions.AddArgument("private")}
                    }
                    Default {
                        Write-Warning "Couldn't find compatible WebDriver executable."
                        return
                    }
                }
                $Service.SuppressInitialDiagnosticInformation = $true
                $Service.HideCommandPromptWindow = $true
                if ([string]::IsNullOrEmpty($WebDriver.WindowHandles)) {
                    $WebDriver = New-Object $Driver -ArgumentList @($DriverService, $DriverOptions)
                }
                Write-Host "Please log into FAKKU then press any key to continue..."
                [Void]$Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                $WebDriver.Navigate().GoToURL("https://fakku.net/login")
                $WebDriver.Navigate().GoToURL($URL)
                $XML = Get-MetadataXML -WebRequest $WebDriver.PageSource -URL $URL
                if (-Not $Persist) {$WebDriver.Quit()}
                Set-MetadataXML -FilePath $File.FullName -XMLPath $XMLPath -Content $XML
                Write-Verbose "Set $FilePath with $URL."
            } catch {
                Write-Warning "Error occurred while scraping $URL : $PSItem"
            }
        }
        $Index++
    }
    Write-Host "Complete."
}
