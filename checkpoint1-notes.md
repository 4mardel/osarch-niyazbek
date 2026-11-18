Markdown · checkpoint1-notes.md

# Checkpoint 1 notes (OSArch)

Built from my READMEs: Lab 0, Lab 1, Lab 2, Lab 3, Lab 4, Lab 5, Lab 6 and Ticket 1. Add a section after Ticket 2. Open in the exam: notes and documentation. Closed: messengers and AI. Reasoning counts more than the answer, so always write the path (command, expected, got, concluded).

## 0. My machines (numbers from my own labs)

### Host (Lab 0, Lab 3)

| Item | Value | Source |
| --- | --- | --- |
| Laptop | ASUS TUF Gaming F15 FX507ZV4, Windows 11 Pro (build 22000) | Lab 0 `systeminfo` |
| CPU | 12th Gen Intel Core i7-12700H, 14 cores / 20 threads, about 2300 MHz | Lab 0 `wmic cpu`, Lab 3 `Get-CimInstance` |
| RAM | 2 x 8 GiB (8589934592 B), SK Hynix, DDR4-3200 SO-DIMM (SMBIOS type 26, form factor 12), 16,011 MB total | Lab 0, Lab 3 |
| Disk | NVMe WD PC SN560 1 TB (1,024,203,640,320 B); C: 953.2 GB total | Lab 0, Lab 3 |
| Free disk | 47.3 GB (Lab 0, 11.10), 76.71 GB (Lab 3, 08.11), 82.3 GB (Ticket 1, 01.11, after both VMs) | the number changes: always state the date |
| Firmware | AMI FX507ZV4.323, 29/08/2023 | Lab 0 |
| Virtualization | Enabled (Task Manager); `systeminfo` says a hypervisor has been detected | Lab 0 |
| Hypervisor | VirtualBox 7.2.20 | Lab 1 |

### Guests

|  | lab01-ubuntu | lab02-windows |
| --- | --- | --- |
| OS | Ubuntu Server 26.04.1 LTS | Windows 11 Enterprise evaluation (90 days) |
| vCPU / RAM | 4 / 4 GB (`free -h` shows 3.3 Gi) | 5 / 4 GB |
| Disk | 25 GB dynamic (5.31 GB actual) | 64 GB thin (27.62 GB actual) |
| Firmware | BIOS | UEFI + Secure Boot + vTPM 2.0 |
| Network | NAT Network `NatNetwork` 10.0.2.0/24, 10.0.2.5 (DHCP) | same network, 10.0.2.50 static, gateway 10.0.2.1 |
| Snapshot | `clean-install` | `clean-install` |

Host Wi-Fi at home: 192.168.68.102.

### Lab 2 overcommit experiment (10 GB + 10 GB promised on a 16 GB host)

|  | Before (guests off) | After (both running) |
| --- | --- | --- |
| In use | 10.7 GB | 15.4 GB |
| Available | 4.9 GB | 274 MB |
| Committed / limit | 21.1 / 29.1 GB | 41.1 / 46.3 GB |

Felt: louder fans after about a minute, brief micro-freezes, no hard freeze. Set back to Ubuntu 4 GB + Windows 4 GB. Lesson: my host already uses 10.7 GB with the guests off, so only about 4.9 GB is really free. Do not assume "16 GB minus 8 GB = 8 GB free".

## 1. Task 1: read a specification (25 points)

Questions: can it run two guests, what to upgrade first, how does it compare with my laptop.

Steps, with numbers:

