# ⚙️ OS Orchestrator & Multitasking — Core Systems Architecture

[Operationalizing OS fundamentals through advanced concurrency, custom shell scripting, and CPU scheduling algorithms.]

[![C](https://img.shields.io/badge/Language-C-blue.svg)](https://en.wikipedia.org/wiki/C_(programming_language))
[![Bash](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![University](https://img.shields.io/badge/University-Patras-red.svg)](https://www.upatras.gr/)

---

## 📋 Overview
The **OS Orchestrator & Multitasking** suite is a comprehensive framework engineered to bridge theoretical Operating System concepts with practical, scalable implementations. Developed within the context of the University of Patras (CEID), this project acts as a vital blueprint for understanding process management, inter-process communication (IPC), and automated data mining at the system level.

## 🎯 The Problem
Modern computational workloads frequently encounter bottlenecks when executing on single-threaded paradigms:
* **Resource Inefficiency:** Sequential task execution fails to harness multi-core architectures effectively.
* **Data Overload:** Parsing extensive server logs manually or with simple tools is error-prone and unscalable.
* **Scheduling Complexity:** Deploying the wrong CPU scheduling algorithm leads to high latency and decreased throughput in critical environments.

## ✅ The Solution
This project transforms theoretical constraints into high-performance solutions through a multi-tiered technical strategy:

| Component | Technology | Target Objective |
| :--- | :--- | :--- |
| **Log Analytics** | Bash / awk / sed | Automated server access log mining |
| **Parallel Processing** | C `fork()` API | Workload distribution for heavy calculations |
| **System Sync** | OS Message Queues | Inter-Process Communication (IPC) |
| **CPU Emulation** | Algorithmic Simulation | Empirical evaluation of SRTF/RR/SJF |

---

## 🏗️ Architecture & Workflow
The system orchestrates a Parent-Child concurrency model integrated with a robust scripting pipeline:

```mermaid
graph TD
    subgraph OS Layer
        P[Parent Process (Aggregator)]
        C1[Child Process 1 (Worker)]
        C2[Child Process N (Worker)]
        MQ[(OS Message Queue)]
    end
    
    subgraph Scripting Pipeline
        LP[Log Parser bash]
        Logs[(access.log)]
    end
    
    P --> |fork| C1
    P --> |fork| C2
    C1 --> |Compute Integral| MQ
    C2 --> |Compute Integral| MQ
    MQ --> |Read Results| P
    
    Logs --> |Input| LP
    LP --> |Filter & Mine| Analytics[User/Browser Analytics]
```

1. **Scripting Layer:** Robust Bash workflows (`awk`, `sed`) slice through dense `access.log` structures to extract user roles, protocols, and browser statistics.
2. **Concurrency Layer (C):** Employs the `fork()` system call to spawn worker nodes that calculate mathematical integrals (`log(x)*sqrt(x)`) in parallel.
3. **IPC Layer:** Utilizes `sys/msg.h` message queues to securely transmit calculation chunks from child nodes back to the parent aggregator.
4. **Analysis Layer:** Evaluates theoretical CPU scheduling performance to optimize process lifecycle management.

## 📂 Project Structure
```text
os-orchestrator-multitasking/
├── README.md             # ⚙️ Master Blueprint (You are here)
├── src/
│   └── scripts/
│       └── logparser.sh  # 🔍 Robust Bash Log Analytics Engine
├── docs/                 # 📚 Detailed Theoretical & Implementation Reports
│   ├── Operating_Systems_Assignment_1.docx
│   └── Project Operating Systems.pdf
└── .gitignore            # Git exclusion rules
```

## 🚀 Quick Start

### 1. Repository Setup
```bash
git clone https://github.com/FilippeZ/os-orchestrator-multitasking.git
cd os-orchestrator-multitasking
```

### 2. Launching the Log Parser
The powerful analytics script offers flexible querying parameters:
```bash
# General Usage
./src/scripts/logparser.sh access.log [OPTION] [VALUE]

# Mine specific user activity
./src/scripts/logparser.sh access.log --usrid admin

# Filter traffic by protocol
./src/scripts/logparser.sh access.log --servprot IPv4

# Extract browser usage statistics
./src/scripts/logparser.sh access.log --browsers
```

## ⚖️ Technical Competencies Mapped

### POSIX Concurrency
* **Process Creation:** Mastery of `fork()`, `wait()`, and process state lifecycle.
* **Synchronization:** Avoidance of race conditions and zombie processes through structural parent-child synchronization.

### Inter-Process Communication
* **Message Queues (`sys/msg.h`):** Designing rigid struct-based message drops and retrievals for concurrent memory isolation.

### Advanced Data Mining
* **Stream Editors:** Utilizing `awk` associative arrays and `sed` pattern matching to bypass standard file iterative reading, drastically improving I/O bound script performance.

## 🛠️ Tech Stack
* **Core Languages:** C, Bash (Shell Scripting)
* **System APIs:** POSIX (`unistd.h`, `sys/wait.h`, `sys/msg.h`, `sys/time.h`)
* **Utilities:** GNU `awk`, `sed`, `sort`
* **Theory Mapping:** Operating System CPU Scheduling (FCFS, SJF, SRTF, RR, LRTFP)

## 📄 License
Licensed under the MIT License — see LICENSE (or implicit) for details. Academic Project, University of Patras (2022-2023).

## 👤 Author
**Filippos-Paraskevas Zygouris**
[GitHub](https://github.com/FilippeZ)
