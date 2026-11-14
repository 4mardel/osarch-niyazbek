# Lab 4 — Partition, mirror, fail, recover

Date: 14.11.2026 · Hypervisor: VirtualBox

## Windows
```
PS C:\WINDOWS\system32> Get-Disk | Select Number, FriendlyName, PartitionStyle, Size

Number FriendlyName  PartitionStyle        Size
------ ------------  --------------        ----
     0 VBOX HARDDISK GPT            68719476736
     1 VBOX HARDDISK GPT             1073741824


PS C:\WINDOWS\system32> Get-Volume | Where FileSystemLabel -eq 'LAB04'

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining       Size
----------- ------------ -------------- --------- ------------ ----------------- -------------       ----
E           LAB04        NTFS           Fixed     Healthy      OK                    989.23 MB 1007.93 MB
```
MBR or GPT: GPT. The system disk of this Windows 11 guest is already GPT (Windows 11 boots with UEFI, which uses GPT), so the new disk follows the same standard. GPT also keeps a backup copy of the partition table and checksums it, so damage is detected and repaired, while MBR has a single unprotected copy and is limited to 2 TiB and four primary partitions. For a 1 GB test disk either would work, so the choice is about safety and consistency, not size.

## Linux — layout before and after
### Before

```
$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
NAME    SIZE TYPE FSTYPE   MOUNTPOINTS
loop0  66.8M loop squashfs /snap/core24/1643
loop1   1.5M loop squashfs /snap/hwctl/123
loop2   1.5M loop squashfs /snap/hwctl/131
loop3  50.1M loop squashfs /snap/snapd/27710
sda      25G disk          
├─sda1    1M part          
└─sda2   25G part ext4     /
sdb       1G disk          
sdc       1G disk          
sdd       1G disk          
sr0    50.7M rom  iso9660  

```

### After

```
$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
NAME     SIZE TYPE  FSTYPE            MOUNTPOINTS
loop0   66.8M loop  squashfs          /snap/core24/1643
loop1    1.5M loop  squashfs          /snap/hwctl/123
loop2    1.5M loop  squashfs          /snap/hwctl/131
loop3   50.1M loop  squashfs          /snap/snapd/27710
sda       25G disk                    
├─sda1     1M part                    
└─sda2    25G part  ext4              /
sdb        1G disk                    
└─sdb1  1022M part  linux_raid_member 
  └─md0 1021M raid1 ext4              /mnt/mirror
sdc        1G disk                    
└─sdc1  1022M part  linux_raid_member 
sdd        1G disk                    
└─sdd1  1022M part  linux_raid_member 
  └─md0 1021M raid1 ext4              /mnt/mirror
sr0     50.7M rom   iso9660           
```

md0 is on sdb1 and sdd1, mounted on /mnt/mirror; sdc1 was removed from the array.

## What I did

### 1. Look before touching

I saved the layout first, so I knew which disks were new. The system disk is `sda` (it has the `/` mount point); `sdb`, `sdc` and `sdd` were empty 1 GB disks. Every command below names only those three.

```
mkdir -p ~/lab04/evidence && cd ~/lab04
{ echo '$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS'; lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS; } > evidence/lsblk-before.txt
```

### 2. Create: partition, mirror, file system

One GPT partition on each disk, marked for RAID, so mdadm uses a partition and not a raw disk:

```
for d in sdb sdc sdd; do
  sudo parted -s /dev/$d mklabel gpt mkpart primary 1MiB 100% set 1 raid on
done
sudo apt install -y mdadm
```

The mirror uses two disks (`sdb1` and `sdc1`). `sdd1` is kept out as the replacement for later:

```
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
cat /proc/mdstat
```

I waited for `[2/2] [UU]`, then saved the healthy state:

```
{ echo '$ cat /proc/mdstat'; cat /proc/mdstat; echo; echo '$ sudo mdadm --detail /dev/md0'; sudo mdadm --detail /dev/md0; } > evidence/array-healthy.txt
```

File system on the array (`/dev/md0`, not on a single partition, otherwise the mirror would be bypassed), mount, and the files for the test:

```
sudo mkfs.ext4 -L mirror /dev/md0
sudo mkdir -p /mnt/mirror
sudo mount /dev/md0 /mnt/mirror
sudo chown $USER: /mnt/mirror
echo "Lab 4 proof file — <your names> — $(date)" > /mnt/mirror/proof.txt
head -c 20M /dev/urandom > /mnt/mirror/random.bin
```

The 20 MB random file makes the test honest: if a single byte were lost, its checksum would change completely. I took the checksum **before** the failure:

```
cd /mnt/mirror && { echo '$ sha256sum proof.txt random.bin'; sha256sum proof.txt random.bin; } > ~/lab04/evidence/checksum-before.txt; cd ~/lab04
```

### 3. Fail one disk

