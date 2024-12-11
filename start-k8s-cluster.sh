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
    vagrant ssh "${MASTER_VM}" -c "${cmd}" || error_exit "Falha ao executar o comando na VM master."
}

# Function to check if a command exists
function check_command {
    local cmd="$1"
    local name="$2"
    if ! command -v "${cmd}" >/dev/null 2>&1; then
        error_exit "${name} não está instalado. Por favor, instale ${name} antes de continuar."
    fi
}

# ========================
# Variables
# ========================

# Name of the master VM
MASTER_VM="kube-master"

# Names of the worker VMs
WORKER_VMS=("kube-node-1" "kube-node-2")

# ========================
# Script Execution
# ========================

# Verificar instalações necessárias
info "Verificando instalações necessárias..."

check_command "ansible" "Ansible"
check_command "vagrant" "Vagrant"

# Verificar VirtualBox através do comando VBoxManage
if ! command -v VBoxManage >/dev/null 2>&1; then
    error_exit "VirtualBox não está instalado. Por favor, instale o VirtualBox antes de continuar."
fi

success "Todas as dependências estão instaladas."

echo

info "Iniciando o ambiente Vagrant..."
vagrant up || error_exit "Falha ao executar 'vagrant up'."

echo

success "Ambiente Vagrant iniciado com sucesso."

echo

info "Status atual das VMs:"
echo "---------------------------------"
vagrant status
echo "---------------------------------"

echo

# Check if the master VM is running
if ! is_vm_running "${MASTER_VM}"; then
    warning "A VM master '${MASTER_VM}' não está no estado 'running'."
    info "Tentando recarregar a VM master '${MASTER_VM}'..."
    vagrant reload "${MASTER_VM}" || error_exit "Falha ao recarregar a VM master '${MASTER_VM}'."

    # Check the status again after reload
    if ! is_vm_running "${MASTER_VM}"; then
        error_exit "A VM master '${MASTER_VM}' ainda não está ativa após o recarregamento. Por favor, verifique o Vagrantfile e a configuração da VM."
    fi
    success "VM master '${MASTER_VM}' recarregada e agora está ativa."
else
    success "VM master '${MASTER_VM}' está ativa."
fi

echo

# Check if the worker VMs are running
for worker in "${WORKER_VMS[@]}"; do
    if ! is_vm_running "${worker}"; then
        warning "A VM worker '${worker}' não está no estado 'running'."
        info "Tentando recarregar a VM worker '${worker}'..."
        vagrant reload "${worker}" || error_exit "Falha ao recarregar a VM worker '${worker}'."

        # Check the status again after reload
        if ! is_vm_running "${worker}"; then
            error_exit "A VM worker '${worker}' ainda não está ativa após o recarregamento. Por favor, verifique o Vagrantfile e a configuração da VM."
        fi
        success "VM worker '${worker}' recarregada e agora está ativa."
    else
        success "VM worker '${worker}' está ativa."
    fi
done

success "Todas as VMs estão ativas."

# Collect Kubernetes cluster information using kubectl on the master VM
info "Coletando informações do cluster Kubernetes na VM '${MASTER_VM}'..."
K8S_CLUSTER_INFO=$(run_on_master "kubectl cluster-info") || error_exit "Falha ao recuperar informações do cluster Kubernetes."

echo -e "${GREEN}Informações do Cluster Kubernetes:${NC}"
echo "---------------------------------"
echo "${K8S_CLUSTER_INFO}"
echo "---------------------------------"

echo

# List the nodes in the Kubernetes cluster
info "Listando nós no cluster Kubernetes:"
run_on_master "kubectl get nodes" || error_exit "Falha ao listar os nós do Kubernetes."

echo

# List the namespaces in the Kubernetes cluster
info "Listando namespaces no cluster Kubernetes:"
run_on_master "kubectl get namespaces" || error_exit "Falha ao listar os namespaces do Kubernetes."

echo

# List the pods in all namespaces
info "Listando pods em todos os namespaces:"
run_on_master "kubectl get pods --all-namespaces" || error_exit "Falha ao listar os pods do Kubernetes."

echo

# Export the kubeconfig from the master VM to the host machine
info "Exportando kubeconfig da VM master para a máquina host..."
run_on_master "cat ~/.kube/config" >kubeconfig_master || error_exit "Falha ao exportar o kubeconfig."

echo

# Verify if kubeconfig was successfully exported
if [[ -f "kubeconfig_master" ]]; then
    success "Kubeconfig exportado com sucesso para 'kubeconfig_master'."
    echo -e "${YELLOW}Você pode usar este arquivo com kubectl adicionando a opção --kubeconfig=./kubeconfig_master${NC}"
    echo -e "${YELLOW}Exemplo:${NC}"
    echo "kubectl --kubeconfig=./kubeconfig_master get nodes"
else
    error_exit "Falha ao verificar o arquivo kubeconfig exportado."
fi

echo

success "Configuração do cluster Kubernetes concluída com sucesso."
