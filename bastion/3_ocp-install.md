mkdir ~/install
cp bastion/install-config.yaml ~/install
cd ~/install
openshift-install create manifests --dir=.
rm -f openshift/99_openshift-cluster-api_master-machines-*.yaml openshift/99_openshift-cluster-api_worker-machineset-*.yaml
sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' manifests/cluster-scheduler-02-config.yml 
openshift-install create ignition-configs --dir=.
chmod +r *.ign
rsync -av *.ign infra:/var/www/html/openshift4/ignitions/

openshift-install wait-for bootstrap-complete  --dir=. --log-level=debug
openshift-install wait-for install-complete  --dir=. --log-level=debug

oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty oc adm certificate approve