1. **RAM:** available RAM (not total) must cover all guests. Guests: Windows 4 GB + Ubuntu 4 GB = 8 GB. On my laptop: 16 GB total, but 10.7 GB already in use, so about 4.9 GB free: tight.
2. **Disk:** use the **maximum** of thin disks: 64 + 25 = 89 GB, plus room for the host. Compare with free space (my 47.3 GB at Lab 0 would not fit the full 89 GB).
3. **Cores:** each VM at most half of the host's cores (my 14 cores: at most 7 each). Mine use 5 and 4, so 9 of 14.
4. **Virtualization:** CPU feature enabled in firmware. Task Manager → Performance → CPU → Virtualization: Enabled. PowerShell: `(Get-CimInstance Win32_ComputerSystem).HypervisorPresent` (`True` = a hypervisor is running, so virtualization is on). `(Get-CimInstance Win32_Processor).VirtualizationFirmwareEnabled` is only reliable when no hypervisor is running: on my laptop it returned `False` because Windows itself runs on a hypervisor (Lab 0 `systeminfo`: "A hypervisor has been detected"), even though virtualization is on and my VMs run. So `False` there does not mean off. Linux host: `lscpu | grep -i virtualization` or `grep -Ec 'vmx|svm' /proc/cpuinfo` (more than 0 = supported). Inside a guest `lscpu` shows `Hypervisor vendor`, which is not the same thing.
5. **Memory type:** DDR generation must match the board; DIMM (desktop) vs SO-DIMM (laptop); free slots; maximum capacity.
6. **Upgrade first:** the bottleneck for VMs is usually RAM, then storage speed. State the trade-off.
7. **Compare with mine:** line by line from section 0.

Compatibility rules (from Lab 3):

- **Socket:** the processor and board must share it (Ryzen 5 7600 = AM5, i5-13400 = LGA1700).
- **Memory:** the processor's controller and the board's slots decide. Ryzen 7600 + ASUS PRIME B650M-A = DDR5 only. i5-13400 can do DDR5 or DDR4, but the MSI PRO B760M-A WIFI DDR4 board has DDR4 slots only.
- **Speed:** rated speed above the platform's listed speed needs a profile (EXPO or XMP) and may still run lower (DDR5-5600 module vs DDR5-5200 listed by AMD).
- **BIOS:** a board may need a BIOS update to support a processor (ASUS lists the 7600 as validated since BIOS 0602).
- **Storage:** M.2 NVMe uses an M.2 slot (no cables). A 2.5-inch SATA SSD needs a SATA port, a data cable and a power cable. SATA tops out at about 550 MB/s.
- **Power supply:** one 24-pin cable powers one motherboard, so two computers need two supplies. Check the CPU 8-pin and SATA connectors.
- **Cooler:** boxed Ryzen 7600 ships with the Wraith Stealth, boxed i5-13400 with the Laminar RM1. "PCG 2020C" is a thermal class, not a cooler.
- **Graphics:** both processors have built-in graphics, so no graphics card is needed for these builds.
- **Case:** micro-ATX boards need a micro-ATX case.

## 2. Task 2: build and justify on Ubuntu (30 points)

Write: what I changed, why this option, the trade-off, and **proof as command output**.

### A. Add a disk (Lab 4)

VM off → Settings → Storage → SATA controller → add hard disk (VDI, dynamically allocated). Attach it on the **same controller** as the system disk, or the guest does not see it.

```
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS     # new disk has no partitions; system disk has /
sudo parted -s /dev/sdX mklabel gpt mkpart primary 1MiB 100%
sudo mkfs.ext4 /dev/sdX1
sudo mkdir -p /mnt/data
sudo mount /dev/sdX1 /mnt/data
sudo chown $USER: /mnt/data
df -h /mnt/data                                # proof
```

Survive a reboot: `sudo blkid /dev/sdX1`, add `UUID=<uuid> /mnt/data ext4 defaults 0 2` to `/etc/fstab`, test with `sudo mount -a`. Never name the system disk (my `sda`).

### B. Snapshot and rollback (Lab 1)

What I did in Lab 1: took snapshot `clean-install`, then broke the guest:

```
cat /etc/hostname
sudo rm /etc/hostname
cat /etc/hostname        # file missing
sudo reboot
```

Then shut down and restored `clean-install`; `cat /etc/hostname` showed the hostname again. VirtualBox: Snapshots → Take; Restore with the VM off. Why: the answer to "without breaking anything". Trade-off: grows over time, not a backup.

### C. VM resources (Lab 1, Lab 2)

VM off → Settings → System: memory and processors. Justify with numbers like in Lab 1: 16 GB host, 4 GB guest leaves 12 GB; 14 cores host, 4 vCPU leaves 10. Never more than half the host's cores per VM; the sum of guest RAM must leave room for the host (my host already uses 10.7 GB). Proof inside the guest: `free -h`, `nproc` or `lscpu`.

## 3. Task 3: diagnose (45 points). Work in layers

Write every step as: **command · what I expected · what I got · what I concluded**. Include a dead end. Check addressing first, then the gateway, then the internet by IP, then DNS.

