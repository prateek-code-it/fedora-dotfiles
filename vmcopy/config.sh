#!/usr/bin/env bash
# ==============================================================================
# Script: config.sh
# Description: Global configuration settings and Virtual Machine definitions.
# ==============================================================================

# Default SSH Host (VirtualBox Host Interface)
HOST="127.0.0.1"

# Connection Defaults
DEFAULT_COMPRESSION="true"
DEFAULT_PARALLEL="1"
DEFAULT_CACHE_TIMEOUT="30"
DEFAULT_TRANSFER_METHOD="rsync"
DEFAULT_THEME="default"

# Control Socket Directory
SSH_CONTROL_DIR="${VMCOPY_CACHE_DIR}/ssh_sockets"
mkdir -p "${SSH_CONTROL_DIR}"

# Virtual Machine Inventory
# Format: "key|Display Name|Username|SSH Port|Home Directory"
VMS=(
  "kali|Kali Linux|pratique|2222|/home/pratikue"
  "debby|Debby Linux|debby|2226|/home/debby"
  "ccserver|Club Central Server|admin_master|2224|/home/admin_master"
)

# Optional Connection Profile Overrides
# Format: PROFILE_<key>="COMPRESSION|TIMEOUT|RSYNC_EXTRA_FLAGS"
PROFILE_kali="true|30|--exclude=.git"
PROFILE_debby="false|60|"
PROFILE_ccserver="true|15|--bwlimit=5000"
