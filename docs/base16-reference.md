# Base16 Color Palette Reference

See the [Theme System](../README.md#theme-system-stylix) section in the README for how colors are applied in this configuration.

Base16 aims to group similar language constructs with a single color. The 16
slots are split into two groups: **base00–base07** are shades used for
backgrounds, foregrounds, and UI chrome; **base08–base0F** are accent colors
used for syntax highlighting.
 
For a dark theme, base00–base07 should run from darkest to lightest. For a
light theme, they run from lightest to darkest.
 
| Slot    | Default Color | Intended Use |
|---------|---------------|--------------|
| base00  | Dark          | Default background |
| base01  | Slightly lighter | Lighter background — status bars, line numbers, folding marks |
| base02  | Lighter still  | Selection background |
| base03  | Mid-dark       | Comments, invisibles, line highlighting |
| base04  | Mid            | Dark foreground — used for status bars |
| base05  | Light          | Default foreground, caret, delimiters, operators |
| base06  | Lighter        | Light foreground (rarely used) |
| base07  | Lightest       | Light background (rarely used) |
| base08  | Red            | Variables, XML tags, markup link text, markup lists, diff deleted |
| base09  | Orange         | Integers, booleans, constants, XML attributes, markup link URLs |
| base0A  | Yellow         | Classes, markup bold, search text background |
| base0B  | Green          | Strings, inherited class, markup code, diff inserted |
| base0C  | Cyan           | Support, regular expressions, escape characters, markup quotes |
| base0D  | Blue           | Functions, methods, attribute IDs, headings |
| base0E  | Magenta        | Keywords, storage, selector, markup italic, diff changed |
| base0F  | Brown/Dark Red | Deprecated, opening/closing embedded language tags (e.g. `<?php ?>`) |
 
## Sources
 
- [Base16 Styling Guidelines](https://github.com/chriskempson/base16/blob/main/styling.md) — Chris Kempson (original spec, v0.2)
- [tinted-theming/base16-schemes](https://github.com/tinted-theming/base16-schemes) — current maintained fork of the scheme collection
- [Base16 Colorscheme Previews](https://tinted-theming.github.io/tinted-gallery/)
    
