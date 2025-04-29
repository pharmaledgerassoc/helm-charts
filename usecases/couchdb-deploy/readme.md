

## install couchdb use case

Install a new couchdb running instance

Chart name: network_name (e.g. epi, csc, iot)<br/>
Plugin : None

### ApiHub deployment

#### Step 1: Clone your private config repository in the folder "private_configs"


1. After the repository was cloned, change the directory to the "private_configs" folder
```shell
cd private_configs
```
2. Create a folder which will represent your installation, like "network_name" and change the directory to that folder
```shell
cd network_name
```

#### Step 2: Install the couchdb helm charts

1. Add couchdb helm repo
```shell
helm repo add pharmaledgerassoc https://pharmaledgerassoc.github.io/helm-charts
```

2. Download the values for the helm chart network_name
```shell
helm show values pharmaledgerassoc/couchdb --version 4.6.0 > couchdb-values.yaml
```

#### Step 3: Adjust private_configs/network_name/couchdb-values.yaml

The file contains parametrization for different sets of values:
1. specify couchdbConfig.couchdb.uuid = GENERATE_SOME_RANDOM_UUID
```bash
# could run on terminal the follow comand to generate an uuid
uuidgen
```
2. specify clusterSize = 1
3. specify adminPassword = PASSWORD_YOU_WANT
4. specify persistent volumes ex:
```shell
persistentVolume:
  enabled: true
  size: 10Gi
  storageClass: "gp3-encrypted"
```

5. specify persistent volumes claim retention ex:
```shell
persistentVolumeClaimRetentionPolicy:
  enabled: true
  whenScaled: Retain
  whenDeleted: Delete
```

#### Step 4: Install the helm chart

1. Install the helm chart
```shell
helm install couchdb pharmaledgerassoc/couchdb --version 4.6.0 -f ./couchdb-values.yaml
```

#### Step 5: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/network_name_


