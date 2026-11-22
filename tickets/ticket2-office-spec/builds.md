# Ticket 2 — Four builds

All prices are from Kaspi.kz on 2026-11-22 and are listed row by row in [budget.csv](budget.csv).

## The platform decision (shared by all four)

All four machines use the same base: **Intel Core i5-13400 BOX + GIGABYTE B760M DS3H DDR4 + DDR4-3200**, a Kingston NV3 1 TB NVMe SSD, a Zalman N5 TF case, a COUGAR GX-S550 power supply and Windows 11 Pro.
The machines differ in what each person's load actually uses up: memory, the monitor, the graphics card and the UPS.

**Why DDR4 and not AM5 + DDR5.** I started with AM5 (Ryzen 5 7600 + DDR5), because a newer socket lasts longer. Then I priced the memory on 2026-11-22:

| Memory, 32 GB (2 x 16) | Price on Kaspi.kz |
|---|---|
| DDR5-5600 Kingston FURY Beast KF556C36BBEK2-32 | 326,990 KZT |
| DDR4-3200 Kingston FURY Beast KF432C16BBK2/32 | 175,990 KZT |
| DDR4-3200 Hiksemi HSC432U32B5 | 137,088 KZT |

DDR5 costs about **190,000 KZT more per 32 GB** than the DDR4 kit I chose. Across the three machines that get 32 GB or more, that comes to about 760,000 KZT (four kits' worth, because the web developer has two), which is a quarter of the budget. The AM5 upgrade path would help only if the office swapped CPUs in 3–4 years. None of these four roles is short of CPU (see each build), so the money goes into memory now.

**What I gave up:** LGA1700 is a finished socket, so there will be no newer Intel CPU for this board. What still lasts: each board has 4 DDR4 slots (up to 128 GB) and a second M.2 slot, so memory and storage can grow, and those are the parts these loads will actually run out of. Using the same board in all four machines also means one set of drivers, one BIOS to update and parts that can be swapped between machines.

**Compatibility (checked as in Lab 3):**
- CPU socket LGA1700 ↔ board socket LGA1700.
- Board memory type DDR4 ↔ DDR4-3200 modules. 3200 MT/s is also the i5-13400's DDR4 limit, so no XMP is needed.
- The board's M.2 slot (PCIe 4.0 x4, 2280) ↔ Kingston NV3, which is M.2 2280 NVMe PCIe 4.0.
- Power: the i5-13400 is a 65 W processor (154 W maximum turbo). The designer's RTX 3050 6 GB draws 70 W from the slot and needs no power cable. The highest-load machine draws roughly 300 W, which is well under 550 W. The PSU has the 24-pin and 8-pin CPU connectors the board needs.
- Cooling: the BOX processor ships with the Intel Laminar RM1 (from Lab 3), at most 47 mm high, which fits the tower case.
- Graphics: the i5-13400 has UHD Graphics 730, so three of the four machines need no graphics card. I avoided the cheaper "F" models, which have no graphics.

---

### Build 1 — accountant

**Load:** accounting software (1C:Accounting, which in practice runs on Windows), the tax authority's web portals and bank clients in a browser (10–15 tabs), Excel with large registers, PDF invoices. About 8 hours a day, 3–4 programs at once, with month-end and quarter-end peaks.

**Bottleneck:** not the CPU, and not even the memory. The machine is light (all of this fits in about 8–10 GB, so 16 GB leaves room). What runs out first is **the screen and reliability**. The accountant reads numbers for eight hours, and a power cut during a 1C posting or a database save can corrupt the database. A UPS is cheap compared with restoring a damaged accounting database.

**Trade-off:** I kept the minimum 16 GB (2 x 8 GB, so it runs in dual channel) instead of 32 GB, and spent the money on a **height-adjustable Dell P2425H** (an office monitor with a 3-year warranty) and an **APC BV800I UPS**, which gives several minutes to save and shut down. The alternative I did not take was 32 GB of memory for about 55,000 KZT more. The accountant's workload never fills 16 GB, and two DIMM slots stay free if it ever does.

**Total:** 592,678 KZT (budget.csv, rows 2–12)

---

### Build 2 — sales manager

**Load:** a CRM in a browser, 30–40 tabs, WhatsApp Web / Telegram, Excel price lists, and 3–4 hours of video calls a day (Zoom / Google Meet), often all at once.

**Bottleneck:** **memory.** Chrome with 40 tabs is about 6–8 GB on its own, a video call adds 1–1.5 GB, and Windows itself uses about 3 GB. That is 11–12 GB before Excel. On 16 GB this sits at the limit, and Windows starts paging to the SSD in the middle of a customer call (Lab 6: when memory runs out, the system swaps and everything stalls). The CPU barely works: the i5-13400 has 10 cores, and a browser plus a call uses two or three of them.

**Trade-off:** 32 GB of memory, paid for by taking the cheapest decent 24" IPS monitor (Philips 24E1N1300A, 61,199 KZT) instead of the Dell the accountant got. The alternatives I did not take were the Dell monitor (+48,500 KZT) and Kingston-branded 32 GB (+38,900 KZT). Hiksemi is Hikvision's memory brand, with the same DDR4-3200 CL16 timings. A headset and a webcam are not in this budget. I assumed the sales manager keeps their own headset, and I would ask Daniyar about it (see README, section 2).

**Total:** 557,085 KZT (budget.csv, rows 13–22)

---

### Build 3 — web developer

**Load:** VS Code, Docker Desktop on WSL2 with 3–5 containers (database, back end, cache, reverse proxy), two or three browsers for testing (Chrome, Firefox, Edge) with DevTools open, and sometimes a VirtualBox VM with another OS (as in Ticket 1). All of it runs at once, all day.

**Bottleneck:** **memory, again, and much more of it.** WSL2 by default reserves up to half of the RAM for its Linux VM. Each database container wants 1–2 GB, each browser with DevTools 2–3 GB, and a test VM 4 GB (Ticket 1). Adding it up: Windows 3 + WSL2/Docker 8–12 + browsers 6–8 + VS Code 1–2 + a VM 4 = **22–29 GB**. That is above 16 GB and too close to 32 GB once the VM starts. The CPU matters only during builds, and 10 cores / 16 threads finish an `npm run build` or a `docker build` in seconds to minutes. Storage speed matters for container images, and NVMe already covers it.

**Trade-off:** **64 GB** (two 2 x 16 GB kits, all four slots), at 274,176 KZT the most expensive part of any build. To pay for it, I kept the same i5-13400 as everyone else instead of an i5-14600K/i7, and chose a 27" 1440p gaming-line monitor (Redmi G27Q, 87,400 KZT) instead of a business monitor. 1440p gives more lines of code on screen, and that is what a developer needs from a monitor. The alternative I did not take was 64 GB of DDR5 on AM5 (884,903 KZT for the memory alone), which would have used up almost a third of the whole budget. The downside of my choice: all four memory slots are full, so the next memory upgrade means replacing modules, not adding them.

**Total:** 720,374 KZT (budget.csv, rows 23–32)

---

### Build 4 — designer

**Load:** Adobe Photoshop and Illustrator (or Figma) with files of 1–3 GB and dozens of layers, print layouts, and short video edits for social media (Premiere Pro, 1080p). Six to eight hours a day, usually two or three heavy programs open at once.

**Bottleneck:** **the monitor first, then memory.** If the colours on screen are wrong, every print job and every brand colour is wrong, and no amount of CPU fixes that. So the monitor is the one part I did not save on: an **ASUS ProArt PA278QV**, a 27" IPS 2560x1440 panel covering 100% sRGB, factory-calibrated (ΔE < 2). Second comes memory: Photoshop keeps its history states and its scratch data in RAM, so with a 2 GB file 16 GB fills up fast. Third is the GPU. Photoshop and Illustrator use it for canvas acceleration and some filters, and Premiere for playback and export, but they do not need a gaming card.

**Trade-off:** 32 GB of memory and an entry-level **RTX 3050 6 GB** (171,000 KZT, 70 W, no extra power cable). The alternative I did not take was an RTX 5060 8 GB (300,000 KZT), which is roughly twice as fast in Premiere. Taking it would have meant either a cheaper monitor or less memory, and the monitor is the bottleneck. The 274,227 KZT that is left unspent in the budget is enough to buy the RTX 5060 later without any other change (see README, question 1).

**Total:** 855,636 KZT (budget.csv, rows 33–43)

---

## Summary

| Role | Memory | Monitor | GPU | Extra | Total, KZT |
|---|---|---|---|---|---|
| Accountant | 16 GB | Dell P2425H 24" adjustable | built-in | UPS | 592,678 |
| Sales manager | 32 GB | Philips 24" IPS | built-in | — | 557,085 |
| Web developer | 64 GB | Redmi 27" 1440p | built-in | — | 720,374 |
| Designer | 32 GB | ASUS ProArt 27" 1440p 100% sRGB | RTX 3050 6 GB | — | 855,636 |
| **Grand total** | | | | | **2,725,773** of 3,000,000 |

The remaining **274,227 KZT (9%)** is not spent. It covers price changes before purchase (the guide warns that memory and SSD prices in Kazakhstan move within a month, and the same 32 GB of memory already ranges from 137,088 to 233,599 KZT between Kaspi sellers), delivery and assembly, and the designer's GPU upgrade later.
