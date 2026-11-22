# Ticket 2 — Kitting out the new office

## 1. What was asked

> From: Daniyar K. (Director)
> Subject: computers for the new office
>
> We are opening the second office and need four computers — accountant, sales, web
> developer, designer. Budget 3,000,000 tenge for everything. Everyone says we should just buy
> the same four machines, is that right? Make sure they last a few years. Monitors included.

## 2. What was actually needed

**Four identical machines is the wrong answer.** The four people put four different loads on a computer, and each load runs out of a different resource first:

| Role | What runs out first | What an "average" identical machine would do |
|---|---|---|
| Accountant | the screen (8 hours of numbers) and reliability (power cuts, the 1C database) | overpays for memory and a GPU the accountant never uses |
| Sales manager | memory (40 browser tabs + video calls ≈ 11–12 GB) | 16 GB swaps during calls; buying 32 GB for everyone wastes money on the accountant |
| Web developer | memory, much more of it (Docker/WSL2 + browsers + a VM ≈ 22–29 GB) | 32 GB is too tight, and buying 64 GB for all four would cost about 470,000 KZT more |
| Designer | colour accuracy of the monitor, then memory, then the GPU | an office monitor makes every print colour wrong |

To make four identical machines good enough for the designer and the developer, I would have to give every machine 64 GB, a GPU and a ProArt monitor. That is about 1,000,000 KZT per machine, 4,000,000 for four, which is over budget. To keep them inside the budget, they would have to be average machines, and then the developer swaps and the designer prints the wrong colours. The part of the director's idea that is right: **the same platform** (CPU, board, case, PSU, SSD) for all four. That gives one driver set, one BIOS and parts that can be swapped between machines. Only the parts that match the load differ (see [builds.md](builds.md)).

**What the request left out**

- **Operating system licences.** "For everything" has to include them. Accounting software in Kazakhstan (1C, bank clients, tax tools) is in practice run on Windows, so I priced four Windows 11 Pro OEM licences (46,800 KZT each).
- **Keyboards, mice, cables.** Not mentioned, but nobody can work without them. Priced as a Logitech MK270 combo for each machine.
- **Power protection.** The accountant's database must not be cut off mid-save, so I added a UPS for that machine.
- **Network.** The board I chose has wired Ethernet and **no Wi-Fi**. Nothing says whether the new office has network sockets at the desks.
- **Headsets and webcams** for the sales manager's video calls.
- **Backups.** The accountant's data needs a second copy somewhere. Nothing says whether the company already has a server or cloud storage.
- **Assembly, delivery, warranty.** Building the machines takes someone's time, and a self-built PC has a warranty on each part, not on the whole computer.
- **"A few years" has no number.** I read it as **4–5 years**, the usual life of an office PC.

**What I would ask Daniyar, and what I assumed instead**

| Question I would ask | What I assumed |
|---|---|
| Does "3,000,000 for everything" include Windows, keyboards, mice and assembly? | Yes, all of it is inside the 3,000,000. Assembly I do myself, and the unspent 274,241 KZT covers delivery or a paid assembly if needed. |
| How many years is "a few"? | 4–5 years. That is why every machine has room to add memory and a second SSD. |
| Which programs does each person use? Is 1C used? | 1C:Accounting on Windows for the accountant; a browser CRM and Zoom/Meet for sales; VS Code + Docker + several browsers for the developer; Adobe Photoshop/Illustrator plus light Premiere video for the designer. |
| Does the developer need Linux, or is Windows fine? | Windows 11 Pro with WSL2 for Docker, so all four machines run the same OS. The developer can still test in Edge, which a Linux machine could not do. |
| Is the designer's work for print or for screens? Any video? | Both, mostly still images, plus short 1080p video for social media. Colour accuracy matters more than raw speed. |
| Are there network sockets at the desks, or only Wi-Fi? | Wired Ethernet. A USB Wi-Fi adapter (a few thousand KZT) can be bought later if needed. |
| Do people already have headsets and webcams? Is there a backup server? | The sales manager keeps their own headset. Backups go to whatever storage the first office already uses. Neither is in this budget. |
| Does the company buy from Kaspi.kz, or does it need a supplier who issues invoices with VAT? | Kaspi.kz, because it delivers anywhere in Kazakhstan and shows prices openly. A company may need an invoice from a seller registered for VAT, and that could change the prices. |

## 3. What I did

1. **Roles → loads.** For each person I wrote down what they run, for how long and how much at once, then estimated how much memory, CPU, GPU and screen that takes (the Load and Bottleneck lines in [builds.md](builds.md)).
2. **Loads → bottleneck → where the money goes.** Memory for sales and the developer, the monitor and a UPS for the accountant, the monitor and then memory and a GPU for the designer.
3. **Platform.** I started with AM5 + DDR5 for the longer upgrade path, then priced the memory: on 2026-11-22, 32 GB of DDR5 cost 326,990 KZT and 32 GB of DDR4 cost 137,088–175,990 KZT. I chose Intel LGA1700 + DDR4 (i5-13400 BOX + GIGABYTE B760M DS3H DDR4) for all four machines, and put the difference into memory. The full reasoning and the compatibility checks (socket, memory type, M.2, power) are at the top of [builds.md](builds.md).
4. **Prices.** All of them come from Kaspi.kz, which sells and delivers across Kazakhstan, and were taken on **2026-11-22**. Every part, with its link and date, is in [budget.csv](budget.csv).