| Step | Linux | Windows | What it tells me |
| --- | --- | --- | --- |
| 1 Address | `ip -br a` | `ipconfig` | `169.254.x.x` or no IPv4 means DHCP failed |
| 2 Gateway | `ping -c 4 10.0.2.1` | `ping 10.0.2.1` | layers 1 and 2 OK |
| 3 Internet by IP | `ping -c 4 8.8.8.8` | `ping 8.8.8.8` | routing out OK |
| 4 DNS | `ping -c 4 ubuntu.com` | `ping ubuntu.com` | fails while 3 works = DNS |
| 5 Route and neighbours | `ip route`, `ip neigh` | `arp -a`, `Get-NetRoute` | default route, who answers on layer 2 |
| 6 Firewall | `sudo ufw status` | `Get-NetFirewallRule`, `Get-NetConnectionProfile` | blocked ICMP or ports |

| Symptom | Cause | Fix |
| --- | --- | --- |
| Windows has only `fe80::` or `169.254.x.x`, `ipconfig /renew` fails | no DHCP answer on the NAT Network | full shutdown and restart; or static `New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.2.50 -PrefixLength 24 -DefaultGateway 10.0.2.1` |
| `ping 8.8.8.8` works, `ping ubuntu.com` fails | no DNS server | `Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 8.8.8.8,1.1.1.1` (Linux: `sudo resolvectl dns enp0s3 8.8.8.8`) |
| Linux pings Windows: 100% loss; Windows pings Linux: works | Windows Defender Firewall blocks inbound ICMP echo (profile Public) | `New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow -Profile Any`. Never switch the firewall off. Check one rule exists (I created it 3 times once) |
| First pings show "General failure" then one reply | ARP resolution | ping again |
| `ping -c 10.0.2.3`: invalid argument | `-c` needs a count | `ping -c 4 10.0.2.3` |
| `ssh: Connection refused` on 127.0.0.1:2222 | port-forward rule not active | add NAT Network port forward 2222 → 10.0.2.5:22, restart the VMs |
| `Connection reset` | rule works, SSH server not running | install and start it (below) |
| `Unit ssh.service could not be found` | openssh-server not installed | `sudo apt install openssh-server`, `sudo systemctl enable --now ssh`, check `systemctl status ssh.socket` |
| `dhclient: command not found` | Ubuntu Server uses netplan | `sudo netplan apply` |
| The two guests cannot see each other | plain NAT (each VM has its own router) or different networks | both on the same NAT Network |
| Bridged guest gets no address | campus network drops unknown MACs | NAT Network |
| Ubuntu kept the old address after a network change | address is given at boot | `sudo netplan apply` or `sudo reboot` |
| New disk not in `lsblk` | added while running, or created but not attached to the controller | shut down, attach on the same controller as the system disk, start |
| `grep` says "binary file matches" | stray non-printable byte | `grep -a`, or clean with `tr -cd '\11\12\40-\176'` |
| Website error 429 | rate limiting (too many requests) | wait, retry once |
| `Initialize-Disk` says already initialised | disk was initialised before | skip to `New-Partition` |
| Windows disk Offline or read-only |  | `Set-Disk -Number 1 -IsOffline $false`, `Set-Disk -Number 1 -IsReadOnly $false` |

### Storage and RAID (Lab 4)

| Step | Command |
| --- | --- |
| Layout | `lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS` |
| Partition for RAID | `sudo parted -s /dev/sdX mklabel gpt mkpart primary 1MiB 100% set 1 raid on` |
| Create mirror (2 disks) | `sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1` |
| File system on the **array** | `sudo mkfs.ext4 -L mirror /dev/md0` (not on one partition) |
| State | `cat /proc/mdstat`, `sudo mdadm --detail /dev/md0` |
| Fail and remove | `sudo mdadm /dev/md0 --fail /dev/sdc1`, then `--remove /dev/sdc1` |
| Add a replacement | `sudo mdadm /dev/md0 --add /dev/sdd1` |
| Keep after reboot | `sudo mdadm --detail --scan \| sudo tee -a /etc/mdadm/mdadm.conf`, `sudo update-initramfs -u` |
| Proof data survived | `sha256sum` before and after, `diff` the sums |

