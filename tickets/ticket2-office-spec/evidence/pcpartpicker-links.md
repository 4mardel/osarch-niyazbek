# PCPartPicker lists

PCPartPicker does not price in tenge and does not sell in Kazakhstan. I used it **only to check compatibility** (CPU socket ↔ board, board memory type ↔ memory, M.2 ↔ SSD) **and the estimated power draw** against the 550 W supply. All prices in this ticket come from Kaspi.kz ([../budget.csv](../budget.csv)).

Where Kaspi's exact model is not in PCPartPicker's database, I picked the closest equivalent with the same specification (for example the Hiksemi DDR4-3200 2 x 16 GB kit becomes any DDR4-3200 CL16 2 x 16 GB kit). The compatibility check depends on the specification, not the brand.

| Build | PCPartPicker list | Compatibility result | Estimated wattage |
|---|---|---|---|
| 1 — accountant | https://pcpartpicker.com/list/gZQxV4 | No incompatibilities (only the standard note: "Some physical constraints are not checked, such as RAM clearance with CPU Coolers") | 232 W |
| 2 — sales manager | https://pcpartpicker.com/list/Z7wKNp | No incompatibilities (same standard note only) | 247 W |
| 3 — web developer | https://pcpartpicker.com/list/kL79R4 | No incompatibilities (same standard note only) | 276 W |
| 4 — designer | https://pcpartpicker.com/list/2zZv2k | No incompatibilities (same standard note only) | 317 W |

All four builds use a 550 W supply. The highest estimate (designer, 317 W) leaves about 42% headroom, so the supply runs in its efficient middle range and has room for the GPU upgrade in README question 1.

The "RAM clearance with CPU coolers" note does not apply: the stock Intel Laminar RM1 is a low (47 mm) top-down cooler that does not reach over the DIMM slots.

**Stand-ins used because PCPartPicker does not list the Kaspi model** (the same specification, so the check is unchanged):
- Case: Zalman N5 TF → **Zalman i3 NEO** (both are ATX mid towers that take a Micro-ATX board).
- Accountant monitor: Dell P2425H → **Dell P2422H** (the previous model: 23.8" 1920x1080 IPS; a monitor does not affect compatibility or the wattage estimate).
- Memory: Hiksemi HSC432U32B5 → a Kingston FURY Beast DDR4-3200 CL16 kit of the same size (2 x 16 GB; the developer has two kits).

## Parts to enter for each list

Common to all four builds:
- CPU: Intel Core i5-13400 (the boxed version with its cooler)
- Motherboard: Gigabyte B760M DS3H DDR4
- Storage: Kingston NV3 1 TB M.2-2280 PCIe 4.0 NVMe
- Case: Zalman N5 TF
- Power supply: Cougar GX-S550 (or any 550 W 80+ Gold ATX)
- Operating system: Microsoft Windows 11 Pro OEM 64-bit

Different per build:

| Build | Memory | Video card | Monitor |
|---|---|---|---|
| Accountant | 2 x Kingston FURY Beast 8 GB DDR4-3200 CL16 | — (UHD 730) | Dell P2425H |
| Sales manager | 1 x DDR4-3200 CL16 2 x 16 GB kit | — (UHD 730) | Philips 24E1N1300A |
| Web developer | 2 x DDR4-3200 CL16 2 x 16 GB kit (64 GB, 4 slots) | — (UHD 730) | Xiaomi Redmi G27Q (or any 27" 2560x1440) |
| Designer | 1 x DDR4-3200 CL16 2 x 16 GB kit | Gigabyte GeForce RTX 3050 WINDFORCE OC 6G | ASUS ProArt PA278QV |
