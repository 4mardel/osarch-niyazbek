# Lab 0 — Inventory your own machine

Pair:                     Driver first half:
Machine:
Date: 11.10.2026

## What I did
Ran commands in cmd to see info about CPU, memory, disk, and BIOS.

| What     | Value                                                                   | Where I got it                                                  |
| -------- | --------                                                                | --------                                                        |
| CPU      | 12th Gen Intel(R) Core(TM) i7-12700H  14             20                 | wmic cpu get Name, NumberOfCores, NumberOfLogicalProcessor      |
| Memory   | 8589934592  Controller0-ChannelA-DIMM0  SK Hynix   3200                 | wmic memorychip get Capacity, Speed, DeviceLocator, Manufacturer|
| Disk     | Fixed hard disk media  NVMe WD PC SN560 SDDPNQE-1T00-1002  1024203640320| wmic diskdrive get Model, MediaType, Size                       |

Steps, with commands in code blocks. Not prose about the steps.

```
wmic cpu get Name, NumberOfCores, NumberOfLogicalProcessors
12th Gen Intel(R) Core(TM) i7-12700H  14             20

wmic memorychip get Capacity, Speed, DeviceLocator, Manufacturer
8589934592  Controller0-ChannelA-DIMM0  SK Hynix      3200

wmic diskdrive get Model, MediaType, Size
Fixed hard disk media  NVMe WD PC SN560 SDDPNQE-1T00-1002  1024203640320

systeminfo
Host Name:                 DESKTOP-OL1E58P
OS Name:                   Microsoft Windows 11 Pro
OS Version:                10.0.22000 N/A Build 22000
OS Manufacturer:           Microsoft Corporation
OS Configuration:          Standalone Workstation
OS Build Type:             Multiprocessor Free
```

## Result
I found information on my hardware and firmware; virtualisation is enabled and present

## Evidence

- [evidence/](evidence/cpu.txt) — cpu info
- [evidence/](evidence/memory.txt) — memory info
- [evidence/](evidence/disk.txt) — disk info