States I recorded: `[2/2] [UU]` healthy, `[2/1] [U_]` degraded (`State : clean, degraded`, one slot `removed`), `[2/2] [UU]` rebuilt with `sdd1` instead of `sdc1`. `md127` after reboot: config not saved. "wrong fs type": I formatted a partition, not `/dev/md0`. "Device or resource busy": still mounted or in an old array: `sudo umount`, `sudo mdadm --stop /dev/md0`. `mdadm: command not found`: `sudo apt install -y mdadm`. RAID is not a backup: it mirrors every write, so a deleted file is deleted on both disks. RAID protects against a dead disk, a backup against mistakes.

### Windows disk (Lab 4)

```
Get-Disk
Initialize-Disk -Number 1 -PartitionStyle GPT          # check the number first, never disk 0
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel LAB04
Get-Volume | Where FileSystemLabel -eq 'LAB04'
```

My result: disk 1, GPT, 1073741824 B, drive E:, NTFS, label LAB04. MBR vs GPT: MBR has one copy of the table, no checksum, max 2 TiB, 4 primary partitions. GPT has a backup copy and checksums; Windows 11 boots with UEFI/GPT.

### Encodings (Lab 5)

My file `staff-broken.csv`: **KZ-1048 (iconv `RK1048`), CRLF, no BOM, separator `;`**. Russian read fine but every Kazakh letter was wrong (`Ә` showed as `Ј`, `Қ` as `Ќ`, `Ұ` as `ў`, `Ө` as `Ґ`).

| Step | Command | What to read |
| --- | --- | --- |
| Guess the type | `file f.csv` | `Non-ISO extended-ASCII text, with CRLF line terminators` = one byte per letter, some legacy code page (`file` cannot say which); `UTF-8 Unicode (with BOM)`; `UTF-16 LE` |
| Bytes | `xxd f.csv \| head -n 8` | first bytes: `EF BB BF` UTF-8 BOM, `FF FE` UTF-16 LE, `49 44` ("ID") = no BOM. Line end `0D 0A` = CRLF, `0A` = LF |
| Which code page | `iconv -f WINDOWS-1251 -t UTF-8 f.csv \| head` and `iconv -f RK1048 -t UTF-8 f.csv \| head` | the one where **every** name reads correctly wins |
| List names | `iconv -l \| grep -i 1048` | KZ-1048 is `RK1048` or `STRK1048-2002` in iconv |
| Locale | `locale` | `LANG=...UTF-8` = terminal expects UTF-8 |

Bytes to remember:

- UTF-8 Cyrillic = 2 bytes, first `D0`/`D1` (`Ф` = `D0 A4`). UTF-16 LE: second byte `04`. Code page (Windows-1251, KZ-1048, KOI8-R) = 1 byte `C0`-`FF`.
- Windows-1251: `А`=`C0`, `а`=`E0`, `Я`=`DF`, `я`=`FF`. KOI8-R: `а`=`C1`, `б`=`C2` (different order).
- Kazakh letters are not in Windows-1251. In KZ-1048: `Ә`=`A3`, `ә`=`BC`, `Қ`=`8D`, `қ`=`9D`. My proof: line 2 starts `31 30 31 3B A3 ...` = `101;Ә...`; `A3` is `Ә` in KZ-1048 and `Ј` in Windows-1251. Russian correct but Kazakh wrong = a code page that is *almost* Windows-1251.

My fix (`scripts/fix.sh`): `{ printf '\357\273\277'; iconv -f RK1048 -t UTF-8 in.csv | tr ';' ','; } > out.csv`.

- **BOM added** because Excel on Windows only recognises UTF-8 on double-click with `EF BB BF`; without it Excel reads the ANSI code page and garbles. Cost: a script may see `\ufeffID` in the first header (strip with `sed '1s/^\xEF\xBB\xBF//'`).
- **CRLF kept** (file is for Windows/Excel; LF would be for Linux scripts: CRLF causes `$'\r': command not found`, `^M` in `cat -A`; fix `sed -i 's/\r$//'` or `dos2unix`).
- **Separator `;` to `,`**: Excel splits by the Windows list separator, which is `,` on my en-GB profile. Safe only if no field contains a comma (the script checks).
- Verified: `file` says `UTF-8 (with BOM)`, Cyrillic is `D0 xx`/`D1 xx`, 16 CR bytes (`tr -cd '\r' < f \| wc -c`), file ends `0D 0A`, and the file reads correctly in Excel, LibreOffice Calc (Character set UTF-8, separator comma) and `cat`.