| Role | Total, KZT | budget.csv rows |
|---|---|---|
| Accountant | 592,671 | 2–12 |
| Sales manager | 557,085 | 13–22 |
| Web developer | 720,367 | 23–32 |
| Designer | 855,636 | 33–43 |
| **Grand total (monitors, Windows, keyboards and mice included)** | **2,725,759** | 44 |
| Left in the budget | 274,241 | |

### Question 1 — Which machine do I upgrade first, in 18 months, and why?

**The designer's graphics card.** I deliberately bought an RTX 3050 6 GB, an entry-level card, so I could afford the ProArt monitor and 32 GB of memory. If the designer does more video (and companies usually ask for more video over time, not less), the 6 GB of video memory and the 3050's speed will be the first limit, in Premiere previews and exports. The upgrade is an RTX 5060-class card (300,000 KZT today, probably less in 18 months). It drops into the same PCIe x16 slot, and the 550 W supply has enough power for its 145 W. Before buying, I must check that the supply has a PCIe 8-pin cable. The unspent 274,241 KZT is roughly that amount. Second in line is the accountant's memory, from 16 GB to 32 GB: two DIMM slots are free, so it means adding modules, not replacing them.

### Question 2 — The same four as pre-built machines

I priced pre-built system units with the same or similar CPU, memory, SSD and Windows, on the same day and from the same marketplace ([prebuilt.csv](prebuilt.csv)). Monitors, keyboards and the UPS are not included on either side, so the comparison below covers only the system units:

| Role | My build (system unit only) | Pre-built on Kaspi.kz | Difference |
|---|---|---|---|
| Accountant | 425,358 | HP i5-14500 / 16 GB / 1 TB / Win 11 Pro: 891,946 | +466,588 |
| Sales manager | 480,446 | the same HP (but only 16 GB): 891,946 | +411,500, with half the memory |
| Web developer | 617,534 | Tehnicom i5-12400F / RTX 5060 Ti / 64 GB / 1 TB: 1,131,082 | +513,548 (includes a GPU the developer does not need) |
| Designer | 651,446 | GoodGame i5-14400F / RTX 5060 / 32 GB / 1 TB: 677,000 | +25,554, but with a **faster GPU** |
| **Total** | 2,174,784 | 3,591,974 | **+1,417,190** |

**What the company would gain** with pre-built machines: one warranty for the whole computer and one place to send it when it breaks (with my builds, a fault means finding out which part failed first); no assembly time; Windows already installed. With a brand like HP, it also gets business support and parts that are the same across a batch.

**What it would lose:** the money. Pre-built would push the four machines over 3,000,000 KZT before buying a single monitor. It would also lose the choice of parts: the HP has 16 GB and nothing says whether its slots allow 64 GB, gaming integrators choose the cheapest board and power supply without naming them, and the developer's 64 GB system comes with a 5060 Ti nobody needs. And it would lose the upgrade path: a brand-name office PC often has two DIMM slots, a small proprietary power supply and no room for a graphics card.

**My conclusion:** build the accountant, sales and developer machines. For the designer, the GoodGame pre-built is honestly competitive: it costs 25,554 KZT more and has a better GPU. I would still build it, because the pre-built's motherboard and power supply are not named, so I cannot check that it will take the GPU upgrade from question 1 or last five years. But if Daniyar values a single warranty more than that, buying this one machine pre-built is a reasonable choice.

### Question 3 — Who will complain about performance within a month, and about what?

**The designer, about video.** I put the designer's money into the monitor and the memory and took the cheapest RTX card. Photoshop and Illustrator will be fine. But the first time the designer drops 4K phone footage into Premiere for a 60-second social media reel, playback on the timeline will stutter and the export will take several minutes instead of under one, because a 6 GB RTX 3050 is an entry-level card. That is the trade-off I chose, and it is why the GPU is the first upgrade (question 1). Second most likely: the developer, if they run two VMs alongside Docker. 64 GB is a lot, but WSL2 takes half of it by default, so `.wslconfig` will need a memory limit.

## 4. Evidence

| File | What it proves |
|---|---|
| [budget.csv](budget.csv) | Every part with its price in KZT, the Kaspi.kz product link and the date (2026-11-22); a total per role and a grand total of 2,725,759 ≤ 3,000,000 |
| [prebuilt.csv](prebuilt.csv) | Pre-built prices for question 2, with links and the date |
| [builds.md](builds.md) | Load · Bottleneck · Trade-off · Total for each of the four machines, the platform decision and the compatibility checks |
| [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md) | One PCPartPicker list per build. PCPartPicker does not price in tenge; I used it only to check compatibility (socket, memory, M.2) and the estimated power draw |
| [evidence/vendor-quotes/](evidence/vendor-quotes/) | A screenshot of each Kaspi.kz price I used, with the address bar and the taskbar date visible |

## 5. What I would do differently

- **Price the memory before choosing the platform.** I started designing around AM5 + DDR5 and had to throw it away once I saw that 32 GB of DDR5 cost 326,990 KZT. Pricing the most volatile part first would have saved that work.
- **Get a second vendor for every part.** All my prices are from Kaspi.kz because it is one site with clear prices. But a Kaspi price is a marketplace seller's price, and the same 32 GB kit ranged from 137,088 to 233,599 KZT between sellers. A second quote from Shop.kz or White Wind for the expensive parts (memory, monitors, GPU) would make the budget easier to defend and would give a company a seller that issues VAT invoices.
- **Ask about the network before choosing the board.** I picked a board without Wi-Fi to save money and only then noticed that the request says nothing about desk sockets.
