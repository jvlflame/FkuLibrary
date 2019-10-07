# Fakku-Library

Scrape Fakku metadata and build a local Fakku manga library with ComicRack (or Ubooquity).

`Set-FakkuMetadata.ps1` will write a `ComicInfo.xml` metadata file directly into your manga archive
(.zip, .cbz, .cbr, .rar, .7z, .cb7).

## Demo

![Demo](/other/demo.jpg)

## Usage

1. `Import-Module Fakku-Library.psm1`
2. `Set-FakkuMetadata -FilePath "C:\Path\to\files\"`
