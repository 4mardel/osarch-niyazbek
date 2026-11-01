# Ticket 1 — New developer starts Monday, needs a test machine

## 1. What was asked

> From: Aigerim T. (Office Manager)
> Subject: test machine for new dev
>
> Hi, we have someone starting on Monday and he needs a test computer
> set up. Nothing special, just so he can try things without breaking
> anything. Can you write down how to do it so I can do the next one
> myself? Thanks

## 2. What was actually needed

**What the request left out, what I would have asked, what I assumed instead**

| Gap in the request | What I would ask Aigerim | What I assumed |
|---|---|---|
| "Test computer": a physical computer or a virtual one? | Does she need new hardware, or can the test machine live on a computer she already has? | A virtual machine on her existing laptop. It is free, takes minutes to reset and can be repeated by a non-IT person. |
| Which operating systems? "Nothing special" does not say. | What will she build and test? | Both Linux (Ubuntu Server) and Windows 11, because a developer testing software needs to try it on both, and Aigerim cannot judge this herself. |
| How much memory and disk does the developer's computer have? | What laptop does she have? | 16 GB RAM and 14 cores (Lab 0 numbers). Disk: 82.3 GB free on 01.11.2026, measured after both VMs were created. The two disks use 5.31 GB + 27.62 GB = 32.93 GB so far, so about 115.23 GB was free before. The guide's 100 GB minimum is the maximum size the two thin disks can reach (64 + 25 = 89 GB) plus room for the host. |
| Does it need the internet? Must the two machines see each other? | — | Both, because installing packages and testing software needs the internet, and testing a client against a server needs the two machines to talk. This decides the network mode. |
| Which hypervisor, which licence? Will anything cost money? | Is there a budget? | VirtualBox 7 without the Extension Pack (free for company use) and the free 90-day Windows 11 evaluation, so Aigerim cannot buy anything by mistake. |

**Where the request is wrong or too simple**

1. **"Without breaking anything" is not what a VM guarantees.** A VM protects the host computer's files and system from what happens inside the guest, but nothing stops the developer from breaking the VM itself. The real protection is a snapshot: a clean one is taken after installation, and going back takes a minute. That is why snapshots are a numbered step in BUILD.md. Isolation also weakens if shared folders or shared clipboard are switched on, so BUILD.md does not enable them.
2. **"Nothing special" hides an expiry date.** The free Windows evaluation works for 90 days. A developer's test machine will probably be needed for longer, so BUILD.md says what happens after 90 days and that the office has to decide: buy a licence, or rebuild with a fresh evaluation.
3. **"So I can do the next one myself" is the real deliverable.** The machine is a one-off; the document is the product. The reader is not an IT person, so every step has one action, a reason, and a way to check it worked. I wrote the troubleshooting table from problems that actually happened to me.

**Resource calculation (host: 16 GB RAM, 115 GB free disk, 14 cores)**

- RAM: Windows 4 GB + Ubuntu 4 GB = 8 GB for the guests. The host and its own programs need about 6 GB. 16 − 8 leaves 8 GB headroom.
- Disk: Windows 64 GB + Ubuntu 25 GB = 89 GB maximum. The disks are thin, so at first they use far less (32.93 GB after installation). The host needs 100 GB free to be safe.
- CPU: 5 vCPU for Windows and 4 for Ubuntu, no more than half of the host's 14 cores per machine.

## 3. What I did

1. Wrote BUILD.md from my notes, screenshots and commands from Lab 1 and Lab 2. I did not reinstall the guests while writing it, so BUILD.md is not yet tested from start to finish. The week 5 peer review is its first full test, and I will fix the first step where the reviewer gets stuck.
2. Wrote BUILD.md for a non-technical reader: 32 numbered steps, a screenshot and a reason for each choice, checks, and a troubleshooting table.
3. Chose **NAT Network** (`NatNetwork`, 10.0.2.0/24) for both guests. Alternatives rejected: plain NAT (each guest gets its own private router, so they cannot see each other), bridged (the campus network may drop unknown MAC addresses), host-only (no internet).
4. Allowed ping on Windows with one rule, and kept the firewall on:
   ```
   New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow -Profile Any
   ```
5. Took a `clean-install` snapshot of both guests.

**Settings that differ from the default**

| Setting | Default | Mine | Why |
|---|---|---|---|
| Windows memory / CPU | 4096 MB / 2 | 4096 MB / 5 | No more than half of the host's cores |
| Ubuntu memory / CPU | 2048 MB / 1> | 2048-4096 MB / 2 | It runs more smoothly |
| OpenSSH server | off | on | Lets me copy command output out of the guest as text |
| Windows firewall | on | on, plus one rule allowing ping | The rule allows only ICMP echo; switching the firewall off would leave the whole machine open |
| Windows address | DHCP | static 10.0.2.50/24 | See "What went wrong" |

**What went wrong, and how I fixed it**

After Windows was installed it had no IPv4 address: `ipconfig` showed only an IPv6 link-local address, and `ipconfig /renew` failed with "An operation was attempted on a nonexistent network connection". The VirtualBox settings were correct. `<what fixed it: e.g. full shutdown and restart>` gave it `10.0.2.3`.
Later it lost the address again and fell back to `169.254.129.232`, so Windows → Ubuntu ping failed with 100% loss. I used `ip neigh`, `arp -a` and `tcpdump` on Ubuntu to check what was and was not arriving, found the wrong address, and gave Windows a static `10.0.2.50/24` with gateway `10.0.2.1` and DNS `8.8.8.8`. Both directions and the internet then worked.
Two smaller problems: `ping ubuntu.com` failed while `ping 8.8.8.8` worked (no DNS; fixed with `Set-DnsClientServerAddress`), and Ubuntu → Windows ping timed out until the firewall rule existed. Both are in the troubleshooting table in BUILD.md.

## 4. Evidence

| File | What it proves |
|---|---|
| [evidence/01-new-vm-wizard.png](evidence/01-new-vm-wizard.png) | The new-VM wizard with my choices (name, ISO, memory, CPU, skip unattended install) |
| [evidence/02-disk-settings.png](evidence/02-disk-settings.png) | The disk is 25/64 GB and thin (not pre-allocated) |
| [evidence/03-network-adapter.png](evidence/03-network-adapter.png) | A guest is on NAT Network `NatNetwork` |
| [evidence/04-guest-uname.txt](evidence/04-guest-uname.txt) | `uname -a` and `lsb_release -a` inside the Linux guest: which system is running |
| [evidence/05-ping-between-guests.txt](evidence/05-ping-between-guests.txt) | Linux → Windows, Windows → Linux, and each guest → the internet, with 0% loss |
| [evidence/06-snapshot-list.png](evidence/06-snapshot-list.png) | The `clean-install` snapshot exists |
| [review/feedback-from-`<surname>`.md](review/) | Peer review (added in week 5) |

## 5. What I would do differently

- I would give Windows a static address in the first place and say so in BUILD.md, because DHCP on the NAT Network failed twice and cost me a lot of time.
- I would give BUILD.md to someone who has not done the labs before writing the screenshots, because I wrote for myself first.
- I would capture command output as text from the start (SSH to the guest), instead of retyping from screenshots.
