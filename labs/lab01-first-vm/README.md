# Lab 1 — Your first virtual machine

Machine: ASUS TUF Gaming F15 Windows 11, guest Ubuntu Server 26.04.1 LTS
Date: 19.10.26

## What I did
1. Installed VirtualBox-7.2.20. Licence: https://www.virtualbox.org/wiki/VirtualBox_PUEL
2. Created VM lab01-ubuntu: 4 vCPU, 4 GB RAM, 25 GB dynamic disk, NAT.
3. Installed Ubuntu Server, took snapshot clean-install.
4. Broke it: cat /etc/hostname
sudo rm /etc/hostname
cat /etc/hostname
sudo reboot
5. Rolled back to clean-install: hostname

## Resource justification
Allocating 4 CPU cores and 4 GB of RAM to the virtual machine strikes an optimal balance between guest performance and host system stability. On a host machine equipped with 14 CPU cores and 16 GB of RAM, dedicating 4 GB of memory leaves 12 GB available for host operations, background services, and local applications without triggering performance-degrading memory swapping. Similarly, assigning 4 CPU cores provides ample multi-threading capacity for workloads inside the guest environment while reserving 10 cores to maintain full host OS responsiveness and smooth overall multitasking.

## Result
The VM boots; the break-and-rollback cycle is shown in the evidence below.

## What did not work the first time
It was hard to know exactly how much resources I needed for the virtual machine.

## Evidence
- [evidence/vm-settings.png](evidence/vm-settings.png) — CPU, memory and disk as configured
- [evidence/guest-release.txt](evidence/guest-release.txt) — Ubuntu Server is running in the guest
- [evidence/broken.png](evidence/broken.png) — the guest in its broken state
- [evidence/snapshot-list.png](evidence/snapshot-list.png) — the snapshot, after the rollback