What went wrong, and what it teaches:

| Symptom | Cause | Fix |
| --- | --- | --- |
| Everything in one column in Excel, but letters correct | separator, not encoding (Excel uses the Windows list separator) | change the separator, or Data > From Text/CSV and choose the delimiter |
| `sep=;` as first line: columns split but text became `Р¤Р°РјРёР»РёСЏ` | `sep=` makes Excel ignore the BOM and read Windows-1251 | do not combine `sep=` with a BOM; swap the separator instead |
| Russian fine, Kazakh wrong (`Ј`, `Ќ`, `ў`, `Ґ`) | decoded as Windows-1251, file is KZ-1048 | `iconv -f RK1048` |
| `iconv: illegal input sequence at position N` | wrong source encoding named | `xxd -s N -l 16 file` and look at the bytes |
| `conversion from 'KZ-1048' is not supported` | iconv name is different | use `RK1048`; `iconv -l \| grep -i 1048` |
| First header shows `ï»¿ID` | UTF-8 BOM read by a program that does not expect it | keep it for Excel or remove it for scripts, and say why |
| PowerShell `Out-File` made a UTF-16 file | PowerShell 5.1 default | always add `-Encoding utf8` |
| LibreOffice opened the CSV in Writer, no import dialog | opened from Start Center / double-click | open from inside Calc: File > Open |
| .NET cannot do KZ-1048 | `GetEncoding` has no KZ-1048 | use `iconv` (Git Bash or Ubuntu) |

Exam logic for an encoding case: ask what one Kazakh letter looks like in the bytes (1 byte or 2), then check BOM, then line ending, then separator, then try the candidate decodings and see which one makes *all* names correct. "It was an encoding problem" earns nothing; name it with the bytes.

### Processes and memory pressure (Lab 6)

My process: `python -m http.server 8000` on both guests (VBoxService exists only on Windows). Windows: PID 9784, parent powershell.exe (5252). Ubuntu: PID 4489, parent -bash (1596).

|  | Task Manager | Process Explorer | htop / ps |
| --- | --- | --- | --- |
| Default "memory" | Memory (private working set) 12,280 K | Working Set 24,040 K | RES 22,520 K |
| Private memory | Commit size 14,004 K | Private Bytes 14,004 K, WS Private 12,252 K | no column |
| Virtual size | not shown | not added | VIRT / vsz 35,404 K |
| Handles / FDs | 156 | 156 | 4 file descriptors |
| Parent | not shown | tree, Image tab | tree, PPID column |

Why the tools disagree:

- Task Manager's Memory is the **private working set**, Process Explorer's default is the **Working Set** (includes shared DLL pages), htop's **RES** includes shared libraries (SHR). Different numbers for different things.
- **Commit size = Private Bytes** (same number, different names). htop has no column for it.
- **VIRT** is the whole address space, not memory in use.
- Windows **handles** count every kernel object (files, registry keys, mutexes, threads). A Linux **file descriptor** is only a file or socket (mine: 0, 1, 2 = terminal, 3 = socket).
- CPU%: Task Manager counts the whole machine as 100%, htop counts one core as 100%.
- Commands: `ps -o pid,ppid,user,rss,vsz,nlwp,cmd -p <PID>`, `ls /proc/<PID>/fd | wc -l`, `sudo ls -l /proc/<PID>/fd`. Process Explorer: run as administrator, View > Lower Pane > Handles, Image tab shows parent and command line.

Memory-pressure experiment (Ubuntu guest lowered to 2048 MB, **no swap**, snapshot `before-lab6` first; guest clock is UTC, Almaty is +5):

```
{ echo "=== BEFORE $(date) ==="; free -h; } > memory-pressure.txt
while true; do echo "=== $(date +%T) ==="; free -h; sleep 3; done | tee -a memory-pressure.txt     # second terminal
stress-ng --vm 2 --vm-bytes 70% --timeout 60s      # then 90%, then 120%
journalctl -k --since "30 min ago" | grep -i -E -B3 -A8 "out of memory|oom-kill"
```

|  | Before | Worst | After |
| --- | --- | --- | --- |
| Available | 1.2 Gi | 34 Mi (120% run, 14:57:56) | 1.2 Gi |
| Swap used | 0 | 0 (no swap exists) | 0 |

