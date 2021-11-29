function Set-FakkuMetadata {
        [CmdletBinding(DefaultParametersetName="Set 1")]
        param(
                [Parameter(ParameterSetName="Set 1", Mandatory = $true, Position = 1)]
                [System.IO.FileInfo]$FilePath,

                [Parameter(ParameterSetName="Set 1", Mandatory = $false)]
                [String]$Url,

                [Parameter(ParameterSetName="Set 1", Mandatory = $false)]
                [Switch]$Recurse,

                [Parameter(Mandatory = $false)]
                [Switch]$Log,

                # Checks for a text file line by line for archive paths
                # Optionally checks for a URL proceeding a ">" to use (e.g. "C:\path\to\file\file.cbz>https://www.fakku.net/hentai/hentai-name")
                # Useful for rescraping metadata with previously found URLs or mass scraping
                [Parameter(ParameterSetName="Set 2", Mandatory = $true, Position = 1)]
                [System.IO.FileInfo]$InputFile,

                [Parameter(Mandatory = $false)]
                [System.IO.FileInfo]$LogPath = ".\fkulibrary.log",

                # Sets path to chromedriver.exe and WebDriver.dll
                [Parameter(Mandatory = $false)]
                [System.IO.FileInfo]$WebDriverPath = "C:\Selenium",

                # To circumvent chromedriver opening a new window every time when individually setting metadata. Open Chrome and login to FAKKU beforehand with the --remote-debugging-port argument (--remote-debugging-port=5656 by default)
                [Parameter(Mandatory = $false)]
                [Switch]$Remote
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

        # Check if FilePath is a directory or file to determine how to proceed
        if ($FilePath) {
                Write-Host "Starting Fakku metadata scraper on path: $FilePath"

                if ((Get-Item -Path $FilePath) -is [System.IO.DirectoryInfo]) {
                        $Archive = Get-LocalArchives -FilePath $FilePath -Recurse:$Recurse
                } else {
                        $Archive = Get-Item $FilePath
                }

                if (Test-Path -Path $FilePath -PathType Container) {
                        if ($Url) {
                                Write-Warning "Url parameter can only be used with a direct file path, not a directory..."
                                return
                        }
                }
        }

        if ($InputFile) {
                # Default separator for InputFile is ">"
                $Separator = ">"
                if ([System.IO.Path]::GetExtension($InputFile) -eq ".txt") {
                        $Archive = Get-Content $InputFile      
                } else {
                        Write-Warning "The input file is not a text file"
                        return
                }
        }

        if ($PSBoundParameters.ContainsKey('Url')) {
                if ($Url -match 'fakku') {
                        $UriLocation = 'fakku'
                } elseif ($Url -match 'panda.chaika') {
                        $UriLocation = 'panda.chaika'
                } else {
                        Write-Warning "Url $Url is not a valid fakku or panda.chaika url"
                        return
                }
                Write-Debug "UriLocation: $UriLocation"
        }

        $Index = 1
        $TotalIndex = $Archive.Count
        foreach ($File in $Archive) {
                if ($UriLocation) {
                        if ($UriLocation -eq 'fakku') {
                                $FakkuUrl = $Url
                        }
                        if ($UriLocation -eq 'panda.chaika') {
                                $PandaChaikaUrl = $Url
                        }
                }

                # Ideally would restructure to not be in main loop sorry. Also kinda bad tbh lol
                if ($InputFile) {
                        if ($File -match "(?<ArchivePath>.+(?=$Separator))$Separator(?<ArchiveURL>https[^$Separator]+)$") {
                                if (Test-Path -Path $Matches.ArchivePath -PathType Leaf) {
                                        $File = Get-Item $Matches.ArchivePath
                                        $Url = $Matches.ArchiveURL
                                        if ($Url -match 'fakku') {
                                                $UriLocation = 'fakku'
                                                $FakkuUrl = $Url
                                        } elseif ($Url -match 'panda.chaika') {
                                                $UriLocation = 'panda.chaika'
                                                $PandaChaikaUrl = $Url
                                        } else {
                                                Write-Warning "Url $Url is not a valid fakku or panda.chaika url"
                                                return
                                        }
                                } else {
                                        Write-Warning "$File is not a valid path"
                                        return
                                }
                                
                        } else {
                                if (Test-Path -Path $File -PathType Leaf){
                                        $File = Get-Item $File
                                } else {
                                        Write-Warning "$File is not a valid path"
                                        return
                                }
                        }
                }

                Write-Debug "FakkuUrl: $FakkuUrl"
                Write-Debug "PandaChaikaUrl: $PandaChaikaUrl"

                $DoujinName = $File.BaseName
                $XMLPath = Join-Path -Path $File.DirectoryName -ChildPath 'ComicInfo.xml'
		Write-Debug "$XMLPath"
                Write-Host "($Index of $TotalIndex) Setting metadata for $DoujinName"

                try {
                        if (!$UriLocation) {
                                $FakkuUrl = Get-FakkuURL -DoujinName $File.BaseName
                        }
                        $WebRequest = Invoke-WebRequest -Uri $FakkuUrl -Method Get -Verbose:$false
                        $xml = $null
                        $xml = Get-MetadataXML -WebRequest $WebRequest.Content -Scraper Fakku -URL $FakkuUrl
                        Set-MetadataXML -FilePath $File.FullName -XMLPath $XMLPath -Content $xml
                        Write-FakkuLog -Log:$Log -LogPath $LogPath -Source "Fakku"
                        Write-Verbose "Set $FilePath with $FakkuUrl"
                        Write-Debug "Set $File using Fakku"
                }

                # Try to get credentials before falling back on panda.chaika.moe
                catch {
                        try {
                                if (!$UriLocation) {
                                        Write-Warning "Attempting to use browser..."
                                        $FakkuUrl = Get-FakkuURL -DoujinName $File.BaseName
                                }
                                
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
                                $ChromeDriver.Navigate().GoToURL($FakkuUrl)
                                $xml = $null
                                $xml = Get-MetadataXML -WebRequest $ChromeDriver.PageSource -Scraper Fakku -URL $FakkuUrl
                                Set-MetadataXML -FilePath $File.FullName -XMLPath $XMLPath -Content $xml
                                Write-FakkuLog -Log:$Log -LogPath $LogPath -Source "Fakku"
                                Write-Verbose "Set $FilePath with $FakkuUrl"
                                Write-Debug "Set $File using Fakku"
                        }

                        # If the Fakku URL returns an error, fallback to panda.chaika.moe
                        catch{
                                try {
                                        if (!$UriLocation) {
                                                Write-Warning "$DoujinName not found on Fakku..."
                                                $PandaChaikaUrl = Get-PandaChaikaURL -DoujinName $File.BaseName
                                        }
					
                                        $WebRequest = Invoke-WebRequest -Uri $PandaChaikaUrl -Method Get -Verbose:$false
                                        $xml = $null
                                        $xml = Get-MetadataXML -WebRequest $WebRequest.Content -Scraper PandaChaika -URL $PandaChaikaUrl
                                        Set-MetadataXML -FilePath $File.FullName -XMLPath $XMLPath -Content $xml
                                        Write-FakkuLog -Log:$Log -LogPath $LogPath -Source "PandaChaikaMoe"
                                        Write-Verbose "Set $FilePath with $PandaChaikaUrl"
                                        Write-Debug "Set $FilePath using Panda.Chaika.Moe"
                                }
        
                                catch {
                                        Write-Warning "$DoujinName not found on panda.chaika..."
                                        #Write-Error | Out-File -FilePath (Join-Path -Path ../$PSScriptRoot -ChildPath 'log.txt') -NoClobber -Append
                                }
                                
                        }
                }

                $Index++
                # Start-Sleep -Seconds 1
        } 
        if ($ChromeDriver) {
                $ChromeDriver.Quit()
        }
        Write-Host "Complete!"
}
