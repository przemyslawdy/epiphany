cd  /epiphany/
git init -q
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1
echo "ls"
ls /epiphany/core/data
ls /epiphany/core/data/azure/infrastructure
echo "Preparing credentials"

bash core/core/src/docker/test-CI/prepare_sp.sh

az login --service-principal -u $SP_CLIENT_ID -p $SP_CLIENT_SECRET --tenant $SP_TENANT_ID

function deleteGroupIfExists {
	doesGroupExists=$(az group exists --name "$1")
	if [ "$doesGroupExists" = true ]; then
		echo "Group $1 exists. Removing...";
		az group delete --name "$1" --yes;
	else
		echo "Group $1 doesn't exist. Skipping.";
	fi
}

#deleteGroupIfExists "epi-qa-rhel-ci"
#deleteGroupIfExists "epi-qa-ubu-ci"

cd  /epiphany/core
echo
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
mkdir results
echo 'Serverspec tests for RHEL started...'
rake inventory=/epiphany/core/build/epiphany/epiphany-qa-rhel/inventory/development user=operations keypath=/tmp/keys/id_rsa spec:all
echo 'Serverspec tests for RHEL finished'
echo
echo 'Serverspec tests for Ubuntu started...'
rake inventory=/epiphany/core/build/epiphany/epiphany-qa-ubu/inventory/development user=operations keypath=/tmp/keys/id_rsa spec:all
echo 'Serverspec tests for RHEL finished'
echo '<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="rspec" tests="3" skipped="0" failures="0" errors="0" time="1.757151" timestamp="2019-03-29T12:13:18+01:00" hostname="PL-L-7004066">
<properties>
<property name="seed" value="40257"/>
</properties>
<testcase classname="spec.elasticsearch-curator.elasticsearch-curator_spec" name="Checking if Elasticsearch Curator package is installed Package &quot;elasticsearch-curator&quot; should be installed" file="./spec/elasticsearch-curator/elasticsearch-curator_spec.rb" time="1.542772"><system-out>elasticsearch-curator-5.5.4-1.x86_64
</system-out></testcase>
</testsuite>
' > results/results.xml
cat results/results.xml
cd /epiphany/core
/bin/bash
