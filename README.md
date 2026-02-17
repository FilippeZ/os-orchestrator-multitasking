# Operating Systems Fundamentals: Scripting & Concurrency

## 📄 Overview
This project explores core Operating System concepts including shell scripting, parallel processing using the C `fork()` API, inter-process communication (IPC) via message queues, and theoretical analysis of CPU scheduling algorithms. It demonstrates how an OS automates tasks and manages resources efficiently.

## 👥 Contributors
*   **Filippos-Paraskevas Zygouris**
*(University of Patras, Dept. of Computer Engineering & Informatics)*

## 🛠️ Components

### 1. Log Parser (`src/scripts/logparser.sh`)
A Bash script designed to analyze server access logs (`access.log`).

**Features:**
*   **User Mining:** Count events per user.
*   **Filtering:** Filter by User Role (`--usrid`), HTTP Method (`-method`), or Protocol (`--servprot`).
*   **Analytics:** Count browser usage (`--browsers`).
*   **Search:** Filter entries by month (`--datum`).

**Usage:**
```bash
./src/scripts/logparser.sh access.log [OPTION] [VALUE]
```
*Example:*
```bash
./src/scripts/logparser.sh access.log --usrid admin
./src/scripts/logparser.sh access.log --datum Feb
```

### 2. Parallel Integral Calculator (C Implementation)
A C program (conceptual/source code in docs) that calculates the integral of `log(x)*sqrt(x)` by splitting the workload across multiple child processes.

**Key Technologies:**
*   `fork()` for process creation.
*   `sys/msg.h` for Message Queues (IPC).
*   `sys/time.h` for high-precision timing.

### 3. CPU Scheduling Analysis
A theoretical performance comparison of the following algorithms:
*   First-Come, First-Served (FCFS)
*   Shortest Job First (SJF)
*   Shortest Remaining Time First (SRTF)
*   Round Robin (RR)
*   Longest Remaining Time First Preemptive (LRTFP)

## 📂 Architecture
*   **Scripting:** Utilizes Unix pipes and filters (`awk`, `sed`) for efficient text processing.
*   **Concurrency:** Implements a Parent-Child model where the Parent acts as an aggregator for results computed by Child worker nodes, synchronized via OS Message Queues.
*   **Documentation:** Detailed reports and assignments available in the `docs/` directory.

## 📝 License
Academic Project - University of Patras (2022-2023)
