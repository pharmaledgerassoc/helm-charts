## Install couchdb use case

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
helm show values pharmaledgerassoc/couchdb --version 4.6.1 > couchdb-values.yaml
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

6. specify secret provider class ex:
```shell
secretProviderClass:
  enabled: true
  spec:
    provider: aws
    parameters:
      objects: |
        - objectName: ${aws_secretsmanager_secret.couchdb.arn}
          objectType: "secretsmanager"
          jmesPath:
            - path: COUCHDB_USER
              objectAlias: COUCHDB_USER
            - path: COUCHDB_PASSWORD
              objectAlias: COUCHDB_PASSWORD
            - path: COUCHDB_READER_PASSWORD
              objectAlias: COUCHDB_READER_PASSWORD
            - path: UUID
              objectAlias: UUID
            - path: COUCHDB_SECRET
              objectAlias: COUCHDB_SECRET
            - path: COUCHDB_ERLANG_COOKIE
              objectAlias: COUCHDB_ERLANG_COOKIE
    secretObjects:
      - secretName: couchdb-couchdb-secrets
        type: Opaque
        data:
          - objectName: COUCHDB_USER
            key: COUCHDB_USER
          - objectName: COUCHDB_PASSWORD
            key: COUCHDB_PASSWORD
          - objectName: COUCHDB_READER_PASSWORD
            key: COUCHDB_READER_PASSWORD
          - objectName: UUID
            key: UUID
          - objectName: COUCHDB_SECRET
            key: COUCHDB_SECRET
          - objectName: COUCHDB_ERLANG_COOKIE
            key: COUCHDB_ERLANG_COOKIE
```

7. enable service account and set the required annotations:
```shell
serviceAccount:
  create: true
  name: couchdb
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.couchdb.arn}
```

8. Set ReaderUserSetup enabled to create the readonly user after the deployment.
```shell
readerUserSetup:
  enabled: true
```


#### Step 4: Create the secret on secret provider

1. Create the secret on secret provider like this example:
```bash
{
  "COUCHDB_ADMIN": "admin",
  "COUCHDB_ADMIN_PASSWORD": "@ocm06vQvnzf?1H6",
  "COUCHDB_READER_PASSWORD": "BfZ*5ToAmJtab*lY",
  "UUID": "5fcb2906-9db6-f587-c1ce-8ca857dcc57c"
}
```

#### Step 5: Install the helm chart

1. Install the helm chart
```shell
helm install couchdb pharmaledgerassoc/couchdb --version 4.6.1 -f ./couchdb-values.yaml
```

#### Step 6: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/network_name_


