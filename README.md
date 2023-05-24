# FAKKU Library

Scrape metadata from FAKKU.net and build your own local FAKKU manga library with Komga or any other CMS that supports `ComicInfo.xml` metadata.

<details>

 <summary>Example results</summary>

 ```xml
<?xml version="1.0"?>
<ComicInfo xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Title>Bare Girl</Title>
  <AlternateSeries>Original Work</AlternateSeries>
  <Summary>Don't stare at me… you make me wanna strip…</Summary>
  <Year>2017</Year>
  <Month>03</Month>
  <Writer>Tsukako</Writer>
  <Publisher>FAKKU</Publisher>
  <Tags>Blowjob, Booty, Busty, Cosplay, Creampie, Hentai, Lingerie, Slice of Life, Stockings, Uncensored, Vanilla</Tags>
  <Web>https://www.fakku.net/hentai/bare-girl-english</Web>
  <LanguageISO>en</LanguageISO>
  <Manga>Yes</Manga>
  <SeriesGroup>Comic Kairakuten BEAST 2017-03</SeriesGroup>
  <AgeRating>Adults Only 18+</AgeRating>
</ComicInfo>
 ```
![Image of the manga "Bare Girl" in Komga tagged with this tool.](/docs/images/komga.jpeg)

</details>

            [Getting Started](#getting-started) | [Setup](#setup) | [Usage](#usage) | [Examples](#examples) | [Parameter Descriptions](#parameter-descriptions)

<br/><br/>

## Getting Started

#### Prerequisites

- [PowerShell 5.0 or higher (6.0+ recommended)](https://aka.ms/powershell-release?tag=stable)
- Komga or any other CMS that supports `ComicInfo.xml` metadata

#### Accepted archive filenames examples

- `[Artist] Title (Comic XXX).ext`
- `Title (Comic XXX).ext`
- `Title.ext`

#### Supported filetypes
- `.zip`
- `.cbz`
- `.rar`
- `.cbr`
- `.7z`
- `.cb7.`

<br/><br/>

## Setup

#### Clone the repository

- [Clone the repository](https://github.com/shrublet/fakku-meta-scraper/archive/refs/heads/main.zip) and extract the files to a directory of your choice.

#### Setup Selenium WebDriver (optional)

- It's highly recommneded to setup and download Selenium as well to access publicly blocked pages. Download the WebDriver for your browser and the Selenium for C# package (linked below). Extract the WebDriver executable (for Google Chrome, this would be `chromedriver.exe`) and `WebDriver.dll` from the raw `.nupkg` package to either the root of your extracted repository (i.e. `.\fakku-meta-scraper-main`) or a directory of your choice.

  - > <sub> ⚠️ The `WebDriver.dll` is packaged inside `.nupkg` file under `.\lib\net48\` and can be opened via any file archiver. Most Windows PCs should have .NET 4.8, so this is the recommended library. If the WebDriver isn't working as expected, ensure the version matches with your browser or try updating your browser/downgrading the WebDriver.</sub>

  - [Browser WebDriver executables](https://www.selenium.dev/documentation/webdriver/getting_started/install_drivers/#quick-reference) [^1]

  - [Selenium WebDriver for C#](https://www.nuget.org/packages/Selenium.WebDriver)

[^1]: Currently only supports Google Chrome, Microsoft Edge, and Firefox.

#### Import the module

- You will need to do this every time you close your PowerShell window unless you add the module to your PowerShell module PATH. Ensure that your PowerShell window is opened in the correct directory.

```sh
cd "C:\path\to\extracted\repository"
```

```sh
Import-Module .\Fakku-Library.psm1
```

<br/><br/>

## Usage

#### Set metadata for archive(s)

```sh
Set-FakkuMetadata
```

###### Available parameters

[`-FilePath`](#-filepath-positional)
[`-Recurse`](#-recurse)
[`-Url`](#-url)
[`-UrlFile`](#-urlfile)
[`InputFile`](#-inputfile)
[`-Sleep`](#-sleep)
[`-WebDriverPath`](#-webdriverpath)
[`-UserProfile`](#-userprofile)
[`-Headless`](#-headless)
[`-Incognito`](#-incognito)
[`-Log`](#-log)
[`-LogPath`](#-logpath)

#### Retrieve and write metadata to the console

```sh
Get-FakkuMetadata
```

###### Available parameters

[`-Name`](#-name-positional)
[`-Url`](#-url)
[`-WebDriverPath`](#-webdriverpath)
[`-UserProfile`](#-userprofile)
[`-Headless`](#-headless)
[`-Incognito`](#-incognito)

#### Return corresponding FAKKU links for archive(s)

```sh
Get-FakkuLinks
```

###### Available parameters

[`-FilePath`](#-filepath-positional)
[`-Name`](#-name-positional)
[`-Recurse`](#-recurse)

<br/><br/>

## Examples

#### Set metadata for an archive

```sh
Set-FakkuMetadata -FilePath "C:\path\to\file.zip"
```

#### Set metadata for archives in specified directory

```sh
Set-FakkuMetadata -FilePath "C:\path\to\files"
```

#### Set metadata for an archive from a FAKKU link

```sh
Set-FakkuMetadata "C:\path\to\file.zip" -Url "https://www.fakku.net/hentai/Bare-Girl-english"
```

#### Set metadata for a list of archives

```sh
Set-FakkuMetadata -InputFile "C:\path\to\list\of\archives.txt"
```

#### Set metadata for archives in specified directory with a list of URLs

```sh
Set-FakkuMetadata "C:\path\to\files" -UrlFile "C:\path\to\list\of\urls.txt"
```

#### Get metadata from a FAKKU link

```sh
Get-FakkuMetadata https://www.fakku.net/hentai/Bare-Girl-english
```

#### Get metadata from a title

```sh
Get-FakkuMetadata "Bare Girl"
```


<br/><br/>

## Parameter Descriptions

- ##### `-FilePath` (positional)
> <sub>Archive or directory or archives to set metadata for</sub>

- ##### `-Name` (positional)
> <sub>Work title to search FAKKU for</sub>

- ##### `-Recurse`
> <sub>If it should recursively search the directory for archives (default: False)</sub>

- ##### `-Url`
> <sub>A FAKKU URL to pull metadata from</sub>

- ##### `-UrlFile`
> <sub>Specify a text file with FAKKU URLs to use for tagging (compatible with both `-FilePath` and `-InputFile`)</sub>

- ##### `-InputFile`
> <sub>Specify a text file with directories to tag</sub>

- ##### `-Sleep`
> <sub>Time to sleep between scrapes (default: 0)</sub>

- ##### `-WebDriverPath`
> <sub>Specify path to `WebDriver.dll` and `driver.exe` (default: `.`)</sub>

- ##### `-UserProfile`
> <sub>Specify path to save browser profiles to (default: `.\profiles`)</sub>

- ##### `-Headless`
> <sub>Launches browser in headless mode (default: False)</sub>

- ##### `-Incognito`
> <sub>Launches browser in incognito/private mode (default: False)</sub>

- ##### `-Log`
> <sub>Whether or not logs should be written (default: False)</sub>

- ##### `-LogPath`
> <sub>Specify path to save log to (default: `.\fakku_library.log`)</sub>
