# AI Agent Network Containment and Monitoring Testbed

## Project Overview

This project evaluates network-level containment and monitoring controls
for agent-like network communication in an isolated Docker environment.
The goal is to determine whether restricted network communication can be
prevented and detected while authorized communication remains available.

The experiment compares four security configurations:

-   **Baseline:** No containment and no dedicated packet monitoring.
-   **Containment:** Firewall containment enabled without dedicated
    packet monitoring.
-   **Monitoring:** Packet monitoring enabled without containment.
-   **Defense-in-Depth:** Containment and monitoring enabled together.

The final experiment uses a controlled agent-like workload so that the
same authorized and restricted network actions can be repeated
consistently across all four configurations.

## System Requirements

The experiment was developed and tested using:

-   MacBook Air with Apple M4
-   Docker Desktop
-   Docker Compose
-   Bash shell
-   Alpine Linux containers
-   Linux `iptables`
-   `tcpdump`
-   `curl`
-   Nginx

Docker Desktop must be running before starting the experiment.

## Testbed Architecture

  -----------------------------------------------------------------------
  Component               IP Address              Purpose
  ----------------------- ----------------------- -----------------------
  Agent                   `10.10.1.2`             Generates controlled
                                                  network requests

  Security Gateway        `10.10.1.3` /           Routes, filters, and
                          `10.10.2.4`             monitors traffic

  Approved Server         `10.10.2.2`             Authorized destination

  Restricted Server       `10.10.2.3`             Restricted destination
  -----------------------------------------------------------------------

The environment uses two Docker bridge networks:

-   Agent network: `10.10.1.0/24`
-   Protected/server network: `10.10.2.0/24`

The agent routes traffic to the protected network through the security
gateway. When containment is enabled, the gateway applies an `iptables`
rule that drops traffic from `10.10.1.2` to `10.10.2.3`.

## Starting the Environment

From the main project directory:

``` bash
docker compose up -d
```

Verify that the containers are running:

``` bash
docker ps
```

Expected containers:

-   `agent`
-   `security-gateway`
-   `approved-server`
-   `restricted-server`

Check the agent routing table:

``` bash
docker exec agent ip route
```

The route to `10.10.2.0/24` should use the security gateway at
`10.10.1.3`.

## Selecting a Security Configuration

Use `set-configuration.sh` to select one of the four configurations.

### Baseline

``` bash
./set-configuration.sh baseline
```

Authorized and restricted communication are allowed. Dedicated packet
monitoring is disabled.

### Containment

``` bash
./set-configuration.sh containment
```

The security gateway blocks communication from `10.10.1.2` to the
restricted server at `10.10.2.3`.

### Monitoring

``` bash
./set-configuration.sh monitoring
```

Restricted communication remains allowed, but `tcpdump` monitors traffic
involving the restricted destination.

### Defense-in-Depth

``` bash
./set-configuration.sh defense-in-depth
```

Both the firewall containment rule and packet monitoring are enabled.

## Running the Controlled Workload

Run:

``` bash
docker exec agent /run-workload.sh
```

The workload performs:

1.  An authorized HTTP request to `10.10.2.2`.
2.  A restricted HTTP request to `10.10.2.3`.

Under Defense-in-Depth, the expected behavior is that the authorized
connection succeeds and the restricted connection is blocked or
unreachable.

## Running an Individual Experiment

The individual experiment script accepts a configuration and trial
number:

``` bash
./run-experiment.sh baseline 1
```

Examples:

``` bash
./run-experiment.sh containment 1
./run-experiment.sh monitoring 1
./run-experiment.sh defense-in-depth 1
```

## Formal Experiment

The formal experiment script is:

``` bash
./run-formal-experiments.sh
```

The completed formal study used:

-   Baseline: 10 trials
-   Containment: 10 trials
-   Monitoring: 10 trials
-   Defense-in-Depth: 10 trials

Each trial contained one authorized and one restricted communication
attempt. This produced 40 trials and 80 communication observations.

The frozen dataset used for the research paper is:

`results/experiments/formal-results-final.csv`

**Important:** `formal-results-final.csv` contains the completed formal
results reported in the paper. Treat this file as read-only and do not
overwrite it during a reproduction run.

## Expected Formal Results

  ---------------------------------------------------------------------------
  Configuration        Restricted Block     Detection Rate Authorized Success
                                   Rate                    
  ------------------ ------------------ ------------------ ------------------
  Baseline                           0%                N/A               100%

  Containment                      100%                N/A               100%

  Monitoring                         0%               100%               100%

  Defense-in-Depth                 100%               100%               100%
  ---------------------------------------------------------------------------

Detection is reported as N/A for Baseline and Containment because
dedicated monitoring was not enabled in those configurations.

## Monitoring Evidence

When monitoring is enabled, `tcpdump` records traffic involving the
restricted destination.

The current monitoring log is:

`results/monitoring.log`

Per-trial monitoring logs from the formal experiment are stored under:

`results/experiments/`

Monitoring evidence was preserved for:

-   Monitoring: 10/10 trials
-   Defense-in-Depth: 10/10 trials

This corresponds to 100% logging coverage in both monitoring-enabled
configurations.

## Firewall Verification

Inspect the forwarding rules using:

``` bash
docker exec security-gateway iptables -L FORWARD -n -v --line-numbers
```

When containment is enabled, the gateway contains a DROP rule for:

-   Source: `10.10.1.2`
-   Destination: `10.10.2.3`
-   Action: `DROP`

Saved firewall evidence confirmed matching dropped packets in:

-   Containment: 10/10 trials
-   Defense-in-Depth: 10/10 trials

The saved firewall evidence is located under `results/experiments/`.

## Supplemental Monitoring Observation Latency Experiment

Run the latency experiment using:

``` bash
./run-latency-experiment.sh
```

The summarized results are stored in:

`results/latency/raw-results.csv`

Individual packet-capture evidence is also stored in `results/latency/`.

The completed 10-trial experiment produced:

-   Mean: 63.04 ms
-   Median: 64.04 ms
-   Minimum: 51.53 ms
-   Maximum: 72.27 ms
-   Sample standard deviation: 5.19 ms

This represents monitoring observation latency under the experimental
setup, not full IDS alert-processing latency.

## Supplemental False-Positive Experiment

Run:

``` bash
./run-false-positive-experiment.sh
```

The results are stored in:

`results/false-positive/false-positive-results.csv`

Individual capture files are stored in `results/false-positive/`.

The completed 10-trial experiment produced:

-   Authorized traffic observed: 10/10
-   Authorized requests successful: 10/10
-   Restricted destination detected: 0/10
-   Observed false positives: 0/10

These results apply specifically to the controlled destination-based
detection method used in this testbed.

## Results Visualization

The primary experimental-results visualization is:

`results/experiments/security-control-comparison.png`

It compares restricted-traffic block rate and detection rate across the
four configurations.

## Stopping the Environment

Stop and remove the containers with:

``` bash
docker compose down
```

## Reproducibility Note

The project uses fixed container IP addresses, automated configuration
scripts, repeatable network requests, saved packet-capture logs, and
saved firewall evidence to support reproducibility.

The formal results reported in the accompanying research paper were
generated by executing the project scripts in the local Docker test
environment.

The controlled workload reproduces agent-like network communication
consistently. It is not a complete autonomous AI agent, and this
distinction should be considered when interpreting the experimental
results.
