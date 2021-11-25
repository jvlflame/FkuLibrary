# Fakku-Library

[![Last commit](https://img.shields.io/github/last-commit/jvlflame/Fakku-Library?style=flat-square)](https://github.com/jvlflame/Fakku-Library/commits/master)
[![Discord](https://img.shields.io/discord/608449512352120834?style=flat-square)](https://discord.gg/K2Yjevk)

## **DISCLAIMER: This project is still in its early stages and may be prone to breaking changes. Use at your own risk.**

Scrape Fakku metadata and build your own local FAKKU manga library with ComicRack, Komga, Ubooquity, any other CMS that supports `ComicInfo.xml` metadata.
Currently supports scraping directly from `Fakku.net`, with failover to `panda.chaika.moe`.

`Set-FakkuMetadata` will write a `ComicInfo.xml` metadata file directly into your manga archive,
supporting filetypes: .zip, .cbz, .rar, .cbr, .7z, and .cb7.

## Demo

![Demo-ComicRack](/other/demo-comicrack.jpg)

![Demo-Gif](/other/demo-usage.gif)

### Sample ComicInfo.xml file

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
  <Genre>vanilla, booty, busty, stockings, creampie, uncensored, unlimited, blowjob, hentai, lingerie, cosplay</Genre>
  <Web>https://www.fakku.net/hentai/Bare-Girl-english</Web>
  <LanguageISO>en</LanguageISO>
  <Manga>Yes</Manga>
  <SeriesGroup>Comic Kairakuten BEAST 2017-03</SeriesGroup>
  <AgeRating>Adults Only 18+</AgeRating>
</ComicInfo>
```

## Table of Contents:

- [Getting Started](#Getting-Started)
- [Usage](#Usage)

## Getting Started

### Prerequisites

- [PowerShell 5.0 or higher (6.0+ recommended)](<(https://github.com/PowerShell/PowerShell)>)
- ComicRack, Komga, Ubooquity, or any other CMS that supports `ComicInfo.xml` metadata

#### Accepted archive filenames

```
[Author] Manga Title (Comic XXX).ext

Manga Title (Comic XXX).ext

Manga Title.ext
```

### Installing

[Clone the repository](https://github.com/jvlflame/FkuLibrary/archive/master.zip) and extract the
files to a directory of your choice.

[Download the chromedriver](https://chromedriver.chromium.org/downloads) version that matches your version of chrome as well as the [Selenium WebDriver for C#](https://goo.gl/uJJ5Sc). Extract `chromedriver.exe` and `WebDriver.dll` to a readable/writable path (by default, it looks at `C:\Selenium`).
> Note: The `WebDriver.dll` file is packaged inside `\selenium-dotnet-3.14.0.zip\dist\Selenium.WebDriver.3.14.0.nupkg\lib\net45\`. The .nupkg file can be treated like a .zip. If ChromeDriver isn't working as expected, ensure the version matches with your Chrome browser. If they match and it still doesn't work, try downgrading the `chromedriver.exe` version or updating Chrome.

#### Import the module

You will need to do this every time you close your PowerShell window unless you add the module to
your PowerShell module PATH

```
Import-Module Fakku-Library.psm1
```

## Usage

To run the module, use PowerShell 5.0 or higher.

### Examples

#### Set metadata for archives in specified filepath

```
Set-FakkuMetadata -FilePath "C:\path\to\files\"
```

#### Set metadata for archives in specified filepath recursively

```
Set-FakkuMetadata -FilePath "C:\path\to\files\" -Recurse
```

#### Set metadata for a single archive

```
Set-FakkuMetadata -FilePath "C:\path\to\file\file.cbz"
```

#### Set metadata for archives in specified filepath using an open instance of Chrome

```
Set-FakkuMetadata -Remote -FilePath "C:\path\to\file\file.cbz"
```
> Note: Use this to circumvent chromedriver opening a new window everytime when setting metadata to individual archives. Make sure to open Chrome with the --remote-debugging-port argument (tries --remote-debugging-port=5656 by default) and login to FAKKU beforehand.

#### Get example metadata from a Fakku link
```
Get-FakkuMetadata https://www.fakku.net/hentai/Bare-Girl-english
```
