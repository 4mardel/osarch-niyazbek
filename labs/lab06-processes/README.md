# Lab 6 — Live processes and memory pressure
Date: 17.11.2026 · Guests: Ubuntu Server 26.04.1 LTS (4 GB RAM, lowered to 2 GB for Part 2, no swap) / Windows 11 Enterprise evaluation (4 GB RAM)

## Part 1 — One process, three tools

Process chosen: `python -m http.server 8000` — why: it can run on both guests, and I start it myself, so I know exactly which process to look at. The recommended `VBoxService` exists only on Windows (`pgrep -a VBoxService` printed nothing on Ubuntu Server, Guest Additions are not installed there). Python 3.12.10 on Windows (installed with winget), Python 3.14.4 on Ubuntu. All three screenshots were taken while the servers ran, at about the same time (19:00-19:30 Almaty).

| | Task Manager (Windows) | Process Explorer (Windows) | htop / ps (Ubuntu) |
|---|---|---|---|
| PID | 9784 | 9784 | 4489 |
| Parent (name and PID) | — (not shown) | powershell.exe (5252) | -bash (1596) |
| "Memory" as shown by default | Memory (private working set): 12,280 K | Working Set: 24,040 K | RES: 22,520 K |
| Private memory | Commit size: 14,004 K | Private Bytes: 14,004 K; WS Private: 12,252 K | no column |
| Working set / RES | Working set: 23,960 K | Working Set: 24,040 K | RES: 22,520 K (SHR: 10,796 K) |
| Virtual size | not shown | not added as a column | VIRT / vsz: 35,404 K |
| Handles / file descriptors | 156 handles | 156 handles | 4 file descriptors |
| Threads | 1 | 1 | 1 (nlwp) |

Evidence: [task-manager.png](evidence/task-manager.png), [process-explorer.png](evidence/process-explorer.png), [htop.png](evidence/htop.png).

Commands on Ubuntu: `ps -o pid,ppid,user,rss,vsz,nlwp,cmd -p 4489` gave PID 4489, PPID 1596, RSS 22520, VSZ 35404, NLWP 1. `ls /proc/4489/fd | wc -l` gave 4: `0`, `1`, `2` (all `/dev/pts/0`, the terminal) and `3` (a socket, the listening port 8000).

### Where the tools disagree

- **Handles vs file descriptors (156 vs 4).** A Windows handle is any kernel object the process has open: files, registry keys, sections, mutexes, semaphores, threads, window stations (I saw all of these in the Process Explorer lower pane). A Linux file descriptor is only a file or socket, so the two numbers are not comparable.
- **"Memory" is not the same number in each tool.** Task Manager's default Memory column is the private working set (12,280 K). Process Explorer's default is the Working Set (24,040 K), which also contains shared pages such as DLLs. htop's RES (22,520 K) includes shared libraries too (SHR 10,796 K), so it is closest to the Working Set, not to Task Manager's Memory. The small differences between Task Manager (23,960 K) and Process Explorer (24,040 K) are because the values change between screenshots.
- **Same number, different names.** Task Manager's Commit size and Process Explorer's Private Bytes are both 14,004 K. htop has no column for it.
- **VIRT is not memory in use.** htop's VIRT (35,404 K) is the whole address space, larger than what is actually in RAM (RES 22,520 K).
- **Only some tools show the parent.** Task Manager does not show it at all. Process Explorer shows it in the tree and on the Image tab (powershell.exe, 5252). htop shows it in the tree and with the PPID column (1596).
- **Different guests, different PIDs.** The Windows and Ubuntu processes are two different `http.server` processes on two machines, so their PIDs and parents are not supposed to match.

## Part 2 — Memory pressure

Guest RAM: 4096 MB lowered to **2048 MB** in VirtualBox (Settings, System) while the guest was powered off; `free -h` then showed 1.6 Gi total · swap: **none** (`Swap: 0B`, `swapon --show` printed nothing) · snapshot `before-lab6` taken first. The guest clock is UTC, so 14:43 on the guest is 19:43 in Almaty.

Steps, in order:

```
# second terminal: continuous recording every 3 seconds
cd ~ && mkdir -p lab06 && cd lab06
{ echo "=== BEFORE $(date) ==="; free -h; } > memory-pressure.txt
while true; do echo "=== $(date +%T) ==="; free -h; sleep 3; done | tee -a memory-pressure.txt

# first terminal: three runs, one after another
stress-ng --vm 2 --vm-bytes 70% --timeout 60s
stress-ng --vm 2 --vm-bytes 90% --timeout 60s
stress-ng --vm 2 --vm-bytes 120% --timeout 90s

# after stopping the recording with Ctrl+C
{ echo "=== AFTER $(date) ==="; free -h; } >> memory-pressure.txt
journalctl -k --since "30 min ago" | grep -i -E -B3 -A8 "out of memory|oom-kill" > ~/lab06/kernel-log-extract.txt
```

| | Before | During (worst) | After |
|---|---|---|---|
| Available | 1.2 Gi (14:43:43) | **34 Mi** (14:57:56, 120% run) | 1.2 Gi (15:01:24) |
| Swap used | 0 B | 0 B (no swap exists) | 0 B |

Per run (times are UTC, from [memory-pressure.txt](evidence/memory-pressure.txt)):

