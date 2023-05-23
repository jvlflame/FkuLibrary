function Get-FakkuMetadata {
    [CmdletBinding(DefaultParameterSetName = 'URL')]
    param(
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Name')]
        [String]$Name,

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'URL')]
        [String]$URL,

        [Parameter(Mandatory = $false, ParameterSetName = 'URL')]
        [System.IO.DirectoryInfo]$WebDriverPath = (Get-Item $PSScriptRoot).Parent,

        [Parameter(Mandatory = $false, ParameterSetName = 'URL')]
        [System.IO.DirectoryInfo]$UserProfile = (Join-Path -Path (Get-Item $PSScriptRoot).Parent -ChildPath "profiles"),

        [Parameter(Mandatory = $false, ParameterSetName = 'URL')]
        [Switch]$Headless,

        [Parameter(Mandatory = $false, ParameterSetName = 'URL')]
        [Switch]$Incognito
    )

    Switch ($PSCmdlet.ParameterSetName) {
        'Name' {
            try {
                $FakkuUrl = Get-FakkuUrl -Name $Name
                $WebRequest = (Invoke-WebRequest -Uri $FakkuUrl -Method Get -Verbose:$false).Content
                $Xml = Get-MetadataXml -WebRequest $WebRequest -URL $FakkuUrl
            } catch {
                Write-Warning "Work ""$Name"" not found."
                return
            }
            Write-Output $Xml
        }

        'URL' {
            try {
                if ($URL -match 'fakku') {
                    $WebRequest = (Invoke-WebRequest -Uri $URL -Method Get -Verbose:$false).Content
                    $Xml = Get-MetadataXml -WebRequest $WebRequest -URL $URL
                } else {
                    Write-Warning "URL ""$URL"" is not a valid FAKKU URL."
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
                            $ProfilePath = Join-Path -Path $UserProfile -ChildPath "Edge"
                            $DriverOptions.AddArgument("user-data-dir=$ProfilePath")
                            if ($Headless) {$DriverOptions.AddArgument("headless")}
                            if ($Incognito) {$DriverOptions.AddArgument("inprivate")}
                        }
                        'chromedriver.exe' {
                            $DriverOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
                            $DriverService = [OpenQA.Selenium.Chrome.ChromeDriverService]::CreateDefaultService($WebDriverPath)
                            $Driver = [OpenQA.Selenium.Chrome.ChromeDriver]
                            $ProfilePath = Join-Path -Path $UserProfile -ChildPath "Chrome"
                            $DriverOptions.AddArgument("user-data-dir=$ProfilePath")
                            if ($Headless) {$DriverOptions.AddArgument("headless")}
                            if ($Incognito) {$DriverOptions.AddArgument("incognito")}
                        }
                        # Untested, but I just hope it works lol.
                        'geckodriver.exe' {
                            $DriverOptions = New-Object OpenQA.Selenium.firefox.FirefoxOptions
                            $DriverService = [OpenQA.Selenium.firefox.FirefoxDriverService]::CreateDefaultService($WebDriverPath)
                            $Driver = [OpenQA.Selenium.firefox.FirefoxDriver]
                            $ProfilePath = Join-Path -Path $UserProfile -ChildPath "Firefox"
                            $DriverOptions.AddArguments("profile $ProfilePath")
                            if ($Headless) {$DriverOptions.AddArguments("headless")}
                            if ($Incognito) {$DriverOptions.AddArguments("private")}
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
                    $WebDriver.Navigate().GoToURL($URL)
                    $Xml = Get-MetadataXml -WebRequest $WebDriver.PageSource -URL $URL
                }
                catch {
                    Write-Warning "Error occurred while scraping ""$URL"": $PSItem"
                }
            }
            if ($WebDriver) {$WebDriver.Quit()}
            Write-Output $Xml
        }
    }
}
