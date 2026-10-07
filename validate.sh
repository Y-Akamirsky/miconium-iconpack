#!/usr/bin/env bash
#
# validate.sh — lightweight structural validator for Miconium icon packs.
#
# Checks that a pack laid out according to PACK_STRUCTURE.md can be loaded by
# Miconium:
#
#   <pack>/
#   ├── accessories/          (optional)
#   ├── frames/
#   │   ├── colorizable/      (required)
#   │   └── static/           (optional)
#   │       ├── Dark/         (optional)
#   │       └── Light/        (optional)
#   └── signs/
#       └── <category>/
#           ├── *.svg         (the default "scalable" variant)
#           └── <variant>/    (named variants: scalable, symbolic, 16, ...)
#
# Requires only bash + coreutils. Exit code 0 = all packs valid, 1 = errors.

set -uo pipefail

readonly REQUIRED_SIGN_CATEGORY_COUNT=1

RED='' GREEN='' YELLOW='' BOLD='' DIM='' NC=''
if [ -t 1 ]; then
    RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'
    BOLD=$'\033[1m';  DIM=$'\033[2m';         NC=$'\033[0m'
fi

errors=0
warnings=0

err()   { printf '%serror:%s %s\n'   "$RED"   "$NC" "$1" >&2; errors=$((errors + 1)); }
warn()  { printf '%swarn:%s %s\n'    "$YELLOW" "$NC" "$1" >&2; warnings=$((warnings + 1)); }
info()  { printf '%s%s%s\n'          "$DIM"   "$1" "$NC"; }
head1() { printf '\n%s==> %s%s\n'    "$BOLD"  "$1" "$NC"; }

# Count regular .svg files in a directory (0 if the directory is absent).
svg_count() {
    [ -d "$1" ] || { echo 0; return; }
    find "$1" -maxdepth 1 -type f -name '*.svg' 2>/dev/null | wc -l
}

# Validate every .svg under a directory tree: readable, non-empty, plausible root.
validate_svgs() {
    local dir="$1" label="$2"
    [ -d "$dir" ] || return 0

    local checked=0 bad=0 file
    while IFS= read -r -d '' file; do
        checked=$((checked + 1))
        if [ ! -s "$file" ]; then
            err "$label: empty SVG file: ${file#./}"
            bad=$((bad + 1))
        elif ! head -c 4096 "$file" | grep -qi '<svg'; then
            err "$label: not an SVG (no <svg> root): ${file#./}"
            bad=$((bad + 1))
        fi
    done < <(find "$dir" -type f -name '*.svg' -print0 2>/dev/null)

    printf '    %-42s %6d SVG  %s\n' "$label" "$checked" \
        "$([ "$bad" -eq 0 ] && printf '%sok%s' "$GREEN" "$NC")"
}

