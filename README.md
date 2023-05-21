# FAKKU metadata scraper

Scrape metadata from FAKKU.net and build your own local FAKKU manga library with Komga or any other CMS that supports `ComicInfo.xml` metadata.

```
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

## Getting Started

### Prerequisites

- [PowerShell 5.0 or higher (6.0+ recommended)](https://aka.ms/powershell-release?tag=stable)
- Komga or any other CMS that supports `ComicInfo.xml` metadata

#### Accepted archive filenames

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

## Setup

#### Clone the repository

- [Clone the repository](https://github.com/shrublet/fakku-meta-scraper/archive/refs/heads/main.zip) and extract the
files to a directory of your choice.



#### Setup Selenium WebDriver

- It's highly recommneded to setup and download Selenium as well to access publicly blocked pages. Download the WebDriver for your browser and the Selenium for C# package. Extract the WebDriver executable (for Google Chrome, this will be `chromedriver.exe`) and `WebDriver.dll` from the `.nupkg` package to either the root of the cloned repository (i.e. `.\fakku-meta-scraper\`) or a directory of your choice.

> <sub>The `WebDriver.dll` is packaged inside `.nupkg` file under `.\lib\net48` and can be opened via any file archiver. Most Windows PCs should have .NET 4.8, so this is the recommended library. If the WebDriver isn't working as expected, ensure the version matches with your browser or try updating your browser/downgrading the WebDriver.</sub>

<sub>[Browser WebDriver executables](https://www.selenium.dev/documentation/webdriver/getting_started/install_drivers/#quick-reference) [^1]</sub>

<sup>[Selenium WebDriver for C#](https://www.nuget.org/packages/Selenium.WebDriver)</sup>

[^1]: Currently only supports Google Chrome, Microsoft Edge, and Firefox.

#### Import the module

- You will need to do this every time you close your PowerShell window unless you add the module to
your PowerShell module PATH

```
Import-Module Fakku-Scraper.psm1
```

## Usage examples

#### Set metadata for an archive

```
Set-FakkuMetadata -FilePath "C:\path\to\file.zip"
```

#### Set metadata for archives in specified filepath (supports recursion via `-Recurse`)

```
Set-FakkuMetadata -FilePath "C:\path\to\files\"
```

#### Set metadata for an archive from a FAKKU link

```
Set-FakkuMetadata -FilePath "C:\path\to\file.zip" -URL https://www.fakku.net/hentai/Bare-Girl-english
```

#### Get example metadata from a FAKKU link

```
Get-FakkuMetadata https://www.fakku.net/hentai/Bare-Girl-english
```

#### Get example metadata from a comic title

```
Get-FakkuMetadata "Bare Girl"
```


#### Set metadata for an archive while using WebDriver in incognito mode

```
Set-FakkuMetadata -FilePath "C:\path\to\file\file.zip" -Incognito
```


