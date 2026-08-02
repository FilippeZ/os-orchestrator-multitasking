#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/wait.h>
#include <math.h>
#include <sys/time.h>

/**
 * @file parallel_integration.c
 * @brief Multiprocessing Parallel Numerical Integration using POSIX System V Message Queues.
 * @details Computes integral of f(x) = log(x) * sqrt(x) over [1.0, 4.0] partitioned across concurrent processes.
 */

// Structure for System V Message Queue IPC
struct message {
    long type;      // Message tag identifier (1-based process index)
    double result;  // Sub-integral calculation payload
};

/**
 * @brief Mathematical target function f(x) = ln(x) * sqrt(x)
 */
double f(double x)
{
    return log(x) * sqrt(x);
}

/**
 * @brief Numerical quadrature integration using midpoint trapezoidal approximation.
 * @param a Lower limit of integration interval
 * @param b Upper limit of integration interval
 * @param n Number of sub-divisions
 * @return Approximate integral over [a, b]
 */
double integrate(double a, double b, unsigned long n)
{
    double dx = (b - a) / n;
    double S = 0.0;
    for (unsigned long i = 0; i < n; i++) {
        double xi = a + (i + 0.5) * dx;
        S += f(xi);
    }
    S *= dx;
    return S;
}

/**
 * @brief High-precision wall-clock time in seconds (microsecond accuracy)
 */
double get_wtime(void)
{
    struct timeval t;
    gettimeofday(&t, NULL);
    return (double)t.tv_sec + (double)t.tv_usec * 1.0e-6;
}

int main(int argc, char *argv[])
{
    // Step 1: Parse number of worker processes from CLI argument (default to 1)
    int num_processes = argc > 1 ? atoi(argv[1]) : 1;
    if (num_processes < 1) {
        fprintf(stderr, "Error: Invalid number of processes %d. Defaulting to 1.\n", num_processes);
        num_processes = 1;
    }

    // Step 2: Create System V Message Queue Key and Queue
    key_t key = ftok("/tmp", 'a');
    if (key == -1) {
        perror("ftok error");
        exit(EXIT_FAILURE);
    }

    int msgid = msgget(key, IPC_CREAT | 0666);
    if (msgid < 0) {
        perror("msgget error");
        exit(EXIT_FAILURE);
    }

    double start_a = 1.0;
    double end_b = 4.0;
    unsigned long total_n = 100000000UL; // 10^8 steps for high accuracy
    double step_size = (end_b - start_a) / num_processes;
    unsigned long steps_per_process = total_n / num_processes;

    // Step 3: Spawn worker child processes using fork()
    for (int i = 0; i < num_processes; i++) {
        pid_t pid = fork();
        if (pid < 0) {
            perror("fork failure");
            exit(EXIT_FAILURE);
        }

        if (pid == 0) {
            // --- CHILD PROCESS EXECUTION ---
            double child_a = start_a + i * step_size;
            double child_b = child_a + step_size;

            double sub_result = integrate(child_a, child_b, steps_per_process);

            // Package result into message structure
            struct message msg;
            msg.type = i + 1;
            msg.result = sub_result;

            // Step 4: Dispatch result message to parent via msgsnd()
            if (msgsnd(msgid, &msg, sizeof(struct message) - sizeof(long), 0) == -1) {
                perror("msgsnd error in child");
                exit(EXIT_FAILURE);
            }

            exit(EXIT_SUCCESS);
        }
    }

    // --- PARENT PROCESS EXECUTION ---
    double total = 0.0;
    double t0 = get_wtime();

    // Step 5 & 6: Receive sub-integrals from message queue using msgrcv()
    for (int i = 0; i < num_processes; i++) {
        struct message msg;
        if (msgrcv(msgid, &msg, sizeof(struct message) - sizeof(long), 0, 0) == -1) {
            perror("msgrcv error in parent");
            exit(EXIT_FAILURE);
        }
        total += msg.result;
    }

    double t1 = get_wtime();

    // Step 7: Wait for all child processes to reap zombies
    for (int i = 0; i < num_processes; i++) {
        wait(NULL);
    }

    printf("====================================================\n");
    printf("Parallel Numerical Integration Results (C + POSIX IPC)\n");
    printf("====================================================\n");
    printf("Processes Used      : %d\n", num_processes);
    printf("Integration Domain  : [%.1f, %.1f]\n", start_a, end_b);
    printf("Total Sub-divisions : %lu\n", total_n);
    printf("Calculated Integral : %.10f\n", total);
    printf("Elapsed Wall-Clock  : %.6f seconds\n", t1 - t0);
    printf("====================================================\n");

    // Step 8: Delete System V Message Queue to prevent kernel memory leaks
    if (msgctl(msgid, IPC_RMID, NULL) == -1) {
        perror("msgctl IPC_RMID error");
        exit(EXIT_FAILURE);
    }

    return 0;
}
