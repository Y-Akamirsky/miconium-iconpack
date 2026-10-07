# Miconium icon pack structure

A **pack** is a plain directory of SVG layers that Miconium assembles into a
complete icon theme. Packs are data only — no build step, no binary format.
If you can edit SVG files, you can build a pack.

```
<pack-name>/
├── accessories/              (optional)
├── frames/
│   ├── colorizable/          required — the recolourable frame backgrounds
│   └── static/               optional — light/dark specific frames
│       ├── Dark/
│       └── Light/
└── signs/
    ├── apps/
    ├── categories/
    ├── devices/
    ├── emblems/
    ├── mimetypes/
    ├── places/
    ├── preferences/
    └── status/
```

## `frames/`

The background shape drawn behind the sign.

- **`frames/colorizable/`** (required) — frame SVGs whose colours Miconium
  rewrites at render time. This is the main source of recolourable frames.
- **`frames/static/Dark/`, `frames/static/Light/`** (optional) — frames chosen
  automatically for dark or light colour schemes. Use these when a frame must
  keep specific colours (e.g. a gradient or a fixed-contrast outline).

## `signs/`

The actual glyphs, grouped by category. Categories are free-form; the ones
listed above are the ones Miconium's output layout expects.

Each category may contain:

- **loose `*.svg` files** — the default variant (treated as `scalable`), or
- **variant subdirectories** — named variants such as `scalable`, `symbolic`,
  `16`, `22`, `scalable-outlined`.

```
signs/apps/
├── scalable/          ← named variant
│   ├── firefox.svg
│   └── ...
├── symbolic/          ← named variant
│   └── ...
└── gimp.svg           ← default variant (no subdirectory)
```

Variants are what makes one pack usable at multiple sizes and styles: a
`symbolic` variant for panels and menus, `16` for small UI slots, and so on.
The user (or the GUI) picks a variant per category.

## `accessories/` (optional)

Decorative overlays drawn on top of the frame — shine, gradients, borders,
"cookie" corners, and similar flourishes. Colours are recoloured at render
time, and each accessory can be positioned, rotated and scaled.

## Colours

Frames, signs and accessories receive colours from the active palette:
`background`, `foreground` and `accent` respectively (the mapping is
configurable per preset). To make a layer accept recolouring, give its shapes
the placeholder colours that Miconium substitutes — see the preset TOML or
`miconium.example.toml` in the program repository.

## Validating your pack

Run the bundled validator — it needs only bash:

```bash
./validate.sh            # validates every pack in the repository
./validate.sh my-pack    # validates one pack
```

It checks required directories, that every category actually contains layers,
that all SVGs are readable, non-empty and carry an `<svg>` root, and prints a
per-category summary. Exit code `0` means Miconium can load the pack.

## Installing your pack

Miconium resolves packs by name, so the directory name is the pack name.

- **System-wide:** install to `/usr/share/miconium/<pack-name>/` — this is
  what this repository's `make install` and `PKGBUILD` do.
- **Per user:** copy to `~/.local/share/miconium/<pack-name>/`.

Then select it in the Miconium GUI, or reference it from a config/preset:

```toml
[pack]
name = "my-pack"
```

If you also want to redistribute it, publish your own repository using this
one as a template — the layout and the validator are all you need.