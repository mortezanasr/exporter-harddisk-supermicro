# StorCLI Prometheus Exporter

A simple yet powerful Prometheus exporter for monitoring Broadcom/LSI/Avago MegaRAID controllers using the `storcli` command-line tool. This project is designed to run as a Docker container for easy deployment and integration into modern monitoring stacks.

The exporter provides metrics on the health of physical drives, making it easy to create dashboards and alerts in Grafana for disk failures or predictive failures.

## Features

- **Direct Hardware Monitoring**: Gathers real-time status of physical disks directly from the RAID controller.
- **Prometheus Format**: Exposes metrics in a format compatible with Prometheus for easy scraping.
- **Dockerized**: Distributed as a pre-built Docker image for maximum portability and simple deployment.
- **Lightweight**: Uses a minimal footprint to avoid consuming significant server resources.

## Metrics Exposed

The primary metric exposed is `hpe_sr_disk_status`, which reports the health of each physical drive.

| Metric Value | Status | Description |
| :--- | :--- | :--- |
| `0` | OK | The drive is online and healthy (`Onln`, `UGood`). |
| `1` | FAIL | The drive is offline or has failed (`Offln`, `Failed`). |
| `2` | PREDICTIVE_FAIL | The drive is predicted to fail soon (`PFail`). |
| `3` | UNKNOWN | The drive is in another state (e.g., Rebuilding, Foreign). |

**Example Metric Output:**
```
# HELP hpe_sr_disk_status Disk physical drive status (0=OK, 1=FAIL, 2=PREDICTIVE_FAIL)
# TYPE hpe_sr_disk_status gauge
hpe_sr_disk_status{controller="0",disk="252:0",status="Onln"} 0
hpe_sr_disk_status{controller="0",disk="252:1",status="Onln"} 0
hpe_sr_disk_status{controller="0",disk="252:2",status="PFail"} 2
```

---

## How to Use

### Prerequisites

1.  A server with a Broadcom/LSI MegaRAID controller.
2.  Docker and Docker Compose installed on the host machine.
3.  The pre-built `storcli-exporter:v1.0` Docker image loaded on the host.

### Step 1: Create the `docker-compose.yml` file

Create a file named `docker-compose.yml` on your server with the following content:

```yaml
version: "3.8"

services:
  sr-exporter:
    image: storcli-exporter:v1.0
    container_name: sr-exporter
    # Host network mode is required for the container to easily access host hardware devices.
    network_mode: host
    # Privileged mode is required for storcli to communicate with the RAID controller.
    privileged: true
    restart: unless-stopped
```

### Step 2: Run the Exporter

Navigate to the directory containing your `docker-compose.yml` file and run the following command to start the exporter in the background:

```bash
docker-compose up -d
```

### Step 3: Verify the Exporter

Check if the metrics are being exposed correctly by curling the endpoint from the host machine. The exporter listens on port `9210`.

```bash
curl http://localhost:9210/metrics
```
You should see the `hpe_sr_disk_status` metrics as output.

### Step 4: Configure Prometheus

Add the following job to your `prometheus.yml` configuration file to start scraping the metrics. Replace `<your_server_ip>` with the IP address of the machine running the exporter.

```yaml
scrape_configs:
  - job_name: 'storcli_exporter'
    static_configs:
      - targets: ['<your_server_ip>:9210']
```
Restart Prometheus to apply the new configuration. You can now query, visualize, and create alerts for the `hpe_sr_disk_status` metric in Prometheus and Grafana.

## Important Notes

- **Privileged Mode**: The container **must** run in `privileged` mode with `network_mode: host`. This is necessary for the `storcli` utility inside the container to get low-level access to the RAID controller hardware on the host machine.
- **Docker Image**: This guide assumes you have already loaded the `storcli-exporter:v1.0` image onto your Docker host. If you need to build the image yourself, you will need the original `Dockerfile` and source files.
# exporter-harddisk-supermicro
