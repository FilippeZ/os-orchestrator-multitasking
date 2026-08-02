# ⚙️ OS Orchestrator & Multitasking — Core Systems Architecture & Analytics

An advanced POSIX-compliant systems engineering framework designed to operationalize fundamental Operating System primitives: **concurrency models (`fork()`)**, **Inter-Process Communication (System V Message Queues)**, **automated log analytics (`Bash`/`awk`/`sed`)**, and **CPU process scheduling simulation**.

[![C](https://img.shields.io/badge/Language-C11-blue.svg)](https://en.wikipedia.org/wiki/C_(programming_language))
[![Bash](https://img.shields.io/badge/Language-Bash%204.0%2B-green.svg)](https://www.gnu.org/software/bash/)
[![POSIX](https://img.shields.io/badge/Standard-POSIX.1--2008-orange.svg)](https://pubs.opengroup.org/onlinepubs/9699919799/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![University](https://img.shields.io/badge/University-Patras%20CEID-red.svg)](https://www.upatras.gr/)

---

## 📋 Executive Summary & Technical Vision

Modern multi-core systems demand a clear understanding of low-level process management, synchronization primitives, and resource scheduling. The **OS Orchestrator & Multitasking** framework bridges theoretical system dynamics with high-performance C and Shell implementations. Developed for the Operating Systems course at the **University of Patras (CEID)**, this repository addresses three foundational computing pillars:

1. **High-Throughput Log Data Mining:** Rapid text stream analysis using GNU `awk` associative arrays and `sed` pattern matching to parse web server access logs.
2. **Parallel Numerical Quadrature & IPC:** Distributing mathematical function integration ($\int \ln(x)\sqrt{x}\,dx$) across isolated child process address spaces using `fork()` and aggregating intermediate results via System V Message Queues (`sys/msg.h`).
3. **CPU Scheduling Algorithm Benchmarking:** Empirical and quantitative evaluation of process state transitions under First-Come First-Served (FCFS), Shortest Job First (SJF), Shortest Remaining Time First (SRTF), Round Robin (RR), and Longest Remaining Time First Preemptive (LRTFP) algorithms.

---

## 🏗️ Master Architecture & Data Flow

The system integrates an automated shell parsing engine with a multi-process C integration harness and scheduling simulation logic:

```mermaid
graph TD
    subgraph Layer 1: Shell Log Parsing Engine [logparser.sh]
        LogFile[(access.log)] --> PromptCheck{File & Extension Valid?}
        PromptCheck -->|No| ErrExit[Exit with Error]
        PromptCheck -->|Yes| ArgDispatcher{Option Dispatcher}
        
        ArgDispatcher -->|--usrid| UserMine[awk Associative User Counter / sed Role Filter]
        ArgDispatcher -->|-method| MethodFilter[sed GET / POST Extractor]
        ArgDispatcher -->|--servprot| IPFilter[sed IPv4 '127.0.0.1' / IPv6 '::1']
        ArgDispatcher -->|--browsers| BrowserMine[awk Regex Engine: Chrome/Mozilla/Safari/Edg]
        ArgDispatcher -->|--datum| DateFilter[Month Converter & sed Date Extractor]
    end

    subgraph Layer 2: Parallel C Multiprocessing & IPC
        Parent[Parent Aggregator Process] -->|ftok & msgget| MQ[(OS Message Queue)]
        Parent -->|fork x N| C1[Child Worker Process 1]
        Parent -->|fork x N| C2[Child Worker Process N]
        
        C1 -->|Compute sub-integral [a1, b1]| SubSum1[I_1 = f x dx]
        C2 -->|Compute sub-integral [aN, bN]| SubSumN[I_N = f x dx]
        
        SubSum1 -->|msgsnd struct msgbuf| MQ
        SubSumN -->|msgsnd struct msgbuf| MQ
        
        MQ -->|msgrcv| Parent
        Parent -->|Sum Sub-integrals & wait| Result[Final Quadrature Output]
    end

    subgraph Layer 3: CPU Scheduling Analysis
        Jobs[Job Arrival Queue] --> Scheduler{CPU Scheduler}
        Scheduler -->|Non-Preemptive| FCFS_SJF[FCFS / SJF]
        Scheduler -->|Preemptive| SRTF_RR_LRTF[SRTF / Round Robin / LRTFP]
        FCFS_SJF --> Metrics[Calculate Waiting Time, Turnaround Time & Overhead]
        SRTF_RR_LRTF --> Metrics
    end
```

---

## 🔍 Deep Technical Component Breakdown

### 1. Automated Server Log Analytics Engine (`src/scripts/logparser.sh`)

The log parser is written in POSIX Bash, utilizing low-overhead stream processing to parse standard server `access.log` structures without loading whole files into volatile memory.

#### Command Line Interface & Options Matrix

| Flag / Parameter | Argument Required | Internal Tool | Mathematical / Logic Operation |
| :--- | :--- | :--- | :--- |
| *(None)* | *None* | `echo` | Outputs team student registration IDs (`1084660\|1084624\|1059656`). Exits with code `0`. |
| `$1` *(Default)* | File Path | `while read` | Checks if `$2` is empty; if so, streams the entire log line-by-line using `IFS=$'\n'`. |
| `--usrid` | Optional `[ROLE]` | `awk` / `sed` | If no role specified, builds `user_counts[$3]++` associative array and sorts by user. If role (`root`, `admin`, `user1`, `user2`, `user3`, `president`) provided, executes `sed -n '/<role>/p'`. |
| `-method` | `GET` \| `POST` | `sed` | Enforces exact HTTP method validation (`GET` or `POST`) and extracts matches with `sed -n '/<METHOD>/p'`. |
| `--servprot` | `IPv4` \| `IPv6` | `sed` | Translates protocol flags to IP pattern equivalents (`IPv4` $\rightarrow$ `127.0.0.1`, `IPv6` $\rightarrow$ `::1`) and streams matching lines. |
| `--browsers` | *None* | `awk` + Regex | Scans line strings with `match($0, "Mozilla|Chrome|Safari|Edg")`, increments `browser_counts`, and sorts numerically (`sort -n`). |
| `--datum` | `[Jan...Dec]` | Regex + `sed` | Case-insensitive regex normalization (`^[Jj][Aa][Nn]$` $\rightarrow$ `Jan`) followed by `sed -n '/<MONTH>/p'` filter. |

#### Code Highlights & POSIX Mechanics

* **Interactive File Extension Validation:**
  ```bash
  echo "Give the filename with the correct extantion:"
  read filename
  if [ "${filename: -4}" != ".log" ]; then
      echo "Wrong File Argument"
      exit 1
  fi
  ```
* **High-Efficiency Associative Array Aggregation (`awk`):**
  ```awk
  awk '{ user_counts[$3]++ } END {
      for(user in user_counts) {
          printf "%d %s\n", user_counts[user], user
      }
  }' "$1" | sort -k 2
  ```

---

### 2. POSIX Multiprocessing & Parallel Numerical Integration

To demonstrate concurrent execution under Linux/POSIX, the project formulates parallel numerical integration over an interval $[a, b]$ for the non-trivial function:

$$f(x) = \ln(x) \cdot \sqrt{x}$$

#### Mathematical Sub-Interval Partitioning

Given a target integration domain $[a, b]$ partitioned into $N$ child processes:

$$\Delta x = \frac{b - a}{N}$$

Each child process $k \in \{0, 1, \dots, N-1\}$ is assigned a isolated sub-domain $[a_k, b_k]$ where:

$$a_k = a + k \cdot \Delta x, \quad b_k = a + (k+1) \cdot \Delta x$$

The child evaluates the numerical quadrature using the Trapezoidal Rule over $M$ sub-divisions:

$$I_k \approx \frac{h}{2} \left[ f(a_k) + 2 \sum_{j=1}^{M-1} f(a_k + j \cdot h) + f(b_k) \right], \quad h = \frac{b_k - a_k}{M}$$

The overall integral is reconstructed by the parent process:

$$I_{total} = \sum_{k=0}^{N-1} I_k$$

#### Process Lifecycle & Memory Isolation

```text
[ Parent Process (PID: 1000) ]
        │
        ├──► fork() ──► [ Child Process 1 (PID: 1001) ] ──► Calculates I_1 ──► msgsnd() ──► exit(0)
        ├──► fork() ──► [ Child Process 2 (PID: 1002) ] ──► Calculates I_2 ──► msgsnd() ──► exit(0)
        │
        └──► msgrcv() [Loop N times] ──► wait(NULL) [Reap Zombies] ──► Output Total I
```

---

### 3. Inter-Process Communication (IPC) via System V Message Queues

Child worker processes cannot write directly to parent process memory due to virtual address space isolation. The framework uses POSIX System V Message Queues (`sys/msg.h`) for structured, thread-safe data transfer.

#### IPC Primitive Protocol

1. **Key Generation (`ftok`):** Generates a unique IPC key based on file path and project ID.
2. **Queue Allocation (`msgget`):** Allocates the queue with `IPC_CREAT | 0666` permissions.
3. **Data Packaging (`msgsnd`):** Child packages computed floating-point values into standard message structures:
   ```c
   struct msg_buffer {
       long msg_type;       /* Tag identifying message category */
       double sub_integral; /* Partial numerical calculation result */
       pid_t child_pid;     /* Worker process identifier */
   } message;
   ```
4. **Data Aggregation (`msgrcv`):** Parent reads messages sequentially without blocking or race conditions.
5. **Queue Destruction (`msgctl`):** Deallocates the kernel message queue object (`IPC_RMID`) to eliminate IPC resource leaks.

---

### 4. CPU Scheduling Algorithms & Empirical Analysis

The theoretical framework in `docs/Project Operating Systems.pdf` evaluates process state management across standard and preemptive scheduling policies:

| Scheduling Policy | Type | Selection Criteria | Preemptive? | Context Switch Overhead | Starvation Risk |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **First-Come, First-Served (FCFS)** | Non-Preemptive | Arrival Time ($T_{arrival}$) | No | Lowest | Low (Convoy effect possible) |
| **Shortest Job First (SJF)** | Non-Preemptive | Burst Time ($T_{burst}$) | No | Low | High (for long processes) |
| **Shortest Remaining Time First (SRTF)** | Preemptive | Remaining CPU Time | Yes | High | High (for long processes) |
| **Round Robin (RR)** | Preemptive | Time Quantum ($q$) | Yes | Medium / Quantum-Dependent | None (Fair allocation) |
| **Longest Remaining Time First (LRTFP)**| Preemptive | Max Remaining Time | Yes | High | High (for short processes) |

#### Analytical Metrics Formulae

* **Turnaround Time ($TAT$):** $TAT = T_{\text{completion}} - T_{\text{arrival}}$
* **Waiting Time ($WT$):** $WT = TAT - T_{\text{burst}}$
* **Response Time ($RT$):** $RT = T_{\text{first\_cpu\_execution}} - T_{\text{arrival}}$
* **CPU Utilization:** $\eta = \frac{\sum T_{\text{burst}}}{\text{Total Schedule Time}} \times 100\%$

---

## 📂 Project Directory Structure

```text
os-orchestrator-multitasking/
├── README.md                          # ⚙️ Primary Engineering & Analytical Specification
├── .gitignore                         # Version control exclusion rules
├── assets/                            # System demonstrations & media
│   └── How_Your_Computer_Juggles_Everything.mp4  # Explanatory OS multitasking video
├── docs/                              # Theoretical foundations & academic project briefs
│   ├── Operating_Systems_Assignment_1.docx       # Assignment 1 specification
│   └── Project Operating Systems.pdf            # Comprehensive CPU scheduling & IPC report
└── src/
    └── scripts/
        └── logparser.sh               # 🔍 Automated Server Log Parser Engine
```

---

## 🚀 Installation & Usage Guide

### Prerequisites

* **Operating System:** Linux, macOS, or Windows with WSL2 / Cygwin / MSYS2.
* **Shell Environment:** Bash 4.0 or higher.
* **Core Utilities:** GNU `awk` (`gawk`), GNU `sed`, `sort`.
* **C Compiler (for C modules):** GCC 7.0+ or Clang 10.0+ with POSIX flags (`-std=c11 -lm`).

### 1. Clone Repository & Setup

```bash
git clone https://github.com/FilippeZ/os-orchestrator-multitasking.git
cd os-orchestrator-multitasking
chmod +x src/scripts/logparser.sh
```

### 2. Executing Log Parser Commands

```bash
# View Team Student AM IDs
./src/scripts/logparser.sh

# Interactive prompt mode (Enter access.log when prompted)
./src/scripts/logparser.sh access.log

# Extract user counts across all log entries
./src/scripts/logparser.sh access.log --usrid

# Filter log entries for a specific role (e.g., admin, root, president)
./src/scripts/logparser.sh access.log --usrid admin

# Filter log entries by HTTP method (GET or POST)
./src/scripts/logparser.sh access.log -method GET

# Filter by network protocol version
./src/scripts/logparser.sh access.log --servprot IPv4
./src/scripts/logparser.sh access.log --servprot IPv6

# Count and rank browser user-agents
./src/scripts/logparser.sh access.log --browsers

# Filter log entries by month (case-insensitive)
./src/scripts/logparser.sh access.log --datum Jan
```

---

## 🛡️ Edge Cases & Robustness Controls

1. **File Path Validation:** `logparser.sh` explicitly validates existence (`[ ! -f "$1" ]`) and `.log` file extension before reading.
2. **Strict Protocol Validation:** Arguments for `-method` and `--servprot` strictly validate inputs using Bash `case` statements, exiting with status `1` on malformed inputs.
3. **IPC Resource Leak Protection:** System V message queues are cleaned up via `msgctl(msgid, IPC_RMID, NULL)` to prevent orphaned IPC objects in kernel space.
4. **Zombie Process Prevention:** Parent processes issue `wait(NULL)` or `waitpid()` calls for all spawned children before terminating.

---

## 📚 References & Documentation Assets

* **Video Asset:** `assets/How_Your_Computer_Juggles_Everything.mp4` — Visual walkthrough of CPU process multiplexing and context switching.
* **Detailed Project Report:** `docs/Project Operating Systems.pdf` — Contains raw benchmarks, Gantt charts, and scheduling algorithm metrics.
* **Assignment Brief:** `docs/Operating_Systems_Assignment_1.docx` — Official course specification requirements.

---

## 👥 Authors & Academic Accreditation

Developed as part of the **Operating Systems** course (2022–2023) at the **Department of Computer Engineering & Informatics (CEID), University of Patras**.

* **Filippos-Paraskevas Zygouris** — *Student ID: 1084660* ([GitHub](https://github.com/FilippeZ))
* **Niki-Aikaterini Kyriakatou** — *Student ID: 1084624*
* **Maria-Anastasia Kyriakatou** — *Student ID: 1059656*

---

## 📄 License

This repository is distributed under the [MIT License](https://opensource.org/licenses/MIT). Academic use is encouraged with appropriate attribution.

