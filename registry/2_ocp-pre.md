#Openshift_Tools#
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.10.66/openshift-client-linux-4.10.66.tar.gz 
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.10.66/openshift-install-linux-4.10.66.tar.gz 
tar xvf openshift-client-linux-4.10.66.tar.gz -C /usr/bin/ 
tar xvf openshift-install-linux-4.10.66.tar.gz -C /usr/bin/ 

openshift-install coreos print-stream-json | grep -Eo '"https.*(kernel-|initramfs.|rootfs.)\w+(\.img)?"' | grep x86 | xargs wget -P images
rsync -av images /var/www/html/openshif4/ 

#SSH_Key#
ssh-keygen -t rsa -b 4096 -N '' -f .ssh/cp4dupi 

#Pull_Secret#
cp config/pull-secret .
