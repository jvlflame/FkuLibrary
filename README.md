# Fakku-Library

[![Last commit](https://img.shields.io/github/last-commit/jvlflame/Fakku-Library?style=flat-square)](https://github.com/jvlflame/Fakku-Library/commits/master)
[![Discord](https://img.shields.io/discord/608449512352120834?style=flat-square)](https://discord.gg/K2Yjevk)

## **DISCLAIMER: This project is still in its early stages and may be prone to breaking changes. Use at your own risk.**

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

## Table of Contents:

- [Getting Started](#Getting-Started)
- [Usage](#Usage)

## Getting Started

### Prerequisites

- [PowerShell 5.0 or higher (6.0+ recommended)](<(https://github.com/PowerShell/PowerShell)>)
- ComicRack, Ubooquity, or any other CMS that supports `ComicInfo.xml` metadata

#### Accepted archive filenames

```
[Author] Manga Title (Comic XXX).ext

Manga Title (Comic XXX).ext

Manga Title.ext
```

### Installing

[Clone the repository](https://github.com/jvlflame/Fakku-Library/archive/master.zip) and extract the
files to a directory of your choice.

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