- `--vm-bytes 70%` is 70% of the **available** memory, not of total RAM (897 MB at the start).
- 90%: finished in 1 min 38 s instead of 60 s, recording went silent 80 s (guest stalled, thrashing), nothing killed.
- 120%: the kernel killed `stress-ng-vm` PID 2389 at 14:58:22 UTC: `Out of memory: Killed process 2389 (stress-ng-vm) total-vm:797984kB, anon-rss:730724kB`, then `watchdog: BUG: soft lockup - CPU#2 stuck for 37s`.
- Why that process: largest memory use (anon-rss about 715 MB) and stress-ng sets `oom_score_adj=1000`, so it is the preferred victim.
- stress-ng still said `passed: 2, failed: 0` because it restarts killed workers: the **kernel log is the proof**, not the tool's own summary.
- Linux OOM killer **kills** a process. Windows does not: it warns, allocations fail, and System event **2004** (source Resource-Exhaustion-Detector) names the top memory users. `Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Resource-Exhaustion-Detector'} -MaxEvents 5` returned "No events were found" on my guest: valid, it never ran low.
- Thrashing signs: `vmstat 2 3` with `si`/`so` (swap in/out) above 0, high `wa`, `r` larger than the CPU count, `available` near 0, and the guest not answering. With no swap the kernel can only drop `buff/cache` (mine fell from 480 Mi to 59 Mi) before it kills.

What went wrong: Python missing on Windows (Store alias, new PowerShell window needed after `winget install`); `scp` with two remote files fails ("filename does not match request"), copy one at a time.

## 4. Cheat sheet

| Fact | Windows (PowerShell) | Linux |
| --- | --- | --- |
| CPU | `Get-CimInstance Win32_Processor` | `lscpu` |
| Memory | `Get-CimInstance Win32_PhysicalMemory` | `free -h`, `sudo dmidecode -t memory` |
| Disks | `Get-PhysicalDisk`, `Get-Disk` | `lsblk -d -o NAME,MODEL,ROTA,TRAN,SIZE` |
| Free space | `Get-Volume C` | `df -h /` |
| Architecture | `$env:PROCESSOR_ARCHITECTURE` (AMD64) | `uname -m` (x86_64) |
| Virtualization enabled | `(Get-CimInstance Win32_ComputerSystem).HypervisorPresent` (True = on; the Processor property gave False on my laptop) | `lscpu \| grep -i virtualization` |
| OS version | `systeminfo` | `uname -a`, `lsb_release -a` |
| Address | `ipconfig` | `ip -br a` |

What the VM hides (Lab 3): Linux in the guest shows the real CPU model name but only the 4 CPUs I assigned (1 thread per core), only 3.3 GiB of RAM, no memory modules in `dmidecode` (only "SMBIOS 2.5 present."), and a virtual disk (`sda`, `VBOX HARDDISK`, `sata`, `ROTA 1`) instead of my NVMe SSD. Hypervisor line in `lscpu`: `KVM`, `full`. Windows on the host sees the real hardware: 14 cores / 20 threads, two 8 GiB DDR4-3200 modules, the NVMe disk (BusType shown as RAID).

## 5. Commands you will see (the official sheet handed out on the day)

What each command or setting in the case sheets shows, and what "normal" looks like. Reason with them, do not memorise.

### Network: Linux

| Command | What it shows / normal |
| --- | --- |
| `ping -c 3 <address>` | 3 test packets. `0% packet loss` = the other side answers. `time` about 1 ms between two VMs. `ttl=64` = answer from Linux, `ttl=128` = from Windows |
| `ip -br addr` | addresses. Look at `enp0s3`: `UP` and an address like `10.0.2.x/24` |
| `ip route` | where packets go. `default via 10.0.2.1` = the gateway to the internet |

### Network: Windows and VirtualBox

