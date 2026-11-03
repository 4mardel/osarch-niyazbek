# Lab 2 — A Windows guest, and a network between them

Machine: ASUS TUF Gaming F15, Windows 11, 16GB, 14 cores, guests Ubuntu Server + Windows 11 Enterprise eval
Date: 31.10.26

## What I did
1. Downloaded Windows 11 Enterprise evaluation. Licence: https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise
2. Created lab02-windows: 5 vCPU, 4 GB, 64 GB thin, UEFI + Secure Boot, vTPM.
3. Network mode: NAT Network (`NatNetwork`, 10.0.2.0/24), both guests. Why: both guests must see each other and the internet. Plain NAT gives each VM its own private router, so they could not see each other, and host-only has no internet. Bridged mode is often blocked on campus Wi-Fi.
4. Ping Ubuntu → Windows timed out because Windows Defender Firewall blocks incoming ICMP echo requests by default, and the network profile was Public (the strictest). Fixed with: `New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow -Profile Any` (the firewall stays on). Windows also lost its DHCP lease (fell back to 169.254.129.232), so I gave it a static address, 10.0.2.50/24, gateway 10.0.2.1.
5. Overcommitment: set 10 GB + 10 GB on a 16 GB host.
6. Set the memory back after the experiment: Ubuntu 4 GB, Windows 4 GB

## Network diagram

```
                      Internet
                          |
         Host laptop 192.168.68.102 (home Wi-Fi)
                          |
      [VirtualBox NAT Network "NatNetwork" · 10.0.2.0/24]
      NAT: guests go out using the host's address · gateway 10.0.2.1
                 /                          \
        lab01-ubuntu                  lab02-windows
        10.0.2.5 (DHCP)               10.0.2.50 (static)
        Ubuntu Server 25.04           Windows 11 Enterprise eval
```

## Result
| | Before | After |
|---|---|---|
| Host RAM in use | 10.7 GB | 15.4 GB |
| Available | 4.9 GB | 274 MB |
| Committed / Swap used | 21.1/29.1 GB | 41.1/46.3 GB |
| What I noticed | — | Within about a minute of starting both VMs, the laptop fans got noticeably louder. There were no major stutters or freezes, only brief micro-freezes. |

## What did not work the first time
**1. Windows had no IPv4 address.**
Saw: `ipconfig` showed only an IPv6 link-local address and no IPv4 or gateway, and `ipconfig /renew` failed with "An operation was attempted on a nonexistent network connection".
It turned out to be: Windows was not getting an answer from the DHCP server on the NAT Network. The adapter settings (NAT Network `NatNetwork`, cable connected, DHCP enabled) were already correct.
I did: Shut the VM down fully and started it again. After that Windows got 10.0.2.3.

**2. Windows could ping 8.8.8.8 but not ubuntu.com.**
Saw: `ping ubuntu.com` said "could not find host", while `ping 8.8.8.8` worked.
It turned out to be: no DNS server was configured on the Windows adapter, so the internet worked but names did not resolve.
I did: set DNS manually with `Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 8.8.8.8,1.1.1.1`.

**3. Ubuntu → Windows ping timed out.**
Saw: 100% packet loss from Ubuntu to Windows, although the ARP table showed Windows's MAC address, so the guests could see each other.
It turned out to be: Windows Defender Firewall blocks incoming ICMP echo requests by default. My first attempt also created the same rule three times, so I removed the duplicates and created one clean rule with `New-NetFirewallRule`. The firewall stayed on.

**4. Windows lost its address and pings failed in both directions.**
Saw: Windows → Ubuntu went to 100% loss, and `ipconfig` showed `169.254.129.232` instead of 10.0.2.3.
It turned out to be: Windows lost its DHCP lease and gave itself a link-local address, so it was no longer in the 10.0.2.0/24 network.
I did: gave Windows a static address, 10.0.2.50/24 with gateway 10.0.2.1. I used `tcpdump` on Ubuntu to check that echo requests arrived and were answered. After that, both directions and the internet worked.

**5. Smaller mistakes.**
- I typed `ping -c 10.0.2.3` without a count, so ping rejected the argument. The correct form is `ping -c 4 10.0.2.3`.
- `dhclient` does not exist on Ubuntu Server, which uses netplan. I used `sudo netplan apply` instead.
- The first Windows → Ubuntu ping showed "General failure" for three packets before one reply, which was just ARP resolution.

## Evidence
- [evidence/ipconfig-windows.txt](evidence/ipconfig-windows.txt) — Windows address
- [evidence/ip-addr-linux.txt](evidence/ip-addr-linux.txt) — Ubuntu address
- [evidence/ping-both-ways.txt](evidence/ping-both-ways.txt) — both directions and the internet
- [evidence/host-memory-before.png](evidence/host-memory-before.png) — host memory, guests off
- [evidence/host-memory-after.png](evidence/host-memory-after.png) — host memory, both guests overcommitted
