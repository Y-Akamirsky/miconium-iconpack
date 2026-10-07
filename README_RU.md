<div align="center">

# **miconium-iconpack**
### Икон-паки для [Miconium](https://github.com/Y-Akamirsky/miconium)

[![Лицензия](https://img.shields.io/badge/license-GPL3-623994)](./LICENSE)

</div>

___

<div align="center">

## О репозитории

</div>

Здесь живут официальные **икон-паки Miconium** — исходные SVG-слои (frames,
signs, accessories), из которых Miconium собирает готовую тему иконок.

Это **отдельный репозиторий от программы Miconium** — и это сделано намеренно:

| | Программа | Икон-паки |
|---|---|---|
| Репозиторий | `Y-Akamirsky/miconium` | `Y-Akamirsky/miconium-iconpack` *(этот)* |
| Версионирование | вместе с приложением | вместе с графикой |
| Ставится в | `/usr/bin`, `/usr/share/applications`, … | `/usr/share/miconium/<pack>` |

Обновление графики **не трогает программу**, а обновление программы **не
трогает ваши паки**. Релизы паков и релизы программы независимы.

Пак — это обычная директория SVG-файлов: без сборки, без бинарного формата.

Сейчас в репозитории:

- **`yamis`** — пак по умолчанию (10000+ иконок, подложки для светлой/тёмной
  темы, украшения)

___

<div align="center">

## Установка

</div>

### Arch Linux (через PKGBUILD)

```bash
git clone https://github.com/Y-Akamirsky/miconium-iconpack.git
cd miconium-iconpack/install/arch-pkgbuild/
makepkg -fsi
```

> [!TIP]
> После установки клон можно удалить: `rm -rf ~/miconium-iconpack`

### Любой дистрибутив (через Make)

```bash
git clone https://github.com/Y-Akamirsky/miconium-iconpack.git
cd miconium-iconpack/
make install            # поддерживаются DESTDIR=/some/stage и PREFIX=...
```

> [!TIP]
> Удаление: `sudo make uninstall`

### Вручную

Просто скопируйте директорию пака в системный каталог:

```bash
sudo cp -r yamis /usr/share/miconium/
```

Пак(и) в `~/.local/share/miconium/<pack>/` тоже подхватываются — это место
для собственных и сторонних паков, оно имеет приоритет.

Активный пак выбирается в конфиге:

```toml
[pack]
name = "yamis"
```

После этого выберите пак в GUI Miconium.

___

<div align="center">

## Собери свой пак

</div>

**Ты можешь собрать свой икон-пак** — свои иконки, свои подложки и свои
украшения, в любом стиле. Пак — это просто директория SVG:

```
my-pack/
├── accessories/        ← украшения: блики, рамки, градиенты
├── frames/
│   ├── colorizable/    ← подложки, перекрашиваются при генерации
│   └── static/{Dark,Light}/
└── signs/
    └── apps/{scalable,symbolic,16}/
```

Рисинг должен оставаться творческим и доступным процессом, поэтому всё можно
свободно комбинировать: взять иконки из `yamis` со своими подложками или,
наоборот, слои значков своего стиля с чужой подложкой. Здесь ничего не
монолитно.

Полная структура описана в **[PACK_STRUCTURE_RU.md](./PACK_STRUCTURE_RU.md)**,
а проверить результат можно встроенным скриптом (только bash, без зависимостей):

```bash
./validate.sh my-pack
```

Он проверит обязательные директории, наличие слоёв в каждой категории и
корректность всех SVG. Код возврата `0` означает, что Miconium сможет
загрузить пак.

Установить можно системно через `make install`, а для пользователя:

```bash
cp -r my-pack ~/.local/share/miconium/
```

___

<div align="center">

## Contributing

</div>

- Новые иконки клади в соответствующую директорию `signs/<категория>/<вариант>/`.
- Добавляй строку-чекбокс в `yamis/neededicons.list`, если добавляешь *желаемую* иконку.
- Перед коммитом запусти `./validate.sh` — CI делает это за тебя.
- Держи `PACK_STRUCTURE_RU.md` в актуальном состоянии.

## Лицензия

GPLv3 — см. [LICENSE](./LICENSE).