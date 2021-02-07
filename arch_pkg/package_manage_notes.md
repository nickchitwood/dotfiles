# Notes on package management

## Expac utility

expac [options] <format> targets

```bash
expac -l '\n' '%E' base
    -l '\n' # List delimiter-newline
    '%E' base # Depends on package-base
```

## pacman

```bash
pacman -Qqg base-devel
    -Qqg # Query quiet group

pacman -Qqen
    -Qqem # Query quiet explicit native

pacman -Qqem
    -Qqem # Query quiet explicit native

pacman -Qo
    -Qo # o - Get owner
```
