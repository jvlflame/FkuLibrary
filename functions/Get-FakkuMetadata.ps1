function Get-FakkuMetadata {
    [CmdletBinding(DefaultParameterSetName = 'Url')]
    param (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Name')]
        [String]$DoujinName,

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Url')]
        [String]$Url,

        # Sets path to chromedriver.exe and WebDriver.dll
        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo]$WebDriverPath = "C:\Selenium",

        # To circumvent chromedriver opening a new window every time when individually setting metadata. Open Chrome and login to FAKKU beforehand with the --remote-debugging-port argument (--remote-debugging-port=5656 by default)
        [Parameter(Mandatory = $false)]
        [Switch]$Remote
    )

    Switch ($PSCmdlet.ParameterSetName) {
        'Name' {
            try {
                $fakkuUrl = Get-FakkuURL -DoujinName $DoujinName
                $fakkuData = Invoke-WebRequest $fakkuUrl -Method Get -Verbose:$false
                $xml = Get-MetadataXML -WebRequest $fakkuData -Scraper Fakku -URL $fakkuUrl
            } catch {
                try {
                    $pandaChaikaUrl = Get-PandaChaikaURL -DoujinName $DoujinName
                    $pandaChaikaData = Invoke-WebRequest $pandaChaikaUrl -Method Get -Verbose:$false
                    $xml = Get-MetadataXML -Webrequest $pandaChaikaData -Scraper PandaChaika
                } catch {
                    Write-Warning "Doujin $DoujinName not found..."
                    return
                }
            }

            Write-Output $xml
        }

        'Url' {
            try {
                if ($Url -match 'fakku') {
                    $fakkuData = Invoke-WebRequest $Url -Method Get -Verbose:$false
                    $xml = Get-MetadataXML -WebRequest $fakkuData -Scraper Fakku -URL $Url
                } elseif ($Url -match 'panda.chaika') {
                    $pandaChaikaData = Invoke-WebRequest $Url -Method Get -Verbose:$false
                    $xml = Get-MetadataXML -Webrequest $pandaChaikaData -Scraper PandaChaika
                } else {
                    Write-Warning "Url $Url is not a valid fakku or panda.chaika url"
                }
            } catch {
                try {      
                        # Test for and adds web driver directory to PATH
                        if (Test-Path -Path $WebDriverPath) {
                                if (($env:Path -split ';') -notcontains $WebDriverPath) {
                                        $env:Path += ";$WebDriverPath"
                                }
                            
                                if (-Not (Test-Path -Path (Join-Path -Path $WebDriverPath -ChildPath "chromedriver.exe"))) {
                                        Write-Warning "chromedriver.exe does not exist. Download the version matching your browser version and extract to your web driver path - https://chromedriver.chromium.org/downloads"
                                }
                            
                                if (-Not (Test-Path -Path (Join-Path -Path $WebDriverPath -ChildPath "WebDriver.dll"))) {
                                        Write-Warning "WebDriver.dll does not exist. Download and extract WebDriver.dll from inside \selenium-dotnet-3.14.0.zip\dist\Selenium.WebDriver.3.14.0.nupkg\lib\net45\ to your web driver path - https://goo.gl/uJJ5Sc"
                                }
                        
                        } else {
                                Write-Warning "Web driver directory does not exist. Please set it using -WebDriverPath (C:\Selenium by default)"
                        }

                        # Opens a new window if it doesn't detect one open.
                        if ([string]::IsNullOrEmpty($ChromeDriver.WindowHandles)) {
                        $DllPath = Join-Path -Path $WebDriverPath -ChildPath "WebDriver.dll"
                                Write-Host "Starting browser..."
                                Import-Module $DllPath
                                $Service = [OpenQA.Selenium.Chrome.ChromeDriverService]::CreateDefaultService($WebDriverPath)
                                $Service.SuppressInitialDiagnosticInformation = $true
                                $Service.HideCommandPromptWindow = $true
                                if ($Remote) {
                                        $ChromeOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
                                        $ChromeOptions.debuggerAddress = "127.0.0.1:5656"
                                        $ChromeDriver = [OpenQA.Selenium.Chrome.ChromeDriver]::new($Service, $ChromeOptions)
                                } else {
                                        $ChromeDriver = [OpenQA.Selenium.Chrome.ChromeDriver]::new($Service)
                                        $ChromeDriver.Navigate().GoToURL("https://fakku.net/login")
                                        Write-Host -NoNewLine 'Please log into FAKKU then press any key to continue...'
                                        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                                }  
                        }
                        $ChromeDriver.Navigate().GoToURL($Url)
                        $xml = Get-MetadataXML -WebRequest $ChromeDriver.PageSource -Scraper Fakku -URL $Url
                } 
                catch {
                    Write-Warning "Error occurred while scraping $Url : $PSItem"
                }
            }

            Write-Output $xml

            if ($ChromeDriver) {
                $ChromeDriver.Quit()
            }
        }
    }
}