| Run | What stress-ng said | Worst `available` | What happened |
|---|---|---|---|
| 70% | 2 workers x 314.54 MB (629 MB of 897 MB available) | 622 Mi (14:45:35) | Nothing dramatic; memory came back when the run ended. |
| 90% | 2 workers x 416.46 MB (833 MB of 925 MB available); finished in 1 min 38 s instead of 60 s | 366 Mi (14:52:20) | The guest stalled: the recording has no entry between 14:52:20 and 14:53:40 (80 s) although it prints every 3 s. No process was killed. |
| 120% | 2 workers x 633 MB (1.24 GB of 1.03 GB available) | **34 Mi** (14:57:56) | The kernel killed a worker at 14:58:22; the recording has a 52 s gap (14:58:21 - 14:59:13). I stopped the run with Ctrl+C at 1 min 18 s. |

Note: `--vm-bytes 70%` means 70% of the *available* memory at the start, not of the 2 GB total. stress-ng reported `passed: 2, failed: 0` even in the 120% run, because it restarts workers that the kernel kills, so the kernel log is the real proof of what happened.

What happened to responsiveness: at 90% and 120% the guest became very slow. The loop that should print every 3 seconds went silent for 80 s and 52 s, so typing and refreshing would have frozen too (thrashing: with no swap, the kernel can only drop the page cache, `buff/cache` fell from 480 Mi to 59 Mi, and keeps hunting for memory).

### What the kernel did

[kernel-log-extract.txt](evidence/kernel-log-extract.txt):

```
Nov 17 14:58:22 lab01-ubuntu kernel: stress-ng-vm invoked oom-killer: gfp_mask=0x140dca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO|__GFP_COMP), order=0, oom_score_adj=1000
Nov 17 14:58:22 lab01-ubuntu kernel: Out of memory: Killed process 2389 (stress-ng-vm) total-vm:797984kB, anon-rss:730724kB, file-rss:1168kB, shmem-rss:72kB, UID:1000 pgtables:1528kB oom_score_adj=1000
Nov 17 14:59:05 lab01-ubuntu kernel: watchdog: BUG: soft lockup - CPU#2 stuck for 37s! [stress-ng-vm:2405]
```

- **Which process:** `stress-ng-vm`, PID 2389. In the kernel's process table the two workers 2388 and 2389 were the big ones (rss 167,122 and 182,991 pages), and 2389 was the larger. The only other candidate, `sleep` (rss 986 pages), is tiny.
- **Why that one:** it used the most memory (anon-rss 730,724 kB, about 715 MB), and stress-ng sets `oom_score_adj=1000` on its workers, which tells the kernel to kill them first.
- **When:** 14:58:22 UTC = 19:58:22 Almaty. This matches `memory-pressure.txt`: `available` was 40 Mi at 14:58:21, then the recording has no entries until 14:59:13, when `used` was back to 401 Mi.
- **The stall:** the soft-lockup lines at 14:59:05 and 14:59:11 (a CPU stuck for 37 s) are the kernel's own record of the guest freezing.

### Windows

```
PS C:\WINDOWS\system32> Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Resource-Exhaustion-Detector'} -MaxEvents 5 | Format-List TimeCreated, Id, Message
Get-WinEvent : No events were found that match the specified selection criteria.
```

An empty result is valid: the Windows guest never ran low on memory. Windows does not kill processes like the Linux OOM killer. When the commit charge (the memory it has promised) comes close to the limit, it warns, new allocations start to fail, and it writes event 2004 from Resource-Exhaustion-Detector, which names the processes that used the most memory. That is the event I would expect after a program like Sysinternals Testlimit pushed the commit charge up.

## What did not work the first time

1. **The recommended process did not exist on both guests.** `pgrep -a VBoxService` on Ubuntu printed nothing (Guest Additions are not installed on the Ubuntu Server guest), so I switched to `http.server` on both.
2. **Python was missing on Windows.** `python --version` showed "Python was not found; run without arguments to install from the Microsoft Store". I installed it with `winget install -e --id Python.Python.3.12 --scope user`; it still failed in the same window and only worked after I opened a new PowerShell, because the old window had the old PATH.
3. **`stress-ng --vm-bytes 70%` did not mean 70% of RAM.** It is a percentage of the available memory (897 MB), so the first run did not really push the guest. I only got real pressure from the 90% and 120% runs.
4. **Copying the files with `scp` failed twice.** The first time the long command was cut off and it tried port 22 (refused); the second time two remote files in one `scp` gave "protocol error: filename does not match request". I copied the two files with one command each. I also ran `mkdir` from inside `evidence/` and created a nested `evidence/labs/...` folder by mistake, then removed it.
5. **The 120% run reported success although a process was killed.** stress-ng said `passed: 2, failed: 0` and I stopped it by hand, so the only proof of the kill is the kernel log.

## Evidence

- [evidence/task-manager.png](evidence/task-manager.png), [evidence/process-explorer.png](evidence/process-explorer.png), [evidence/htop.png](evidence/htop.png) — the same `http.server` process in three tools
- [evidence/memory-pressure.txt](evidence/memory-pressure.txt) — `free -h` before, during (every 3 s) and after
- [evidence/kernel-log-extract.txt](evidence/kernel-log-extract.txt) — the OOM killer lines and the soft-lockup warnings