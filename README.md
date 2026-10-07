<div align="center">

# **miconium-iconpack**
### Icon packs for [Miconium](https://github.com/Y-Akamirsky/miconium)

[![License](https://img.shields.io/badge/license-GPL3-623994)](./LICENSE)

</div>

___

<div align="center">

## About

</div>

This repository ships the official **Miconium icon packs** — the raw SVG
layers (frames, signs, accessories) that Miconium assembles into a finished
icon theme.

It is a **separate repository from the Miconium program on purpose**:

| | Program | Icon packs |
|---|---|---|
| Repository | `Y-Akamirsky/miconium` | `Y-Akamirsky/miconium-iconpack` *(this one)* |
| Versioning | follows the app | follows the artwork |
| Installs to | `/usr/bin`, `/usr/share/applications`, … | `/usr/share/miconium/<pack>` |

Updating artwork therefore **never touches the program**, and updating the
program **never touches your packs**. Pack releases and app releases are
independent.

Packs are plain directories of SVG files — no build step, no binary format.

Currently included:

- **`yamis`** — the default pack (10000+ icons, light/dark frames, accessories)

___

<div align="center">

## Installation

</div>

### Arch Linux (via PKGBUILD)

```bash
git clone https://github.com/Y-Akamirsky/miconium-iconpack.git
cd miconium-iconpack/install/arch-pkgbuild/
makepkg -fsi
```

> [!TIP]
> After installing you can delete the clone: `rm -rf ~/miconium-iconpack`

### Any distro (via Make)

```bash
git clone https://github.com/Y-Akamirsky/miconium-iconpack.git
cd miconium-iconpack/
make install            # DESTDIR=/some/stage and PREFIX=... are supported
```

> [!TIP]
> Remove again with `sudo make uninstall`

### Manually

Just copy a pack directory into the system share directory:

```bash
sudo cp -r yamis /usr/share/miconium/
```

Packs placed in `~/.local/share/miconium/<pack>/` are picked up too — that
location is for your own / third-party packs and takes precedence.

Miconium resolves the active pack from your config:

```toml
[pack]
name = "yamis"
```

Then pick the pack in the Miconium GUI.

___

<div align="center">

## Build your own pack

</div>

**You can build your own icon pack** — your own icons, your own frames and your
own decorations, in any style you like. A pack is just a directory of SVGs:

```
my-pack/
├── accessories/        ← your decorations: shine, borders, gradients
├── frames/
│   ├── colorizable/    ← your backgrounds, recoloured at render time
│   └── static/{Dark,Light}/
└── signs/
    └── apps/{scalable,symbolic,16}/
```

Ricing should be a creative and accessible process, so you can mix and match
freely: take `yamis`' icons with your own frames, or sign layers of your own
style with a frame from somewhere else. Nothing here is monolithic.

Read **[PACK_STRUCTURE.md](./PACK_STRUCTURE.md)** for the full layout, then
validate your work with the bundled script (bash only, no dependencies):

```bash
./validate.sh my-pack
```

It checks required directories, that every category really contains layers,
and that every SVG is readable and valid. Exit code `0` means Miconium can
load it.

Install it system-wide with `make install`, or per user with:

```bash
cp -r my-pack ~/.local/share/miconium/
```

___

<div align="center">

## Contributing

</div>

- New icons go into the matching `signs/<category>/<variant>/` directory.
- Add a checkbox line to `yamis/neededicons.list` when you add a *wanted* icon.
- Run `./validate.sh` before committing — CI does it for you.
- Keep the structure documented in `PACK_STRUCTURE.md` in sync.

## License

GPLv3 — see [LICENSE](./LICENSE).