I simulated a dead disk with `--fail` and `--remove` (I did not detach the virtual disk and reboot). Then I saved the degraded state straight away, before doing anything else:

```
sudo mdadm /dev/md0 --fail /dev/sdc1
sudo mdadm /dev/md0 --remove /dev/sdc1
{ echo '$ cat /proc/mdstat'; cat /proc/mdstat; echo; echo '$ sudo mdadm --detail /dev/md0'; sudo mdadm --detail /dev/md0; } > evidence/array-degraded.txt
```

`/proc/mdstat` showed `[2/1] [U_]` and the detail showed `State : clean, degraded`: one disk up, one missing.

### 4. Prove the data survived

I did not just claim it: I read the proof file and took the checksums again, then compared them with `diff`. The first line (the command) is skipped, so only the sums are compared:

```
cat /mnt/mirror/proof.txt
cd /mnt/mirror && { echo '$ sha256sum proof.txt random.bin'; sha256sum proof.txt random.bin; } > ~/lab04/evidence/checksum-after-failure.txt; cd ~/lab04
diff <(tail -n +2 evidence/checksum-before.txt) <(tail -n +2 evidence/checksum-after-failure.txt) && echo "checksums match"
```

The result was `checksums match`: the sums before and after the failure are identical.

### 5. Rebuild with the third disk

```
sudo mdadm /dev/md0 --add /dev/sdd1
cat /proc/mdstat
{ echo '$ cat /proc/mdstat'; cat /proc/mdstat; echo; echo '$ sudo mdadm --detail /dev/md0'; sudo mdadm --detail /dev/md0; } > evidence/array-rebuilt.txt
```

The array went back to `[2/2] [UU]`, and the active devices are now `sdb1` and `sdd1`. The 1 GB rebuild takes only seconds, so I saved the output as soon as it showed `[UU]` again.

### 6. Keep the mirror after a reboot, and save the layout after

```
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
{ echo '$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS'; lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS; } > evidence/lsblk-after.txt
```

Without the config line the array may come back as `md127` or not at all after a restart.

### 7. Windows part

Separately in the Windows guest: `Initialize-Disk -Number 1 -PartitionStyle GPT`, then `New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel LAB04`. I checked the disk number first so I did not touch disk 0, the system disk. The result is in the Windows section above.

## Three states
| State | What /proc/mdstat showed | File |
| --- | --- | --- |
| Healthy | [2/2] [UU], sdb1 and sdc1 | evidence/array-healthy.txt |
| Degraded | [2/1] [U_], sdb1 only | evidence/array-degraded.txt |
| Rebuilt | [2/2] [UU], sdd1 replaced sdc1 | evidence/array-rebuilt.txt |

Checksums before and after the failure: match (evidence/checksum-before.txt and evidence/checksum-after-failure.txt are identical).

## RAID is not a backup
Your colleague deleted the wrong file from the mirror an hour ago. Does RAID 1 help? Why?

No, RAID 1 does not help here: it copies every write to both disks at once, so the deletion was mirrored to both disks as well, and the file is gone from each of them. RAID protects against a disk failing, which I showed when the array kept working on one disk and the checksums matched, but it does not protect against deleted files, mistakes, corruption or malware, because the mirror copies those too. To get the file back I would need a separate backup, which is a copy taken at an earlier point in time and kept apart from the mirror, for example on another disk, another machine or offsite.

## What did not work the first time

**1. The new disks were created but not attached to the VM.**
Saw: after creating `lab04-d1`, `lab04-d2` and `lab04-d3` in VirtualBox, the disk list showed them under "Not Attached", and the Ubuntu VM would not have seen them yet.
It turned out to be: creating a virtual disk only makes the `.vdi` file. It still has to be chosen and attached to a controller before the guest gets a disk.
I did: selected each disk in the list, clicked Choose, and checked in Settings → Storage that all three sat on the same SATA controller as the system disk. After that, `lsblk` inside Ubuntu showed three empty 1 GB disks (`sdb`, `sdc`, `sdd`).

**2. The pasted commands looked scrambled in the terminal.**
Saw: when I pasted several commands into the SSH window, parts of the next commands appeared in the middle of the previous output (for example a fragment like `t evidence/array-healthy.txt` glued to the prompt), so the screen looked wrong.
It turned out to be: the terminal echoes pasted text while the earlier commands are still running, so the lines mix on screen. The commands themselves ran correctly.
I did: checked each evidence file with cat instead of trusting the screen. The files had the command line on top and clean output below it, and the checksums matched.

## Evidence
- evidence/lsblk-before.txt: three empty 1 GB disks before any change
- evidence/array-healthy.txt, array-degraded.txt, array-rebuilt.txt: the three states of the mirror
- evidence/checksum-before.txt, checksum-after-failure.txt: identical sums before and after the failure
- evidence/lsblk-after.txt: layout after, with md0 on sdb1 and sdd1