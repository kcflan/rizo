<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/readme/banner-dark.png">
  <img src="docs/readme/banner-light.png" alt="rizo — a two-ink risograph theme for Typora">
</picture>

<p align="center">
  <a href="../../releases/latest"><img src="https://img.shields.io/github/v/release/kcflan/rizo?style=for-the-badge&label=release&color=F0339A&labelColor=1D1A2C" alt="Latest release"></a>
  <img src="https://img.shields.io/badge/Typora-1.8%2B-0068B5?style=for-the-badge&labelColor=1D1A2C" alt="Typora 1.8+">
  <img src="https://img.shields.io/badge/themes-light%20%2B%20dark-F0339A?style=for-the-badge&labelColor=1D1A2C" alt="Light and dark themes">
  <img src="https://img.shields.io/badge/fonts-bundled-0068B5?style=for-the-badge&labelColor=1D1A2C" alt="Fonts bundled">
</p>

A two-ink risograph theme for [Typora](https://typora.io). Heavy grotesque headings printed slightly off-register, a bookish serif for reading, halftone quotes, and inked tables and code blocks — made to turn AI-generated reports into something you actually want to read.

## Before and after

The same document, in Typora's default GitHub theme and in rizo.

| Typora default | rizo |
| :---: | :---: |
| <img src="docs/readme/before-github.png" alt="A report in Typora's default GitHub theme" width="100%"> | <img src="docs/readme/after-rizo.png" alt="The same report in rizo" width="100%"> |

## Two inks, two papers

Two themes, **Rizo** and **Rizo Dark**, printed in Fluorescent Pink + Blue.

<img src="docs/readme/swatches.png" alt="Ink swatches: cream paper, ink, Fluorescent Pink #F0339A and Blue #0068B5 for light; midnight paper, ink, #FF5CB5 and #5DB8F5 for dark">

## Install

> [!IMPORTANT]
> Requires **Typora 1.8 or later**. Older versions lack the alert blocks and the modern CSS rizo's colors and shadows rely on.

1. Download [`rizo.zip`](../../releases/latest/download/rizo.zip) from the [latest release](../../releases/latest).
2. In Typora: **Settings › Appearance › Open Theme Folder**.
3. Unzip it, then copy `rizo.css`, `rizo-dark.css` and the `rizo/` folder into the theme folder.
4. Restart Typora and pick **Themes › Rizo** or **Themes › Rizo Dark**.

> [!TIP]
> **Follow macOS light / dark automatically:** in **Settings › Appearance**, enable the separate theme for dark mode, then choose **Rizo** for light and **Rizo Dark** for dark.

> [!TIP]
> **Keyboard shortcuts for switching:** in **System Settings › Keyboard › Keyboard Shortcuts › App Shortcuts**, add Typora and enter the menu title exactly (`Rizo` or `Rizo Dark`) with a shortcut of your choice.

## Up close

| | |
| :---: | :---: |
| <img src="docs/readme/detail-headings.png" alt="Off-register headings and lead paragraph"> | <img src="docs/readme/detail-table.png" alt="Inked table with a blue header and offset pink shadow"> |
| **Off-register headings** in Bricolage Grotesque, a Literata lead paragraph | **Inked tables** with a blue header row and an offset pink block |
| <img src="docs/readme/detail-alerts.png" alt="Note and warning alerts in Rizo Dark"> | <img src="docs/readme/detail-code.png" alt="Code block with language chip in Rizo Dark"> |
| **Alerts** (`> [!NOTE]`, `TIP`, `IMPORTANT`, `WARNING`, `CAUTION`), shown in Rizo Dark | **Code blocks** in Space Mono with a language chip and ink syntax colors |
| <img src="docs/readme/detail-quote-tasks.png" alt="Halftone blockquote and task list"> | <img src="docs/readme/detail-pdf.png" alt="First page of a PDF export from Rizo on cream paper and from Rizo Dark on midnight paper"> |
| **Halftone quotes** and inked task lists | **PDF export** keeps the theme's paper edge to edge: cream from Rizo, midnight from Rizo Dark. Typora colors the PDF margins with the theme's background, so a white page would sit inside a colored frame |

Also styled: h1–h6, YAML front matter, footnotes, highlights, `<kbd>`, TOC, and Typora's sidebar, outline, search, quick open, menus, focus mode and source mode.

## Fonts

Bundled, so it works offline: [Bricolage Grotesque](https://fonts.google.com/specimen/Bricolage+Grotesque) (headings, UI), [Literata](https://fonts.google.com/specimen/Literata) (body), [Space Mono](https://fonts.google.com/specimen/Space+Mono) (code). All SIL Open Font License 1.1.

## Development

```bash
scripts/install.sh               # macOS / Linux: symlink this repo into Typora's themes folder
scripts/install.sh --uninstall   # remove the symlinks
scripts/package.sh 1.0.0         # build dist/rizo.zip for a release
scripts/refresh-release.sh       # small fix: move the latest tag here and replace its zip (needs gh)
python3 scripts/getfonts.py      # re-download the bundled fonts
```

On Windows, from PowerShell:

```powershell
scripts\install.ps1             # link this repo into %APPDATA%\Typora\themes
scripts\install.ps1 -Uninstall  # remove the links
```

File symlinks on Windows need Developer Mode (**Settings › System › For developers**) or an admin PowerShell. Set `TYPORA_THEMES` to use a different themes folder on any OS.

`samples/sample.md` exercises every styled element.

## License

Free to use and modify for yourself; not to redistribute. See [LICENSE](LICENSE).
