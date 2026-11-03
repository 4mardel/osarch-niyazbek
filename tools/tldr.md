# tldr: extracting an archive without reading eight screens of prose

Presented: week 6, Alimkhan Barat / Damir Niyazbek

## The problem

The built-in man pages are overwhelmingly long and detailed. Finding the correct combination of flags for a simple, everyday task (like extracting an archive) requires reading through pages of dense technical prose. We proved this live by running `man tar | wc -l`, which outputs over a thousand lines.

## What we showed

- **`tldr tar` / `tldr ss`**: instead of full documentation, it instantly outputs the most practical, ready-to-use commands for creating archives and troubleshooting network sockets.
- **Offline capability** (`sudo ip link set ens33 down` → `tldr chmod`): we demonstrated how it provides simple, human-readable examples for standard file permissions even when the virtual machine is completely disconnected from the internet, thanks to its local cache.

## When to reach for it

When you know which command you need but forgot the exact syntax or flags for a standard, everyday operation.

Do not use it if you need deep system configuration or rare parameters. For those, you still need the built-in man pages.

## Installing

- **Linux:** `sudo apt install tealdeer` (run `tldr --update` on first use to download the local cache)
- **Windows:** `winget install tldr`
