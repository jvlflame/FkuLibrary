# Fakku-Library

## **DISCLAIMER: This project is still in it's very early stages and may be prone to large or breaking changes. Use at your own risk.**

Scrape Fakku metadata and build your own local Fakku manga library with ComicRack (or Ubooquity).
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
  <Series>Comic Kairakuten BEAST 2017-03</Series>
  <Summary>Don't stare at me… you make me wanna strip…</Summary>
  <Writer>Tsukako</Writer>
  <Publisher>Fakku</Publisher>
  <Genre>vanilla, blowjob, oppai, stockings, slice of life, hentai, booty, creampie, uncensored, lingerie, cosplay, subscription</Genre>
  <LanguageISO>en</LanguageISO>
  <AgeRating>Adults Only 18+</AgeRating>
  <Manga>Yes</Manga>
</ComicInfo>
```

## Usage

On PowerShell 5.0+ run the following commands

1. Import the module

```
Import-Module Fakku-Library.psm1
```

2. Set metadata for your Fakku archives

```
# Set metadata for archives in specified filepath
Set-FakkuMetadata -FilePath "C:\path\to\files\"

# Set metadata for archives in specified filepath recursively
Set-FakkuMetadata -FilePath "C:\path\to\files\" -Recurse

# Set metadata for a single archive
Set-FakkuMetadata -FilePath "C:\path\to\file\file.cbz"
```
