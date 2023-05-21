function Get-FakkuMetadata {
    [CmdletBinding(DefaultParameterSetName = 'URL')]
    param(
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Name')]
        [String]$ComicName,

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'URL')]
        [String]$URL,

        [Parameter(Mandatory = $false, ParameterSetName = 'URL')]
        [System.IO.DirectoryInfo]$WebDriverPath = (Get-Item $PSScriptRoot).Parent,

        [Parameter(Mandatory = $false, ParameterSetName = 'URL')]
        [Switch]$Persist,

        # Ensure the profile isn't currently in use or this option will not work.
        [Parameter(Mandatory = $false, ParameterSetName = 'URL')]
        [Switch]$UserProfile,

        [Parameter(Mandatory = $false, ParameterSetName = 'URL')]
        [Switch]$Incognito
    )

    Switch ($PSCmdlet.ParameterSetName) {
        'Name' {
            try {
                $FakkuURL = Get-FakkuURL -ComicName $ComicName
                $FakkuData = (Invoke-WebRequest -Uri $FakkuURL -Method Get -Verbose:$false).Content
                $XML = Get-MetadataXML -WebRequest $FakkuData -URL $FakkuURL
            } catch {
                Write-Warning "Comic $ComicName not found."
                return
            }
            Write-Output $XML
        }

        'URL' {
            try {
                if ($URL -match 'fakku') {
                    $FakkuData = (Invoke-WebRequest -Uri $URL -Method Get -Verbose:$false).Content
                    $XML = Get-MetadataXML -WebRequest $FakkuData -URL $URL
                } else {
                    Write-Warning "URL $URL is not a valid FAKKU URL."
                }
            } catch {
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

                    # Initialize new WebDriver if can't find one
                    if ([string]::IsNullOrEmpty($WebDriver.WindowHandles)) {
                        $WebDriver = New-Object $Driver -ArgumentList @($DriverService, $DriverOptions)
                    }
                    $WebDriver.Navigate().GoToURL("https://fakku.net/login")
                    Write-Host "Please log into FAKKU then press any key to continue..."
                    [Void]$Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
                    $WebDriver.Navigate().GoToURL($URL)
                    $XML = Get-MetadataXML -WebRequest $WebDriver.PageSource -URL $URL
                    if (-Not $Persist) {$WebDriver.Quit()}
                }
                catch {
                    Write-Warning "Error occurred while scraping $URL : $PSItem"
                }
            }
            Write-Output $XML
        }
    }
}
