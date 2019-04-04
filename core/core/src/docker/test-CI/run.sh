cd  /epiphany/
git init -q
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1
echo "Preparing credentials"
sed -i "s/{{ sp_subscription_id }}/$SP_SUBSCRIPTION_ID/g; s/{{ sp_client_id }}/$SP_CLIENT_ID/g; s/{{ sp_tenant_id }}/$SP_TENANT_ID/g; s/{{ sp_client_secret }}/$SP_CLIENT_SECRET/g" core/data/azure/infrastructure/epiphany-qa-template/service_principal/*
mkdir -p core/build/azure/infrastructure/epiphany-qa-rhel
mkdir -p core/build/azure/infrastructure/epiphany-qa-ubu
cp core/data/azure/infrastructure/epiphany-qa-template/service_principal/* core/build/azure/infrastructure/epiphany-qa-rhel
cp core/data/azure/infrastructure/epiphany-qa-template/service_principal/* core/build/azure/infrastructure/epiphany-qa-ubu

az login --service-principal -u $SP_CLIENT_ID -p $SP_CLIENT_SECRET --tenant $SP_TENANT_ID

function deleteGroupIfExists {
	doesGroupExists=$(az group exists --name "$1")
	echo "$doesGroupExists"
	if [ "$doesGroupExists" = true ]; then
		echo "Group $1 exists. Removing.";
		az group delete --name "$1" --yes;
	else
		echo "Group $1 doesn't exist. Skipping.";
	fi
}

deleteGroupIfExists "epi-qa-rhel-ci"
deleteGroupIfExists "epi-qa-ubu-ci"

cd  /epiphany/core
echo 'Epiphany build for RHEL started...'
bash epiphany -a -b -i -f infrastructure/epiphany-qa-rhel -t /infrastructure/epiphany-qa-template & PIDRHEL=$!
wait $PIDRHEL
echo
echo 'Epiphany build for RHEL completed'
echo
echo 'Epiphany build for Ubuntu started...'
#bash epiphany -a -b -i -f infrastructure/epiphany-qa-ubu -t /infrastructure/epiphany-qa-template & PIDUBU=$!
wait $PIDUBU
echo
echo 'Epiphany build for Ubuntu completed'
echo
az logout &2>/dev/null
cd /epiphany/core/core/test/serverspec
echo 'Serverspec tests for RHEL started...'
rake inventory=/epiphany/core/build/epiphany/epiphany-qa-rhel/inventory/development user=operations keypath=/tmp/keys/id_rsa spec:all
echo 'Serverspec tests for RHEL finished'
echo
echo 'Serverspec tests for Ubuntu started...'
rake inventory=/epiphany/core/build/epiphany/epiphany-qa-ubu/inventory/development user=operations keypath=/tmp/keys/id_rsa spec:all
echo 'Serverspec tests for RHEL finished'

cd  /epiphany/core
/bin/bash
