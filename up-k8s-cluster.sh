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

# Function to execute a command on the master VM and return the output
function run_on_master {
    local cmd="$1"
    vagrant ssh "${MASTER_VM}" -c "${cmd}" || error_exit "Failed to execute command on the master VM."
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

# Desired server IP and port
DESIRED_SERVER="https://192.168.1.10:6444"

# ========================
# Script Execution
# ========================

# Check necessary installations
info "Checking necessary installations..."

check_command "ansible" "Ansible"
check_command "vagrant" "Vagrant"

# Check VirtualBox using the VBoxManage command
if ! command -v VBoxManage >/dev/null 2>&1; then
    error_exit "VirtualBox is not installed. Please install VirtualBox before continuing."
fi

success "All dependencies are installed."

info "Starting the Vagrant environment..."
vagrant up || error_exit "Failed to execute 'vagrant up'."

echo

success "Vagrant environment started successfully."

echo

info "Current status of VMs:"
echo "---------------------------------"
vagrant status
echo "---------------------------------"

echo

# Check if the master VM is running
if ! is_vm_running "${MASTER_VM}"; then
    warning "The master VM '${MASTER_VM}' is not in the 'running' state."
    info "Attempting to reload the master VM '${MASTER_VM}'..."
    vagrant reload "${MASTER_VM}" || error_exit "Failed to reload the master VM '${MASTER_VM}'."

    # Check the status again after reload
    if ! is_vm_running "${MASTER_VM}"; then
        error_exit "The master VM '${MASTER_VM}' is still not active after reload. Please check the Vagrantfile and VM configuration."
    fi
    success "Master VM '${MASTER_VM}' reloaded and is now active."
else
    success "Master VM '${MASTER_VM}' is active."
fi

success "All VMs are active."

# Collect Kubernetes cluster information using kubectl on the master VM
info "Collecting Kubernetes cluster information on VM '${MASTER_VM}'..."
K8S_CLUSTER_INFO=$(run_on_master "kubectl cluster-info") || error_exit "Failed to retrieve Kubernetes cluster information."

echo -e "${GREEN}Kubernetes Cluster Information:${NC}"
echo "---------------------------------"
echo "${K8S_CLUSTER_INFO}"
echo "---------------------------------"

echo

# List the nodes in the Kubernetes cluster
info "Listing nodes in the Kubernetes cluster:"
run_on_master "kubectl get nodes" || error_exit "Failed to list Kubernetes nodes."

echo

# List the pods in all namespaces
info "Listing pods in all namespaces:"
run_on_master "kubectl get pods --all-namespaces" || error_exit "Failed to list Kubernetes pods."

echo

# Export the kubeconfig from the master VM to the host machine
info "Exporting kubeconfig from the master VM to the host machine..."
run_on_master "cat ~/.kube/config" >kubeconfig_master || error_exit "Failed to export kubeconfig."

echo

# Modify the server IP and port in the exported kubeconfig
info "Modifying server to ${DESIRED_SERVER}..."
sed -i "s|server: https://[^:]*:[0-9]*|server: ${DESIRED_SERVER}|" kubeconfig_master || error_exit "Failed to modify the kubeconfig server IP."

success "Kubeconfig server IP modified to '${DESIRED_SERVER}'."

echo

# Verify if kubeconfig was successfully exported and modified
if [[ -f "kubeconfig_master" ]]; then
    success "Kubeconfig successfully exported and modified to 'kubeconfig_master'."
    echo -e "${YELLOW}You can use this file with kubectl by adding the option --kubeconfig=./kubeconfig_master${NC}"
    echo -e "${YELLOW}Example:${NC}"
    echo "kubectl --kubeconfig=./kubeconfig_master get nodes"
else
    error_exit "Failed to verify the exported kubeconfig file."
fi

echo

success "Kubernetes cluster setup completed successfully."