| Command / setting | What it shows / normal |
| --- | --- |
| `ipconfig` | IPv4 address, mask, default gateway |
| `ping -n 2 <address>` | Windows ping. `Reply from ...` = answered |
| `Get-NetFirewallProfile` | firewall on for Domain / Private / Public. On (`True`) is normal |
| `Get-NetFirewallRule -DisplayName "..."` | one rule: Enabled, Direction (Inbound/Outbound), Action (Allow/Block). Error "No ... objects found" = no such rule |
| `New-NetFirewallRule ...` | creates a rule (Lab 2: "Allow ping in (ICMPv4)") |
| VirtualBox, Settings, Network | **NAT**: each VM alone behind its own router, gateway `10.0.2.2`. **NAT Network**: VMs share one network, gateway `10.0.2.1`. Bridged. Host-only (Lab 2). Advanced has **Cable Connected** |
| VirtualBox, Snapshots | saved states. "Restored from ..." = the VM went back to that moment, anything done after it is gone |

### Machine resources

| Command / setting | What it shows / normal |
| --- | --- |
| `nproc` | how many CPUs this machine (the VM) sees |
| `free -h` | memory. `available` = what programs can still get. Swap = disk used as extra memory (slow). `0B` total = no swap |
| `uptime` | last 3 numbers = load average (1, 5, 15 min) = tasks wanting a CPU. Load about equal to the number of CPUs = busy, much more = tasks waiting |
| `vmstat 2 3` | every 2 s: `r` tasks waiting for CPU, `si`/`so` pages swapped in/out per second (should be about 0), `us`/`sy` CPU busy %, `id` idle %, `wa` waiting for disk % |
| `ps -eo pid,user,rss,comm --sort=-rss` | processes sorted by memory. RSS in KB (1 000 000 KB is about 1 GB) |
| `swapon --show` | active swap areas. No output = swap is off |
| Task Manager, Performance | Memory: In use, Available, Committed (promised / limit), Installed. CPU: cores, logical processors, Virtualization. Disk: Active time 100% = disk is the bottleneck |
| VirtualBox, Settings, System | Base Memory (MB) and Processors given to the VM. Motherboard: Enable EFI, Enable Secure Boot, TPM version. General, Version sets the defaults for that OS |

### Services and logs

| Command | What it shows / normal |
| --- | --- |
| `systemctl status <name>` | `Active: active (running)` / `inactive` / `failed`, and why, e.g. `Result: oom-kill` |
| `journalctl -k` | kernel messages (Lab 6). `Out of memory: Killed process ...` = the OOM killer stopped that process |
| `history` | commands typed earlier in this shell, numbered |

### Disks

| Command / file | What it shows / normal |
| --- | --- |
| `df -h` | mounted file systems: size, used, available, Use%, where mounted |
| `lsblk` | all disks and partitions (`sda`, `sdb1`...), size, file system, MOUNTPOINTS (empty = not mounted) |
| `findmnt /data` | what is mounted at `/data`. No output = nothing |
| `sudo blkid` | each partition's UUID and file system type |
| `/etc/fstab` | file systems mounted at every boot, one per line: `UUID=... /mountpoint ext4 defaults 0 2`. `mount` by hand lasts only until reboot. `sudo mount -a` mounts everything in fstab (no output = OK) |
| VirtualBox, Settings, Storage | virtual disks (`.vdi`) attached to the VM and their sizes; the optical drive (`.iso`) |

### Text and encodings (Lab 5)

| Command | What it shows / normal |
| --- | --- |
| `file <name>` | guesses the type: "UTF-8 text", "ISO-8859 text" (= some one-byte encoding, not necessarily Latin-1), "with CRLF line terminators" (= Windows line ends) |
| `xxd <name> \| head` | the bytes in hex. In UTF-8 a Cyrillic letter is 2 bytes (`d0..`/`d1..`), in CP1251 it is 1 byte (`c0`-`ff`) |
| `iconv -f FROM -t TO` | converts between encodings, e.g. `-f CP1251 -t UTF-8` |
| `locale` | `LANG=...UTF-8` = the terminal expects UTF-8 |

### Reading a case in 25 minutes

2 min read the ticket and pick the layer (network, disk, memory/CPU, VM settings, data). 5 min read all evidence once and mark which E belong. 12 min write the table (E# | what it shows, quoted | what I conclude / rule out | next). 6 min ignored evidence, missing evidence (one more command and the output I expect), root cause, fix, verification with expected output (also after a reboot). Practice Case 0 (no internet): `Network is unreachable`, `enp0s3 DOWN`, no route, `NO-CARRIER`, **Cable Connected unticked** in VirtualBox.

## 6. Sections to add later

- Ticket 2 (office spec): method for sizing a machine