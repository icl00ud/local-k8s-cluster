#!/bin/bash

# Script para executar 'vagrant up' e coletar informações do cluster Kubernetes

# Habilita a saída de erros e encerra o script em caso de erro
set -e

# Função para exibir mensagens de erro e encerrar o script
function error_exit {
    echo "Erro: $1" >&2
    exit 1
}

# Inicia as VMs definidas no Vagrantfile
echo "Iniciando o ambiente Vagrant..."
vagrant up || error_exit "Falha ao executar 'vagrant up'."

echo "Ambiente Vagrant iniciado com sucesso."

# Obtém a lista de VMs ativas
VMS=$(vagrant status --machine-readable | grep ",state,running" | awk -F, '{print $2}')

echo "Máquinas virtuais ativas:"
echo "$VMS"

# Define o nome da VM master (ajuste conforme necessário)
MASTER_VM="master"  # Altere para o nome da sua VM master

# Verifica se a VM master está ativa
if ! echo "$VMS" | grep -qw "$MASTER_VM"; then
    error_exit "VM master '$MASTER_VM' não está ativa. Verifique o Vagrantfile."
fi

echo "Coletando informações do cluster Kubernetes na VM '$MASTER_VM'..."

# Coleta informações do cluster Kubernetes usando kubectl na VM master
K8S_INFO=$(vagrant ssh "$MASTER_VM" -c "kubectl cluster-info" 2>/dev/null) || error_exit "Falha ao obter informações do cluster Kubernetes."

echo "Informações do Cluster Kubernetes:"
echo "---------------------------------"
echo "$K8S_INFO"
echo "---------------------------------"

# Lista os nós do cluster Kubernetes
echo "Listando nós do cluster Kubernetes:"
vagrant ssh "$MASTER_VM" -c "kubectl get nodes" || error_exit "Falha ao listar os nós do Kubernetes."

# Exporta o kubeconfig da VM master para a máquina host
echo "Exportando kubeconfig da VM master para a máquina host..."
vagrant ssh "$MASTER_VM" -c "cat ~/.kube/config" > kubeconfig_master || error_exit "Falha ao exportar kubeconfig."

# Verifica se o kubeconfig foi exportado com sucesso
if [ -f "kubeconfig_master" ]; then
    echo "Kubeconfig exportado com sucesso para 'kubeconfig_master'."
    echo "Você pode usar este arquivo com kubectl adicionando a opção --kubeconfig=./kubeconfig_master"
else
    error_exit "Falha ao verificar o arquivo kubeconfig exportado."
fi

echo "Configuração do cluster Kubernetes concluída com sucesso."
