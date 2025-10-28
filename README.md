# OpenShift UPI Installation Guide

## Overview

This guide describes how to install **OpenShift 4.17.17** using the **UPI (User Provisioned Infrastructure)** method. It assumes a lab environment with static IPs, custom services (DHCP, DNS, TFTP, HTTP), and manual provisioning of nodes. The installation is orchestrated using a series of shell scripts.

> **Note:** All values in this guide are based on the default configuration in `vars.sh`. You should modify them to suit your environment.

---

## Assumed Environment

- **Base Domain:** `example.com`
- **Cluster Name:** `ocp4`
- **OpenShift Version:** `4.17.17`
- **Architecture:** `x86_64`
- **Subnet:** `192.168.50.0/24`
- **Utility Server IP:** `172.25.250.253`
- **NTP Server IP:** `192.168.50.254`
- **Installation Directory:** `/home/lab/install/openshift-install`
- **Disk Device:** `vda`
- **SSH Key Name:** `ocp4upi`

---

## Script Overview

The installation is broken down into **7 scripts**, each handling a specific part of the setup:

### 1. `vars.sh`
Sets all environment variables used throughout the installation. 

### 2. `0_rpms.sh`
Installs required packages on the **utility server**, which acts as:

- DHCP server
- DNS server
- TFTP server (for PXE boot)
- HTTP server (to serve ignition files)
- HAPROXY server (to serve OpenShift Ingress and API LBs)

**Packages installed:**
```bash
dhcp-server bind haproxy httpd tftp syslinux openssl podman jq wget
```

### 3. `1_services.sh`
Configures and starts the necessary services:

- DNS
- TFTP
- NTP
- DHCP
- HAPROXY

### 4. `2_firewall.sh`
Opens required firewall ports for OpenShift installation and operation:

```bash
Ports: 6443, 22623, 443, 80, 8080
Zone: public
```

### 5. `3_ocp.sh`
Prepares OpenShift installation prerequisites:

- Downloads `oc` and `openshift-install` binaries
- Sets up the pull secret and SSH key
- Downloads RHCOS images 

### 6. `4_ocp-install.sh`
Generates `install-config.yaml` and starts the OpenShift installation process.

### 7. `5_chrony.sh`
Configures NTP (`chrony`) on all OpenShift nodes **post-installation**.

---

## Installation Steps

1. **Prepare vars.sh**


2. **Install Required Packages**
   ```bash
   ./0_rpms.sh
   ```

3. **Configure Services**
   ```bash
   ./1_services.sh
   ```

4. **Configure Firewall**
   ```bash
   ./2_firewall.sh
   ```

5. **Prepare OpenShift Installation**
   ```bash
   ./3_ocp.sh
   ```

6. **Start Installation**
   ```bash
   ./4_ocp-install.sh
   ```

7. **Post-Install NTP Setup**
   ```bash
   ./5_chrony.sh
   ```

---

## Notes

- Ensure all IPs and MAC addresses in `vars.sh` match your actual environment.
- The utility server must be reachable by all OpenShift nodes.
- DNS must resolve the cluster domain correctly.
- DHCP must assign static IPs based on MAC addresses.
- You may need to manually provision VMs or bare-metal nodes with the correct boot parameters.

---