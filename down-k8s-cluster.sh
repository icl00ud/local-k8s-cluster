#!/bin/bash

set -e

# ========================
# Color Definitions
# ========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ========================
# Function Definitions
# ========================

# Function to display error messages and exit the script
function error_exit {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to display informational messages
function info {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to display success messages
function success {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to display warning messages
function warning {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if a VM is running using 'vagrant status <vm>'
function is_vm_running {
    local vm_name="$1"
    local status=$(vagrant status "${vm_name}" | grep -i "^${vm_name}" | awk '{print $2}' | tr '[:upper:]' '[:lower:]')
    if [[ ${status} == "running" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if a command exists
function check_command {
    local cmd="$1"
    local name="$2"
    if ! command -v "${cmd}" >/dev/null 2>&1; then
        error_exit "${name} is not installed. Please install ${name} before continuing."
    fi
}

# ========================
# Variables
# ========================

# Name of the master VM
MASTER_VM="kube-master"

# Names of the worker VMs
WORKER_VMS=("kube-node-1" "kube-node-2")

# Kubeconfig file exported
KUBECONFIG_FILE="kubeconfig_master"

# ========================
# Script Execution
# ========================

# Check necessary installations
info "Checking necessary installations..."

check_command "vagrant" "Vagrant"

# Check VirtualBox using the VBoxManage command
if ! command -v VBoxManage >/dev/null 2>&1; then
    error_exit "VirtualBox is not installed. Please install VirtualBox before continuing."
fi

success "All dependencies are installed."

echo

# Halt the Vagrant VMs
info "Stopping the Vagrant environment..."
vagrant halt || error_exit "Failed to execute 'vagrant halt'."

echo

success "Vagrant environment stopped successfully."

echo

info "Current status of VMs:"
echo "---------------------------------"
vagrant status
echo "---------------------------------"

echo

# Destroy the VMs
info "Destroying the VMs defined in the Vagrantfile..."
vagrant destroy -f || error_exit "Failed to destroy the VMs."

echo

success "VMs destroyed successfully."

echo

# Remove the kubeconfig file if it exists
if [[ -f "${KUBECONFIG_FILE}" ]]; then
    info "Removing the kubeconfig file '${KUBECONFIG_FILE}'..."
    rm -f "${KUBECONFIG_FILE}" || warning "Could not remove the kubeconfig file '${KUBECONFIG_FILE}'."
    success "Kubeconfig file '${KUBECONFIG_FILE}' removed."
else
    info "Kubeconfig file '${KUBECONFIG_FILE}' not found. No action needed."
fi

echo

success "Kubernetes cluster has been torn down successfully."

echo

success "Cluster teardown script finished successfully."
