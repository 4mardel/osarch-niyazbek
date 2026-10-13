# Lab 0 — Inventory your own machine

Pair: Tamerlan Shakenov                     Driver first half:
Machine: ASUS TUF Gaming F15
Date: 11.10.2026

## What I did
Ran commands in cmd to view CPU, memory, disk, and BIOS info.

| What     | Value                                                                   | Where I got it                                                  |
| -------- | --------                                                                | --------                                                        |
| CPU      | 12th Gen Intel(R) Core(TM) i7-12700H  14             20                 | wmic cpu get Name, NumberOfCores, NumberOfLogicalProcessor      |
| Memory   | 8589934592  Controller0-ChannelA-DIMM0  SK Hynix   3200  x2             | wmic memorychip get Capacity, Speed, DeviceLocator, Manufacturer|
| Disk     | Fixed hard disk media  NVMe WD PC SN560 SDDPNQE-1T00-1002  1024203640320/ Total free bytes:    50,815,713,280 ( 47.3 GB)| wmic diskdrive get Model, MediaType, Size/fsutil volume diskfree C:|

Steps, with commands in code blocks. Not prose about the steps.

```
wmic cpu get Name, NumberOfCores, NumberOfLogicalProcessors
12th Gen Intel(R) Core(TM) i7-12700H  14             20

wmic memorychip get Capacity, Speed, DeviceLocator, Manufacturer
8589934592  Controller0-ChannelA-DIMM0  SK Hynix      3200

fsutil volume diskfree C:
Total free bytes                :    50,815,713,280 ( 47.3 GB)
Total bytes                     : 1,023,454,212,096 (953.2 GB)
Total quota free bytes          :    50,815,713,280 ( 47.3 GB)
Unavailable pool bytes          :                 0 (  0.0 KB)
Quota unavailable pool bytes    :                 0 (  0.0 KB)
Used bytes                      :   972,617,396,224 (905.8 GB)
Total Reserved bytes            :        21,102,592 ( 20.1 MB)
Volume storage reserved bytes   :                 0 (  0.0 KB)
Available committed bytes       :                 0 (  0.0 KB)
Pool available bytes            :                 0 (  0.0 KB)

wmic diskdrive get Model, MediaType, Size
Fixed hard disk media  NVMe WD PC SN560 SDDPNQE-1T00-1002  1024203640320

systeminfo
Host Name:                 DESKTOP-OL1E58P
OS Name:                   Microsoft Windows 11 Pro
OS Version:                10.0.22000 N/A Build 22000
OS Manufacturer:           Microsoft Corporation
OS Configuration:          Standalone Workstation
OS Build Type:             Multiprocessor Free
Registered Owner:          ASUS
Registered Organization:
Product ID:                00330-80000-00000-AA118
Original Install Date:     05/09/2023, 13:44:00
System Boot Time:          22/09/2026, 19:20:41
System Manufacturer:       ASUSTeK COMPUTER INC.
System Model:              ASUS TUF Gaming F15 FX507ZV4_FX507ZV4
System Type:               x64-based PC
Processor(s):              1 Processor(s) Installed.
                           [01]: Intel64 Family 6 Model 154 Stepping 3 GenuineIntel ~2300 Mhz
BIOS Version:              American Megatrends International, LLC. FX507ZV4.323, 29/08/2023
Windows Directory:         C:\Windows
System Directory:          C:\Windows\system32
Boot Device:               \Device\HarddiskVolume1
System Locale:             ru;Russian
Input Locale:              ru;Russian
Time Zone:                 (UTC+05:00) Qyzylorda
Total Physical Memory:     16,011 MB
Available Physical Memory: 3,694 MB
Virtual Memory: Max Size:  29,835 MB
Virtual Memory: Available: 10,414 MB
Virtual Memory: In Use:    19,421 MB
Page File Location(s):     C:\pagefile.sys
Domain:                    WORKGROUP
Logon Server:              \\DESKTOP-OL1E58P
Hotfix(s):                 7 Hotfix(s) Installed.
                           [01]: KB5030650
                           [02]: KB5029715
                           [03]: KB5011048
                           [04]: KB5011069
                           [05]: KB5014869
                           [06]: KB5031358
                           [07]: KB5031591
Hyper-V Requirements:      A hypervisor has been detected. Features required for Hyper-V will not be displayed.Host Name:                 DESKTOP-OL1E58P
```

## Result
I found information on my hardware and firmware; virtualisation is enabled and present

## Evidence

- [evidence/](evidence/cpu.txt) — cpu info
- [evidence/](evidence/memory.txt) — memory info
- [evidence/](evidence/disk.txt) — disk info
