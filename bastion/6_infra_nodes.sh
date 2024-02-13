BASE_DOMAIN='lab.local'
CLUSTER_NAME='ocp4'
INSTALL_HOME="/opt/install"
INSTALL_DIR=$INSTALL_HOME/ocp4_install

export KUBECONFIG=$INSTALL_DIR/auth/kubeconfig

vms=("worker1" "worker2" "worker3")
for VM_NAME in "${vms[@]}"
do
	    oc label node $VM_NAME.$CLUSTER_NAME.$BASE_DOMAIN node-role.kubernetes.io/app=""
done

vms=("infra1" "infra2" "infra3")
for VM_NAME in "${vms[@]}"
do
	    oc label node $VM_NAME.$CLUSTER_NAME.$BASE_DOMAIN node-role.kubernetes.io/infra=""
done