validate_pack() {
    local pack="$1" name
    name="$(basename "$pack")"

    head1 "Pack: $name  (${pack})"

    if [ ! -d "$pack" ]; then
        err "$name: not a directory"
        return
    fi

    # ── frames ──────────────────────────────────────────────────────────────
    if [ ! -d "$pack/frames" ]; then
        err "$name: missing required directory: frames/"
    else
        local colorizable
        colorizable="$(svg_count "$pack/frames/colorizable")"
        if [ ! -d "$pack/frames/colorizable" ]; then
            err "$name: missing required directory: frames/colorizable/"
        elif [ "$colorizable" -eq 0 ]; then
            err "$name: frames/colorizable/ contains no .svg files"
        else
            printf '    %-42s %6d SVG\n' "frames/colorizable/" "$colorizable"
            validate_svgs "$pack/frames/colorizable" "frames/colorizable"
        fi

        # static frames are optional, but must be consistent if present
        if [ -d "$pack/frames/static" ]; then
            local mode n
            for mode in Dark Light; do
                if [ -d "$pack/frames/static/$mode" ]; then
                    n="$(svg_count "$pack/frames/static/$mode")"
                    if [ "$n" -eq 0 ]; then
                        warn "$name: frames/static/$mode/ is empty"
                    else
                        printf '    %-42s %6d SVG\n' "frames/static/$mode/" "$n"
                        validate_svgs "$pack/frames/static/$mode" "frames/static/$mode"
                    fi
                fi
            done
        fi
    fi

    # ── signs ───────────────────────────────────────────────────────────────
    if [ ! -d "$pack/signs" ]; then
        err "$name: missing required directory: signs/"
    else
        local categories=0 cat variant_direct variant_sub total_svgs
        total_svgs=0
        for cat in "$pack"/signs/*/; do
            [ -d "$cat" ] || continue
            cat="$(basename "$cat")"

            # a sign category is non-empty if it holds loose SVGs (the default
            # "scalable" variant) or at least one variant subdirectory
            variant_direct="$(svg_count "$pack/signs/$cat")"
            variant_sub=0
            for variant in "$pack/signs/$cat"/*/; do
                [ -d "$variant" ] || continue
                [ "$(svg_count "$variant")" -gt 0 ] && variant_sub=$((variant_sub + 1))
            done

            if [ "$variant_direct" -eq 0 ] && [ "$variant_sub" -eq 0 ]; then
                err "$name: signs/$cat/ has no SVG layers (neither loose files nor variants)"
                continue
            fi

            categories=$((categories + 1))
            total_svgs=$((total_svgs + variant_direct))
            local v v_count
            for v in "$pack/signs/$cat"/*/; do
                [ -d "$v" ] || continue
                v_count="$(svg_count "$v")"
                total_svgs=$((total_svgs + v_count))
                printf '    %-42s %6d SVG\n' "signs/$cat/$(basename "$v")/" "$v_count"
            done
            [ "$variant_direct" -gt 0 ] && \
                printf '    %-42s %6d SVG\n' "signs/$cat/ (default variant)" "$variant_direct"
        done

        if [ "$categories" -lt "$REQUIRED_SIGN_CATEGORY_COUNT" ]; then
            err "$name: signs/ contains no usable category directories"
        else
            printf '    %-42s %6d\n' "sign categories" "$categories"
            printf '    %-42s %6d SVG\n' "sign layers (total)" "$total_svgs"
            validate_svgs "$pack/signs" "signs"
        fi
    fi

    # ── accessories (optional) ──────────────────────────────────────────────
    if [ -d "$pack/accessories" ]; then
        local acc
        acc="$(svg_count "$pack/accessories")"
        if [ "$acc" -eq 0 ]; then
            warn "$name: accessories/ contains no .svg files"
        else
            printf '    %-42s %6d SVG\n' "accessories/" "$acc"
            validate_svgs "$pack/accessories" "accessories"
        fi
    else
        info "    no accessories/ directory (optional)"
    fi

    # ── stray non-SVG payloads ──────────────────────────────────────────────
    if [ -d "$pack/signs" ]; then
        local stray
        stray="$(find "$pack/signs" -maxdepth 2 -type f ! -name '*.svg' 2>/dev/null | wc -l)"
        [ "$stray" -gt 0 ] && warn "$name: $stray non-SVG file(s) inside signs/ (ignored by Miconium)"
    fi
}

# ── main ────────────────────────────────────────────────────────────────────
main() {
    local -a packs=()

    if [ "$#" -gt 0 ]; then
        packs=("$@")
    else
        # auto-discover every pack in the repository root
        local d
        while IFS= read -r -d '' d; do
            packs+=("$d")
        done < <(find . -mindepth 1 -maxdepth 1 -type d \
                    -exec test -d '{}/frames' ';' -exec test -d '{}/signs' ';' -print0 2>/dev/null)
    fi

    if [ "${#packs[@]}" -eq 0 ]; then
        err "no packs found (expected a directory containing frames/ and signs/)"
        exit 1
    fi

    printf '%sValidating %d pack(s)%s\n' "$BOLD" "${#packs[@]}" "$NC"
    local p
    for p in "${packs[@]}"; do
        validate_pack "$p"
    done

    echo
    if [ "$errors" -gt 0 ]; then
        printf '%sFAILED%s — %d error(s), %d warning(s)\n' \
            "$RED" "$NC" "$errors" "$warnings" >&2
        exit 1
    fi
    printf '%sOK%s — all %d pack(s) valid%s\n' \
        "$GREEN" "$NC" "${#packs[@]}" \
        "$([ "$warnings" -gt 0 ] && printf ' (%d warning(s))' "$warnings")"
}

main "$@"