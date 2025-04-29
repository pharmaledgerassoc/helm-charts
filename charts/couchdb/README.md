# CouchDB Helm Chart

This Helm chart deploys **Apache CouchDB** with support for persistent volumes, secrets, and basic clustering options.

### 📦 Chart Structure

```yaml
charts/
└── couchdb-4.6.0.tgz        # External CouchDB chart dependency

templates/
├── job.yaml                 # Init or configuration job template
└── secret.yaml             # Kubernetes Secret template

Chart.yaml                   # Metadata and dependencies
Chart.lock                   # Dependency lock file
values.yaml                 # Default configuration
```

---

## 🧰 Installation

### 1. Add the repo

```bash
helm repo add pharmaledgerassoc https://pharmaledgerassoc.github.io/helm-charts
```

### 2. Change the values

Create a custom `couchdb-values.yaml` file with the content from the `values.yaml` file or use the `values.yaml` file from the chart.

```bash
helm show values pharmaledgerassoc/couchdb-custom --version 0.0.1 > couchdb-values.yaml
```

You must set the following values:

- uuid
	you can generate a UUID using the following command:
	
```bash
uuidgen
```

- adminPassword and readerPassword  
  These are the passwords for the admin and reader users. You can set them to any value you want but is recommended to use a strong password.
  
  **The helm chart will create a secret on kubernetes with these values and use them to connect to the database. The MAHs must use an internal management system to manage this secrets.**

### 3. Install the chart

After changing the values, you can install the chart using the following command:

```bash
helm install couchdb pharmaledgerassoc/couchdb-custom --version 0.0.1 -f ./couchdb-values.yaml
```

### Values file explanation

You can find the default values in the `values.yaml` file. The following table explains the most important values:

|Parameter|Description|Default|
|---|---|---|
|`couchdb.clusterSize`|Number of CouchDB nodes in the cluster|`1`|
|`couchdb.adminPassword`|Admin password|`REPLACE_ME_ADMIN_PASSWORD`|
|`couchdb.persistentVolume.enabled`|Enable persistent storage|`true`|
|`couchdb.persistentVolume.size`|Volume size|`10Gi`|
|`couchdb.persistentVolume.storageClass`|StorageClass name|`"gp3-encrypted"`|
|`couchdb.persistentVolumeClaimRetentionPolicy`|Retention policy when deleted/scaled|`Retain/Delete`|
|`secret.adminPassword`|Password stored in Kubernetes Secret|`REPLACE_ME_ADMIN_PASSWORD`|
|`secret.readerPassword`|Read-only user password|`REPLACE_ME_READER_PASSWORD`|
